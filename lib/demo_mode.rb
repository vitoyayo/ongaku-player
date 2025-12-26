# Demo mode for when there is no connection to YouTube
class DemoMode
  DEMO_TRACKS = [
    {
      id: "demo1",
      title: "Lofi Hip Hop Radio - Beats to Relax/Study",
      url: "https://www.youtube.com/watch?v=jfKfPfyJRdk",
      duration: "LIVE",
      tags: ["lofi", "hiphop", "chill", "study", "relax"]
    },
    {
      id: "demo2",
      title: "Chill Lofi Study Beats",
      url: "https://www.youtube.com/watch?v=5qap5aO4i9A",
      duration: "1:23:45",
      tags: ["lofi", "chill", "study", "beats"]
    },
    {
      id: "demo3",
      title: "Jazz Hop Cafe - Smooth Jazz & Lofi Hip Hop",
      url: "https://www.youtube.com/watch?v=Dx5qFachd3A",
      duration: "2:15:30",
      tags: ["jazz", "lofi", "hiphop", "smooth"]
    },
    {
      id: "demo4",
      title: "Ambient Study Music - Deep Focus",
      url: "https://www.youtube.com/watch?v=lTRiuFIWV54",
      duration: "3:00:00",
      tags: ["ambient", "study", "focus", "concentration"]
    },
    {
      id: "demo5",
      title: "Lo-fi Beats for Coding",
      url: "https://www.youtube.com/watch?v=bmVKaAV_7-A",
      duration: "1:45:12",
      tags: ["lofi", "coding", "programming", "beats"]
    },
    {
      id: "demo6",
      title: "Chillhop Radio - jazzy & lofi hip hop beats",
      url: "https://www.youtube.com/watch?v=5yx6BWlEVcY",
      duration: "LIVE",
      tags: ["chillhop", "jazz", "lofi", "hiphop", "chill"]
    },
    {
      id: "demo7",
      title: "Synthwave Radio - Beats to Chill/Game To",
      url: "https://www.youtube.com/watch?v=4xDzrJKXOOY",
      duration: "1:30:22",
      tags: ["synthwave", "chill", "gaming", "electronic"]
    },
    {
      id: "demo8",
      title: "Japanese Lofi Hip Hop Mix",
      url: "https://www.youtube.com/watch?v=FjHGZj2IjBk",
      duration: "2:05:18",
      tags: ["lofi", "japanese", "hiphop", "mix", "anime"]
    },
    {
      id: "demo9",
      title: "Deep Ambient Space Music - Meditation",
      url: "https://www.youtube.com/watch?v=1",
      duration: "2:30:00",
      tags: ["ambient", "space", "meditation", "relaxation"]
    },
    {
      id: "demo10",
      title: "Cyberpunk Synthwave Mix - Night Drive",
      url: "https://www.youtube.com/watch?v=2",
      duration: "1:15:45",
      tags: ["synthwave", "cyberpunk", "electronic", "night"]
    }
  ].freeze

  def self.search(query, max_results = 10)
    # Extract tags from the search
    tags = query.scan(/#(\w+)/).flatten.map(&:downcase)

    if tags.any?
      # Search by tags
      results = DEMO_TRACKS.select do |track|
        track_tags = track[:tags] || []
        title_lower = track[:title].downcase

        # Check if it matches any tag
        tags.any? { |tag| track_tags.include?(tag) || title_lower.include?(tag) }
      end
    else
      # Normal search by title
      query_lower = query.downcase
      results = DEMO_TRACKS.select do |track|
        track[:title].downcase.include?(query_lower)
      end
    end

    # If no results, return all
    results = DEMO_TRACKS if results.empty?

    results.take(max_results)
  end

  def self.enabled?
    ENV['DEMO_MODE'] == '1' || !internet_available?
  end

  def self.internet_available?
    system('timeout 2 curl -s https://www.youtube.com > /dev/null 2>&1')
  end
end
