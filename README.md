# MCP Switcher – User Guide

**Version:** 1.0  
**Date:** December 2025  
**Last Updated:** 2025-12-27  
**Status:** Ready for Use

<img width="443" height="560" alt="" src="https://github.com/user-attachments/assets/093429a8-182c-425e-9a4d-550c72b46ba1" />


<img width="563" height="699" alt="" src="https://github.com/user-attachments/assets/f7847bcb-6eb1-4b0b-8cc7-68084865a408" />


---

## 📖 Introduction

### Purpose of This Document

This guide explains how to install, configure, and use **MCP Switcher**—a CLI tool for managing MCP (Model Context Protocol) server configurations. You will learn how to:

- Install the application on your system
- Create and manage MCP server entries
- Enable or disable servers without manual JSON editing
- Export clean configurations for use with Cursor, Claude, or other MCP-compatible tools
- Troubleshoot common issues

### Scope

This document covers:
- **Installation** on macOS 13.0 and later
- **Core operations** (listing, toggling, creating, removing servers)
- **Configuration export** and integration with Cursor/Claude
- **Troubleshooting** common problems
- **Data backup and recovery**

This document does **not** cover:
- Internal architecture or design (see `ARCHITECTURE.md`)
- Swift development or building from source (see `Sources/` directory)
- Contributing to the project (see `CONTRIBUTING.md` if provided)

### Target Audience

- **End Users:** Developers and AI engineers who manage multiple MCP servers
- **System Administrators:** Teams managing shared MCP configurations
- **Cursor/Claude Users:** Anyone integrating MCP Switcher with AI tooling

**Prerequisite Knowledge:** Basic command-line interface (CLI) experience. No advanced technical knowledge required.

### How to Use This Document

1. **Start with "Concept of Operations"** if this is your first time using MCP Switcher.
2. **Go to "Installation and Setup"** if you need to install the application.
3. **Use "Task-Based Procedures"** to find instructions for specific actions (enable a server, export configuration, etc.).
4. **Check "Troubleshooting"** if you encounter problems.
5. **Refer to the "Glossary"** for unfamiliar terms.

---

## 🎯 Concept of Operations

### What Are MCP Servers?

MCP (Model Context Protocol) is a protocol that allows AI models and tools to interact with external data sources and services. An **MCP Server** is a remote or local endpoint that provides MCP-compatible functionality.

**Examples:**
- A local command that runs code analysis
- A remote API endpoint that retrieves data
- A service that provides file system access
- A tool that connects to a database

### The Problem: Manual Configuration

Normally, to use MCP servers with tools like Cursor or Claude, you must:

1. Edit a JSON configuration file manually
2. Ensure correct JSON syntax (one mistake breaks everything)
3. Manage multiple server entries without breaking the structure
4. Re-generate the file every time you enable or disable a server

This is **error-prone and time-consuming**.

### The MCP Switcher Solution

MCP Switcher **eliminates manual JSON editing** by providing a simple database and CLI commands:

```
┌─────────────────────────────────────────┐
│ You: "mcp-switcher enable github"       │
└──────────────┬──────────────────────────┘
               ↓
┌──────────────────────────────────────────┐
│ MCP Switcher Updates SQLite Database     │
└──────────────┬──────────────────────────┘
               ↓
┌──────────────────────────────────────────┐
│ You: "mcp-switcher export"               │
└──────────────┬──────────────────────────┘
               ↓
┌──────────────────────────────────────────┐
│ Clean, Valid JSON Export Generated ✓     │
└──────────────────────────────────────────┘
```

### Typical Workflow

1. **Add servers** once (command-based or URL-based)
2. **Enable/disable** servers as needed via CLI
3. **Export** the configuration when ready to use
4. **Point Cursor/Claude** to the exported file
5. **Repeat step 2** whenever you need to change which servers are active

### Key Benefits

