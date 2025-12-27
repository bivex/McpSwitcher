/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:27:20
 * Last Updated: 2025-12-27T20:27:20
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// Domain-level errors representing business rule violations
public enum DomainError: Error, LocalizedError {
    /// Server name validation failed
    case invalidServerName(String)
    
    /// Server ID validation failed
    case invalidServerId(String)
    
    /// Configuration validation failed
    case invalidConfiguration(String)
    
    /// Server not found in repository
    case serverNotFound(String)
    
    /// Server with this name already exists
    case serverAlreadyExists(String)
    
    /// Conflict when modifying server state
    case stateConflict(String)
    
    /// Operation failed for generic business reason
    case operationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidServerName(let msg),
             .invalidServerId(let msg),
             .invalidConfiguration(let msg),
             .serverNotFound(let msg),
             .serverAlreadyExists(let msg),
             .stateConflict(let msg),
             .operationFailed(let msg):
            return msg
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidServerName:
            return "Please provide a non-empty server name (max 255 characters)"
        case .invalidServerId:
            return "Server ID must be a valid UUID"
        case .invalidConfiguration:
            return "Configuration must be valid command-based or URL-based config"
        case .serverNotFound:
            return "Check if the server exists and try again"
        case .serverAlreadyExists:
            return "Use a different server name or update the existing one"
        case .stateConflict:
            return "The server state may have changed; refresh and try again"
        case .operationFailed:
            return "Check the logs for details"
        }
    }
}

