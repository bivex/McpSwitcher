# McpSwitcher Installation Guide

## 📦 Package Information

**Version**: 1.0.0  
**Package**: McpSwitcher-1.0.0.dmg  
**Size**: ~2.1 MB  
**Platform**: macOS 12.0+  

## 🚀 Installation Steps

### Method 1: DMG Installer (Recommended)

1. **Download** `McpSwitcher-1.0.0.dmg`

2. **Open the DMG**
   - Double-click the DMG file
   - A Finder window will open

3. **Install the Application**
   - Drag `McpSwitcher.app` to the `Applications` folder
   - Wait for copy to complete

4. **Launch the Application**
   - Open `Applications` folder
   - Double-click `McpSwitcher.app`
   - An orange icon 🟠 will appear in your menu bar

5. **First Run**
   - If macOS shows security warning:
     - Go to **System Settings** → **Privacy & Security**
     - Click **Open Anyway** next to McpSwitcher
   - The app will launch and show in menu bar

### Method 2: Manual Installation

If you prefer to build from source:

```bash
# Clone or download the repository
cd /path/to/McpSwitcher

# Build release version
swift build -c release

# The binary will be at:
.build/release/mcp-tray
```

## 🎯 What's Included

The DMG package contains:

1. **McpSwitcher.app**
   - Main tray application
   - SwiftUI interface
   - Skills search and management
   - Server toggling

2. **mcp-switcher CLI** (inside app bundle)
   - Command-line interface
   - Located at: `McpSwitcher.app/Contents/Resources/bin/mcp-switcher`

3. **Documentation**
   - README.md
   - INSTALL.md

## 📋 Using McpSwitcher

### Tray App Features

**1. Server Management Tab**
- View all MCP servers
- Toggle servers on/off
- Auto-sync with Cursor's MCP configuration
- Real-time status updates

**2. Skills Tab**
- Search for Claude skills (SkillsMP integration)
- Browse and filter skills
- **Purple Button** 🟣: Copy skill content directly from GitHub
  - Supports SKILL.md, skill.md, README.md
  - Clean content without formatting
  - Permanent caching
  - Offline access after first fetch
- View skill metadata (description, tags, stars)
- Pagination support

### Purple Button Usage

The purple button is the key feature for skill management:

1. **Search for skills** in the Skills tab
2. **Find a skill** with a GitHub URL
3. **Click the purple button** 🟣
4. **Content is copied** to clipboard
5. **Paste** into Claude or any AI assistant
6. **Green checkmark** ✓ shows cached skills

### CLI Usage

If you want to use the CLI tool system-wide:

```bash
# Add to your PATH (optional)
sudo ln -s /Applications/McpSwitcher.app/Contents/Resources/bin/mcp-switcher /usr/local/bin/

# Then use from anywhere:
mcp-switcher list
mcp-switcher toggle server-name
mcp-switcher sync
```

## 🔧 Configuration

### SkillsMP API Key

To use the Skills search feature:

1. Get API key from [SkillsMP](https://skillsmp.com)
2. Open McpSwitcher tray app
3. Go to **Skills** tab
4. Enter API key in the secure field
5. Click key button to save

The API key is stored securely in macOS Keychain.

### Database Location

McpSwitcher stores its database at:
```
~/Library/Application Support/McpSwitcher/mcp_switcher.db
```

### Cursor MCP Configuration

The app automatically syncs with Cursor's MCP configuration at:
```
~/.cursor/mcp.json
```

## 🔄 Updates

To update McpSwitcher:

1. Quit the current version (right-click tray icon → Quit)
2. Download new DMG
3. Replace old app in Applications folder
4. Launch new version

Your settings and cached skills are preserved.

## 🗑️ Uninstallation

To remove McpSwitcher:

1. Quit the app (right-click tray icon → Quit)
2. Delete from Applications folder:
   ```bash
   rm -rf /Applications/McpSwitcher.app
   ```
3. (Optional) Remove database:
   ```bash
   rm -rf ~/Library/Application\ Support/McpSwitcher
   ```

## ⚙️ System Requirements

- **macOS**: 12.0 (Monterey) or later
- **Disk Space**: ~10 MB (plus cache)
- **Memory**: ~50 MB RAM
- **Network**: Required for Skills search and GitHub fetching

## 🐛 Troubleshooting

### App doesn't open
- Check System Settings → Privacy & Security
- Click "Open Anyway" for McpSwitcher
- Make sure you're running macOS 12.0+

### Purple button doesn't work
- Check internet connection
- Verify GitHub URL is accessible
- Check console logs (if running from terminal)

### Skills search doesn't work
- Verify SkillsMP API key is set
- Check internet connection
- Try refreshing the search

### Tray icon doesn't appear
- Check if app is running in Activity Monitor
- Restart the app
- Check menu bar isn't hidden

## 📞 Support

- **GitHub**: https://github.com/bivex
- **Email**: support@b-b.top
- **Documentation**: See README.md and other .md files

## 📄 License

MIT License - See LICENSE file for details

---

**Version**: 1.0.0  
**Last Updated**: December 28, 2025  
**Created by**: Bivex