| Benefit | How It Helps |
|---------|--------------|
| **No JSON errors** | Automatic validation and generation |
| **Version history** | All servers stored in SQLite; easy to revert |
| **Command-line speed** | One-command enable/disable instead of file editing |
| **Clean exports** | Only enabled servers appear in generated JSON |
| **Backup support** | Auto-backups before each export |

---

## 🚀 Installation and Setup

### System Requirements

- **OS:** macOS 13.0 or later
- **Swift:** Swift 5.9 or later
- **Disk Space:** ~50 MB (binary + database)
- **Network:** Internet access for building from source (via Swift Package Manager)

### Installation Steps

#### Step 1: Download and Build

```bash
# Clone the repository or navigate to the project directory
cd /Volumes/External/Code/McpSwitcher

# Build the application in release mode
swift build -c release

# The binary will be at: .build/release/mcp-switcher
```

#### Step 2: Verify Installation

```bash
# Test the binary works
./.build/release/mcp-switcher --version

# Expected output:
# mcp-switcher version 1.0
```

#### Step 3: Install to System Path (Optional)

To use `mcp-switcher` from any terminal, install it to your PATH:

```bash
# Create symlink to /usr/local/bin
ln -s $(pwd)/.build/release/mcp-switcher /usr/local/bin/mcp-switcher

# Verify it's accessible
mcp-switcher --version
```

If you prefer not to create a symlink, you can always run the full path:
```bash
/Volumes/External/Code/McpSwitcher/.build/release/mcp-switcher
```

#### Step 4: Verify Database Location

MCP Switcher automatically creates a database directory on first run:

```bash
# Database location (created automatically):
~/.config/McpSwitcher/mcp-switcher.db

# Backup directory (created automatically):
~/.config/McpSwitcher/backups/

# Verify the directory exists after first run:
ls -la ~/.config/McpSwitcher/
```

### Troubleshooting Installation

**Problem:** `command not found: swift`
- **Solution:** Install Xcode Command Line Tools: `xcode-select --install`

**Problem:** Build fails with "module not found"
- **Solution:** Ensure you're in the correct directory: `cd /Volumes/External/Code/McpSwitcher`

**Problem:** Permission denied when creating symlink
- **Solution:** Use `sudo` and verify the path: `sudo ln -s $(pwd)/.build/release/mcp-switcher /usr/local/bin/mcp-switcher`

---

## 📚 Task-Based Procedures

This section provides step-by-step instructions for common tasks. Each procedure includes preconditions, numbered steps, and expected results.

### Task 1: List All Servers

**Purpose:** View all MCP servers in your database and their current status.

**Preconditions:**
- MCP Switcher is installed
- You have added at least one server (or imported from a JSON file)

**Steps:**

1. Open a terminal
2. Run the list command:
   ```bash
   mcp-switcher list
   ```

**Expected Result:**

```
NAME                     STATUS          CREATED
─────────────────────────────────────────────────────────────
github                   ✓ ENABLED       2025-12-27T10:30:00Z
context7                 ✗ DISABLED      2025-12-27T10:30:00Z
plane                    ✓ ENABLED       2025-12-27T10:30:00Z
```

**Related Commands:**
- `mcp-switcher list --enabled-only` → Show only enabled servers
- `mcp-switcher list --detailed` → Show full configuration for each server

---

### Task 2: Enable a Server

**Purpose:** Activate a server so it will be included in JSON exports.

**Preconditions:**
- The server exists in your database (check with `list`)
- The server is currently disabled

**Steps:**

1. Open a terminal
2. Run the enable command with the server name:
   ```bash
   mcp-switcher enable github
   ```
   
   Or use the server ID (for servers with non-unique names):
   ```bash
   mcp-switcher enable "550e8400-e29b-41d4-a716-446655440000"
   ```

**Expected Result:**

```
✓ Server 'github' has been enabled.
```

The server is now active and will appear in JSON exports.

---

### Task 3: Disable a Server

