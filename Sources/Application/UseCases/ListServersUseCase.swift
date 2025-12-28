/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:07:56
 * Last Updated: 2025-12-28T14:23:58
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import Domain
import Infrastructure

/// Use Case: List all MCP servers with their current state
public struct ListServersUseCase {
    let repository: ServerRepository
    
    public init(repository: ServerRepository) {
        self.repository = repository
    }
    
    /// Execute the use case
    /// - Parameter includeDisabled: Whether to include disabled servers in output
    /// - Returns: Array of ServerDTOs
    public func execute(includeDisabled: Bool = true) async throws -> [ServerDTO] {
        let servers = try await repository.findAll()
        
        let filtered = includeDisabled ? servers : servers.filter { $0.isEnabled }
        return filtered.map { ServerDTO(from: $0) }
    }
    
    /// Get detailed view with configuration
    public func executeDetailed(includeDisabled: Bool = true) async throws -> [ServerDetailDTO] {
        let servers = try await repository.findAll()
        
        let filtered = includeDisabled ? servers : servers.filter { $0.isEnabled }
        return filtered.map { ServerDetailDTO(from: $0) }
    }
}

