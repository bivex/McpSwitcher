/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:31:09
 * Last Updated: 2025-12-27T20:31:21
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import Domain
import Infrastructure

/// Input for creating a new server
public struct CreateServerInput {
    public let name: String
    public let configuration: ServerConfiguration
    public let enabled: Bool
    public let description: String?
    
    public init(
        name: String,
        configuration: ServerConfiguration,
        enabled: Bool = false,
        description: String? = nil
    ) {
        self.name = name
        self.configuration = configuration
        self.enabled = enabled
        self.description = description
    }
}

/// Use Case: Create a new MCP server configuration
public struct CreateServerUseCase {
    let repository: ServerRepository
    
    public init(repository: ServerRepository) {
        self.repository = repository
    }
    
    /// Execute: Create and persist a new server
    /// - Parameter input: CreateServerInput with server details
    /// - Returns: Created ServerDTO
    /// - Throws: DomainError if validation fails or name already exists
    public func execute(input: CreateServerInput) async throws -> ServerDTO {
        // Validate configuration
        try input.configuration.validate()
        
        // Check for duplicate name
        let existing = try await repository.findByName(input.name)
        if !existing.isEmpty {
            throw DomainError.serverAlreadyExists("Server with name '\(input.name)' already exists")
        }
        
        // Create new server (domain will validate invariants)
        let newServer = try MCPServer(
            name: input.name,
            configuration: input.configuration,
            isEnabled: input.enabled,
            description: input.description
        )
        
        // Persist
        try await repository.save(newServer)
        
        return ServerDTO(from: newServer)
    }
}

