# 🎵 Ongaku Player

A lightweight YouTube music player for terminal, written in Ruby.

## Features

- 🎧 Play music directly from YouTube
- 🖥️ Simple terminal interface
- ⚡ Lightweight and fast
- 🎮 Intuitive controls
- 🔍 Integrated YouTube search

## Requirements

- Ruby 2.7+
- `yt-dlp` (for getting YouTube URLs)
- `mpv` (for audio playback)

### System dependency installation

#### Ubuntu/Debian
```bash
sudo apt-get install yt-dlp mpv
```

#### macOS
```bash
brew install yt-dlp mpv
```

#### Arch Linux
```bash
sudo pacman -S yt-dlp mpv
```

## Installation

### Method 1: Automatic installation (Recommended)

```bash
# Clone the repository
git clone https://github.com/vitoyayo/ongaku-player.git
cd ongaku-player

# Run installer (installs everything automatically)
./install.sh
```

The installer will detect your operating system and install:
- System dependencies (yt-dlp, mpv)
- Required Ruby gems
- The `ongaku` executable in your PATH

### Method 2: Installation as Ruby gem

```bash
# Clone the repository
git clone https://github.com/vitoyayo/ongaku-player.git
cd ongaku-player

# Build and install the gem
gem build ongaku-player.gemspec
gem install ongaku-player-*.gem

# Install system dependencies manually
# Ubuntu/Debian:
sudo apt-get install yt-dlp mpv

# macOS:
brew install yt-dlp mpv

# Arch Linux:
sudo pacman -S yt-dlp mpv
```

### Method 3: Installation with Rake

```bash
# Clone the repository
git clone https://github.com/vitoyayo/ongaku-player.git
cd ongaku-player

# Install system dependencies first (see Method 2)

# Install with rake
rake install
```

### Method 4: Manual installation

```bash
# Clone the repository
git clone https://github.com/vitoyayo/ongaku-player.git
cd ongaku-player

# Install system dependencies
sudo apt-get install yt-dlp mpv  # Ubuntu/Debian

# Install Ruby gems
gem install tty-prompt tty-box tty-cursor pastel

# Make executable
chmod +x ongaku.rb
```

## Usage

```bash
# If installed with install.sh or as gem
ongaku

# Or run directly from the repository
./bin/ongaku

# With ruby
ruby ongaku.rb

# With rake (development mode)
rake run

# Demo mode (without internet connection)
DEMO_MODE=1 ongaku
# or
rake demo
```

### Operation Modes

**Normal Mode**: Searches and plays music directly from YouTube using yt-dlp.

**Demo Mode**: If there's no internet connection, the player automatically uses a sample song list. You can force demo mode with:
```bash
DEMO_MODE=1 ./ongaku.rb
```

### Controls

- `🔍 Search music`: Search songs on YouTube (or in demo list)
  - Normal search: "lofi hip hop"
  - Search by tags: "#ambient" or "#lofi beats"
  - Combined: "study music #chill"
- `📋 View queue`: View and manage playback queue
- `⏯️ Playback`: Playback controls (pause, next, volume, etc.)
- `❌ Exit`: Close the player

### Playback Controls

- ⏸️ Pause/Resume
- ⏹️ Stop
- ⏭️ Next song
- ⏮️ Previous song
- 🔊 Volume up
- 🔉 Volume down
- ⏩ Forward 10 seconds
- ⏪ Rewind 10 seconds

## Architecture

The player is designed to be as lightweight as possible:

- Uses `yt-dlp` to get streaming URLs from YouTube
- Uses `mpv` as audio backend (very efficient)
- Minimalist interface with `tty-prompt`
- No file downloads (direct streaming)

## Useful Commands

```bash
# Build the gem
rake build

# Install locally
rake install

# Uninstall
rake uninstall

# Run in development
rake run

# Demo mode
rake demo

# Show visual demo
rake show_demo

# Test search
rake test_search

# Clean and reinstall
rake reinstall
```

## Development

### Project Structure

```
ongaku-player/
├── bin/
│   └── ongaku              # Main executable
├── lib/
│   ├── ongaku_player.rb    # Main module
│   ├── youtube_search.rb   # YouTube search
│   ├── player.rb           # Player with mpv
│   ├── ui.rb               # User interface
│   └── demo_mode.rb        # Demo mode
├── ongaku-player.gemspec   # Gem specification
├── Gemfile                 # Dependencies
├── Rakefile                # Rake tasks
├── install.sh              # Automatic installer
├── README.md               # This file
├── FEATURES.md             # Detailed features
└── LICENSE                 # MIT License
```

### Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

## License

MIT - See [LICENSE](LICENSE) for more details.
