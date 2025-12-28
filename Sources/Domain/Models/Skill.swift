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

/// Represents a skill from the SkillsMP platform
public struct Skill {
    /// Unique identifier for the skill
    public let id: String

    /// Title/name of the skill
    public let title: String

    /// Description of what the skill teaches
    public let description: String?

    /// Category or topic of the skill (derived from tags or content)
    public let category: String?

    /// Difficulty level (beginner, intermediate, advanced)
    public let difficulty: String?

    /// Duration in minutes (if available)
    public let duration: Int?

    /// Star rating (0-5)
    public let stars: Double?

    /// Number of stars/reviews
    public let starCount: Int?

    /// Tags associated with the skill
    public let tags: [String]

    /// URL to access the skill on SkillsMP
    public let url: String?

    /// GitHub URL for the skill
    public let githubUrl: String?

    /// Author/creator of the skill
    public let author: String?

    /// When the skill was created/updated
    public let updatedAt: Date?

    /// Initialize a Skill from API response
    public init(
        id: String,
        title: String,
        description: String? = nil,
        category: String? = nil,
        difficulty: String? = nil,
        duration: Int? = nil,
        stars: Double? = nil,
        starCount: Int? = nil,
        tags: [String] = [],
        url: String? = nil,
        githubUrl: String? = nil,
        author: String? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.duration = duration
        self.stars = stars
        self.starCount = starCount
        self.tags = tags
        self.url = url
        self.githubUrl = githubUrl
        self.author = author
        self.updatedAt = updatedAt
    }

    /// Create a formatted string representation for clipboard copying
    public func formatForClipboard() -> String {
        print("🏗️ Formatting skill: \(title)")
        var result = "🎯 \(title)\n"

        if let description = description {
            result += "\n📝 Description:\n\(description)\n"
        }

        if let category = category {
            result += "\n🏷️ Category: \(category)"
        }

        if let difficulty = difficulty {
            result += "\n📊 Difficulty: \(difficulty)"
        }

        if let duration = duration {
            result += "\n⏱️ Duration: \(duration) minutes"
        }

        if let stars = stars {
            let starText = String(format: "%.1f", stars)
            result += "\n⭐ Rating: \(starText)"
            if let starCount = starCount {
                result += " (\(starCount) reviews)"
            }
        }

        if !tags.isEmpty {
            result += "\n🏷️ Tags: \(tags.joined(separator: ", "))"
        }

        if let author = author {
            result += "\n👤 Author: \(author)"
        }

        if let url = url {
            result += "\n🔗 SkillsMP URL: \(url)"
        }

        if let githubUrl = githubUrl {
            result += "\n🔗 GitHub URL: \(githubUrl)"
        }

        if let updatedAt = updatedAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            result += "\n📅 Updated: \(formatter.string(from: updatedAt))"
        }

        print("✅ Generated clipboard text (\(result.count) chars) for: \(title)")
        return result
    }
}

// MARK: - Equatable
extension Skill: Equatable {
    public static func == (lhs: Skill, rhs: Skill) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension Skill: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Codable
extension Skill: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, description, category, difficulty, duration
        case stars, tags
        case url = "skillUrl", githubUrl, author
        case updatedAt = "updatedAt"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        difficulty = try container.decodeIfPresent(String.self, forKey: .difficulty)
        duration = try container.decodeIfPresent(Int.self, forKey: .duration)
        stars = try container.decodeIfPresent(Double.self, forKey: .stars)
        starCount = nil // Not provided in current API
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        url = try container.decodeIfPresent(String.self, forKey: .url)
        githubUrl = try container.decodeIfPresent(String.self, forKey: .githubUrl)
        author = try container.decodeIfPresent(String.self, forKey: .author)

        // Handle updatedAt as Unix timestamp (Double or Int)
        if let timestamp = try? container.decode(Int.self, forKey: .updatedAt) {
            updatedAt = Date(timeIntervalSince1970: TimeInterval(timestamp))
        } else if let timestamp = try? container.decode(Double.self, forKey: .updatedAt) {
            updatedAt = Date(timeIntervalSince1970: timestamp)
        } else {
            updatedAt = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(difficulty, forKey: .difficulty)
        try container.encodeIfPresent(duration, forKey: .duration)
        try container.encodeIfPresent(stars, forKey: .stars)
        try container.encode(tags, forKey: .tags)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(githubUrl, forKey: .githubUrl)
        try container.encodeIfPresent(author, forKey: .author)

        // Encode updatedAt as Unix timestamp
        if let updatedAt = updatedAt {
            try container.encode(Int(updatedAt.timeIntervalSince1970), forKey: .updatedAt)
        }
    }
}

/// Search result containing skills and metadata
public struct SkillSearchResult {
    /// Array of skills found
    public let skills: [Skill]

    /// Total number of results available
    public let totalCount: Int

    /// Current page number
    public let page: Int

    /// Number of results per page
    public let limit: Int

    /// Whether there are more results available
    public var hasMore: Bool {
        return page * limit < totalCount
    }

    public init(skills: [Skill], totalCount: Int, page: Int, limit: Int) {
        self.skills = skills
        self.totalCount = totalCount
        self.page = page
        self.limit = limit
    }
}

// MARK: - Codable
extension SkillSearchResult: Codable {
    enum CodingKeys: String, CodingKey {
        case skills, totalCount = "total_count", page, limit
    }
}
