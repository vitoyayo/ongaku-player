#!/usr/bin/env ruby

# Script de prueba para búsqueda por tags

ENV['DEMO_MODE'] = '1'  # Usar modo demo para pruebas

require_relative 'lib/youtube_search'
require 'pastel'

pastel = Pastel.new

puts pastel.cyan.bold("🏷️  Prueba de búsqueda por TAGS\n\n")

# Prueba 1: Búsqueda por tag #ambient
puts pastel.yellow("Prueba 1: Buscando '#ambient'\n")
results = YouTubeSearch.search("#ambient", 5)
puts "Resultados encontrados: #{results.length}\n"
results.each_with_index do |track, i|
  puts "  #{i+1}. #{track[:title]}"
  puts "     Tags: #{track[:tags].join(', ')}" if track[:tags]
  puts ""
end

puts pastel.dim("─" * 70) + "\n\n"

# Prueba 2: Búsqueda por tag #lofi
puts pastel.yellow("Prueba 2: Buscando '#lofi'\n")
results = YouTubeSearch.search("#lofi", 5)
puts "Resultados encontrados: #{results.length}\n"
results.each_with_index do |track, i|
  puts "  #{i+1}. #{track[:title]}"
  puts "     Tags: #{track[:tags].join(', ')}" if track[:tags]
  puts ""
end

puts pastel.dim("─" * 70) + "\n\n"

# Prueba 3: Búsqueda por tag #synthwave
puts pastel.yellow("Prueba 3: Buscando '#synthwave'\n")
results = YouTubeSearch.search("#synthwave", 5)
puts "Resultados encontrados: #{results.length}\n"
results.each_with_index do |track, i|
  puts "  #{i+1}. #{track[:title]}"
  puts "     Tags: #{track[:tags].join(', ')}" if track[:tags]
  puts ""
end

puts pastel.dim("─" * 70) + "\n\n"

# Prueba 4: Búsqueda combinada
puts pastel.yellow("Prueba 4: Buscando 'study #chill'\n")
results = YouTubeSearch.search("study #chill", 5)
puts "Resultados encontrados: #{results.length}\n"
results.each_with_index do |track, i|
  puts "  #{i+1}. #{track[:title]}"
  puts "     Tags: #{track[:tags].join(', ')}" if track[:tags]
  puts ""
end

puts pastel.dim("─" * 70) + "\n\n"

# Prueba 5: Múltiples tags
puts pastel.yellow("Prueba 5: Buscando '#lofi #japanese'\n")
results = YouTubeSearch.search("#lofi #japanese", 5)
puts "Resultados encontrados: #{results.length}\n"
results.each_with_index do |track, i|
  puts "  #{i+1}. #{track[:title]}"
  puts "     Tags: #{track[:tags].join(', ')}" if track[:tags]
  puts ""
end

puts pastel.green.bold("\n✅ Pruebas completadas!\n")
puts pastel.dim("Nota: Estas pruebas usan el modo demo con 10 canciones de ejemplo.\n")
puts pastel.dim("En modo normal, buscará en YouTube y filtrará por tags.\n")
