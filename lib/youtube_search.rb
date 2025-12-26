require 'json'
require 'open3'
require_relative 'demo_mode'

class YouTubeSearch
  class SearchError < StandardError; end

  def self.search(query, max_results = 10)
    # Use demo mode if there's no connection or it's enabled
    if DemoMode.enabled?
      return DemoMode.search(query, max_results)
    end

    # Process tags in the search
    tags = extract_tags(query)
    search_query = query

    # If there are tags, optimize the search
    if tags.any?
      # Remove # from tags for the search
      tag_terms = tags.map { |t| t.gsub('#', '') }.join(' ')
      # Combine with the rest of the query
      base_query = query.gsub(/#\w+/, '').strip
      search_query = "#{base_query} #{tag_terms}".strip
    end

    # Search videos on YouTube using yt-dlp
    cmd = [
      'yt-dlp',
      '--dump-json',
      '--skip-download',
      '--flat-playlist',
      '--no-warnings',
      '--quiet',
      "ytsearch#{max_results * 2}:#{search_query}"  # Search more to filter later
    ]

    stdout, stderr, status = Open3.capture3(*cmd)

    unless status.success?
      raise SearchError, "Error searching YouTube: #{stderr}"
    end

    # Parse results
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
        # Ignore invalid lines
      end
    end

    # If there are tags in the search, filter results
    if tags.any?
      results = filter_by_tags(results, tags, search_query)
    end

    # Limit to max_results
    results.take(max_results)
  end

  def self.extract_tags(query)
    # Extract all tags (#word) from the query
    query.scan(/#(\w+)/).flatten.map { |tag| "##{tag.downcase}" }
  end

  def self.filter_by_tags(results, tags, original_query)
    # Filter results that contain tags in the title or description
    tag_words = tags.map { |t| t.gsub('#', '').downcase }

    filtered = results.select do |track|
      title_lower = track[:title].downcase
      # Check if the title contains any of the tags
      tag_words.any? { |tag| title_lower.include?(tag) } ||
      # Or if the video tags match
      (track[:tags] && track[:tags].any? { |t| tag_words.include?(t.downcase) })
    end

    # If no filtered results, return the original ones
    filtered.any? ? filtered : results
  end

  def self.get_audio_url(video_url)
    # In demo mode, return the URL directly for mpv to process
    if DemoMode.enabled?
      return video_url
    end

    # Get direct audio URL using yt-dlp
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
      raise SearchError, "Error getting audio URL: #{stderr}"
    end

    stdout.strip
  end

  def self.get_related(video_url, max_results = 25)
    # Extract video ID
    video_id = video_url.match(/(?:v=|youtu\.be\/)([^&]+)/)[1] rescue nil
    return [] unless video_id

    # Use YouTube Mix to get related videos
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
        # Skip current video
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
        # Ignore invalid lines
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
