#!/usr/bin/env ruby

require 'bundler/setup'
require_relative 'lib/ui'

# Verificar dependencias del sistema
def check_dependencies
  missing = []

  unless system('which yt-dlp > /dev/null 2>&1')
    missing << 'yt-dlp'
  end

  unless system('which mpv > /dev/null 2>&1')
    missing << 'mpv'
  end

  unless missing.empty?
    puts "❌ Faltan dependencias del sistema: #{missing.join(', ')}"
    puts "\nInstalación:"
    puts "  Ubuntu/Debian: sudo apt-get install #{missing.join(' ')}"
    puts "  macOS: brew install #{missing.join(' ')}"
    puts "  Arch Linux: sudo pacman -S #{missing.join(' ')}"
    exit 1
  end
end

# Verificar dependencias
check_dependencies

# Iniciar interfaz
begin
  ui = UI.new
  ui.start
rescue Interrupt
  puts "\n\n👋 ¡Hasta luego!"
  exit
rescue => e
  puts "\n❌ Error: #{e.message}"
  puts e.backtrace.join("\n") if ENV['DEBUG']
  exit 1
end
