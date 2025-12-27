/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:09:03
 * Last Updated: 2025-12-27T20:09:30
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import ArgumentParser
import Domain
import Infrastructure
import Application

@main
struct MCPSwitcher: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mcp-switcher",
        abstract: "Manage MCP server configurations with ease",
        subcommands: [
            List.self,
            Enable.self,
            Disable.self,
            Toggle.self,
            Add.self,
            Remove.self,
            Export.self,
            Status.self,
            Import.self
        ]
    )

    func run() async throws {
        // This will never be called since we have subcommands
    }
}

// MARK: - List Command
struct List: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "List all MCP servers and their states"
    )
    
    @Flag(help: "Show only enabled servers")
    var enabledOnly: Bool = false
    
    @Flag(help: "Show detailed configuration information")
    var detailed: Bool = false
    
    func run() async throws {
        let db = try Database()
        let repo = SQLiteServerRepository(database: db)
        let useCase = ListServersUseCase(repository: repo)
        
        if detailed {
            let servers = try await useCase.executeDetailed(includeDisabled: !enabledOnly)
            print(formatServersDetailed(servers))
        } else {
            let servers = try await useCase.execute(includeDisabled: !enabledOnly)
            print(formatServers(servers))
        }
    }
    
    private func formatServers(_ servers: [ServerDTO]) -> String {
        guard !servers.isEmpty else {
            return "No servers found"
        }
        
        let header = "NAME".padding(toLength: 25, withPad: " ", startingAt: 0) +
                     "STATUS".padding(toLength: 15, withPad: " ", startingAt: 0) +
                     "CREATED"
        
        var lines = [header]
        lines.append(String(repeating: "-", count: 60))
        
        for server in servers {
            let status = server.isEnabled ? "✓ ENABLED" : "✗ DISABLED"
            let line = server.name.padding(toLength: 25, withPad: " ", startingAt: 0) +
                      status.padding(toLength: 15, withPad: " ", startingAt: 0) +
                      server.createdAt
            lines.append(line)
        }
        
        return lines.joined(separator: "\n")
    }
    
    private func formatServersDetailed(_ servers: [ServerDetailDTO]) -> String {
        guard !servers.isEmpty else {
            return "No servers found"
        }
        
        var output = ""
        for (index, server) in servers.enumerated() {
            output += """
            \(index + 1). \(server.name)
               ID: \(server.id)
               Status: \(server.isEnabled ? "✓ ENABLED" : "✗ DISABLED")
               Created: \(server.createdAt)
               Modified: \(server.modifiedAt)
            """
            
            if let desc = server.description {
                output += "\n   Description: \(desc)"
            }
            
            output += "\n   Configuration: \(formatConfig(server.configuration))\n\n"
        }
        
        return output
    }
    
    private func formatConfig(_ config: [String: AnyCodable]) -> String {
        return String(describing: config)
    }
}

// MARK: - Enable Command
struct Enable: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Enable an MCP server"
    )
    
    @Argument(help: "Name or ID of the server to enable")
    var serverName: String
    
    func run() async throws {
        let db = try Database()
        let repo = SQLiteServerRepository(database: db)
        let syncUseCase = SyncWithMCPJSONUseCase(repository: repo)
        let useCase = ToggleServerUseCase(repository: repo, syncUseCase: syncUseCase)

        // Try to find by name first, then by ID
        let servers = try await repo.findByName(serverName)
        let server = if let foundServer = servers.first {
            foundServer
        } else {
            try await repo.findById(serverName)
        }
        guard let server = server else {
            print("❌ Server '\(serverName)' not found")
            throw ExitCode.failure
        }

        let result = try await useCase.setEnabled(server.id, enabled: true)
        print("✓ Enabled: \(result.name)")
    }
}

// MARK: - Disable Command
struct Disable: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Disable an MCP server"
    )
    
    @Argument(help: "Name or ID of the server to disable")
    var serverName: String
    
    func run() async throws {
        let db = try Database()
        let repo = SQLiteServerRepository(database: db)
        let syncUseCase = SyncWithMCPJSONUseCase(repository: repo)
        let useCase = ToggleServerUseCase(repository: repo, syncUseCase: syncUseCase)

        // Try to find by name first, then by ID
        let servers = try await repo.findByName(serverName)
        let server = if let foundServer = servers.first {
            foundServer
        } else {
            try await repo.findById(serverName)
        }
        guard let server = server else {
            print("❌ Server '\(serverName)' not found")
            throw ExitCode.failure
        }

        let result = try await useCase.setEnabled(server.id, enabled: false)
        print("✓ Disabled: \(result.name)")
    }
}

// MARK: - Toggle Command
struct Toggle: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Toggle an MCP server (enable/disable)"
    )
    
    @Argument(help: "Name or ID of the server to toggle")
    var serverName: String
    
    func run() async throws {
        let db = try Database()
        let repo = SQLiteServerRepository(database: db)
        let syncUseCase = SyncWithMCPJSONUseCase(repository: repo)
        let useCase = ToggleServerUseCase(repository: repo, syncUseCase: syncUseCase)

        // Try to find by name first, then by ID
        let servers = try await repo.findByName(serverName)
        let server = if let foundServer = servers.first {
            foundServer
        } else {
            try await repo.findById(serverName)
        }
        guard let server = server else {
            print("❌ Server '\(serverName)' not found")
            throw ExitCode.failure
        }

        let result = try await useCase.execute(serverId: server.id)
        print("✓ Toggled \(result.name): \(result.isEnabled ? "ENABLED" : "DISABLED")")
    }
}

