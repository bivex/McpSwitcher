# 🔵 Permanent Parsing Feature - Purple Button

## Overview
The **Purple Button** in the Skills view provides permanent parsing and caching of GitHub skill content. When you click it, the entire skill content is fetched, parsed, formatted, and saved permanently.

## 🎯 What It Does

### 1. **Fetches Raw Content**
- Automatically tries multiple GitHub raw file URLs:
  - Direct `.md` files
  - `skill.md` in directories
  - `README.md` in directories
  - Common Claude skill locations

### 2. **Parses & Formats**
The parser extracts and formats:
- ✅ Markdown headers (H1, H2, H3)
- ✅ Code blocks with syntax highlighting
- ✅ Bullet lists and numbered lists
- ✅ YAML frontmatter (title, description, author)
- ✅ Regular paragraphs and text

### 3. **Enhanced Metadata**
Each parsed skill includes:
```
═══════════════════════════════════════════════════════════
🎯 SKILL: [SKILL NAME]
═══════════════════════════════════════════════════════════

📋 METADATA
────────────────────────────────────────
🆔 Skill ID: [unique-id]
📝 Description: [description]
🏷️  Tags: [tag1, tag2, tag3]
🔗 Source: [github-url]
📅 Parsed: [date and time]
────────────────────────────────────────

📄 PARSED GITHUB CONTENT
═══════════════════════════════════════════════════════════

[Full parsed content with formatting]

═══════════════════════════════════════════════════════════
✅ PERMANENT PARSING COMPLETE
═══════════════════════════════════════════════════════════

🎉 SKILL CONTENT SUCCESSFULLY PARSED FROM GITHUB
📋 READY FOR IMPORT INTO CLAUDE DESKTOP OR OTHER AI ASSISTANTS
🔗 SOURCE: GitHub raw content (permanently parsed)
💾 ПАРСЕНО И ГОТОВО К ИСПОЛЬЗОВАНИЮ
✨ Skill ID: [id]
📊 Total Characters: [count]
⏰ Parsed at: [timestamp]
✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨

💡 HOW TO USE THIS SKILL:
1. This content is now in your clipboard
2. Paste it into your AI assistant
3. The skill is ready to use immediately
4. Cached permanently in McpSwitcher
═══════════════════════════════════════════════════════════
```

### 4. **Permanent Caching**
- Saves to `UserDefaults` with key: `parsed_skill_[skillId]`
- Maintains a list of all parsed skills: `all_parsed_skills`
- Survives app restarts
- Can be cleared via "Clear Cache" button

### 5. **Visual Indicators**
- ✅ Green checkmark next to skill title = already parsed and cached
- 🔵 Purple button shows checkmark when skill is cached
- 💾 Footer shows count of cached skills

## 🎨 UI Elements

### Purple Button Location
In each skill row, you'll see three buttons:
1. 🟢 **Green Link** - Opens GitHub URL in browser
2. 🟣 **Purple Doc** - **PERMANENT PARSING** (this is the one!)
3. 🔵 **Blue Copy** - Copies skill metadata only

### Footer Information
```
[X skills total, showing page Y] • [Z parsed 💾]  [Clear Cache] [Clear]
```

## 📋 How to Use

### First Time Parsing
1. Search for skills using the Skills tab
2. Find a skill with a GitHub URL
3. Click the **purple button** (doc.text icon)
4. Wait for parsing (you'll see console logs)
5. Content is automatically copied to clipboard
6. Content is permanently saved to cache

### Using Cached Content
1. Skills with green checkmark are already parsed
2. Click purple button again to re-copy cached content
3. No network request needed - instant copy!

### Managing Cache
- View cache count in footer: `• 5 parsed 💾`
- Clear all cached skills: Click **"Clear Cache"** button
- Individual skills can be re-parsed by clicking purple button again

## 🔍 Console Logs

When you click the purple button, you'll see:
```
🔵 PURPLE BUTTON: Starting permanent parsing for skill: [name]
🔗 GitHub URL: [url]
✅ Successfully fetched [X] characters of raw content
🎨 Starting permanent parsing for: [name]
✅ SUCCESSFULLY COPIED PARSED CONTENT TO CLIPBOARD
📊 Content length: [X] characters
🎯 Skill: [name]
📝 Preview: [first 200 chars]...
💾 Permanently saved parsed skill to cache: [name]
```

## 🛠️ Technical Details

### Storage
- Uses `UserDefaults` for persistent storage
- Each skill stored with metadata:
  ```json
  {
    "id": "skill-id",
    "title": "Skill Title",
    "githubUrl": "https://github.com/...",
    "parsedAt": 1735401982.0,
    "rawContent": "full parsed content..."
  }
  ```

### Fallback Behavior
If GitHub fetch fails:
- Automatically falls back to copying skill metadata
- User still gets useful information
- Error is logged but doesn't break the UI

### Cache Management Functions
```swift
getParsedSkillsCount() -> Int          // Get number of cached skills
loadParsedSkillFromCache(skillId:)     // Load specific cached skill
clearParsedSkillsCache()               // Clear all cached skills
saveParsedSkillToCache(skill:content:) // Save new parsed skill
```

## 🎯 Use Cases

### 1. Offline Access
- Parse skills once while online
- Access full content anytime, even offline
- No repeated network requests

### 2. Quick Reference
- Build a library of parsed skills
- Instant clipboard access
- Share formatted content easily

### 3. Import to AI Assistants
- Content is pre-formatted for Claude Desktop
- Ready to paste into any AI assistant
- Includes all necessary metadata

### 4. Skill Management
- Track which skills you've reviewed
- Green checkmarks show parsed skills
- Easy to identify your skill library

## 📊 Performance

- **First Parse**: 1-3 seconds (network + parsing)
- **Cached Access**: < 0.1 seconds (instant)
- **Storage**: ~5-50 KB per skill (depends on content size)
- **No Limits**: Parse as many skills as you want

## 🔐 Privacy & Security

- All data stored locally on your Mac
- No external servers involved (except GitHub fetch)
- Cache can be cleared anytime
- No personal data collected

## 🚀 Future Enhancements

Possible improvements:
- Export all cached skills to JSON
- Import/export cache between devices
- Search within cached skills
- Auto-update cached skills from GitHub
- Syntax highlighting in preview
- Markdown rendering in UI

## 📝 Testing

To test the feature:
```bash
# 1. Build the tray app
swift build

# 2. Run the tray app
.build/debug/mcp-tray

# 3. Open Skills tab
# 4. Search for skills (need SkillsMP API key)
# 5. Click purple button on any skill with GitHub URL
# 6. Check console for logs
# 7. Paste clipboard content to verify
```

## 🐛 Troubleshooting

### Purple button doesn't appear
- Skill must have a `githubUrl` field
- Check that skill data includes GitHub link

### Parsing fails
- Check console logs for specific error
- Verify GitHub URL is accessible
- Try fallback (copies skill info instead)

### Cache not persisting
- Check UserDefaults permissions
- Verify app has write access
- Try clearing and re-parsing

### Content looks wrong
- Parser handles standard markdown
- Some custom formats may not parse perfectly
- Raw content is always preserved in cache

---

**Created**: 2025-12-28  
**Author**: Bivex  
**Version**: 1.0  
**License**: MIT

