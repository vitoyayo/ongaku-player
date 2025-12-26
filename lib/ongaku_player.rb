require_relative 'ui'

module OngakuPlayer
  VERSION = "1.0.0"

  def self.run
    # Check system dependencies
    check_dependencies

    # Start interface
    begin
      ui = UI.new
      ui.start
    rescue Interrupt
      puts "\n\n👋 Goodbye!"
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
      puts "❌ Missing system dependencies: #{missing.join(', ')}"
      puts "\n📦 Dependency installation:\n\n"
      puts "  Ubuntu/Debian:"
      puts "  $ sudo apt-get install #{missing.join(' ')}\n\n"
      puts "  macOS:"
      puts "  $ brew install #{missing.join(' ')}\n\n"
      puts "  Arch Linux:"
      puts "  $ sudo pacman -S #{missing.join(' ')}\n\n"
      puts "  Or run the installation script:"
      puts "  $ sudo ./install.sh\n"
      exit 1
    end
  end
end