**Purpose:** Deactivate a server so it will not be included in JSON exports.

**Preconditions:**
- The server exists in your database
- The server is currently enabled

**Steps:**

1. Open a terminal
2. Run the disable command:
   ```bash
   mcp-switcher disable context7
   ```

**Expected Result:**

```
✓ Server 'context7' has been disabled.
```

The server remains in the database but is excluded from exports.

---

### Task 4: Toggle a Server (Enable ↔ Disable)

**Purpose:** Quickly switch a server between enabled and disabled states.

**Preconditions:**
- The server exists in your database

**Steps:**

1. Open a terminal
2. Run the toggle command:
   ```bash
   mcp-switcher toggle plane
   ```

**Expected Result:**

If the server was enabled:
```
✓ Server 'plane' has been disabled.
```

If the server was disabled:
```
✓ Server 'plane' has been enabled.
```

---

### Task 5: View Status Summary

**Purpose:** Get a quick overview of all servers and their status.

**Preconditions:**
- At least one server exists in your database

**Steps:**

1. Open a terminal
2. Run the status command:
   ```bash
   mcp-switcher status
   ```

**Expected Result:**

```
MCP Switcher Status
═══════════════════════════════════════
Total Servers:    10
Enabled:          7 ✓
Disabled:         3 ✗
```

---

### Task 6: Add a New Command-Based Server

**Purpose:** Create a new server that runs a local command.

**Preconditions:**
- The command you want to run is available on your system
- You know the command name and any required arguments

**Steps:**

1. Open a terminal
2. Run the add command with the required parameters:
   ```bash
   mcp-switcher add myserver \
     --command "npx" \
     --args "@makeplane/plane-mcp-server" \
     --env "API_KEY=secret,API_HOST=https://example.com" \
     --description "My custom server"
   ```

**Parameter Explanation:**
- `myserver` → Name for your server (must be unique)
- `--command` → The executable to run (e.g., `npx`, `python`, `node`)
- `--args` → Arguments to pass to the command (can be multiple)
- `--env` → Environment variables as comma-separated `KEY=VALUE` pairs (optional)
- `--description` → Human-readable description (optional)

**Expected Result:**

```
✓ Server 'myserver' created successfully.
ID: 550e8400-e29b-41d4-a716-446655440000
```

---

### Task 7: Add a New URL-Based Server

**Purpose:** Create a new server that connects to a remote HTTP endpoint.

**Preconditions:**
- You have the URL to an MCP-compatible HTTP endpoint
- You know any required headers (e.g., API keys)

**Steps:**

1. Open a terminal
2. Run the add command with the URL parameters:
   ```bash
   mcp-switcher add myapi \
     --url "https://api.example.com/mcp" \
     --headers "Authorization=Bearer token123,X-API-Key=secret" \
     --description "Remote MCP endpoint"
   ```

**Parameter Explanation:**
- `myapi` → Name for your server (must be unique)
- `--url` → The HTTP endpoint URL
- `--headers` → HTTP headers as comma-separated `KEY=VALUE` pairs (optional)
- `--description` → Human-readable description (optional)

**Expected Result:**

```
✓ Server 'myapi' created successfully.
ID: 550e8400-e29b-41d4-a716-446655440000
```

---

### Task 8: Remove a Server

**Purpose:** Delete a server from your database.

**Preconditions:**
- The server exists in your database
- You have confirmed you no longer need this server

**Steps:**

1. Open a terminal
2. Run the remove command:
   ```bash
   mcp-switcher remove myserver
   ```
   
   The system will ask for confirmation:
   ```
   Are you sure you want to remove 'myserver'? (yes/no)
   ```

3. Type `yes` and press Enter

**Alternative:** Skip confirmation with the `--force` flag:
```bash
mcp-switcher remove myserver --force
```

**Expected Result:**

```
✓ Server 'myserver' has been removed.
```

