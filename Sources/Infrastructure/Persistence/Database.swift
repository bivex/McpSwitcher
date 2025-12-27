/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:10:38
 * Last Updated: 2025-12-27T20:31:16
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import SQLite
import Domain

/// SQLite database manager
public class Database {
    private let dbPath: String
    public var path: String { dbPath }
    private var db: SQLite.Connection?
    
    private let serversTable = Table("mcp_servers")
    private let id = Expression<String>("id")
    private let name = Expression<String>("name")
    private let configType = Expression<String>("config_type")
    private let configData = Expression<String>("config_data")
    private let isEnabled = Expression<Bool>("is_enabled")
    private let description = Expression<String?>("description")
    private let createdAt = Expression<Double>("created_at")
    private let modifiedAt = Expression<Double>("modified_at")
    
    public init(dbPath: String = "") throws {
        let path = dbPath.isEmpty ? Self.defaultPath() : dbPath
        self.dbPath = path
        
        // Create database connection
        self.db = try SQLite.Connection(path)
        try createTablesIfNeeded()
    }
    
    private static func defaultPath() -> String {
        let fm = FileManager.default
        let appSupport = try? fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dbDir = (appSupport?.appendingPathComponent("McpSwitcher"))?.path ?? "/tmp"
        try? fm.createDirectory(atPath: dbDir, withIntermediateDirectories: true)
        return "\(dbDir)/mcp-switcher.db"
    }
    
    private func createTablesIfNeeded() throws {
        guard let db = db else { throw DomainError.operationFailed("Database not initialized") }
        
        try db.run(serversTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(name, unique: true)
            table.column(configType)
            table.column(configData)
            table.column(isEnabled, defaultValue: false)
            table.column(description)
            table.column(createdAt)
            table.column(modifiedAt)
        })
    }
    
    func save(server: MCPServer) throws {
        guard let db = db else { throw DomainError.operationFailed("Database not initialized") }
        
        let configData = try encodeConfiguration(server.configuration)
        let configType = getConfigType(server.configuration)
        
        let insert = serversTable.insert(or: .replace,
            id <- server.id,
            name <- server.name,
            self.configType <- configType,
            self.configData <- configData,
            isEnabled <- server.isEnabled,
            description <- server.description,
            createdAt <- server.createdAt.timeIntervalSince1970,
            modifiedAt <- server.modifiedAt.timeIntervalSince1970
        )
        
        try db.run(insert)
    }
    
    func findById(_ id: String) throws -> MCPServer? {
        guard let db = db else { throw DomainError.operationFailed("Database not initialized") }
        
        let query = serversTable.filter(self.id == id)
        
        for row in try db.prepare(query) {
            return try rowToServer(row)
        }
        
        return nil
    }
    
    func findAll() throws -> [MCPServer] {
        guard let db = db else { throw DomainError.operationFailed("Database not initialized") }
        
        var servers: [MCPServer] = []
        for row in try db.prepare(serversTable.order(name)) {
            servers.append(try rowToServer(row))
        }
        
        return servers
    }
    
    func findEnabled() throws -> [MCPServer] {
        guard let db = db else { throw DomainError.operationFailed("Database not initialized") }
        
        let query = serversTable.filter(isEnabled == true).order(name)
        var servers: [MCPServer] = []
        
        for row in try db.prepare(query) {
            servers.append(try rowToServer(row))
        }
        
        return servers
    }
    
    func findByName(_ name: String) throws -> [MCPServer] {
        guard let db = db else { throw DomainError.operationFailed("Database not initialized") }
        
        let query = serversTable.filter(self.name.like("%\(name)%")).order(self.name)
        var servers: [MCPServer] = []
        
        for row in try db.prepare(query) {
            servers.append(try rowToServer(row))
        }
        
        return servers
    }
    
    func delete(_ id: String) throws {
        guard let db = db else { throw DomainError.operationFailed("Database not initialized") }
        
        let query = serversTable.filter(self.id == id)
        try db.run(query.delete())
    }
    
    func count() throws -> Int {
        guard let db = db else { throw DomainError.operationFailed("Database not initialized") }
        return try db.scalar(serversTable.count)
    }
    
    func enabledCount() throws -> Int {
        guard let db = db else { throw DomainError.operationFailed("Database not initialized") }
        return try db.scalar(serversTable.filter(isEnabled == true).count)
    }

    public func getAllServers() throws -> [MCPServer] {
        guard let db = db else { throw DomainError.operationFailed("Database not initialized") }

        var servers: [MCPServer] = []
        for row in try db.prepare(serversTable.order(name)) {
            servers.append(try rowToServer(row))
        }
        return servers
    }

    public func updateServerEnabled(serverId: String, isEnabled: Bool) throws {
        guard let db = db else { throw DomainError.operationFailed("Database not initialized") }

        try db.run(serversTable.filter(id == serverId).update(
            self.isEnabled <- isEnabled,
            modifiedAt <- Date().timeIntervalSince1970
        ))
    }
    
    // MARK: - Private Helpers
    
    private func rowToServer(_ row: Row) throws -> MCPServer {
        let serverId = try row.get(id)
        let serverName = try row.get(name)
        let type = try row.get(configType)
        let configData = try row.get(configData)
        let enabled = try row.get(isEnabled)
        let desc = try row.get(description)
        let created = try row.get(createdAt)
        let modified = try row.get(modifiedAt)
        
        let config = try decodeConfiguration(configData, type: type)
        
        return try MCPServer(
            id: serverId,
            name: serverName,
            configuration: config,
            isEnabled: enabled,
            createdAt: Date(timeIntervalSince1970: created),
            modifiedAt: Date(timeIntervalSince1970: modified),
            description: desc
        )
    }
    
    private func encodeConfiguration(_ config: ServerConfiguration) throws -> String {
        let encoder = JSONEncoder()
        let data = try encoder.encode(config)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw DomainError.invalidConfiguration("Failed to encode configuration")
        }
        return jsonString
    }
    
    private func decodeConfiguration(_ json: String, type: String) throws -> ServerConfiguration {
        guard let data = json.data(using: .utf8) else {
            throw DomainError.invalidConfiguration("Failed to decode configuration string")
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(ServerConfiguration.self, from: data)
    }
    
    private func getConfigType(_ config: ServerConfiguration) -> String {
        switch config {
        case .command:
            return "command"
        case .url:
            return "url"
        }
    }
}

