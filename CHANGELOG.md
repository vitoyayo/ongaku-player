# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-12-26

### Initial Release

First public release of Ongaku Player - A lightweight YouTube music player for terminal.

### Features

#### 🔍 YouTube Search
- Integrated search using yt-dlp
- Results display with title and duration
- Interactive selection with tty-prompt
- Tag-based search filtering (e.g., `#lofi`, `#ambient`, `#jazz`)
- Combined search support (e.g., `study music #chill`)

#### 🎵 Playback
- Direct streaming from YouTube (no file downloads)
- Audio-only playback using mpv backend
- Live stream support
- Background playback
- Automatic related songs loading (autoplay)

#### 🎮 Controls
- ⏸️ Pause/Resume
- ⏹️ Stop
- ⏭️ Next song
- ⏮️ Previous song
- 🔊 Volume up
- 🔉 Volume down
- ⏩ Forward 10 seconds
- ⏪ Rewind 10 seconds

#### ⭐ Favorites
- Save favorite tracks
- Persistent storage in `~/.config/ongaku/favorites.json`
- Quick access to favorites
- Remove from favorites

#### 📋 Queue Management
- Automatic playback queue
- View all queued songs
- Skip to any song in queue
- Current song indicator
- Auto-queue related songs with autoplay

#### 🎨 User Interface
- Interactive terminal UI with tty-prompt
- Colored output with pastel
- Minimalist design
- Clear status indicators
- Autoplay toggle (ON/OFF)

#### 🚀 Demo Mode
- 10 sample tracks for offline testing
- Automatic activation when no internet
- Manual activation with `DEMO_MODE=1`
- Tag-based filtering in demo mode

#### 🔧 Installation
- Automatic installer script (`install.sh`)
- Ruby gem packaging
- Rake tasks for development
- Cross-platform support (Linux, macOS)

### Dependencies

#### System Requirements
- Ruby 2.7+
- yt-dlp
- mpv

#### Ruby Gems
- tty-prompt ~> 0.23
- tty-box ~> 0.7
- tty-cursor ~> 0.7
- pastel ~> 0.8

### Supported Platforms
- Ubuntu/Debian
- Arch Linux
- Fedora/RHEL
- macOS (with Homebrew)
