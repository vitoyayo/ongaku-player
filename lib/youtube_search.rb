require 'json'
require 'open3'
require_relative 'demo_mode'

class YouTubeSearch
  class SearchError < StandardError; end

  def self.search(query, max_results = 10)
    # Usar modo demo si no hay conexión o está habilitado
    if DemoMode.enabled?
      return DemoMode.search(query, max_results)
    end

    # Procesar tags en la búsqueda
    tags = extract_tags(query)
    search_query = query

    # Si hay tags, optimizar la búsqueda
    if tags.any?
      # Remover los # de los tags para la búsqueda
      tag_terms = tags.map { |t| t.gsub('#', '') }.join(' ')
      # Combinar con el resto de la query
      base_query = query.gsub(/#\w+/, '').strip
      search_query = "#{base_query} #{tag_terms}".strip
    end

    # Buscar videos en YouTube usando yt-dlp
    cmd = [
      'yt-dlp',
      '--dump-json',
      '--skip-download',
      '--flat-playlist',
      '--no-warnings',
      '--quiet',
      "ytsearch#{max_results * 2}:#{search_query}"  # Buscar más para filtrar después
    ]

    stdout, stderr, status = Open3.capture3(*cmd)

    unless status.success?
      raise SearchError, "Error al buscar en YouTube: #{stderr}"
    end

    # Parsear resultados
    results = []
    stdout.each_line do |line|
      next if line.strip.empty?

      begin
        data = JSON.parse(line)
        track = {
          id: data['id'],
          title: data['title'],
          url: "https://www.youtube.com/watch?v=#{data['id']}",
          duration: format_duration(data['duration']),
          tags: data['tags'] || []
        }
        results << track
      rescue JSON::ParserError
        # Ignorar líneas inválidas
      end
    end

    # Si hay tags en la búsqueda, filtrar resultados
    if tags.any?
      results = filter_by_tags(results, tags, search_query)
    end

    # Limitar a max_results
    results.take(max_results)
  end

  def self.extract_tags(query)
    # Extraer todos los tags (#palabra) de la query
    query.scan(/#(\w+)/).flatten.map { |tag| "##{tag.downcase}" }
  end

  def self.filter_by_tags(results, tags, original_query)
    # Filtrar resultados que contengan los tags en el título o descripción
    tag_words = tags.map { |t| t.gsub('#', '').downcase }

    filtered = results.select do |track|
      title_lower = track[:title].downcase
      # Verificar si el título contiene alguno de los tags
      tag_words.any? { |tag| title_lower.include?(tag) } ||
      # O si los tags del video coinciden
      (track[:tags] && track[:tags].any? { |t| tag_words.include?(t.downcase) })
    end

    # Si no hay resultados filtrados, devolver los originales
    filtered.any? ? filtered : results
  end

  def self.get_audio_url(video_url)
    # En modo demo, devolver la URL directamente para que mpv la procese
    if DemoMode.enabled?
      return video_url
    end

    # Obtener URL directa del audio usando yt-dlp
    cmd = [
      'yt-dlp',
      '--format', 'bestaudio',
      '--get-url',
      '--no-warnings',
      '--quiet',
      video_url
    ]

    stdout, stderr, status = Open3.capture3(*cmd)

    unless status.success?
      raise SearchError, "Error al obtener URL de audio: #{stderr}"
    end

    stdout.strip
  end

  def self.get_related(video_url, max_results = 25)
    # Extraer video ID
    video_id = video_url.match(/(?:v=|youtu\.be\/)([^&]+)/)[1] rescue nil
    return [] unless video_id

    # Usar YouTube Mix para obtener videos relacionados
    mix_url = "https://www.youtube.com/watch?v=#{video_id}&list=RD#{video_id}"

    cmd = [
      'yt-dlp',
      '--dump-json',
      '--skip-download',
      '--flat-playlist',
      '--no-warnings',
      '--quiet',
      mix_url
    ]

    stdout, stderr, status = Open3.capture3(*cmd)

    return [] unless status.success?

    results = []
    stdout.each_line do |line|
      next if line.strip.empty?
      break if results.length >= max_results

      begin
        data = JSON.parse(line)
        # Saltar el video actual
        next if data['id'] == video_id

        track = {
          id: data['id'],
          title: data['title'],
          url: "https://www.youtube.com/watch?v=#{data['id']}",
          duration: format_duration(data['duration']),
          tags: data['tags'] || []
        }
        results << track
      rescue JSON::ParserError
        # Ignorar líneas inválidas
      end
    end

    results
  end

  def self.format_duration(seconds)
    return "?" unless seconds

    minutes = seconds / 60
    secs = seconds % 60
    format("%d:%02d", minutes, secs)
  end
end
