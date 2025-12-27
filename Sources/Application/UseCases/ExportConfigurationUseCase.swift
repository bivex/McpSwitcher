/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:30:24
 * Last Updated: 2025-12-27T20:30:27
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import Domain
import Infrastructure

/// Output format for exported configuration
public struct ExportedConfiguration {
    public let jsonString: String
    public let dictionary: [String: Any]
    public let enabledServersCount: Int
    public let totalServersCount: Int
    
    public init(
        jsonString: String,
        dictionary: [String: Any],
        enabledServersCount: Int,
        totalServersCount: Int
    ) {
        self.jsonString = jsonString
        self.dictionary = dictionary
        self.enabledServersCount = enabledServersCount
        self.totalServersCount = totalServersCount
    }
}

/// Use Case: Export enabled server configurations to JSON format
public struct ExportConfigurationUseCase {
    let repository: ServerRepository
    
    public init(repository: ServerRepository) {
        self.repository = repository
    }
    
    /// Execute: Export enabled servers to JSON-compatible dictionary
    /// - Parameter includeMetadata: Whether to include export metadata
    /// - Returns: ExportedConfiguration with JSON and dictionary
    /// - Throws: DomainError if export fails
    public func execute(includeMetadata: Bool = false) async throws -> ExportedConfiguration {
        let servers = try await repository.findAll()
        
        let exportDict: [String: Any]
        if includeMetadata {
            exportDict = ConfigurationExporter.exportWithMetadata(servers)
        } else {
            exportDict = ["mcpServers": ConfigurationExporter.exportEnabledServers(servers)]
        }
        
        let jsonString = try ConfigurationExporter.toJSON(exportDict, pretty: true)
        let enabledCount = servers.filter { $0.isEnabled }.count
        
        return ExportedConfiguration(
            jsonString: jsonString,
            dictionary: exportDict,
            enabledServersCount: enabledCount,
            totalServersCount: servers.count
        )
    }
    
    /// Export to a file path
    /// - Parameters:
    ///   - filePath: Where to write the JSON file
    ///   - includeMetadata: Whether to include export metadata
    /// - Throws: DomainError if operation fails
    public func exportToFile(
        _ filePath: String,
        includeMetadata: Bool = false
    ) async throws -> ExportedConfiguration {
        let exported = try await execute(includeMetadata: includeMetadata)
        
        let url = URL(fileURLWithPath: filePath)
        try exported.jsonString.write(to: url, atomically: true, encoding: .utf8)
        
        return exported
    }
}

