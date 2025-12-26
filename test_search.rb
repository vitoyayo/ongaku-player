#!/usr/bin/env ruby

require_relative 'lib/youtube_search'

puts "🔍 Testing YouTube search...\n\n"

begin
  results = YouTubeSearch.search("lofi hip hop", 5)

  puts "Results found: #{results.length}\n\n"

  results.each_with_index do |track, i|
    puts "#{i+1}. #{track[:title]}"
    puts "   Duration: #{track[:duration]}"
    puts "   URL: #{track[:url]}\n\n"
  end

  puts "\n✅ Search working correctly!"

rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.join("\n")
end
