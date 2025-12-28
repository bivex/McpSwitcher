# ⭐ Favorites Feature Guide

## 🎯 Overview

The **Favorites** feature allows you to save your most-used Claude skills for quick access. No more searching - just open the Favorites tab and copy any skill instantly!

## ✨ What's New

### 🆕 Third Tab - Favorites

A dedicated tab for your favorite skills:
- **Star Icon** ⭐ in the tab bar
- Quick access to all saved skills
- Same powerful features as Skills tab
- Persistent storage (survives app restart)

### ⭐ Star Button

Every skill now has a **star button**:
- **Empty star** ☆ - Not favorited
- **Yellow star** ⭐ - Favorited
- Click to toggle favorite status
- Instant visual feedback

## 🚀 How to Use

### Adding to Favorites

1. **Search for a skill** in the Skills tab
2. **Find a skill** you like
3. **Click the star button** ⭐ (next to other action buttons)
4. **Star turns yellow** - skill is now favorited!

```
Skills Tab:
┌────────────────────────────────────────────────────┐
│ [Skill Title]              ☆ 🟢 🟣 🔵            │  ← Click empty star
│ Description...                                     │
└────────────────────────────────────────────────────┘

After clicking:
┌────────────────────────────────────────────────────┐
│ [Skill Title]              ⭐ 🟢 🟣 🔵           │  ← Now filled star
│ Description...                                     │
└────────────────────────────────────────────────────┘
```

### Viewing Favorites

1. **Click orange tray icon** 🟠 in menu bar
2. **Select "Favorites" tab** (star icon ⭐)
3. **See all your favorited skills** in one place
4. **Badge shows count** (e.g., "5" skills)

### Using Favorited Skills

Once in Favorites tab, you can:

- **🟣 Purple Button** - Copy skill content from GitHub
- **🟢 Green Button** - Open GitHub link in browser  
- **🔵 Blue Button** - Copy skill metadata
- **⭐ Yellow Star** - Remove from favorites
- **✓ Green Check** - Shows if cached

All the same features as the Skills tab!

### Removing from Favorites

Two ways to remove:

**Method 1: From Skills Tab**
1. Search and find the skill
2. Click the **yellow star** ⭐
3. Star becomes empty ☆
4. Removed from Favorites

**Method 2: From Favorites Tab**
1. Open Favorites tab
2. Find the skill
3. Click the **yellow star** ⭐
4. Skill removed instantly

**Method 3: Clear All**
1. Open Favorites tab
2. Click **"Clear All"** button at bottom
3. Confirms - all favorites removed

## 📊 UI Elements

### Button Layout

Each skill row now has these buttons (left to right):

```
[Skill Title] [✓ if cached] [⭐ star] [🟢 link] [🟣 GitHub] [🔵 copy]
```

- **✓ Green Check** - Skill is cached (permanent)
- **⭐ Star** - Toggle favorite (empty ☆ or filled ⭐)
- **🟢 Link** - Open GitHub in browser
- **🟣 Purple** - Copy from GitHub (with checkmark if cached)
- **🔵 Blue** - Copy metadata

### Favorites Tab Layout

```
┌─────────────────────────────────────────────────────┐
│ Favorite Skills                              [5]    │  ← Header with count badge
├─────────────────────────────────────────────────────┤
│                                                      │
│ [Skill 1]                    ⭐ 🟢 🟣 🔵          │
│ ─────────────────────────────────────────────────  │
│ [Skill 2]                    ⭐ 🟢 🟣 🔵          │
│ ─────────────────────────────────────────────────  │
│ [Skill 3]                    ⭐ 🟢 🟣 🔵          │
│                                                      │
├─────────────────────────────────────────────────────┤
│ 5 favorite skills                    [Clear All]    │  ← Footer with count
└─────────────────────────────────────────────────────┘
```

### Empty State

When no favorites yet:

```
┌─────────────────────────────────────────────────────┐
│ Favorite Skills                                     │
├─────────────────────────────────────────────────────┤
│                                                      │
│                      ⭐                             │
│                       ✕                             │
│                                                      │
│              No Favorite Skills Yet                 │
│                                                      │
│  Add skills to favorites by clicking the star ⭐    │
│                    button                            │
│                                                      │
└─────────────────────────────────────────────────────┘
```

## 💾 Data Storage

### What's Saved

For each favorite skill, we store:

- **Skill ID** - Unique identifier
- **Title** - Skill name
- **Description** - What it does
- **Category** - Type of skill
- **Difficulty** - Beginner/Intermediate/Advanced
- **Stars & Count** - Rating information
- **Tags** - Skill tags
- **Author** - Creator name
- **URL** - SkillsMP link
- **GitHub URL** - Source repository
- **Added Date** - When favorited

### Storage Location

Favorites are stored in:
- **UserDefaults** - macOS user preferences
- **Key**: `favorite_skills` (array of IDs)
- **Data**: `favorite_skill_data_[id]` (full skill info)

### Persistence

✅ Survives app restart  
✅ Survives Mac restart  
✅ Independent from cache  
✅ Can be cleared anytime  

## 🎯 Use Cases

### 1. Quick Access Library

Build your personal skill library:
- Favorite 10-20 most-used skills
- Access instantly from Favorites tab
- No need to search repeatedly
- Perfect for daily workflow

### 2. Project Collections

Organize skills by project:
- Favorite all skills for current project
- Switch projects, clear favorites
- Add new project's skills
- Easy project-based workflow

### 3. Learning Path

Track skills you're learning:
- Favorite skills to master
- Practice with them regularly
- Remove when mastered
- Build knowledge progressively

