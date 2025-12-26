#!/usr/bin/env ruby

# Test script for tag search

ENV['DEMO_MODE'] = '1'  # Use demo mode for testing

require_relative 'lib/youtube_search'
require 'pastel'

pastel = Pastel.new

puts pastel.cyan.bold("🏷️  TAG search test\n\n")

# Test 1: Search by tag #ambient
puts pastel.yellow("Test 1: Searching '#ambient'\n")
results = YouTubeSearch.search("#ambient", 5)
puts "Results found: #{results.length}\n"
results.each_with_index do |track, i|
  puts "  #{i+1}. #{track[:title]}"
  puts "     Tags: #{track[:tags].join(', ')}" if track[:tags]
  puts ""
end

puts pastel.dim("─" * 70) + "\n\n"

# Test 2: Search by tag #lofi
puts pastel.yellow("Test 2: Searching '#lofi'\n")
results = YouTubeSearch.search("#lofi", 5)
puts "Results found: #{results.length}\n"
results.each_with_index do |track, i|
  puts "  #{i+1}. #{track[:title]}"
  puts "     Tags: #{track[:tags].join(', ')}" if track[:tags]
  puts ""
end

puts pastel.dim("─" * 70) + "\n\n"

# Test 3: Search by tag #synthwave
puts pastel.yellow("Test 3: Searching '#synthwave'\n")
results = YouTubeSearch.search("#synthwave", 5)
puts "Results found: #{results.length}\n"
results.each_with_index do |track, i|
  puts "  #{i+1}. #{track[:title]}"
  puts "     Tags: #{track[:tags].join(', ')}" if track[:tags]
  puts ""
end

puts pastel.dim("─" * 70) + "\n\n"

# Test 4: Combined search
puts pastel.yellow("Test 4: Searching 'study #chill'\n")
results = YouTubeSearch.search("study #chill", 5)
puts "Results found: #{results.length}\n"
results.each_with_index do |track, i|
  puts "  #{i+1}. #{track[:title]}"
  puts "     Tags: #{track[:tags].join(', ')}" if track[:tags]
  puts ""
end

puts pastel.dim("─" * 70) + "\n\n"

# Test 5: Multiple tags
puts pastel.yellow("Test 5: Searching '#lofi #japanese'\n")
results = YouTubeSearch.search("#lofi #japanese", 5)
puts "Results found: #{results.length}\n"
results.each_with_index do |track, i|
  puts "  #{i+1}. #{track[:title]}"
  puts "     Tags: #{track[:tags].join(', ')}" if track[:tags]
  puts ""
end

puts pastel.green.bold("\n✅ Tests completed!\n")
puts pastel.dim("Note: These tests use demo mode with 10 sample songs.\n")
puts pastel.dim("In normal mode, it will search YouTube and filter by tags.\n")
