#!/bin/bash

# Test script for real SkillsMP API integration
# This tests the actual API calls with the real response format

echo "🧪 Testing Real SkillsMP API Integration"
echo "========================================="
echo

echo "This test requires a valid SkillsMP API key."
echo "Set it with: export SKILLSMP_API_KEY='your_key_here'"
echo

# Check if API key is set
if [ -z "$SKILLSMP_API_KEY" ]; then
    echo "❌ SKILLSMP_API_KEY environment variable not set"
    echo "Please set it and run again:"
    echo "export SKILLSMP_API_KEY='sk_live_your_api_key_here'"
    exit 1
fi

echo "✅ API key found"

# Test keyword search
echo
echo "1. Testing keyword search for 'coder':"
echo "   Command: swift run mcp-switcher search-skills coder --api-key $SKILLSMP_API_KEY --limit 5"

swift run mcp-switcher search-skills coder --api-key "$SKILLSMP_API_KEY" --limit 5 2>&1 | head -20

echo
echo "2. Testing AI search for 'web scraping':"
echo "   Command: swift run mcp-switcher search-skills-ai 'web scraping' --api-key $SKILLSMP_API_KEY"

swift run mcp-switcher search-skills-ai "web scraping" --api-key "$SKILLSMP_API_KEY" 2>&1 | head -15

echo
echo "3. Testing tray app compilation:"
echo "   Command: swift build --product mcp-tray"

if swift build --product mcp-tray >/dev/null 2>&1; then
    echo "✅ Tray app builds successfully"
else
    echo "❌ Tray app build failed"
fi

echo
echo "🎉 API integration test completed!"
