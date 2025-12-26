#!/bin/bash

# Ongaku Player - Script de instalación automática
# Este script instala todas las dependencias y el reproductor

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           🎵 Instalador de Ongaku Player 🎵                   ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Detectar sistema operativo
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/arch-release ]; then
            echo "arch"
        elif [ -f /etc/fedora-release ]; then
            echo "fedora"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Instalar dependencias del sistema
install_system_deps() {
    local os=$(detect_os)

    echo "📦 Instalando dependencias del sistema..."
    echo ""

    case $os in
        debian)
            echo "Sistema detectado: Debian/Ubuntu"
            if ! command_exists yt-dlp || ! command_exists mpv; then
                echo "Instalando yt-dlp y mpv..."
                sudo apt-get update
                sudo apt-get install -y yt-dlp mpv
            else
                echo "✓ yt-dlp y mpv ya están instalados"
            fi
            ;;
        arch)
            echo "Sistema detectado: Arch Linux"
            if ! command_exists yt-dlp || ! command_exists mpv; then
                echo "Instalando yt-dlp y mpv..."
                sudo pacman -S --noconfirm yt-dlp mpv
            else
                echo "✓ yt-dlp y mpv ya están instalados"
            fi
            ;;
        fedora)
            echo "Sistema detectado: Fedora/RHEL"
            if ! command_exists yt-dlp || ! command_exists mpv; then
                echo "Instalando mpv..."
                sudo dnf install -y mpv
                echo "Instalando yt-dlp con pip..."
                if ! command_exists pip3; then
                    sudo dnf install -y python3-pip
                fi
                pip3 install --user yt-dlp
            else
                echo "✓ yt-dlp y mpv ya están instalados"
            fi
            ;;
        macos)
            echo "Sistema detectado: macOS"
            if ! command_exists brew; then
                echo "❌ Homebrew no está instalado."
                echo "Por favor instala Homebrew primero: https://brew.sh"
                exit 1
            fi
            if ! command_exists yt-dlp || ! command_exists mpv; then
                echo "Instalando yt-dlp y mpv..."
                brew install yt-dlp mpv
            else
                echo "✓ yt-dlp y mpv ya están instalados"
            fi
            ;;
        *)
            echo "⚠️  Sistema operativo no reconocido."
            echo "Por favor instala manualmente:"
            echo "  - yt-dlp: https://github.com/yt-dlp/yt-dlp"
            echo "  - mpv: https://mpv.io"
            if ! command_exists yt-dlp || ! command_exists mpv; then
                exit 1
            fi
            ;;
    esac

    echo ""
}

# Instalar gemas de Ruby
install_ruby_gems() {
    echo "💎 Instalando gemas de Ruby..."
    echo ""

    if ! command_exists ruby; then
        echo "❌ Ruby no está instalado."
        echo "Por favor instala Ruby primero: https://www.ruby-lang.org"
        exit 1
    fi

    if ! command_exists gem; then
        echo "❌ RubyGems no está instalado."
        exit 1
    fi

    echo "Versión de Ruby: $(ruby -v)"
    echo ""

    # Opción 1: Instalar como gema
    if [ -f "ongaku-player.gemspec" ]; then
        echo "📦 Construyendo e instalando gema..."
        gem build ongaku-player.gemspec
        gem install ongaku-player-*.gem --no-document
        echo "✓ Gema instalada"
    else
        # Opción 2: Instalar dependencias solamente
        echo "📦 Instalando dependencias..."
        gem install tty-prompt tty-box tty-cursor pastel --no-document
        echo "✓ Dependencias instaladas"
    fi

    echo ""
}

# Crear enlace simbólico (si es instalación local)
create_symlink() {
    if [ ! -f "ongaku-player.gemspec" ]; then
        echo "🔗 Creando enlace simbólico..."

        local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        local bin_path="$script_dir/bin/ongaku"

        if [ ! -f "$bin_path" ]; then
            bin_path="$script_dir/ongaku.rb"
        fi

        # Instalar en ~/.local/bin o /usr/local/bin
        if [ -w "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin" 2>/dev/null; then
            ln -sf "$bin_path" "$HOME/.local/bin/ongaku"
            echo "✓ Enlace creado en: $HOME/.local/bin/ongaku"
            echo ""
            echo "Asegúrate de que $HOME/.local/bin esté en tu PATH:"
            echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        elif [ -w "/usr/local/bin" ]; then
            sudo ln -sf "$bin_path" "/usr/local/bin/ongaku"
            echo "✓ Enlace creado en: /usr/local/bin/ongaku"
        else
            echo "⚠️  No se pudo crear enlace simbólico."
            echo "Ejecuta manualmente: $bin_path"
        fi
        echo ""
    fi
}

# Verificar instalación
verify_installation() {
    echo "✅ Verificando instalación..."
    echo ""

    local all_good=true

    if command_exists yt-dlp; then
        echo "✓ yt-dlp: $(yt-dlp --version)"
    else
        echo "❌ yt-dlp no encontrado"
        all_good=false
    fi

    if command_exists mpv; then
        echo "✓ mpv: $(mpv --version | head -1)"
    else
        echo "❌ mpv no encontrado"
        all_good=false
    fi

    if command_exists ruby; then
        echo "✓ ruby: $(ruby -v)"
    else
        echo "❌ ruby no encontrado"
        all_good=false
    fi

    echo ""

    if $all_good; then
        echo "╔═══════════════════════════════════════════════════════════════╗"
        echo "║           ✅ ¡Instalación completada con éxito! ✅            ║"
        echo "╚═══════════════════════════════════════════════════════════════╝"
        echo ""
        echo "🚀 Para ejecutar Ongaku Player:"
        echo ""
        if command_exists ongaku; then
            echo "   $ ongaku"
        else
            echo "   $ ./bin/ongaku"
            echo "   o"
            echo "   $ ruby ongaku.rb"
        fi
        echo ""
        echo "🎵 Modo demo (sin conexión):"
        echo "   $ DEMO_MODE=1 ongaku"
        echo ""
        echo "📖 Documentación: README.md"
        echo ""
        echo "¡Disfruta tu música! 🎧"
    else
        echo "❌ La instalación no se completó correctamente."
        echo "Por favor revisa los errores arriba."
        exit 1
    fi
}

# Menú principal
main() {
    echo "Opciones de instalación:"
    echo ""
    echo "  1) Instalación completa (recomendado)"
    echo "  2) Solo dependencias del sistema"
    echo "  3) Solo gemas de Ruby"
    echo "  4) Verificar instalación"
    echo ""

    read -p "Selecciona una opción [1-4]: " choice
    echo ""

    case $choice in
        1)
            install_system_deps
            install_ruby_gems
            create_symlink
            verify_installation
            ;;
        2)
            install_system_deps
            echo "✓ Dependencias del sistema instaladas"
            ;;
        3)
            install_ruby_gems
            create_symlink
            echo "✓ Gemas de Ruby instaladas"
            ;;
        4)
            verify_installation
            ;;
        *)
            echo "Opción inválida. Ejecutando instalación completa..."
            install_system_deps
            install_ruby_gems
            create_symlink
            verify_installation
            ;;
    esac
}

# Ejecutar instalación
main
