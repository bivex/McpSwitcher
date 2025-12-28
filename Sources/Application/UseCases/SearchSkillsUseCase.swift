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
import Domain

/// Input for skill search use case
public struct SkillSearchInput {
    /// Search query string
    public let query: String

    /// Page number (starting from 1)
    public let page: Int

    /// Number of results per page (max 100)
    public let limit: Int

    /// Sort order ("stars" or "recent")
    public let sortBy: String?

    public init(query: String, page: Int = 1, limit: Int = 20, sortBy: String? = nil) {
        self.query = query
        self.page = max(1, page)
        self.limit = min(max(1, limit), 100)
        self.sortBy = sortBy
    }
}

/// Use Case: Search skills using keywords
public struct SearchSkillsUseCase {
    let skillsAPIService: SkillsAPIService

    public init(skillsAPIService: SkillsAPIService) {
        self.skillsAPIService = skillsAPIService
    }

    /// Execute keyword-based skill search
    /// - Parameter input: Search parameters
    /// - Returns: Search results
    public func execute(input: SkillSearchInput) async throws -> SkillSearchResult {
        return try await skillsAPIService.searchSkills(
            query: input.query,
            page: input.page,
            limit: input.limit,
            sortBy: input.sortBy
        )
    }
}

/// Use Case: Search skills using AI semantic search
public struct SearchSkillsAIUseCase {
    let skillsAPIService: SkillsAPIService

    public init(skillsAPIService: SkillsAPIService) {
        self.skillsAPIService = skillsAPIService
    }

    /// Execute AI-powered semantic skill search
    /// - Parameter query: Natural language search query
    /// - Returns: Search results
    public func execute(query: String) async throws -> SkillSearchResult {
        return try await skillsAPIService.searchSkillsAI(query: query)
    }
}
