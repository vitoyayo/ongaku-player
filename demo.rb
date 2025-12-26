#!/usr/bin/env ruby

# Demo visual del reproductor Ongaku
# Muestra la interfaz sin necesidad de reproducir música real

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
puts pastel.dim("Reproductor de YouTube para terminal\n")
puts pastel.yellow("Modo: DEMO (usando canciones de ejemplo)\n\n")

# Mostrar lista de canciones disponibles
puts pastel.green.bold("📋 Canciones disponibles en modo demo:\n\n")

DemoMode::DEMO_TRACKS.each_with_index do |track, i|
  puts "#{pastel.cyan((i+1).to_s.rjust(2))}. #{track[:title]}"
  puts "    #{pastel.dim("Duración:")} #{track[:duration]}"
  puts ""
end

puts "\n" + pastel.dim("─" * 70) + "\n\n"

# Simular búsqueda
puts pastel.yellow("🔍 Ejemplo de búsqueda: 'lofi'\n\n")

results = DemoMode.search("lofi", 5)
puts pastel.green("Resultados encontrados: #{results.length}\n\n")

results.each_with_index do |track, i|
  puts "  #{i+1}. #{track[:title]} [#{track[:duration]}]"
end

puts "\n" + pastel.dim("─" * 70) + "\n\n"

# Características
puts pastel.cyan.bold("✨ Características:\n\n")
features = [
  "🎧 Reproduce música desde YouTube",
  "🖥️ Interfaz sencilla en terminal",
  "⚡ Ligero y rápido",
  "🎮 Controles intuitivos (pausar, siguiente, volumen, etc.)",
  "🔍 Búsqueda integrada",
  "📋 Cola de reproducción",
  "🎵 Modo demo sin conexión"
]

features.each do |feature|
  puts "  #{feature}"
end

puts "\n" + pastel.dim("─" * 70) + "\n\n"

puts pastel.green.bold("Para ejecutar el reproductor:\n")
puts "  #{pastel.white("./ongaku.rb")} - Modo normal (requiere conexión)"
puts "  #{pastel.white("DEMO_MODE=1 ./ongaku.rb")} - Modo demo\n\n"

puts pastel.dim("Presiona Ctrl+C para salir de este demo")
puts pastel.dim("o ejecuta el reproductor real con los comandos de arriba\n")