The server is deleted permanently and cannot be recovered from the database.

---

### Task 9: Export Configuration to JSON

**Purpose:** Generate a clean JSON file containing all enabled servers for use with Cursor, Claude, or other tools.

**Preconditions:**
- At least one server is enabled
- You know where you want to save the JSON file

**Steps:**

1. Open a terminal
2. Run the export command:
   ```bash
   mcp-switcher export --output ~/.cursor/mcp-servers.json
   ```

3. Verify the file was created:
   ```bash
   ls -la ~/.cursor/mcp-servers.json
   ```

**Expected Result:**

The file is created with the following structure:

```json
{
  "mcpServers": {
    "github": {
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer github_pat_..."
      }
    },
    "plane": {
      "command": "npx",
      "args": ["-y", "@makeplane/plane-mcp-server"],
      "env": {
        "PLANE_API_KEY": "...",
        "PLANE_API_HOST_URL": "..."
      }
    }
  }
}
```

**Related Options:**
- `--with-metadata` → Include additional metadata (timestamps, descriptions)

---

### Task 10: Use Exported Configuration with Cursor

**Purpose:** Integrate the exported MCP Switcher configuration into Cursor's MCP settings.

**Preconditions:**
- You have exported a configuration file (see Task 9)
- Cursor is installed on your system

**Steps:**

1. Export your configuration:
   ```bash
   mcp-switcher export --output ~/.cursor/mcp-servers.json
   ```

2. Open Cursor settings (or configuration file)

3. Reference the exported JSON in your MCP configuration:
   ```json
   {
     "mcpServers": {
       // Reference the exported file or copy the contents
     }
   }
   ```

4. Restart Cursor or reload settings

5. Verify the servers are available in Cursor's MCP interface

**Note:** Refer to Cursor's documentation for exact configuration steps, as they may vary by version.

---

### Task 11: Import Servers from an Existing JSON File

**Purpose:** Migrate existing MCP server configurations from another tool into MCP Switcher.

**Preconditions:**
- You have an existing MCP server JSON file
- The file follows the standard MCP configuration format

**Steps:**

1. Open a terminal
2. Run the import command:
   ```bash
   mcp-switcher import ~/my-existing-servers.json
   ```

3. Review the import summary:
   ```
   ✓ Imported 3 servers:
   - github
   - plane
   - context7
   ```

**Expected Result:**

All servers from the JSON file are added to your MCP Switcher database. They are imported as disabled by default; enable them with the `enable` command (see Task 2).

---

## 💾 Data Management

### Where Your Data Is Stored

MCP Switcher stores all server configurations in a SQLite database:

```
~/.config/McpSwitcher/
├── mcp-switcher.db          (Main database)
├── backups/                 (Automatic backups)
│   ├── mcp-switcher-2025-12-27-10-30.db.backup
│   ├── mcp-switcher-2025-12-27-14-00.db.backup
│   └── ...
```

**Key Details:**
- The `~/.config/` directory is automatically created on your system if it doesn't exist
- The database contains all server names, configurations, and enabled/disabled status
- Backups are created automatically before each export

### Backup and Recovery

**Automatic Backups:**

MCP Switcher creates an automatic backup before each export operation. Backups are stored in `~/.config/McpSwitcher/backups/`.

**Manual Backup:**

To manually back up your database, copy it:

```bash
cp ~/.config/McpSwitcher/mcp-switcher.db ~/my-manual-backup.db
```

**Recovery:**

If you need to restore from a backup:

1. Stop any running MCP Switcher processes
2. Restore the backup:
   ```bash
   cp ~/my-manual-backup.db ~/.config/McpSwitcher/mcp-switcher.db
   ```
3. Verify with `mcp-switcher list`

---

## 🔧 Troubleshooting and Error Resolution

### "Server not found" Error

**Problem:** You run `mcp-switcher enable myserver` and get an error.

