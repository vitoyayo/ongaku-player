#!/usr/bin/env ruby

# Visual demo of the Ongaku player
# Shows the interface without needing to play real music

require 'tty-prompt'
require 'tty-box'
require 'pastel'
require_relative 'lib/demo_mode'

pastel = Pastel.new
prompt = TTY::Prompt.new

# Banner
system('clear')
banner = TTY::Box.frame(
  pastel.cyan.bold("🎵 ONGAKU PLAYER - DEMO 🎵"),
  padding: 1,
  align: :center
)
puts banner
puts pastel.dim("YouTube player for terminal\n")
puts pastel.yellow("Mode: DEMO (using sample songs)\n\n")

# Show list of available songs
puts pastel.green.bold("📋 Available songs in demo mode:\n\n")

DemoMode::DEMO_TRACKS.each_with_index do |track, i|
  puts "#{pastel.cyan((i+1).to_s.rjust(2))}. #{track[:title]}"
  puts "    #{pastel.dim("Duration:")} #{track[:duration]}"
  puts ""
end

puts "\n" + pastel.dim("─" * 70) + "\n\n"

# Simulate search
puts pastel.yellow("🔍 Search example: 'lofi'\n\n")

results = DemoMode.search("lofi", 5)
puts pastel.green("Results found: #{results.length}\n\n")

results.each_with_index do |track, i|
  puts "  #{i+1}. #{track[:title]} [#{track[:duration]}]"
end

puts "\n" + pastel.dim("─" * 70) + "\n\n"

# Features
puts pastel.cyan.bold("✨ Features:\n\n")
features = [
  "🎧 Play music from YouTube",
  "🖥️ Simple terminal interface",
  "⚡ Lightweight and fast",
  "🎮 Intuitive controls (pause, next, volume, etc.)",
  "🔍 Integrated search",
  "📋 Playback queue",
  "🎵 Offline demo mode"
]

features.each do |feature|
  puts "  #{feature}"
end

puts "\n" + pastel.dim("─" * 70) + "\n\n"

puts pastel.green.bold("To run the player:\n")
puts "  #{pastel.white("./ongaku.rb")} - Normal mode (requires connection)"
puts "  #{pastel.white("DEMO_MODE=1 ./ongaku.rb")} - Demo mode\n\n"

puts pastel.dim("Press Ctrl+C to exit this demo")
puts pastel.dim("or run the real player with the commands above\n")
