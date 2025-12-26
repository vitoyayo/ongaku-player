Gem::Specification.new do |spec|
  spec.name          = "ongaku-player"
  spec.version       = "1.0.0"
  spec.authors       = ["Ongaku Player Team"]
  spec.email         = [""]
  spec.summary       = "YouTube music player for terminal"
  spec.description   = "A lightweight YouTube player for terminal, written in Ruby. Similar to lowfi but with full search capabilities."
  spec.homepage      = "https://github.com/vitoyayo/ongaku-player"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.files         = Dir['lib/**/*.rb', 'bin/*', 'README.md', 'LICENSE', 'FEATURES.md']
  spec.bindir        = "bin"
  spec.executables   = ["ongaku"]
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_runtime_dependency "tty-prompt", "~> 0.23"
  spec.add_runtime_dependency "tty-box", "~> 0.7"
  spec.add_runtime_dependency "tty-cursor", "~> 0.7"
  spec.add_runtime_dependency "pastel", "~> 0.8"

  # Metadata
  spec.metadata = {
    "bug_tracker_uri"   => "https://github.com/vitoyayo/ongaku-player/issues",
    "documentation_uri" => "https://github.com/vitoyayo/ongaku-player/blob/main/README.md",
    "source_code_uri"   => "https://github.com/vitoyayo/ongaku-player"
  }

  spec.post_install_message = <<~MSG
    ╔═══════════════════════════════════════════════════════════════╗
    ║           🎵 Ongaku Player installed successfully! 🎵         ║
    ╚═══════════════════════════════════════════════════════════════╝

    IMPORTANT: This program requires system dependencies:

    📦 Required dependencies:
       • yt-dlp (for YouTube search)
       • mpv (for audio playback)

    🔧 Quick dependency installation:

       Ubuntu/Debian:
       $ sudo apt-get install yt-dlp mpv

       macOS:
       $ brew install yt-dlp mpv

       Arch Linux:
       $ sudo pacman -S yt-dlp mpv

    🚀 To run:
       $ ongaku

    📖 Full documentation:
       https://github.com/vitoyayo/ongaku-player

    Enjoy your music! 🎧
  MSG
end
