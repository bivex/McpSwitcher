/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:31:10
 * Last Updated: 2025-12-27T20:31:22
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import Domain

/// SQLite implementation of ServerRepository (adapter/infrastructure)
public class SQLiteServerRepository: ServerRepository {
    private let database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func findById(_ id: String) async throws -> MCPServer? {
        return try database.findById(id)
    }
    
    public func findAll() async throws -> [MCPServer] {
        return try database.findAll()
    }
    
    public func findEnabled() async throws -> [MCPServer] {
        return try database.findEnabled()
    }
    
    public func findByName(_ name: String) async throws -> [MCPServer] {
        return try database.findByName(name)
    }
    
    public func save(_ server: MCPServer) async throws {
        try database.save(server: server)
    }
    
    public func delete(_ id: String) async throws {
        try database.delete(id)
    }
    
    public func count() async throws -> Int {
        return try database.count()
    }
    
    public func enabledCount() async throws -> Int {
        return try database.enabledCount()
    }
}

