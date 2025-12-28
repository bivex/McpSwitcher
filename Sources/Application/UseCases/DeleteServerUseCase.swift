/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:31:20
 * Last Updated: 2025-12-28T14:10:50
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import Domain
import Infrastructure

/// Use Case: Delete an MCP server configuration
public struct DeleteServerUseCase {
    let repository: ServerRepository
    
    public init(repository: ServerRepository) {
        self.repository = repository
    }
    
    /// Execute: Delete a server by ID
    /// - Parameter serverId: ID of server to delete
    /// - Throws: DomainError.serverNotFound if server doesn't exist
    public func execute(serverId: String) async throws {
        // Verify server exists before deletion
        guard let _ = try await repository.findById(serverId) else {
            throw DomainError.serverNotFound("Server with ID \(serverId) not found")
        }
        
        try await repository.delete(serverId)
    }
}