// MARK: - Export Command
struct Export: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Export enabled servers to JSON file"
    )
    
    @Option(help: "Output file path (default: mcp-servers.json)")
    var output: String = "mcp-servers.json"
    
    @Flag(help: "Include export metadata")
    var withMetadata: Bool = false
    
    func run() async throws {
        let db = try Database()
        let repo = SQLiteServerRepository(database: db)
        let useCase = ExportConfigurationUseCase(repository: repo)
        
        let exported = try await useCase.exportToFile(output, includeMetadata: withMetadata)
        print("✓ Exported \(exported.enabledServersCount) enabled server(s) to: \(output)")
        if exported.enabledServersCount == 0 {
            print("  ℹ No enabled servers to export")
        }
    }
}

// MARK: - Status Command
struct Status: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Show overall status summary"
    )
    
    func run() async throws {
        let db = try Database()
        let repo = SQLiteServerRepository(database: db)
        
        let total = try await repo.count()
        let enabled = try await repo.enabledCount()
        let disabled = total - enabled
        
        print("""
        MCP Switcher Status
        ═══════════════════════════════════════
        Total Servers:    \(total)
        Enabled:          \(enabled) ✓
        Disabled:         \(disabled) ✗
        """)
    }
}

// MARK: - Add Command
struct Add: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Add a new MCP server"
    )
    
    @Argument(help: "Name of the server")
    var name: String
    
    @Option(help: "Command to execute (for command-based servers)")
    var command: String?
    
    @Option(help: "Command arguments (comma-separated)")
    var args: String?
    
    @Option(help: "Environment variables (KEY=VALUE, comma-separated)")
    var env: String?
    
    @Option(help: "URL endpoint (for URL-based servers)")
    var url: String?
    
    @Option(help: "HTTP headers (KEY=VALUE, comma-separated)")
    var headers: String?
    
    @Option(help: "Server description")
    var description: String?
    
    @Flag(help: "Enable the server immediately")
    var enable: Bool = false
    
    func run() async throws {
        // Parse configuration
        let config: ServerConfiguration
        
        if let url = url {
            let headerDict = parseKeyValuePairs(headers)
            config = .url(url: url, headers: headerDict)
        } else if let command = command {
            let argsList = args?.split(separator: ",").map(String.init) ?? []
            let envDict = parseKeyValuePairs(env)
            config = .command(command: command, args: argsList, env: envDict)
        } else {
            print("❌ Either --command or --url must be provided")
            throw ExitCode.failure
        }
        
        let db = try Database()
        let repo = SQLiteServerRepository(database: db)
        let useCase = CreateServerUseCase(repository: repo)
        
        let input = CreateServerInput(
            name: name,
            configuration: config,
            enabled: enable,
            description: description
        )
        
        do {
            let server = try await useCase.execute(input: input)
            print("✓ Created server: \(server.name)")
        } catch {
            print("❌ Failed to create server: \(error)")
            throw ExitCode.failure
        }
    }
    
    private func parseKeyValuePairs(_ input: String?) -> [String: String] {
        guard let input = input else { return [:] }
        
        var dict: [String: String] = [:]
        let pairs = input.split(separator: ",")
        
        for pair in pairs {
            let parts = pair.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                dict[String(parts[0].trimmingCharacters(in: .whitespaces))] =
                    String(parts[1].trimmingCharacters(in: .whitespaces))
            }
        }
        
        return dict
    }
}

// MARK: - Remove Command
struct Remove: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Remove an MCP server"
    )
    
    @Argument(help: "Name or ID of the server to remove")
    var serverName: String
    
    @Flag(help: "Skip confirmation prompt")
    var force: Bool = false
    
    func run() async throws {
        let db = try Database()
        let repo = SQLiteServerRepository(database: db)
        
        // Try to find by name first, then by ID
        let servers = try await repo.findByName(serverName)
        let server = if let foundServer = servers.first {
            foundServer
        } else {
            try await repo.findById(serverName)
        }
        guard let server = server else {
            print("❌ Server '\(serverName)' not found")
            throw ExitCode.failure
        }
        
        if !force {
            print("⚠️  Are you sure you want to delete '\(server.name)'? (yes/no)")
            let response = readLine() ?? ""
            guard response.lowercased() == "yes" else {
                print("Cancelled")
                return
            }
        }
        
        let useCase = DeleteServerUseCase(repository: repo)
        try await useCase.execute(serverId: server.id)
        print("✓ Removed: \(server.name)")
    }
}

// MARK: - Import Command
struct Import: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Import MCP servers from JSON file"
    )

    @Argument(help: "Path to JSON file containing server configurations")
    var jsonFile: String

    @Flag(help: "Skip existing servers (don't overwrite)")
    var skipExisting: Bool = false

    @Flag(help: "Enable all imported servers by default")
    var enableAll: Bool = false

    func run() async throws {
        let db = try Database()
        let repo = SQLiteServerRepository(database: db)
        let useCase = ImportFromJSONUseCase(repository: repo)

        let result = try await useCase.execute(
            jsonFile: jsonFile,
            skipExisting: skipExisting,
            enableAll: enableAll
        )

        print("✓ Import completed:")
        print("  - Added: \(result.added)")
        print("  - Updated: \(result.updated)")
        print("  - Skipped: \(result.skipped)")
        print("  - Errors: \(result.errors.count)")

        if !result.errors.isEmpty {
            print("\n❌ Errors:")
            for error in result.errors {
                print("  - \(error)")
            }
        }
    }
}

