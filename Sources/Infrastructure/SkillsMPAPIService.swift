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

/// HTTP client implementation for SkillsMP API
public class SkillsMPAPIService: SkillsAPIService {
    private let baseURL = "https://skillsmp.com/api/v1"
    private let apiKey: String
    private let session: URLSession

    public init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    public func searchSkills(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        sortBy: String? = nil
    ) async throws -> SkillSearchResult {
        guard !apiKey.isEmpty else {
            throw SkillsAPIError.missingAPIKey
        }

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw SkillsAPIError.missingQuery
        }

        var components = URLComponents(string: "\(baseURL)/skills/search")!
        var queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(min(limit, 100)))
        ]

        if let sortBy = sortBy {
            queryItems.append(URLQueryItem(name: "sortBy", value: sortBy))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw SkillsAPIError.invalidResponse
        }

        return try await performRequest(url: url)
    }

    public func searchSkillsAI(query: String) async throws -> SkillSearchResult {
        guard !apiKey.isEmpty else {
            throw SkillsAPIError.missingAPIKey
        }

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw SkillsAPIError.missingQuery
        }

        var components = URLComponents(string: "\(baseURL)/skills/ai-search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]

        guard let url = components.url else {
            throw SkillsAPIError.invalidResponse
        }

        return try await performRequest(url: url)
    }

    private func performRequest(url: URL) async throws -> SkillSearchResult {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SkillsAPIError.invalidResponse
            }

            // Handle API errors
            if httpResponse.statusCode == 401 {
                if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    switch errorResponse.error.code {
                    case "MISSING_API_KEY", "INVALID_API_KEY":
                        throw SkillsAPIError.invalidAPIKey
                    default:
                        throw SkillsAPIError.serverError(
                            code: errorResponse.error.code,
                            message: errorResponse.error.message
                        )
                    }
                }
                throw SkillsAPIError.invalidAPIKey
            }

            if httpResponse.statusCode == 400 {
                if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    if errorResponse.error.code == "MISSING_QUERY" {
                        throw SkillsAPIError.missingQuery
                    }
                    throw SkillsAPIError.serverError(
                        code: errorResponse.error.code,
                        message: errorResponse.error.message
                    )
                }
                throw SkillsAPIError.invalidResponse
            }

            if !(200...299).contains(httpResponse.statusCode) {
                throw SkillsAPIError.serverError(
                    code: "HTTP_\(httpResponse.statusCode)",
                    message: "HTTP error \(httpResponse.statusCode)"
                )
            }

            // Parse successful response
            let decoder = JSONDecoder()

            do {
                let apiResponse = try decoder.decode(SkillsMPAPIResponse.self, from: data)
                return apiResponse.toSkillSearchResult()
            } catch {
                throw SkillsAPIError.invalidResponse
            }

        } catch let error as SkillsAPIError {
            throw error
        } catch {
            throw SkillsAPIError.networkError(error)
        }
    }
}

// MARK: - API Response Models
private struct APIErrorResponse: Codable {
    struct APIError: Codable {
        let code: String
        let message: String
    }

    let success: Bool
    let error: APIError
}

private struct SkillsMPAPIResponse: Codable {
    let success: Bool
    let data: SkillsMPData

    func toSkillSearchResult() -> SkillSearchResult {
        // Handle both search and AI search response formats
        if let skills = data.skills, let pagination = data.pagination {
            // Regular search response
            return SkillSearchResult(
                skills: skills,
                totalCount: pagination.total,
                page: pagination.page,
                limit: pagination.limit
            )
        } else if let aiResults = data.data {
            // AI search response - extract skills from results
            let skills = aiResults.compactMap { $0.skill }
            return SkillSearchResult(
                skills: skills,
                totalCount: skills.count,
                page: 1,
                limit: skills.count
            )
        } else {
            // Fallback
            return SkillSearchResult(skills: [], totalCount: 0, page: 1, limit: 20)
        }
    }
}

private struct SkillsMPData: Codable {
    // Regular search fields
    let skills: [Skill]?
    let pagination: SkillsMPPagination?

    // AI search fields
    let data: [SkillsMPAISearchResult]?

    // Other fields we don't use
    let object: String?
    let search_query: String?
    let has_more: Bool?
    let next_page: String?
}

private struct SkillsMPPagination: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int?
    let hasNext: Bool?
    let hasPrev: Bool?
}

private struct SkillsMPAISearchResult: Codable {
    let file_id: String
    let filename: String
    let score: Double
    let skill: Skill
}
