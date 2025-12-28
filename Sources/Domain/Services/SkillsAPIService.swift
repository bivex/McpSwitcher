/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-28T12:00:00
 * Last Updated: 2025-12-28T14:10:50
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// Protocol for SkillsMP API service
public protocol SkillsAPIService {
    /// Search skills using keywords
    /// - Parameters:
    ///   - query: Search query string
    ///   - page: Page number (default: 1)
    ///   - limit: Results per page (default: 20, max: 100)
    ///   - sortBy: Sort order ("stars" or "recent", default: nil)
    /// - Returns: Search result with skills
    func searchSkills(
        query: String,
        page: Int,
        limit: Int,
        sortBy: String?
    ) async throws -> SkillSearchResult

    /// Search skills using AI semantic search
    /// - Parameter query: AI-powered search query
    /// - Returns: Search result with skills
    func searchSkillsAI(query: String) async throws -> SkillSearchResult
}

/// Protocol for clipboard operations
public protocol ClipboardService {
    /// Copy text to system clipboard
    /// - Parameter text: Text to copy
    /// - Returns: Success status
    func copyToClipboard(_ text: String) -> Bool
}

/// Errors that can occur during SkillsMP API operations
public enum SkillsAPIError: Error {
    case missingAPIKey
    case invalidAPIKey
    case missingQuery
    case networkError(Error)
    case invalidResponse
    case serverError(code: String, message: String)

    public var localizedDescription: String {
        switch self {
        case .missingAPIKey:
            return "API key is required but not provided"
        case .invalidAPIKey:
            return "The provided API key is invalid"
        case .missingQuery:
            return "Search query is required"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code, let message):
            return "\(code): \(message)"
        }
    }
}
