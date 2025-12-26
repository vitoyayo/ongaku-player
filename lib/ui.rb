require 'tty-prompt'
require 'tty-box'
require 'pastel'
require_relative 'youtube_search'
require_relative 'player'
require_relative 'favorites'
require_relative 'url_cache'

class UI
  # Search and queue settings
  SEARCH_RESULTS_LIMIT = 50
  RELATED_VIDEOS_LIMIT = 30
  AUTO_QUEUE_SIZE = 20        # Suggestions added to queue automatically
  PREFETCH_LIMIT = 3          # Number of URLs to prefetch from search results

  # UI display settings
  MENU_PAGE_SIZE = 10
  LIST_PAGE_SIZE = 15
  SEARCH_PAGE_SIZE = 20

  # UI timing (seconds)
  SHORT_DELAY = 0.5
  LONG_DELAY = 1.0

  def initialize
    @prompt = TTY::Prompt.new
    @pastel = Pastel.new
    @player = Player.new
    @favorites = Favorites.new
    @queue = []
    @current_index = 0
    @autoplay = true
    @suggestions = []
    @loading_suggestions = false
    @monitor_thread = nil
    setup_signal_handlers
  end

  def start
    show_banner
    main_menu
  end

  def cleanup
    @monitor_thread&.kill
    @player.stop
  end

  private

  def setup_signal_handlers
    at_exit { cleanup }
    trap('INT') { cleanup; exit }
    trap('TERM') { cleanup; exit }
  end

  def show_banner
    system('clear')

    puts ""
    puts @pastel.cyan("  +--------------------------------------+")
    puts @pastel.cyan("  |      O N G A K U   P L A Y E R       |")
    puts @pastel.cyan("  +--------------------------------------+")

    autoplay_status = @autoplay ? @pastel.green("ON") : @pastel.red("OFF")
    puts @pastel.dim("       YouTube Music Terminal")
    puts @pastel.dim("         Autoplay: ") + autoplay_status
    puts ""
  end

  def main_menu
    loop do
      # Check if the song ended and we need to play the next one
      check_autoplay

      show_current_track if @player.playing?

      choices = [
        { name: "🔍 Search music", value: :search },
        { name: "⭐ Favorites (#{@favorites.count})", value: :favorites },
        { name: "📋 View queue (#{@queue.length} songs)", value: :queue },
        { name: "⏯️  Playback", value: :controls },
        { name: "🔄 Autoplay: #{@autoplay ? 'ON' : 'OFF'}", value: :toggle_autoplay },
        { name: "❌ Exit", value: :exit }
      ]

      choice = @prompt.select("What would you like to do?", choices, per_page: MENU_PAGE_SIZE)

      case choice
      when :search
        search_music
      when :favorites
        show_favorites
      when :queue
        show_queue
      when :controls
        show_controls
      when :toggle_autoplay
        @autoplay = !@autoplay
        status = @autoplay ? "enabled" : "disabled"
        puts @pastel.cyan("🔄 Autoplay #{status}")
        sleep SHORT_DELAY
      when :exit
        cleanup
        puts @pastel.green("\nGoodbye! 👋\n")
        exit
      end
    end
  end

  def check_autoplay
    return unless @autoplay
    return if @player.playing?
    return if @suggestions.empty?

    # Play next suggestion
    next_track = @suggestions.shift
    if next_track
      @queue << next_track
      play_track(next_track)
    end
  end

  def show_current_track
    if @player.current_track
      track = @player.current_track
      status = @player.playing? ? "▶️  Playing" : "⏸️  Paused"
      puts @pastel.green.bold("#{status}: ") + @pastel.white(track[:title])
      puts @pastel.dim("   [#{track[:duration]}]")

      if @autoplay && @queue.length > 1
        # Show next in queue
        current_idx = @queue.find_index { |t| t[:id] == track[:id] }
        if current_idx && current_idx < @queue.length - 1
          next_track = @queue[current_idx + 1]
          puts @pastel.dim("   Next: #{next_track[:title]}")
        end
      end
      puts @pastel.dim("─" * 60)
    end
  end

  def search_music
    show_banner
    puts @pastel.dim("💡 Tip: Use tags for specific searches (e.g., #ambient, #lofi, #jazz)")
    puts @pastel.dim("     Example: 'study music #chill' or just '#ambient'")
    puts @pastel.dim("     Press Enter without typing to go back\n")

    query = @prompt.ask("🔍 Search on YouTube:")

    # If nothing was typed, return to menu
    return if query.nil? || query.strip.empty?

    tags = query.scan(/#(\w+)/).flatten
    if tags.any?
      puts @pastel.cyan("\n🏷️  Searching with tags: #{tags.map { |t| "##{t}" }.join(', ')}")
    end

    puts @pastel.yellow("⏳ Searching...")

    begin
      results = YouTubeSearch.search(query, SEARCH_RESULTS_LIMIT)

      if results.empty?
        @prompt.error("No results found")
        sleep LONG_DELAY
        return
      end

      # Prefetch URLs for the first results in background (for faster playback)
      prefetch_urls(results.first(PREFETCH_LIMIT))

      choices = results.map do |result|
        {
          name: "#{result[:title]} [#{result[:duration]}]",
          value: result
        }
      end

      choices << { name: @pastel.dim("← Back"), value: :back }

      selected = @prompt.select("Select a song:", choices, per_page: SEARCH_PAGE_SIZE)

      return if selected == :back

      add_to_queue(selected)
      play_track(selected)

    rescue YouTubeSearch::SearchError => e
      @prompt.error("Error: #{e.message}")
      sleep LONG_DELAY
    end
  end

  def prefetch_urls(tracks)
    return if tracks.empty?
    urls = tracks.map { |t| t[:url] }
    UrlCache.instance.prefetch_batch(urls, Player::AUDIO_FORMAT, limit: PREFETCH_LIMIT)
    warn "[DEBUG] Prefetching #{urls.size} URLs in background" if ENV['DEBUG']
  end

  def add_to_queue(track)
    @queue << track unless @queue.any? { |t| t[:id] == track[:id] }
    puts @pastel.green("✓ Added to queue: #{track[:title]}")
    sleep SHORT_DELAY
  end

  def show_queue
    loop do
      show_banner

      if @queue.empty? && @suggestions.empty?
        puts @pastel.yellow("The queue is empty")
        @prompt.keypress("Press any key to continue...")
        return
      end

      choices = []

      # Option to go back to start
      choices << { name: @pastel.dim("← Back to menu"), value: :back }

      # Show current queue
      if @queue.any?
        puts @pastel.cyan("Playback queue (#{@queue.length}):")
        @queue.each_with_index do |track, index|
          prefix = @player.current_track && @player.current_track[:id] == track[:id] ? "▶️ " : "   "
          choices << {
            name: "#{prefix}#{track[:title]} [#{track[:duration]}]",
            value: { type: :queue, track: track }
          }
        end
      end

      # Show suggestions
      if @suggestions.any?
        choices << { name: @pastel.dim("─── Suggestions (#{@suggestions.length}) ───"), value: :none }
        @suggestions.first(10).each do |track|
          choices << {
            name: "   #{track[:title]} [#{track[:duration]}]",
            value: { type: :suggestion, track: track }
          }
        end
      end

      selected = @prompt.select("Select a song:", choices, per_page: SEARCH_PAGE_SIZE)

      case selected
      when :back
        return
      when :none
        next
      else
        if selected.is_a?(Hash)
          track = selected[:track]
          if selected[:type] == :suggestion
            @suggestions.delete(track)
            @queue << track unless @queue.any? { |t| t[:id] == track[:id] }
          end
          play_track(track)
        end
      end
    end
  end

  def show_favorites
    loop do
      show_banner

      if @favorites.empty?
        puts @pastel.yellow("You have no saved favorites")
        puts @pastel.dim("\nAdd songs to favorites from the playback menu")
        @prompt.keypress("Press any key to continue...")
        return
      end

      puts @pastel.yellow("⭐ Your Favorites (#{@favorites.count}):\n")

      choices = []
      choices << { name: @pastel.dim("← Back to menu"), value: :back }

      @favorites.list.each do |track|
        is_current = @player.current_track && @player.current_track[:id] == track[:id]
        prefix = is_current ? "▶️ " : "   "
        choices << {
          name: "#{prefix}#{track[:title]} [#{track[:duration]}]",
          value: { action: :play, track: track }
        }
      end

      choices << { name: @pastel.red("🗑️  Delete favorites..."), value: :delete_menu }

      selected = @prompt.select("Select a song:", choices, per_page: LIST_PAGE_SIZE)

      case selected
      when :back
        return
      when :delete_menu
        delete_favorites_menu
      else
        if selected.is_a?(Hash) && selected[:action] == :play
          track = selected[:track]
          add_to_queue(track)
          play_track(track)
        end
      end
    end
  end

  def delete_favorites_menu
    show_banner
    puts @pastel.red("🗑️  Delete Favorites:\n")

    choices = []
    choices << { name: @pastel.dim("← Cancel"), value: :back }

    @favorites.list.each do |track|
      choices << {
        name: "   #{track[:title]}",
        value: track
      }
    end

    selected = @prompt.select("Select to delete:", choices, per_page: LIST_PAGE_SIZE)

    return if selected == :back

    if @favorites.remove(selected[:id])
      puts @pastel.green("✓ Removed from favorites: #{selected[:title]}")
      sleep SHORT_DELAY
    end
  end

  def toggle_current_favorite
    return unless @player.current_track

    track = @player.current_track

    if @favorites.include?(track[:id])
      if @favorites.remove(track[:id])
        puts @pastel.yellow("💔 Removed from favorites: #{track[:title]}")
      end
    else
      if @favorites.add(track)
        puts @pastel.green("⭐ Added to favorites: #{track[:title]}")
      end
    end
    sleep SHORT_DELAY
  end

  def play_track(track)
    show_banner
    puts @pastel.cyan("⏳ Loading: #{track[:title]}...")
    puts @pastel.dim("   (Audio may take a few seconds to start)")

    begin
      if @player.play(track[:url], track)
        puts @pastel.green("▶️  Playing: #{track[:title]}")

        # Load suggestions in background
        load_suggestions_async(track[:url])

        sleep SHORT_DELAY
      else
        @prompt.error("Could not play the song")
      end

    rescue => e
      @prompt.error("Error: #{e.message}")
      sleep LONG_DELAY
    end
  end

  def load_suggestions_async(video_url)
    return if @loading_suggestions

    Thread.new do
      @loading_suggestions = true
      begin
        related = YouTubeSearch.get_related(video_url, RELATED_VIDEOS_LIMIT)
        # Filter those already in queue
        queue_ids = @queue.map { |t| t[:id] }
        new_suggestions = related.reject { |t| queue_ids.include?(t[:id]) }

        # Add first suggestions to queue automatically
        new_suggestions.first(AUTO_QUEUE_SIZE).each do |track|
          @queue << track unless @queue.any? { |t| t[:id] == track[:id] }
        end

        # Prefetch the next few tracks for faster playback
        prefetch_urls(new_suggestions.first(PREFETCH_LIMIT))

        # Save the rest as additional suggestions
        @suggestions = new_suggestions.drop(AUTO_QUEUE_SIZE)
      rescue YouTubeSearch::SearchError, StandardError => e
        warn "[DEBUG] Failed to load suggestions: #{e.message}" if ENV['DEBUG']
      ensure
        @loading_suggestions = false
      end
    end
  end

  def show_controls
    loop do
      show_banner
      show_current_track

      unless @player.playing?
        if @autoplay && !@queue.empty?
          play_next
          next
        end
        puts @pastel.yellow("\nNothing is playing")
        @prompt.keypress("Press any key to continue...")
        return
      end

      is_favorite = @player.current_track && @favorites.include?(@player.current_track[:id])
      fav_label = is_favorite ? "💔 Remove from favorites" : "⭐ Add to favorites"

      choices = [
        { name: "⏸️  Pause/Resume", value: :pause },
        { name: fav_label, value: :toggle_favorite },
        { name: "⏹️  Stop", value: :stop },
        { name: "⏭️  Next", value: :next },
        { name: "⏮️  Previous", value: :prev },
        { name: "🔊 Volume up", value: :vol_up },
        { name: "🔉 Volume down", value: :vol_down },
        { name: "⏩ Forward 10s", value: :forward },
        { name: "⏪ Rewind 10s", value: :backward },
        { name: @pastel.dim("← Back to menu"), value: :back }
      ]

      choice = @prompt.select("Controls:", choices, per_page: MENU_PAGE_SIZE)

      case choice
      when :pause
        @player.pause
      when :toggle_favorite
        toggle_current_favorite
      when :stop
        @player.stop
        return
      when :next
        play_next
      when :prev
        play_previous
      when :vol_up
        @player.volume_up
      when :vol_down
        @player.volume_down
      when :forward
        @player.seek_forward
      when :backward
        @player.seek_backward
      when :back
        return
      end
    end
  end

  def play_next
    # First try with suggestions if autoplay is active
    if @autoplay && !@suggestions.empty?
      next_track = @suggestions.shift
      add_to_queue(next_track)
      play_track(next_track)
      return
    end

    # Otherwise, use the normal queue
    return if @queue.empty?

    current_id = @player.current_track&.dig(:id)
    current_idx = @queue.find_index { |t| t[:id] == current_id } || -1
    next_idx = (current_idx + 1) % @queue.length
    play_track(@queue[next_idx])
  end

  def play_previous
    return if @queue.empty?

    current_id = @player.current_track&.dig(:id)
    current_idx = @queue.find_index { |t| t[:id] == current_id } || 0
    prev_idx = (current_idx - 1) % @queue.length
    play_track(@queue[prev_idx])
  end
end
