#!/bin/bash

# Ongaku Player - Automatic installation script
# This script installs all dependencies and the player

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           🎵 Ongaku Player Installer 🎵                       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Detect operating system
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

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install system dependencies
install_system_deps() {
    local os=$(detect_os)

    echo "📦 Installing system dependencies..."
    echo ""

    case $os in
        debian)
            echo "Detected system: Debian/Ubuntu"
            if ! command_exists yt-dlp || ! command_exists mpv; then
                echo "Installing yt-dlp and mpv..."
                sudo apt-get update
                sudo apt-get install -y yt-dlp mpv
            else
                echo "✓ yt-dlp and mpv are already installed"
            fi
            ;;
        arch)
            echo "Detected system: Arch Linux"
            if ! command_exists yt-dlp || ! command_exists mpv; then
                echo "Installing yt-dlp and mpv..."
                sudo pacman -S --noconfirm yt-dlp mpv
            else
                echo "✓ yt-dlp and mpv are already installed"
            fi
            ;;
        fedora)
            echo "Detected system: Fedora/RHEL"
            if ! command_exists yt-dlp || ! command_exists mpv; then
                echo "Installing mpv..."
                sudo dnf install -y mpv
                echo "Installing yt-dlp with pip..."
                if ! command_exists pip3; then
                    sudo dnf install -y python3-pip
                fi
                pip3 install --user yt-dlp
            else
                echo "✓ yt-dlp and mpv are already installed"
            fi
            ;;
        macos)
            echo "Detected system: macOS"
            if ! command_exists brew; then
                echo "❌ Homebrew is not installed."
                echo "Please install Homebrew first: https://brew.sh"
                exit 1
            fi
            if ! command_exists yt-dlp || ! command_exists mpv; then
                echo "Installing yt-dlp and mpv..."
                brew install yt-dlp mpv
            else
                echo "✓ yt-dlp and mpv are already installed"
            fi
            ;;
        *)
            echo "⚠️  Operating system not recognized."
            echo "Please install manually:"
            echo "  - yt-dlp: https://github.com/yt-dlp/yt-dlp"
            echo "  - mpv: https://mpv.io"
            if ! command_exists yt-dlp || ! command_exists mpv; then
                exit 1
            fi
            ;;
    esac

    echo ""
}

# Install Ruby gems
install_ruby_gems() {
    echo "💎 Installing Ruby gems..."
    echo ""

    if ! command_exists ruby; then
        echo "❌ Ruby is not installed."
        echo "Please install Ruby first: https://www.ruby-lang.org"
        exit 1
    fi

    if ! command_exists gem; then
        echo "❌ RubyGems is not installed."
        exit 1
    fi

    echo "Ruby version: $(ruby -v)"
    echo ""

    # Option 1: Install as gem
    if [ -f "ongaku-player.gemspec" ]; then
        echo "📦 Building and installing gem..."
        gem build ongaku-player.gemspec
        gem install ongaku-player-*.gem --no-document
        echo "✓ Gem installed"
    else
        # Option 2: Install dependencies only
        echo "📦 Installing dependencies..."
        gem install tty-prompt tty-box tty-cursor pastel --no-document
        echo "✓ Dependencies installed"
    fi

    echo ""
}

# Create symbolic link (if local installation)
create_symlink() {
    if [ ! -f "ongaku-player.gemspec" ]; then
        echo "🔗 Creating symbolic link..."

        local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        local bin_path="$script_dir/bin/ongaku"

        if [ ! -f "$bin_path" ]; then
            bin_path="$script_dir/ongaku.rb"
        fi

        # Install in ~/.local/bin or /usr/local/bin
        if [ -w "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin" 2>/dev/null; then
            ln -sf "$bin_path" "$HOME/.local/bin/ongaku"
            echo "✓ Link created at: $HOME/.local/bin/ongaku"
            echo ""
            echo "Make sure $HOME/.local/bin is in your PATH:"
            echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        elif [ -w "/usr/local/bin" ]; then
            sudo ln -sf "$bin_path" "/usr/local/bin/ongaku"
            echo "✓ Link created at: /usr/local/bin/ongaku"
        else
            echo "⚠️  Could not create symbolic link."
            echo "Run manually: $bin_path"
        fi
        echo ""
    fi
}

# Verify installation
verify_installation() {
    echo "✅ Verifying installation..."
    echo ""

    local all_good=true

    if command_exists yt-dlp; then
        echo "✓ yt-dlp: $(yt-dlp --version)"
    else
        echo "❌ yt-dlp not found"
        all_good=false
    fi

    if command_exists mpv; then
        echo "✓ mpv: $(mpv --version | head -1)"
    else
        echo "❌ mpv not found"
        all_good=false
    fi

    if command_exists ruby; then
        echo "✓ ruby: $(ruby -v)"
    else
        echo "❌ ruby not found"
        all_good=false
    fi

    echo ""

    if $all_good; then
        echo "╔═══════════════════════════════════════════════════════════════╗"
        echo "║           ✅ Installation completed successfully! ✅          ║"
        echo "╚═══════════════════════════════════════════════════════════════╝"
        echo ""
        echo "🚀 To run Ongaku Player:"
        echo ""
        if command_exists ongaku; then
            echo "   $ ongaku"
        else
            echo "   $ ./bin/ongaku"
            echo "   or"
            echo "   $ ruby ongaku.rb"
        fi
        echo ""
        echo "🎵 Demo mode (offline):"
        echo "   $ DEMO_MODE=1 ongaku"
        echo ""
        echo "📖 Documentation: README.md"
        echo ""
        echo "Enjoy your music! 🎧"
    else
        echo "❌ Installation did not complete successfully."
        echo "Please check the errors above."
        exit 1
    fi
}

# Main menu
main() {
    echo "Installation options:"
    echo ""
    echo "  1) Full installation (recommended)"
    echo "  2) System dependencies only"
    echo "  3) Ruby gems only"
    echo "  4) Verify installation"
    echo ""

    read -p "Select an option [1-4]: " choice
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
            echo "✓ System dependencies installed"
            ;;
        3)
            install_ruby_gems
            create_symlink
            echo "✓ Ruby gems installed"
            ;;
        4)
            verify_installation
            ;;
        *)
            echo "Invalid option. Running full installation..."
            install_system_deps
            install_ruby_gems
            create_symlink
            verify_installation
            ;;
    esac
}

# Run installation
main
