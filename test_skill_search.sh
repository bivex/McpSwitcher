#!/bin/bash

# Test script for SkillsMP skill search functionality
# This demonstrates how to use the new skill search features

echo "🧪 Testing SkillsMP Skill Search Features"
echo "=========================================="
echo

echo "1. Testing search-skills command without API key:"
echo "   Command: swift run mcp-switcher search-skills 'web development'"
echo "   Expected: Error about missing API key"
echo

# Test without API key
swift run mcp-switcher search-skills 'web development' 2>&1 || true
echo

echo "2. Testing with invalid API key:"
echo "   Command: swift run mcp-switcher search-skills 'web development' --api-key 'invalid_key'"
echo "   Expected: Authentication error"
echo

# Test with invalid API key
swift run mcp-switcher search-skills 'web development' --api-key 'invalid_key' 2>&1 || true
echo

echo "3. Testing help commands:"
echo "   Available commands:"
swift run mcp-switcher --help | grep -E "(search-skills|copy-skill)" | sed 's/^/   /'
echo

echo "4. Environment variable setup:"
echo "   To set API key permanently, add to your shell profile:"
echo "   export SKILLSMP_API_KEY='your_api_key_here'"
echo

echo "5. Usage examples:"
echo "   # Keyword search"
echo "   mcp-switcher search-skills 'SEO' --sort-by stars --limit 10"
echo
echo "   # AI semantic search"
echo "   mcp-switcher search-skills-ai 'How to create a web scraper'"
echo
echo "   # Copy skill to clipboard"
echo "   mcp-switcher copy-skill 'skill_id_here'"
echo

echo "✅ Test script completed!"
