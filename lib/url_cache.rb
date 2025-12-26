require 'open3'
require 'singleton'

class UrlCache
  include Singleton

  CACHE_TTL = 300  # 5 minutes (URLs expire after ~6 hours, but we use shorter TTL for safety)
  RESOLVE_TIMEOUT = 10  # Max seconds to wait for URL resolution

  def initialize
    @cache = {}
    @pending = {}
    @mutex = Mutex.new
  end

  # Get cached direct URL for a video, or nil if not cached
  def get(video_url)
    @mutex.synchronize do
      entry = @cache[video_url]
      return nil unless entry
      return nil if Time.now > entry[:expires]
      entry[:direct_url]
    end
  end

  # Check if URL is being prefetched
  def pending?(video_url)
    @mutex.synchronize { @pending.key?(video_url) }
  end

  # Start prefetching a URL in background
  def prefetch(video_url, audio_format = '251/140/bestaudio')
    return if get(video_url)  # Already cached
    return if pending?(video_url)  # Already fetching

    @mutex.synchronize { @pending[video_url] = true }

    Thread.new do
      begin
        direct_url = resolve_url(video_url, audio_format)
        if direct_url && !direct_url.empty?
          @mutex.synchronize do
            @cache[video_url] = {
              direct_url: direct_url,
              expires: Time.now + CACHE_TTL
            }
          end
          warn "[DEBUG] Prefetched URL for #{video_url[0..50]}..." if ENV['DEBUG']
        end
      rescue => e
        warn "[DEBUG] Prefetch failed: #{e.message}" if ENV['DEBUG']
      ensure
        @mutex.synchronize { @pending.delete(video_url) }
      end
    end
  end

  # Prefetch multiple URLs (for search results)
  def prefetch_batch(video_urls, audio_format = '251/140/bestaudio', limit: 3)
    video_urls.first(limit).each do |url|
      prefetch(url, audio_format)
    end
  end

  # Wait for a pending prefetch to complete (with timeout)
  def wait_for(video_url, timeout: 5)
    return get(video_url) if get(video_url)
    return nil unless pending?(video_url)

    start_time = Time.now
    while pending?(video_url) && (Time.now - start_time) < timeout
      sleep 0.1
    end
    get(video_url)
  end

  # Clear expired entries
  def cleanup
    @mutex.synchronize do
      now = Time.now
      @cache.delete_if { |_, entry| now > entry[:expires] }
    end
  end

  # Clear all cache
  def clear
    @mutex.synchronize do
      @cache.clear
      @pending.clear
    end
  end

  # Stats for debugging
  def stats
    @mutex.synchronize do
      {
        cached: @cache.size,
        pending: @pending.size
      }
    end
  end

  private

  def resolve_url(video_url, audio_format)
    ytdlp_cmd = File.exist?(File.expand_path('~/.local/bin/yt-dlp-new')) ?
                File.expand_path('~/.local/bin/yt-dlp-new') : 'yt-dlp'

    # Use -g to get direct URL without downloading
    # Add optimization flags
    cmd = [
      ytdlp_cmd,
      '-f', audio_format,
      '-g',                      # Get URL only
      '--no-warnings',
      '--no-playlist',           # Don't process as playlist
      '--no-check-certificates', # Skip SSL verification (faster)
      '--socket-timeout', '5',   # Shorter timeout
      video_url
    ]

    stdout, stderr, status = Open3.capture3(*cmd)

    if status.success? && !stdout.strip.empty?
      stdout.strip.split("\n").first  # First URL (audio)
    else
      warn "[DEBUG] yt-dlp resolve failed: #{stderr}" if ENV['DEBUG']
      nil
    end
  end
end
