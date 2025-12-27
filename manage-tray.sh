#!/bin/bash
# MCP Switcher Tray Auto-start Management Script

PLIST_FILE="$HOME/Library/LaunchAgents/com.mcpswitcher.tray.plist"

case "$1" in
    "start")
        echo "Starting MCP Switcher Tray..."
        launchctl load "$PLIST_FILE"
        echo "✓ MCP Switcher Tray started"
        ;;
    "stop")
        echo "Stopping MCP Switcher Tray..."
        launchctl unload "$PLIST_FILE"
        echo "✓ MCP Switcher Tray stopped"
        ;;
    "restart")
        echo "Restarting MCP Switcher Tray..."
        launchctl unload "$PLIST_FILE"
        sleep 1
        launchctl load "$PLIST_FILE"
        echo "✓ MCP Switcher Tray restarted"
        ;;
    "status")
        echo "MCP Switcher Tray status:"
        launchctl list | grep mcp || echo "Not running"
        ;;
    "enable")
        echo "Enabling auto-start for MCP Switcher Tray..."
        launchctl load "$PLIST_FILE"
        echo "✓ Auto-start enabled"
        ;;
    "disable")
        echo "Disabling auto-start for MCP Switcher Tray..."
        launchctl unload "$PLIST_FILE"
        echo "✓ Auto-start disabled"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|enable|disable}"
        echo ""
        echo "Commands:"
        echo "  start   - Start MCP Switcher Tray immediately"
        echo "  stop    - Stop MCP Switcher Tray"
        echo "  restart - Restart MCP Switcher Tray"
        echo "  status  - Show current status"
        echo "  enable  - Enable auto-start on login"
        echo "  disable - Disable auto-start on login"
        ;;
esac