**Causes:**
- The server name is misspelled
- The server doesn't exist in your database
- You're using a partial name instead of the exact name

**Solutions:**

1. **Check spelling:** List all servers to see exact names
   ```bash
   mcp-switcher list
   ```

2. **Use the full server ID** if the name is ambiguous:
   ```bash
   mcp-switcher enable "550e8400-e29b-41d4-a716-446655440000"
   ```

3. **Create the server** if it doesn't exist:
   ```bash
   mcp-switcher add myserver --command "npx" --args "my-package"
   ```

---

### "Database locked" Error

**Problem:** You get a "database locked" or "database is busy" error.

**Causes:**
- Another instance of MCP Switcher is running
- A background process is accessing the database
- The database file is corrupted

**Solutions:**

1. **Check for running processes:**
   ```bash
   ps aux | grep mcp-switcher
   ```

2. **Kill any running processes:**
   ```bash
   pkill -f mcp-switcher
   ```

3. **Wait 5–10 seconds** and try again

4. **If the problem persists,** restore from a recent backup (see "Data Management")

---

### JSON Export Is Empty or Missing Servers

**Problem:** You run `mcp-switcher export` but the resulting JSON has no servers or is missing some you expected.

**Causes:**
- No servers are enabled
- Servers are disabled and filtered out of the export
- The export command syntax is incorrect

**Solutions:**

1. **Check how many servers are enabled:**
   ```bash
   mcp-switcher list --enabled-only
   ```

2. **If no servers appear,** enable at least one:
   ```bash
   mcp-switcher list                    # See all servers
   mcp-switcher enable <server-name>    # Enable a server
   ```

3. **Run the export again:**
   ```bash
   mcp-switcher export --output my-config.json
   ```

4. **Verify the file exists:**
   ```bash
   cat my-config.json
   ```

---

### Swift Build Fails

**Problem:** `swift build -c release` fails with an error.

**Causes:**
- Swift is not installed or outdated
- You're not in the correct directory
- Dependency download failed due to network issues

**Solutions:**

1. **Check Swift version:**
   ```bash
   swift --version
   ```
   
   If missing, install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

2. **Verify you're in the correct directory:**
   ```bash
   pwd
   # Should show: /Volumes/External/Code/McpSwitcher
   ```

3. **Clean and rebuild:**
   ```bash
   rm -rf .build
   swift build -c release
   ```

4. **Check internet connection** (required for downloading Swift dependencies)

---

### Permission Denied When Installing to /usr/local/bin

**Problem:** `ln -s` fails with "Permission denied" when trying to create a symlink in `/usr/local/bin`.

**Solution:**

Use `sudo` to create the symlink with elevated privileges:

```bash
sudo ln -s $(pwd)/.build/release/mcp-switcher /usr/local/bin/mcp-switcher
```

You may be prompted for your password.

---

### No Output from Commands

**Problem:** Running `mcp-switcher list` or other commands produces no output.

**Causes:**
- The application has no servers in the database
- The database is inaccessible or corrupted
- The command syntax is wrong

**Solutions:**

