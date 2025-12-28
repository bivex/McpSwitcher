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

/// Use Case: Copy skill information to clipboard
public struct CopySkillToClipboardUseCase {
    let clipboardService: ClipboardService

    public init(clipboardService: ClipboardService) {
        self.clipboardService = clipboardService
    }

    /// Copy a single skill to clipboard
    /// - Parameter skill: The skill to copy
    /// - Returns: Success status
    public func execute(skill: Skill) -> Bool {
        let formattedText = skill.formatForClipboard()
        return clipboardService.copyToClipboard(formattedText)
    }

    /// Copy multiple skills to clipboard
    /// - Parameter skills: Array of skills to copy
    /// - Returns: Success status
    public func execute(skills: [Skill]) -> Bool {
        let formattedText = skills.map { $0.formatForClipboard() }
            .joined(separator: "\n\n---\n\n")
        return clipboardService.copyToClipboard(formattedText)
    }
}
