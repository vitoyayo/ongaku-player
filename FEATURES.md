# Ongaku Player Features

## 🎯 Project Goals

Create a lightweight YouTube music player for terminal, similar to lowfi, but with full search and playback capabilities.

## ✨ Implemented Features

### 🔍 YouTube Search
- Integrated search using yt-dlp
- Results with title and duration
- Interactive selection with tty-prompt
- Results filtering

### 🎵 Playback
- Direct streaming (no downloads)
- Backend with mpv (very efficient)
- Audio only (no video)
- Background playback

### 🎮 Controls
- ⏸️ Pause/Resume
- ⏹️ Stop
- ⏭️ Next song
- ⏮️ Previous song
- 🔊/🔉 Volume control
- ⏩/⏪ Forward/Rewind

### 📋 Queue Management
- Playback queue
- View all songs
- Skip to any song
- Current song indicator

### 🎨 Interface
- UI with tty-prompt (interactive menus)
- Decorative boxes with tty-box
- Colors with pastel
- Minimalist design

### 🚀 Demo Mode
- Sample song list
- Works offline
- Automatic connectivity detection
- Useful for testing

## 🏗️ Architecture

```
ongaku-player/
├── ongaku.rb              # Main executable file
├── lib/
│   ├── youtube_search.rb  # YouTube search with yt-dlp
│   ├── player.rb          # Player with mpv
│   ├── ui.rb              # User interface
│   └── demo_mode.rb       # Offline demo mode
├── demo.rb                # Visual demo
├── test_search.rb         # Test script
├── Gemfile                # Ruby dependencies
├── README.md              # Main documentation
└── FEATURES.md            # This file
```

## 🔧 Dependencies

### System
- `yt-dlp`: For searching and getting YouTube URLs
- `mpv`: For audio playback

### Ruby (gems)
- `tty-prompt`: Interactive menus
- `tty-box`: Decorative boxes
- `tty-cursor`: Cursor control
- `pastel`: Terminal colors
- `down`: File download (optional)

## 💡 Design Decisions

### Why yt-dlp?
- Better maintained than youtube-dl
- Support for multiple sites
- Frequently updated
- Excellent for extracting streaming URLs

### Why mpv?
- Very lightweight and efficient
- Streaming support
- IPC socket control
- No graphical interface required

### Why Ruby?
- Elegant and clear syntax
- Excellent terminal gems (tty-*)
- Easy to read and maintain
- Ideal for system scripts

### Why not download files?
- Direct streaming saves space
- Immediate playback
- No temporary file cleanup required
- Lower disk usage

## 🎯 Use Cases

1. **Programmers**: Background music while coding
2. **Students**: Music for studying/concentrating
3. **Remote servers**: Playback via SSH
4. **Minimalists**: No browser needed
5. **Terminal users**: Everything from the command line

## 🔮 Possible Future Improvements

- [ ] Saved playlists
- [ ] Playback history
- [ ] Audio equalization
- [ ] Synchronized lyrics
- [ ] SoundCloud support
- [ ] Search by artist/album
- [ ] ASCII spectrum visualizer
- [ ] Global hotkeys
- [ ] State saving between sessions
- [ ] Shuffle mode
- [ ] Repeat song/queue

## 📊 Comparison with Other Solutions

### vs lowfi
- ✅ Similar in concept
- ✅ Ongaku has full search
- ✅ More control options
- ✅ Playback queue

### vs YouTube in browser
- ✅ Much lighter
- ✅ No browser RAM consumption
- ✅ Faster interface
- ❌ No comments/likes

### vs spotify-tui
- ✅ No premium account required
- ✅ Access to all of YouTube
- ❌ Spotify has better organized catalog

## 📝 License

MIT
