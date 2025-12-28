/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:27:24
 * Last Updated: 2025-12-28T14:10:50
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// Domain service for exporting server configurations
/// This is a pure domain service with no infrastructure dependencies
public struct ConfigurationExporter {
    /// Export enabled servers to JSON-compatible dictionary
    /// Only enabled servers are included in the export
    /// - Parameter servers: Array of MCPServer instances
    /// - Returns: Dictionary with server names as keys
    public static func exportEnabledServers(_ servers: [MCPServer]) -> [String: [String: Any]] {
        let enabledServers = servers.filter { $0.isEnabled }
        
        var result: [String: [String: Any]] = [:]
        for server in enabledServers {
            result[server.name] = server.configuration.toDictionary()
        }
        
        return result
    }
    
    /// Export all servers (regardless of enabled state) with metadata
    /// - Parameter servers: Array of MCPServer instances
    /// - Returns: Dictionary with server metadata
    public static func exportWithMetadata(_ servers: [MCPServer]) -> [String: Any] {
        return [
            "servers": exportEnabledServers(servers),
            "metadata": [
                "total": servers.count,
                "enabled": servers.filter { $0.isEnabled }.count,
                "disabled": servers.filter { !$0.isEnabled }.count,
                "exportedAt": ISO8601DateFormatter().string(from: Date())
            ]
        ]
    }
    
    /// Convert exported dictionary to formatted JSON string
    /// - Parameter data: Dictionary to convert
    /// - Parameter pretty: Whether to format with indentation
    /// - Returns: JSON string
    /// - Throws: EncodingError if serialization fails
    public static func toJSON(_ data: [String: Any], pretty: Bool = true) throws -> String {
        let jsonData = try JSONSerialization.data(
            withJSONObject: data,
            options: pretty ? [.prettyPrinted, .sortedKeys] : []
        )
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw DomainError.operationFailed("Failed to convert JSON data to string")
        }
        
        return jsonString
    }
}

