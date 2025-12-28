/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:30:32
 * Last Updated: 2025-12-28T14:10:50
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import Domain
import Infrastructure

/// Use Case: Enable or disable an MCP server
public struct ToggleServerUseCase {
    let repository: ServerRepository
    let syncUseCase: SyncWithMCPJSONUseCase

    public init(repository: ServerRepository, syncUseCase: SyncWithMCPJSONUseCase? = nil) {
        self.repository = repository
        self.syncUseCase = syncUseCase ?? SyncWithMCPJSONUseCase(repository: repository)
    }
    
    /// Execute: Toggle server state (enabled -> disabled or vice versa)
    /// - Parameter serverId: ID of server to toggle
    /// - Returns: Updated ServerDTO
    public func execute(serverId: String) async throws -> ServerDTO {
        guard let server = try await repository.findById(serverId) else {
            throw DomainError.serverNotFound("Server with ID \(serverId) not found")
        }

        let updatedServer = try server.toggle()
        try await repository.save(updatedServer)

        // Sync with mcp.json
        do {
            _ = try await syncUseCase.syncEnabledServers()
        } catch {
            print("⚠️ Failed to sync server \(updatedServer.name) with mcp.json: \(error)")
            // Don't fail the toggle operation if sync fails
        }

        return ServerDTO(from: updatedServer)
    }
    
    /// Set explicit enabled state
    /// - Parameters:
    ///   - serverId: ID of server to update
    ///   - enabled: Whether to enable or disable
    /// - Returns: Updated ServerDTO
    public func setEnabled(_ serverId: String, enabled: Bool) async throws -> ServerDTO {
        guard let server = try await repository.findById(serverId) else {
            throw DomainError.serverNotFound("Server with ID \(serverId) not found")
        }

        if server.isEnabled == enabled {
            return ServerDTO(from: server)
        }

        let updatedServer = try server.withEnabled(enabled)
        try await repository.save(updatedServer)

        // Sync with mcp.json
        do {
            _ = try await syncUseCase.syncEnabledServers()
        } catch {
            print("⚠️ Failed to sync server \(updatedServer.name) with mcp.json: \(error)")
            // Don't fail the toggle operation if sync fails
        }

        return ServerDTO(from: updatedServer)
    }
}

