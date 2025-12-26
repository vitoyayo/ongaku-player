require 'socket'
require 'json'
require 'timeout'

class Player
  attr_reader :current_track, :playing

  SOCKET_PATH = '/tmp/ongaku-mpv-socket'

  def initialize
    @pid = nil
    @ytdlp_pid = nil
    @current_track = nil
    @playing = false
  end

  def play(url, track_info = nil)
    # Detener cualquier reproducción anterior
    stop

    # Limpiar socket anterior si existe
    File.delete(SOCKET_PATH) if File.exist?(SOCKET_PATH)

    @current_track = track_info
    @playing = true

    # Detectar si es un live stream
    is_live = track_info && (track_info[:duration] == "LIVE" || track_info[:duration] == "?")

    if is_live
      # Para live streams, usar mpv directamente (maneja mejor HLS)
      play_direct(url)
    else
      # Para videos normales, usar pipe yt-dlp -> mpv (evita 403 en HLS)
      play_with_pipe(url)
    end

    true
  rescue => e
    stop
    puts "Error al reproducir: #{e.message}"
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

    sleep 2
  end

  def play_with_pipe(url)
    # Crear pipe para comunicación entre yt-dlp y mpv
    reader, writer = IO.pipe

    # Usar yt-dlp actualizado con formato directo (no HLS)
    ytdlp_cmd = File.exist?(File.expand_path('~/.local/bin/yt-dlp-new')) ?
                File.expand_path('~/.local/bin/yt-dlp-new') : 'yt-dlp'

    # yt-dlp descarga y escribe al pipe
    # Formato 251 (opus webm) o 140 (m4a) - formatos directos sin HLS
    @ytdlp_pid = fork do
      reader.close
      $stdout.reopen(writer)
      $stderr.reopen('/dev/null', 'w')
      exec(ytdlp_cmd, '-f', '251/140/bestaudio', '-o', '-', '--no-warnings', '--no-progress', url)
    end
    writer.close

    # mpv lee del pipe
    @pid = fork do
      $stdin.reopen(reader)
      $stdout.reopen('/dev/null', 'w')
      $stderr.reopen('/dev/null', 'w')
      exec('mpv', '--no-video', '--no-terminal', "--input-ipc-server=#{SOCKET_PATH}", '-')
    end
    reader.close

    # Monitorear cuando termina la reproducción
    Thread.new do
      Process.wait(@pid) rescue nil
      Process.kill('TERM', @ytdlp_pid) rescue nil
      Process.wait(@ytdlp_pid) rescue nil
      @playing = false
      @current_track = nil
      @pid = nil
      @ytdlp_pid = nil
    end

    # Esperar a que yt-dlp comience a enviar datos
    sleep 2
  end

  def stop
    # Matar yt-dlp primero
    if @ytdlp_pid
      begin
        Process.kill('TERM', @ytdlp_pid)
        Process.wait(@ytdlp_pid)
      rescue Errno::ESRCH, Errno::ECHILD
      end
      @ytdlp_pid = nil
    end

    # Matar mpv
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

    # Limpiar socket
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
    send_command(['add', 'volume', '5'])
  end

  def volume_down
    send_command(['add', 'volume', '-5'])
  end

  def seek_forward
    send_command(['seek', '10'])
  end

  def seek_backward
    send_command(['seek', '-10'])
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
    rescue
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
