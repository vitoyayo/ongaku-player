require 'tty-prompt'
require 'tty-box'
require 'pastel'
require_relative 'youtube_search'
require_relative 'player'
require_relative 'favorites'

class UI
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
      # Verificar si terminó la canción y hay que reproducir la siguiente
      check_autoplay

      show_current_track if @player.playing?

      choices = [
        { name: "🔍 Buscar música", value: :search },
        { name: "⭐ Favoritos (#{@favorites.count})", value: :favorites },
        { name: "📋 Ver cola (#{@queue.length} canciones)", value: :queue },
        { name: "⏯️  Reproducción", value: :controls },
        { name: "🔄 Autoplay: #{@autoplay ? 'ON' : 'OFF'}", value: :toggle_autoplay },
        { name: "❌ Salir", value: :exit }
      ]

      choice = @prompt.select("¿Qué deseas hacer?", choices, per_page: 10)

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
        status = @autoplay ? "activado" : "desactivado"
        puts @pastel.cyan("🔄 Autoplay #{status}")
        sleep 0.5
      when :exit
        cleanup
        puts @pastel.green("\n¡Adiós! 👋\n")
        exit
      end
    end
  end

  def check_autoplay
    return unless @autoplay
    return if @player.playing?
    return if @suggestions.empty?

    # Reproducir siguiente sugerencia
    next_track = @suggestions.shift
    if next_track
      @queue << next_track
      play_track(next_track)
    end
  end

  def show_current_track
    if @player.current_track
      track = @player.current_track
      status = @player.playing? ? "▶️  Reproduciendo" : "⏸️  Pausado"
      puts @pastel.green.bold("#{status}: ") + @pastel.white(track[:title])
      puts @pastel.dim("   [#{track[:duration]}]")

      if @autoplay && @queue.length > 1
        # Mostrar siguiente en cola
        current_idx = @queue.find_index { |t| t[:id] == track[:id] }
        if current_idx && current_idx < @queue.length - 1
          next_track = @queue[current_idx + 1]
          puts @pastel.dim("   Siguiente: #{next_track[:title]}")
        end
      end
      puts @pastel.dim("─" * 60)
    end
  end

  def search_music
    show_banner
    puts @pastel.dim("💡 Tip: Usa tags para búsquedas específicas (ej: #ambient, #lofi, #jazz)")
    puts @pastel.dim("     Ejemplo: 'study music #chill' o solo '#ambient'")
    puts @pastel.dim("     Presiona Enter sin escribir nada para volver\n")

    query = @prompt.ask("🔍 Buscar en YouTube:")

    # Si no escribió nada, volver al menú
    return if query.nil? || query.strip.empty?

    tags = query.scan(/#(\w+)/).flatten
    if tags.any?
      puts @pastel.cyan("\n🏷️  Buscando con tags: #{tags.map { |t| "##{t}" }.join(', ')}")
    end

    puts @pastel.yellow("⏳ Buscando...")

    begin
      results = YouTubeSearch.search(query, 50)

      if results.empty?
        @prompt.error("No se encontraron resultados")
        sleep 1
        return
      end

      choices = results.map do |result|
        {
          name: "#{result[:title]} [#{result[:duration]}]",
          value: result
        }
      end

      choices << { name: @pastel.dim("← Volver"), value: :back }

      selected = @prompt.select("Selecciona una canción:", choices, per_page: 20)

      return if selected == :back

      add_to_queue(selected)
      play_track(selected)

    rescue YouTubeSearch::SearchError => e
      @prompt.error("Error: #{e.message}")
      sleep 1
    end
  end

  def add_to_queue(track)
    @queue << track unless @queue.any? { |t| t[:id] == track[:id] }
    puts @pastel.green("✓ Agregado a la cola: #{track[:title]}")
    sleep 0.5
  end

  def show_queue
    loop do
      show_banner

      if @queue.empty? && @suggestions.empty?
        puts @pastel.yellow("La cola está vacía")
        @prompt.keypress("Presiona cualquier tecla para continuar...")
        return
      end

      choices = []

      # Opción de volver al inicio
      choices << { name: @pastel.dim("← Volver al menú"), value: :back }

      # Mostrar cola actual
      if @queue.any?
        puts @pastel.cyan("Cola de reproducción (#{@queue.length}):")
        @queue.each_with_index do |track, index|
          prefix = @player.current_track && @player.current_track[:id] == track[:id] ? "▶️ " : "   "
          choices << {
            name: "#{prefix}#{track[:title]} [#{track[:duration]}]",
            value: { type: :queue, track: track }
          }
        end
      end

      # Mostrar sugerencias
      if @suggestions.any?
        choices << { name: @pastel.dim("─── Sugerencias (#{@suggestions.length}) ───"), value: :none }
        @suggestions.first(10).each do |track|
          choices << {
            name: "   #{track[:title]} [#{track[:duration]}]",
            value: { type: :suggestion, track: track }
          }
        end
      end

      selected = @prompt.select("Selecciona una canción:", choices, per_page: 20)

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
        puts @pastel.yellow("No tienes favoritos guardados")
        puts @pastel.dim("\nAgrega canciones a favoritos desde el menú de reproducción")
        @prompt.keypress("Presiona cualquier tecla para continuar...")
        return
      end

      puts @pastel.yellow("⭐ Tus Favoritos (#{@favorites.count}):\n")

      choices = []
      choices << { name: @pastel.dim("← Volver al menú"), value: :back }

      @favorites.list.each do |track|
        is_current = @player.current_track && @player.current_track[:id] == track[:id]
        prefix = is_current ? "▶️ " : "   "
        choices << {
          name: "#{prefix}#{track[:title]} [#{track[:duration]}]",
          value: { action: :play, track: track }
        }
      end

      choices << { name: @pastel.red("🗑️  Eliminar favoritos..."), value: :delete_menu }

      selected = @prompt.select("Selecciona una canción:", choices, per_page: 15)

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
    puts @pastel.red("🗑️  Eliminar Favoritos:\n")

    choices = []
    choices << { name: @pastel.dim("← Cancelar"), value: :back }

    @favorites.list.each do |track|
      choices << {
        name: "   #{track[:title]}",
        value: track
      }
    end

    selected = @prompt.select("Selecciona para eliminar:", choices, per_page: 15)

    return if selected == :back

    if @favorites.remove(selected[:id])
      puts @pastel.green("✓ Eliminado de favoritos: #{selected[:title]}")
      sleep 0.5
    end
  end

  def toggle_current_favorite
    return unless @player.current_track

    track = @player.current_track

    if @favorites.include?(track[:id])
      if @favorites.remove(track[:id])
        puts @pastel.yellow("💔 Eliminado de favoritos: #{track[:title]}")
      end
    else
      if @favorites.add(track)
        puts @pastel.green("⭐ Agregado a favoritos: #{track[:title]}")
      end
    end
    sleep 0.5
  end

  def play_track(track)
    show_banner
    puts @pastel.cyan("⏳ Cargando: #{track[:title]}...")
    puts @pastel.dim("   (El audio puede tardar unos segundos en comenzar)")

    begin
      if @player.play(track[:url], track)
        puts @pastel.green("▶️  Reproduciendo: #{track[:title]}")

        # Cargar sugerencias en background
        load_suggestions_async(track[:url])

        sleep 0.5
      else
        @prompt.error("No se pudo reproducir la canción")
      end

    rescue => e
      @prompt.error("Error: #{e.message}")
      sleep 1
    end
  end

  def load_suggestions_async(video_url)
    return if @loading_suggestions

    Thread.new do
      @loading_suggestions = true
      begin
        related = YouTubeSearch.get_related(video_url, 30)
        # Filtrar los que ya están en cola
        queue_ids = @queue.map { |t| t[:id] }
        new_suggestions = related.reject { |t| queue_ids.include?(t[:id]) }

        # Agregar las primeras 20 sugerencias a la cola automáticamente
        new_suggestions.first(20).each do |track|
          @queue << track unless @queue.any? { |t| t[:id] == track[:id] }
        end

        # Guardar el resto como sugerencias adicionales
        @suggestions = new_suggestions.drop(20)
      rescue => e
        # Ignorar errores de carga de sugerencias
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
        puts @pastel.yellow("\nNo hay nada reproduciéndose")
        @prompt.keypress("Presiona cualquier tecla para continuar...")
        return
      end

      is_favorite = @player.current_track && @favorites.include?(@player.current_track[:id])
      fav_label = is_favorite ? "💔 Quitar de favoritos" : "⭐ Agregar a favoritos"

      choices = [
        { name: "⏸️  Pausar/Reanudar", value: :pause },
        { name: fav_label, value: :toggle_favorite },
        { name: "⏹️  Detener", value: :stop },
        { name: "⏭️  Siguiente", value: :next },
        { name: "⏮️  Anterior", value: :prev },
        { name: "🔊 Subir volumen", value: :vol_up },
        { name: "🔉 Bajar volumen", value: :vol_down },
        { name: "⏩ Adelantar 10s", value: :forward },
        { name: "⏪ Retroceder 10s", value: :backward },
        { name: @pastel.dim("← Volver al menú"), value: :back }
      ]

      choice = @prompt.select("Controles:", choices, per_page: 10)

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
    # Primero intentar con sugerencias si autoplay está activo
    if @autoplay && !@suggestions.empty?
      next_track = @suggestions.shift
      add_to_queue(next_track)
      play_track(next_track)
      return
    end

    # Si no, usar la cola normal
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
