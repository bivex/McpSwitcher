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

#if os(macOS)
import AppKit
#endif

/// System clipboard service implementation
public class SystemClipboardService: ClipboardService {
    public init() {}

    public func copyToClipboard(_ text: String) -> Bool {
        #if os(macOS)
        print("📋 Attempting to copy \(text.count) characters to macOS clipboard")
        let pasteboard = NSPasteboard.general
        print("📋 Got pasteboard reference: \(pasteboard)")

        // Try to clear contents
        let clearResult = pasteboard.clearContents()
        print("📋 Clear contents result: \(clearResult)")

        // Try to set string
        let success = pasteboard.setString(text, forType: .string)
        print("📋 Set string result: \(success)")

        // Verify the content was actually set
        if let retrievedText = pasteboard.string(forType: .string) {
            print("📋 Verification - retrieved \(retrievedText.count) characters")
            if retrievedText == text {
                print("📋 Content verification: MATCH ✓")
            } else {
                print("📋 Content verification: MISMATCH ✗")
            }
        } else {
            print("📋 Content verification: FAILED to retrieve ✗")
        }

        print("📋 Clipboard copy result: \(success ? "SUCCESS" : "FAILED")")

        // If NSPasteboard failed, try fallback with pbcopy command
        if !success {
            print("📋 Trying fallback with pbcopy command...")
            return tryPbcopyFallback(text)
        }

        return success
        #else
        // For other platforms, we'll implement a basic fallback
        // In a real implementation, you'd use platform-specific APIs
        print("Clipboard functionality not implemented for this platform")
        print("Content to copy:")
        print(text)
        return false
        #endif
    }

    private func tryPbcopyFallback(_ text: String) -> Bool {
        #if os(macOS)
        do {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = ["-c", "echo '\(text.replacingOccurrences(of: "'", with: "'\"'\"'"))' | pbcopy"]

            try process.run()
            process.waitUntilExit()

            let exitCode = process.terminationStatus
            print("📋 pbcopy fallback result: exit code \(exitCode)")
            return exitCode == 0
        } catch {
            print("📋 pbcopy fallback failed: \(error)")
            return false
        }
        #else
        return false
        #endif
    }
}
