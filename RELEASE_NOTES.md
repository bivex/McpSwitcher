# 🎉 McpSwitcher v1.0.0 Release Notes

**Release Date**: December 28, 2025  
**Package**: McpSwitcher-1.0.0.dmg (2.1 MB)

## ✨ What's New

### 🟣 Purple Button - Direct GitHub Skills Copy

The star feature of this release! Copy Claude skills directly from GitHub with one click:

- **Direct GitHub Integration**: Fetches skill content from GitHub repositories
- **Smart File Detection**: Automatically finds SKILL.md, skill.md, README.md
- **Clean Content**: Pure markdown without extra formatting
- **Permanent Caching**: Skills saved locally for offline access
- **Visual Indicators**: Green checkmarks show cached skills
- **Instant Re-copy**: Cached skills copy instantly without network requests

### 📚 Skills Search & Management

Integrated SkillsMP platform for discovering Claude skills:

- **Keyword Search**: Find skills by keywords
- **AI Semantic Search**: Find skills using natural language
- **Filtering & Sorting**: Sort by stars, recent, relevance
- **Pagination**: Browse through thousands of skills
- **Rich Metadata**: View descriptions, tags, ratings, authors
- **Cache Management**: Clear cache, view cached count

### 🖥️ Server Management

Complete MCP server control from your menu bar:

- **Toggle Servers**: Enable/disable servers with one click
- **Auto-Sync**: Syncs with Cursor's MCP configuration
- **Real-time Updates**: See server status instantly
- **Visual Status**: Green/gray indicators for enabled/disabled
- **Server Count**: Menu bar shows number of active servers

### 🎨 Modern SwiftUI Interface

Beautiful native macOS interface:

- **Dark Mode**: Sleek dark theme matching macOS
- **Tab Interface**: Separate tabs for Servers and Skills
- **Responsive**: Smooth animations and transitions
- **Native Controls**: Uses standard macOS UI elements
- **Menu Bar App**: Unobtrusive tray application

## 🚀 Installation

### Download & Install

1. Download `McpSwitcher-1.0.0.dmg`
2. Open the DMG file
3. Drag `McpSwitcher.app` to Applications folder
4. Launch from Applications
5. Grant permissions if prompted

See `INSTALLATION.md` for detailed instructions.

## 📋 Features Overview

### Tray Application

| Feature | Description |
|---------|-------------|
| **Server Toggle** | Enable/disable MCP servers |
| **Auto-Sync** | Syncs with Cursor's mcp.json |
| **Skills Search** | Search SkillsMP platform |
| **GitHub Copy** | Copy skills directly from GitHub |
| **Caching** | Permanent local skill storage |
| **Menu Bar** | Quick access from menu bar |

### Command Line Interface

Included in the app bundle at `Resources/bin/mcp-switcher`:

```bash
mcp-switcher list              # List all servers
mcp-switcher toggle <name>     # Toggle server
mcp-switcher enable <name>     # Enable server
mcp-switcher disable <name>    # Disable server
mcp-switcher sync              # Sync with Cursor
mcp-switcher import <json>     # Import servers
mcp-switcher export            # Export configuration
```

## 🎯 Use Cases

### For AI Developers
- Quickly toggle MCP servers for testing
- Discover and import Claude skills
- Manage server configurations
- Build skill library offline

### For Cursor Users
- Control MCP servers without editing JSON
- Seamless integration with Cursor
- Visual server management
- Quick enable/disable workflows

### For Skill Collectors
- Search thousands of Claude skills
- Copy skills from GitHub instantly
- Build permanent skill cache
- Share skills easily (clipboard)

## 🔧 Technical Details

### Built With
- **Swift** - Native macOS application
- **SwiftUI** - Modern UI framework
- **SQLite** - Local database
- **Foundation** - Core macOS APIs

### Architecture
- **Domain-Driven Design** - Clean architecture
- **Repository Pattern** - Data access abstraction
- **Use Cases** - Business logic separation
- **Clean Code** - Well-documented, maintainable

### Performance
- **Small Footprint**: ~2 MB disk, ~50 MB RAM
- **Fast Startup**: Launches in < 1 second
- **Efficient Caching**: Instant skill access
- **Low CPU**: Minimal background usage

## 📊 Statistics

- **Lines of Code**: ~1,500 Swift
- **Build Time**: ~3 seconds (release)
- **App Size**: 2.1 MB (compressed)
- **Supported Skills**: Unlimited (with cache)

## 🔐 Security & Privacy

- **Local Storage**: All data stored locally
- **No Telemetry**: No analytics or tracking
- **Secure Keychain**: API keys in macOS Keychain
- **Open Source**: Code available for review
- **MIT License**: Free to use and modify

## 🐛 Known Issues

None reported in this release!

## 🔮 Roadmap

Planned for future releases:

- [ ] Skill editor (create/edit skills)
- [ ] Skill categories and collections
- [ ] Export cached skills to files
- [ ] Import skills from local files
- [ ] Skill syntax highlighting preview
- [ ] Auto-update checker
- [ ] Icon customization
- [ ] Keyboard shortcuts
- [ ] Multi-language support

## 💡 Tips & Tricks

### Purple Button Workflow
1. Search for a skill
2. Click purple button to cache it
3. Paste into Claude Desktop
4. Click purple button again anytime for instant re-copy

### Cache Management
- Footer shows cached skill count
- Green checkmarks indicate cached skills
- "Clear Cache" button removes all cached skills
- Cached skills survive app restarts

### Server Management
- Right-click tray icon for quick menu
- Toggle servers without opening window
- Server count shows in menu bar
- Auto-syncs every time you toggle

## 📞 Support

- **Issues**: Report on GitHub
- **Email**: support@b-b.top
- **Documentation**: See INSTALLATION.md
- **Source Code**: Available on request

## 🙏 Acknowledgments

- **PyTorch Team** - For excellent skill examples
- **SkillsMP** - For skill platform and API
- **Cursor Team** - For MCP integration
- **Swift Community** - For great tools and libraries

## 📄 License

MIT License - Copyright © 2025 Bivex

---

**Download**: McpSwitcher-1.0.0.dmg  
**Size**: 2.1 MB  
**macOS**: 12.0+ (Monterey, Ventura, Sonoma)  
**Released**: December 28, 2025

🎉 **Thank you for using McpSwitcher!** 🎉

