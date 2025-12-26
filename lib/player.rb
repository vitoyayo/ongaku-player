require 'socket'
require 'json'
require 'timeout'
require_relative 'url_cache'

class Player
  attr_reader :current_track, :playing

  SOCKET_PATH = '/tmp/ongaku-mpv-socket'.freeze
  AUDIO_FORMAT = '251/140/bestaudio'.freeze  # Opus (251), M4A (140), or best available
  VOLUME_STEP = 5                             # Volume increment/decrement amount
  SEEK_SECONDS = 10                           # Seek forward/backward amount
  STARTUP_DELAY = 2                           # Fallback delay if dynamic wait fails
  DYNAMIC_WAIT_TIMEOUT = 10                   # Max seconds to wait for playback to start
  DYNAMIC_WAIT_INTERVAL = 0.1                 # Check interval for dynamic wait

  def initialize
    @pid = nil
    @ytdlp_pid = nil
    @current_track = nil
    @playing = false
  end

  def play(url, track_info = nil)
    # Stop any previous playback
    stop

    # Clean up previous socket if exists
    File.delete(SOCKET_PATH) if File.exist?(SOCKET_PATH)

    @current_track = track_info
    @playing = true

    # Detect if it's a live stream
    is_live = track_info && (track_info[:duration] == "LIVE" || track_info[:duration] == "?")

    if is_live
      # For live streams, use mpv directly (handles HLS better)
      play_direct(url)
    else
      # For normal videos, use pipe yt-dlp -> mpv (avoids 403 on HLS)
      play_with_pipe(url)
    end

    true
  rescue => e
    stop
    puts "Error playing: #{e.message}"
    false
  end

  def play_direct(url)
    @pid = fork do
      $stdout.reopen('/dev/null', 'w')
      $stderr.reopen('/dev/null', 'w')
      exec('mpv', '--no-video', '--no-terminal', "--input-ipc-server=#{SOCKET_PATH}", url)
    end

    Thread.new do
      Process.wait(@pid) rescue nil
      @playing = false
      @current_track = nil
      @pid = nil
    end

    sleep STARTUP_DELAY
  end

  def play_with_pipe(url)
    # Check if we have a cached direct URL (from prefetch)
    cached_url = UrlCache.instance.get(url)

    if cached_url
      # Use cached direct URL - much faster!
      warn "[DEBUG] Using cached URL for instant playback" if ENV['DEBUG']
      play_direct_url(cached_url)
    else
      # Fallback to yt-dlp pipe method
      play_with_ytdlp_pipe(url)
    end
  end

  def play_direct_url(direct_url)
    # Play directly from the resolved URL - no yt-dlp needed
    @pid = fork do
      $stdout.reopen('/dev/null', 'w')
      $stderr.reopen('/dev/null', 'w')
      exec('mpv', '--no-video', '--no-terminal', "--input-ipc-server=#{SOCKET_PATH}", direct_url)
    end

    # Monitor when playback ends
    Thread.new do
      Process.wait(@pid) rescue nil
      @playing = false
      @current_track = nil
      @pid = nil
    end

    # Wait for mpv to start (usually very fast with direct URL)
    wait_for_playback_start
  end

  def play_with_ytdlp_pipe(url)
    # Create pipe for communication between yt-dlp and mpv
    reader, writer = IO.pipe

    # Use updated yt-dlp with direct format (not HLS)
    ytdlp_cmd = File.exist?(File.expand_path('~/.local/bin/yt-dlp-new')) ?
                File.expand_path('~/.local/bin/yt-dlp-new') : 'yt-dlp'

    # yt-dlp downloads and writes to pipe with optimization flags
    @ytdlp_pid = fork do
      reader.close
      $stdout.reopen(writer)
      $stderr.reopen('/dev/null', 'w')
      exec(ytdlp_cmd,
           '-f', AUDIO_FORMAT,
           '-o', '-',
           '--no-warnings',
           '--no-progress',
           '--no-playlist',           # Don't process as playlist
           '--no-check-certificates', # Skip SSL verification (faster)
           '--socket-timeout', '5',   # Shorter timeout
           url)
    end
    writer.close

    # mpv reads from pipe
    @pid = fork do
      $stdin.reopen(reader)
      $stdout.reopen('/dev/null', 'w')
      $stderr.reopen('/dev/null', 'w')
      exec('mpv', '--no-video', '--no-terminal', "--input-ipc-server=#{SOCKET_PATH}", '-')
    end
    reader.close

    # Monitor when playback ends
    Thread.new do
      Process.wait(@pid) rescue nil
      Process.kill('TERM', @ytdlp_pid) rescue nil
      Process.wait(@ytdlp_pid) rescue nil
      @playing = false
      @current_track = nil
      @pid = nil
      @ytdlp_pid = nil
    end

    # Dynamic wait for playback to start
    wait_for_playback_start
  end

  # Wait dynamically for playback to start instead of fixed sleep
  def wait_for_playback_start
    start_time = Time.now

    # Wait for socket to appear (indicates mpv is ready)
    while (Time.now - start_time) < DYNAMIC_WAIT_TIMEOUT
      if File.exist?(SOCKET_PATH)
        # Socket exists, check if we can get duration or time-pos
        if get_property('duration') || get_property('time-pos')
          warn "[DEBUG] Playback started in #{(Time.now - start_time).round(2)}s" if ENV['DEBUG']
          return true
        end
      end
      sleep DYNAMIC_WAIT_INTERVAL
    end

    # Fallback: if we couldn't detect start, just wait a bit more
    warn "[DEBUG] Playback start detection timed out, using fallback" if ENV['DEBUG']
    sleep STARTUP_DELAY
    true
  end

  def stop
    # Kill yt-dlp first
    if @ytdlp_pid
      begin
        Process.kill('TERM', @ytdlp_pid)
        Process.wait(@ytdlp_pid)
      rescue Errno::ESRCH, Errno::ECHILD
      end
      @ytdlp_pid = nil
    end

    # Kill mpv
    if @pid
      begin
        Process.kill('TERM', @pid)
        Process.wait(@pid)
      rescue Errno::ESRCH, Errno::ECHILD
      end
      @pid = nil
    end

    @playing = false
    @current_track = nil

    # Clean up socket
    File.delete(SOCKET_PATH) if File.exist?(SOCKET_PATH)
  end

  def pause
    send_command(['cycle', 'pause']) if playing?
  end

  def playing?
    @playing && @pid && process_alive?(@pid)
  end

  def send_command(cmd_array)
    return false unless @pid
    return false unless File.exist?(SOCKET_PATH)

    begin
      socket = UNIXSocket.new(SOCKET_PATH)
      command = { 'command' => cmd_array }.to_json + "\n"
      socket.write(command)
      socket.close
      true
    rescue Errno::ECONNREFUSED, Errno::ENOENT
      false
    end
  end

  def volume_up
    send_command(['add', 'volume', VOLUME_STEP.to_s])
  end

  def volume_down
    send_command(['add', 'volume', (-VOLUME_STEP).to_s])
  end

  def seek_forward
    send_command(['seek', SEEK_SECONDS.to_s])
  end

  def seek_backward
    send_command(['seek', (-SEEK_SECONDS).to_s])
  end

  def get_time_pos
    get_property('time-pos')
  end

  def get_duration
    get_property('duration')
  end

  def get_property(name)
    return nil unless @pid
    return nil unless File.exist?(SOCKET_PATH)

    begin
      socket = UNIXSocket.new(SOCKET_PATH)
      command = { 'command' => ['get_property', name] }.to_json + "\n"
      socket.write(command)
      response = socket.gets
      socket.close

      if response
        data = JSON.parse(response)
        return data['data'] if data['error'] == 'success'
      end
    rescue Errno::ECONNREFUSED, Errno::ENOENT, JSON::ParserError, IOError => e
      warn "[DEBUG] get_property(#{name}) failed: #{e.message}" if ENV['DEBUG']
    end
    nil
  end

  private

  def process_alive?(pid)
    Process.kill(0, pid)
    true
  rescue Errno::ESRCH, Errno::EPERM
    false
  end
end
