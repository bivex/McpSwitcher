/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:27:17
 * Last Updated: 2025-12-28T14:10:50
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// Core domain entity representing an MCP Server
/// Invariants:
/// - name must be non-empty and unique
/// - id is immutable after creation
/// - state can only be ENABLED or DISABLED
public struct MCPServer {
    /// Unique identifier for this server (UUID)
    public let id: String
    
    /// Human-readable name of the server
    public let name: String
    
    /// Server configuration (either command-based or URL-based)
    public let configuration: ServerConfiguration
    
    /// Current enabled/disabled state
    public let isEnabled: Bool
    
    /// When this server was created
    public let createdAt: Date
    
    /// When this server was last modified
    public let modifiedAt: Date
    
    /// Optional description of the server
    public let description: String?
    
    /// Initializer - validates invariants
    /// - Throws: DomainError if invariants are violated
    public init(
        id: String = UUID().uuidString,
        name: String,
        configuration: ServerConfiguration,
        isEnabled: Bool = false,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        description: String? = nil
    ) throws {
        // Validate invariants
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw DomainError.invalidServerName("Server name cannot be empty")
        }
        
        guard name.count <= 255 else {
            throw DomainError.invalidServerName("Server name cannot exceed 255 characters")
        }
        
        guard !id.isEmpty else {
            throw DomainError.invalidServerId("Server ID cannot be empty")
        }
        
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespaces)
        self.configuration = configuration
        self.isEnabled = isEnabled
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.description = description
    }
    
    /// Create a copy with enabled state toggled
    public func toggle() throws -> MCPServer {
        return try MCPServer(
            id: id,
            name: name,
            configuration: configuration,
            isEnabled: !isEnabled,
            createdAt: createdAt,
            modifiedAt: Date(),
            description: description
        )
    }
    
    /// Create a copy with updated enabled state
    public func withEnabled(_ enabled: Bool) throws -> MCPServer {
        return try MCPServer(
            id: id,
            name: name,
            configuration: configuration,
            isEnabled: enabled,
            createdAt: createdAt,
            modifiedAt: Date(),
            description: description
        )
    }
    
    /// Create a copy with updated configuration
    public func withConfiguration(_ newConfig: ServerConfiguration) throws -> MCPServer {
        return try MCPServer(
            id: id,
            name: name,
            configuration: newConfig,
            isEnabled: isEnabled,
            createdAt: createdAt,
            modifiedAt: Date(),
            description: description
        )
    }
}

// MARK: - Equatable
extension MCPServer: Equatable {
    public static func == (lhs: MCPServer, rhs: MCPServer) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension MCPServer: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

