require_relative 'ui'

module OngakuPlayer
  VERSION = "1.0.0"

  def self.run
    # Verificar dependencias del sistema
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
  end

  def self.check_dependencies
    missing = []

    unless system('which yt-dlp > /dev/null 2>&1')
      missing << 'yt-dlp'
    end

    unless system('which mpv > /dev/null 2>&1')
      missing << 'mpv'
    end

    unless missing.empty?
      puts "❌ Faltan dependencias del sistema: #{missing.join(', ')}"
      puts "\n📦 Instalación de dependencias:\n\n"
      puts "  Ubuntu/Debian:"
      puts "  $ sudo apt-get install #{missing.join(' ')}\n\n"
      puts "  macOS:"
      puts "  $ brew install #{missing.join(' ')}\n\n"
      puts "  Arch Linux:"
      puts "  $ sudo pacman -S #{missing.join(' ')}\n\n"
      puts "  O ejecuta el script de instalación:"
      puts "  $ sudo ./install.sh\n"
      exit 1
    end
  end
end
