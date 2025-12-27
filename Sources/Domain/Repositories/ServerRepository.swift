/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:07:40
 * Last Updated: 2025-12-27T20:27:24
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// Domain port: Repository interface for MCP Server persistence
/// Any implementation must satisfy these contracts
public protocol ServerRepository {
    /// Find server by ID
    /// - Parameter id: Server UUID
    /// - Returns: MCPServer if found, nil otherwise
    func findById(_ id: String) async throws -> MCPServer?
    
    /// Find all servers regardless of state
    /// - Returns: Array of all MCPServer instances
    func findAll() async throws -> [MCPServer]
    
    /// Find only enabled servers
    /// - Returns: Array of enabled MCPServer instances
    func findEnabled() async throws -> [MCPServer]
    
    /// Find servers by name (supports partial match)
    /// - Parameter name: Name or partial name to search
    /// - Returns: Array of matching MCPServer instances
    func findByName(_ name: String) async throws -> [MCPServer]
    
    /// Persist a new or updated server
    /// - Parameter server: MCPServer to save
    /// - Throws: DomainError.serverAlreadyExists if name is duplicate
    func save(_ server: MCPServer) async throws
    
    /// Delete server by ID
    /// - Parameter id: Server UUID to delete
    /// - Throws: DomainError.serverNotFound if server doesn't exist
    func delete(_ id: String) async throws
    
    /// Get count of all servers
    /// - Returns: Total number of servers
    func count() async throws -> Int
    
    /// Get count of enabled servers
    /// - Returns: Number of enabled servers
    func enabledCount() async throws -> Int
}

/// Domain event: Fired when server state changes
public struct ServerStateChangedEvent {
    public let serverId: String
    public let previousState: Bool
    public let newState: Bool
    public let timestamp: Date
    
    public init(serverId: String, previousState: Bool, newState: Bool, timestamp: Date = Date()) {
        self.serverId = serverId
        self.previousState = previousState
        self.newState = newState
        self.timestamp = timestamp
    }
}

/// Domain event: Fired when server is created
public struct ServerCreatedEvent {
    public let serverId: String
    public let name: String
    public let timestamp: Date
    
    public init(serverId: String, name: String, timestamp: Date = Date()) {
        self.serverId = serverId
        self.name = name
        self.timestamp = timestamp
    }
}

/// Domain event: Fired when server is deleted
public struct ServerDeletedEvent {
    public let serverId: String
    public let name: String
    public let timestamp: Date
    
    public init(serverId: String, name: String, timestamp: Date = Date()) {
        self.serverId = serverId
        self.name = name
        self.timestamp = timestamp
    }
}

