/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:31:18
 * Last Updated: 2025-12-27T20:31:18
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import Domain
import Infrastructure

/// Result of import operation
public struct ImportResult {
    public let added: Int
    public let updated: Int
    public let skipped: Int
    public let errors: [String]

    public init(added: Int = 0, updated: Int = 0, skipped: Int = 0, errors: [String] = []) {
        self.added = added
        self.updated = updated
        self.skipped = skipped
        self.errors = errors
    }
}

/// Use Case: Import MCP servers from JSON file
public struct ImportFromJSONUseCase {
    let repository: ServerRepository

    public init(repository: ServerRepository) {
        self.repository = repository
    }

    /// Auto-import from Cursor MCP configuration file
    public func autoImportFromCursorMCP() async throws -> ImportResult {
        let cursorMCPPath = "/Users/\(NSUserName())/.cursor/mcp.json"

        // Check if file exists
        guard FileManager.default.fileExists(atPath: cursorMCPPath) else {
            return ImportResult() // No file to import
        }

        // Import with skip existing servers and don't enable them
        return try await execute(jsonFile: cursorMCPPath, skipExisting: true, enableAll: false)
    }

    /// Execute: Import servers from JSON file
    /// - Parameters:
    ///   - jsonFile: Path to JSON file
    ///   - skipExisting: Skip servers that already exist
    ///   - enableAll: Enable all imported servers
    /// - Returns: ImportResult with statistics
    /// - Throws: DomainError if file reading or parsing fails
    public func execute(jsonFile: String, skipExisting: Bool, enableAll: Bool) async throws -> ImportResult {
        // Read and parse JSON file
        let jsonData = try readJSONFile(at: jsonFile)
        let serverConfigs = try parseServerConfigurations(from: jsonData)

        var result = ImportResult()
        var errors: [String] = []

        for (name, configDict) in serverConfigs {
            do {
                let configuration = try ServerConfiguration.fromDictionary(configDict)

                // Check if server already exists
                let existing = try await repository.findByName(name)

                if !existing.isEmpty {
                    if skipExisting {
                        result = ImportResult(
                            added: result.added,
                            updated: result.updated,
                            skipped: result.skipped + 1,
                            errors: result.errors
                        )
                        continue
                    } else {
                        // Update existing server
                        let existingServer = existing[0]
                        let updatedServer = try MCPServer(
                            id: existingServer.id,
                            name: name,
                            configuration: configuration,
                            isEnabled: enableAll ? true : existingServer.isEnabled,
                            createdAt: existingServer.createdAt,
                            modifiedAt: Date(),
                            description: existingServer.description
                        )
                        try await repository.save(updatedServer)
                        result = ImportResult(
                            added: result.added,
                            updated: result.updated + 1,
                            skipped: result.skipped,
                            errors: result.errors
                        )
                    }
                } else {
                    // Create new server
                    let newServer = try MCPServer(
                        name: name,
                        configuration: configuration,
                        isEnabled: enableAll,
                        description: nil
                    )
                    try await repository.save(newServer)
                    result = ImportResult(
                        added: result.added + 1,
                        updated: result.updated,
                        skipped: result.skipped,
                        errors: result.errors
                    )
                }
            } catch {
                errors.append("Failed to import '\(name)': \(error.localizedDescription)")
            }
        }

        return ImportResult(
            added: result.added,
            updated: result.updated,
            skipped: result.skipped,
            errors: errors
        )
    }

    private func readJSONFile(at path: String) throws -> Data {
        let url = URL(fileURLWithPath: path)
        return try Data(contentsOf: url)
    }

    private func parseServerConfigurations(from data: Data) throws -> [String: [String: Any]] {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

        // Handle different JSON formats
        if let dict = jsonObject as? [String: Any] {
            // Check if it's wrapped in "servers" key (from export with metadata)
            if let servers = dict["servers"] as? [String: [String: Any]] {
                return servers
            }
            // Check if it's wrapped in "mcpServers" key (Cursor MCP format)
            if let servers = dict["mcpServers"] as? [String: [String: Any]] {
                return servers
            }
            // Assume it's a direct server configuration dictionary
            // Each key is a server name, each value should be a server config dict
            var result: [String: [String: Any]] = [:]
            for (key, value) in dict {
                if let configDict = value as? [String: Any] {
                    result[key] = configDict
                } else {
                    throw DomainError.invalidConfiguration("Server configuration for '\(key)' must be an object")
                }
            }
            return result
        }

        throw DomainError.invalidConfiguration("JSON must be an object with server configurations")
    }
}
