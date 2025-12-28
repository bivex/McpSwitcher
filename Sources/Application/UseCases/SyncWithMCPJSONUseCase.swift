/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:56:00
 * Last Updated: 2025-12-28T14:10:50
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import Domain
import Infrastructure

/// Result of sync operation
public struct SyncResult {
    public let added: Int
    public let removed: Int
    public let errors: [String]

    public init(added: Int = 0, removed: Int = 0, errors: [String] = []) {
        self.added = added
        self.removed = removed
        self.errors = errors
    }
}

/// Use Case: Sync enabled MCP servers with mcp.json file
public struct SyncWithMCPJSONUseCase {
    let repository: ServerRepository
    let mcpJSONPath: String

    public init(repository: ServerRepository, mcpJSONPath: String = "/Users/\(NSUserName())/.cursor/mcp.json") {
        self.repository = repository
        self.mcpJSONPath = mcpJSONPath
    }

    /// Sync all enabled servers to mcp.json
    public func syncEnabledServers() async throws -> SyncResult {
        // Get all enabled servers from database
        let allServers = try await repository.findAll()
        let enabledServers = allServers.filter { $0.isEnabled }

        // Read current mcp.json
        let currentJSON = try readCurrentMCPJSON()

        // Create new mcpServers dictionary with only enabled servers
        var newMcpServers: [String: [String: Any]] = [:]

        for server in enabledServers {
            newMcpServers[server.name] = server.configuration.toDictionary()
        }

        // Update JSON structure
        var updatedJSON = currentJSON
        updatedJSON["mcpServers"] = newMcpServers

        // Write back to file
        try writeMCPJSON(updatedJSON)

        let removedCount = (currentJSON["mcpServers"] as? [String: Any])?.count ?? 0 - newMcpServers.count

        return SyncResult(
            added: newMcpServers.count,
            removed: max(0, removedCount),
            errors: []
        )
    }

    /// Sync a specific server (add if enabled, remove if disabled)
    public func syncServer(_ server: MCPServer) async throws -> SyncResult {
        var result = SyncResult()

        if server.isEnabled {
            // Add server to JSON
            try addServerToJSON(server)
            result = SyncResult(added: 1, removed: 0, errors: [])
        } else {
            // Remove server from JSON
            let removed = try removeServerFromJSON(server.name)
            result = SyncResult(added: 0, removed: removed ? 1 : 0, errors: [])
        }

        return result
    }

    private func readCurrentMCPJSON() throws -> [String: Any] {
        guard FileManager.default.fileExists(atPath: mcpJSONPath) else {
            // Create new JSON structure if file doesn't exist
            return ["mcpServers": [:]]
        }

        let data = try Data(contentsOf: URL(fileURLWithPath: mcpJSONPath))
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

        guard let dict = jsonObject as? [String: Any] else {
            throw DomainError.invalidConfiguration("Invalid JSON structure")
        }

        return dict
    }

    private func writeMCPJSON(_ json: [String: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        try data.write(to: URL(fileURLWithPath: mcpJSONPath), options: [.atomic])
    }

    private func addServerToJSON(_ server: MCPServer) throws {
        var currentJSON = try readCurrentMCPJSON()

        // Ensure mcpServers key exists
        if currentJSON["mcpServers"] == nil {
            currentJSON["mcpServers"] = [:]
        }

        guard var mcpServers = currentJSON["mcpServers"] as? [String: Any] else {
            throw DomainError.invalidConfiguration("Invalid mcpServers structure")
        }

        // Add server configuration
        mcpServers[server.name] = server.configuration.toDictionary()

        // Update and write back
        currentJSON["mcpServers"] = mcpServers
        try writeMCPJSON(currentJSON)
    }

    private func removeServerFromJSON(_ serverName: String) throws -> Bool {
        var currentJSON = try readCurrentMCPJSON()

        guard var mcpServers = currentJSON["mcpServers"] as? [String: Any] else {
            return false // No mcpServers section
        }

        let existed = mcpServers[serverName] != nil
        mcpServers.removeValue(forKey: serverName)

        // Update and write back
        currentJSON["mcpServers"] = mcpServers
        try writeMCPJSON(currentJSON)

        return existed
    }
}