### 4. Skill Curation

Build a curated collection:
- Research best skills
- Favorite high-quality ones
- Share list with team
- Export for others (future feature)

## 📈 Statistics

In footer of Favorites tab:

```
5 favorite skills                    [Clear All]
```

Shows:
- Total count of favorites
- Plural/singular grammar ("skill" vs "skills")
- Clear All button to remove all

## 🔄 Workflow Examples

### Example 1: Daily Coding Assistant

```
Morning:
1. Open McpSwitcher → Favorites tab
2. See your 10 favorited coding skills
3. Click purple button on "Python Helper"
4. Paste into Claude Desktop
5. Start coding!

Benefits:
- No searching
- Instant access
- Consistent workflow
- Saves 2-3 minutes per day
```

### Example 2: Learning New Framework

```
Learning React:
1. Search "React" in Skills tab
2. Find good tutorials/helpers
3. Star 5 best React skills
4. Switch to Favorites tab
5. Work through each skill
6. Use purple button to copy
7. Practice in Claude Desktop

Benefits:
- Organized learning
- Progress tracking
- Quick reference
- Structured approach
```

### Example 3: Project Starter Pack

```
Starting new project:
1. Clear old favorites (if any)
2. Search for project-relevant skills
3. Star: Testing, Documentation, API Design, etc.
4. Favorites tab = Project toolkit
5. Use throughout development
6. Share favorites list with team (export feature coming)

Benefits:
- Project-specific toolkit
- Team alignment
- Quick onboarding
- Consistent practices
```

## ⚙️ Technical Details

### Implementation

```swift
// Toggle favorite
func toggleFavorite(_ skill: SkillInfo) {
    var favorites = UserDefaults.standard.stringArray(forKey: "favorite_skills") ?? []
    
    if favorites.contains(skill.id) {
        favorites.removeAll { $0 == skill.id }
        // Remove from favorites
    } else {
        favorites.append(skill.id)
        // Add to favorites + save full data
    }
}

// Get all favorites
func getFavoriteSkills() -> [SkillInfo] {
    // Load IDs and reconstruct skills
}
```

### Storage Format

```json
{
  "favorite_skills": ["skill-1", "skill-2", "skill-3"],
  "favorite_skill_data_skill-1": {
    "id": "skill-1",
    "title": "Python Helper",
    "description": "...",
    "tags": ["python", "coding"],
    "githubUrl": "...",
    "addedAt": 1735405200.0
  }
}
```

## 🆚 Favorites vs Cache

Two different features:

| Feature | Favorites ⭐ | Cache 💾 |
|---------|-------------|---------|
| **Purpose** | Quick access | Offline content |
| **What's Saved** | Skill metadata | GitHub content |
| **Trigger** | Manual (star button) | Automatic (purple button) |
| **Icon** | Yellow star | Green checkmark |
| **Storage** | UserDefaults | UserDefaults |
| **Size** | ~1 KB per skill | ~5-50 KB per skill |
| **Use Case** | Organization | Performance |

You can have:
- ✅ Favorited but not cached
- ✅ Cached but not favorited  
- ✅ Both favorited AND cached (best!)
- ✅ Neither

## 🎨 Visual Indicators

### Star States

**☆ Empty Star** (Gray)
- Not favorited
- Click to add to favorites
- Default state

**⭐ Filled Star** (Yellow)
- Favorited
- Click to remove from favorites
- Shows you've saved it

### Combined Indicators

**✓ ⭐** - Cached + Favorited (Perfect!)
**✓ ☆** - Cached only
**⭐** - Favorited only
**No indicators** - Neither

## 🔮 Future Enhancements

Planned features:

- [ ] **Export Favorites** - Save to JSON file
- [ ] **Import Favorites** - Load from JSON file
- [ ] **Favorite Collections** - Multiple favorite lists
- [ ] **Sort Favorites** - By date, name, stars
- [ ] **Search Favorites** - Find in favorites
- [ ] **Favorite Stats** - Most used, last accessed
- [ ] **Sync Favorites** - Across devices (iCloud)
- [ ] **Share Favorites** - Share list with others

## 💡 Tips & Tricks

### Tip 1: Start Small
- Don't favorite everything
- Start with 5-10 essential skills
- Add more as needed
- Quality over quantity

### Tip 2: Regular Cleanup
- Review favorites monthly
- Remove unused ones
- Keep list fresh and relevant
- Clear All and restart if needed

### Tip 3: Combine with Cache
- Favorite a skill
- Click purple button to cache it
- Now you have both: organization + offline access
- Best of both worlds!

### Tip 4: Project Collections
- Use favorites for current project
- Clear when switching projects
- Quick project context switch
- Keeps focus sharp

### Tip 5: Learning Tracker
- Favorite skills you're learning
- Work through them systematically
- Remove when mastered
- Visual progress!

## 🐛 Troubleshooting

### Star button doesn't appear
- Check you're on Skills or Favorites tab
- Servers tab doesn't have stars
- Restart app if needed

### Favorites not saving
- Check UserDefaults permissions
- Verify app has write access
- Try Clear All and re-favorite

### Favorites disappeared
- Check you didn't click Clear All
- Verify app updated correctly
- Favorites survive restart normally

### Star not updating visually
- Click again (toggle)
- Switch tabs and back
- Restart app if persistent

## 📞 Support

Issues with Favorites feature:
- Check this guide first
- Verify storage location
- Try Clear All and restart
- Report bugs on GitHub

---

**Version**: 1.0.0 (with Favorites)  
**Released**: December 28, 2025  
**Feature**: Favorites Management ⭐  
**Author**: Bivex

