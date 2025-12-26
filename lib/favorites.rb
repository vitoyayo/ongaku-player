require 'json'
require 'fileutils'

class Favorites
  CONFIG_DIR = File.expand_path('~/.config/ongaku')
  FAVORITES_FILE = File.join(CONFIG_DIR, 'favorites.json')

  def initialize
    ensure_config_dir
    @favorites = load_favorites
  end

  def add(track)
    return false if include?(track[:id])

    @favorites << {
      id: track[:id],
      title: track[:title],
      url: track[:url],
      duration: track[:duration],
      added_at: Time.now.to_i
    }
    save_favorites
    true
  end

  def remove(track_id)
    initial_count = @favorites.length
    @favorites.reject! { |t| t[:id] == track_id }

    if @favorites.length < initial_count
      save_favorites
      true
    else
      false
    end
  end

  def list
    @favorites.sort_by { |t| -t[:added_at].to_i }
  end

  def include?(track_id)
    @favorites.any? { |t| t[:id] == track_id }
  end

  def find(track_id)
    @favorites.find { |t| t[:id] == track_id }
  end

  def count
    @favorites.length
  end

  def empty?
    @favorites.empty?
  end

  def search(query)
    query_lower = query.downcase
    @favorites.select { |t| t[:title].downcase.include?(query_lower) }
  end

  private

  def ensure_config_dir
    FileUtils.mkdir_p(CONFIG_DIR) unless Dir.exist?(CONFIG_DIR)
  end

  def load_favorites
    return [] unless File.exist?(FAVORITES_FILE)

    data = JSON.parse(File.read(FAVORITES_FILE), symbolize_names: true)
    data.is_a?(Array) ? data : []
  rescue JSON::ParserError
    []
  end

  def save_favorites
    File.write(FAVORITES_FILE, JSON.pretty_generate(@favorites))
  end
end
