Gem::Specification.new do |spec|
  spec.name          = "ongaku-player"
  spec.version       = "1.0.0"
  spec.authors       = ["Ongaku Player Team"]
  spec.email         = [""]
  spec.summary       = "Reproductor de música de YouTube para terminal"
  spec.description   = "Un reproductor ligero de YouTube para terminal, escrito en Ruby. Similar a lowfi pero con búsqueda completa."
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
    ║           🎵 Ongaku Player instalado con éxito! 🎵            ║
    ╚═══════════════════════════════════════════════════════════════╝

    IMPORTANTE: Este programa requiere dependencias del sistema:

    📦 Dependencias necesarias:
       • yt-dlp (para buscar en YouTube)
       • mpv (para reproducir audio)

    🔧 Instalación rápida de dependencias:

       Ubuntu/Debian:
       $ sudo apt-get install yt-dlp mpv

       macOS:
       $ brew install yt-dlp mpv

       Arch Linux:
       $ sudo pacman -S yt-dlp mpv

    🚀 Para ejecutar:
       $ ongaku

    📖 Documentación completa:
       https://github.com/vitoyayo/ongaku-player

    ¡Disfruta tu música! 🎧
  MSG
end
