/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:31:13
 * Last Updated: 2025-12-28T14:10:50
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import XCTest
@testable import McpSwitcher

final class ServerConfigurationTests: XCTestCase {
    
    func testURLConfigCreation() throws {
        let config = ServerConfiguration.url(
            url: "https://api.example.com/mcp",
            headers: ["Authorization": "Bearer token"]
        )
        
        try config.validate()
        // Should not throw
    }
    
    func testURLConfigValidationFailsWithInvalidURL() throws {
        let config = ServerConfiguration.url(
            url: "not-a-url",
            headers: [:]
        )
        
        XCTAssertThrowsError(try config.validate())
    }
    
    func testCommandConfigCreation() throws {
        let config = ServerConfiguration.command(
            command: "npx",
            args: ["-y", "@package/server"],
            env: ["API_KEY": "secret"]
        )
        
        try config.validate()
        // Should not throw
    }
    
    func testCommandConfigValidationFailsWithEmptyCommand() throws {
        let config = ServerConfiguration.command(
            command: "",
            args: [],
            env: [:]
        )
        
        XCTAssertThrowsError(try config.validate())
    }
    
    func testConfigurationToDictionary() throws {
        let config = ServerConfiguration.url(
            url: "https://api.example.com",
            headers: ["Key": "Value"]
        )
        
        let dict = config.toDictionary()
        
        XCTAssertEqual(dict["url"] as? String, "https://api.example.com")
        XCTAssertEqual(dict["headers"] as? [String: String], ["Key": "Value"])
    }
    
    func testConfigurationEquality() {
        let config1 = ServerConfiguration.url(
            url: "https://api.example.com",
            headers: ["Key": "Value"]
        )
        
        let config2 = ServerConfiguration.url(
            url: "https://api.example.com",
            headers: ["Key": "Value"]
        )
        
        let config3 = ServerConfiguration.url(
            url: "https://api.other.com",
            headers: [:]
        )
        
        XCTAssertEqual(config1, config2)
        XCTAssertNotEqual(config1, config3)
    }
}