1. **Check the application version** (ensures it's working):
   ```bash
   mcp-switcher --version
   ```

2. **If no output,** the binary may not be working. Rebuild:
   ```bash
   cd /Volumes/External/Code/McpSwitcher
   swift build -c release
   ./.build/release/mcp-switcher list
   ```

3. **Verify the database exists:**
   ```bash
   ls -la ~/.config/McpSwitcher/mcp-switcher.db
   ```

4. **If the database is missing,** add a server to initialize it:
   ```bash
   mcp-switcher add test-server --command "echo" --args "hello"
   ```

---

## 🗑️ Uninstallation

### When to Uninstall

You may want to uninstall MCP Switcher if:
- You no longer need to manage MCP servers
- You're switching to a different tool or workflow
- You want to perform a fresh installation

### Uninstallation Steps

#### Step 1: Remove the Symlink (if installed)

If you created a symlink in `/usr/local/bin`:

```bash
sudo rm /usr/local/bin/mcp-switcher
```

#### Step 2: Remove the Binary

If you want to remove the built binary:

```bash
cd /Volumes/External/Code/McpSwitcher
rm -rf .build
```

#### Step 3: Remove the Database (Optional)

**Warning:** This permanently deletes all your MCP Switcher server configurations. Only do this if you no longer need them.

```bash
rm -rf ~/.config/McpSwitcher/
```

If you want to keep your data, back it up first:

```bash
cp -r ~/.config/McpSwitcher/ ~/mcp-switcher-backup/
```

#### Step 4: Verify Removal

```bash
which mcp-switcher
# Should output: not found
```

---

## 📖 Glossary

**API Key**  
A secret token used to authenticate requests to a remote service. Do not share API keys publicly.

**Backup**  
A copy of your database file. MCP Switcher creates automatic backups before each export.

**CLI (Command-Line Interface)**  
A text-based interface where you type commands (e.g., `mcp-switcher list`).

**Database**  
A structured file that stores all your MCP server configurations. MCP Switcher uses SQLite.

**Enabled Server**  
A server that is active and will be included in JSON exports.

**Disabled Server**  
A server that is inactive and will not be included in JSON exports.

**Export**  
The process of generating a clean JSON file from your database containing only enabled servers.

**Header (HTTP)**  
Metadata sent with HTTP requests, often including authentication credentials.

**JSON**  
JavaScript Object Notation—a text format for representing structured data.

**MCP (Model Context Protocol)**  
A protocol that allows AI models and tools to interact with external services and data sources.

**MCP Server**  
An endpoint (local command or remote URL) that provides MCP-compatible functionality.

**Symlink**  
A shortcut to a file or directory. Used to make `mcp-switcher` accessible from anywhere in the terminal.

**SQLite**  
A lightweight database system used by MCP Switcher to store configurations locally.

**UUID**  
Universally Unique Identifier—a long string (e.g., `550e8400-e29b-41d4-a716-446655440000`) that uniquely identifies a server.

---

## 🔍 Index

- **A**
  - Add a new server: Task 6, Task 7
  - Backup and recovery: Data Management section

- **B**
  - Backup: Glossary; Data Management section

- **C**
  - CLI: Glossary; Installation and Setup section
  - Command-based server: Task 6
  - Cursor integration: Task 10; Concept of Operations section

- **D**
  - Database: Data Management section; Glossary
  - Disable a server: Task 3
  - Troubleshooting: Troubleshooting section

- **E**
  - Enable a server: Task 2
  - Export configuration: Task 9; Concept of Operations section

- **I**
  - Installation: Installation and Setup section
  - Import servers: Task 11

- **L**
  - List servers: Task 1

- **R**
  - Remove a server: Task 8

- **S**
  - Status summary: Task 5
  - Symlink: Installation and Setup section; Glossary

- **T**
  - Toggle a server: Task 4
  - Troubleshooting: Troubleshooting and Error Resolution section

- **U**
  - Uninstallation: Uninstallation section
  - URL-based server: Task 7

---

## 📞 Getting Help

If you encounter issues not covered in this guide:

1. **Check the Troubleshooting section** above for common problems
2. **Review the Glossary** for unfamiliar terms
3. **Use the Index** to find information quickly
4. **Run `mcp-switcher --help`** for command-line help
5. **Contact the developers** via the project repository

---

## 📄 License

MIT

---

## 📝 Document Information

**Document Type:** User Guide and Installation Guide  
**Audience:** End users, developers, system administrators  
**Last Reviewed:** 2025-12-27  
**Next Review Date:** Recommend quarterly or with each software release  

For architecture, design, and contribution information, see separate documentation files (ARCHITECTURE.md, CONTRIBUTING.md).

---

**Made with ❤️ for developers who appreciate clean, simple tools**
