#!/usr/bin/env ruby

require_relative 'lib/youtube_search'

puts "🔍 Probando búsqueda en YouTube...\n\n"

begin
  results = YouTubeSearch.search("lofi hip hop", 5)

  puts "Resultados encontrados: #{results.length}\n\n"

  results.each_with_index do |track, i|
    puts "#{i+1}. #{track[:title]}"
    puts "   Duración: #{track[:duration]}"
    puts "   URL: #{track[:url]}\n\n"
  end

  puts "\n✅ Búsqueda funcionando correctamente!"

rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.join("\n")
end
