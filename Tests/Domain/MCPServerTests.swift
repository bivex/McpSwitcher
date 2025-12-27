/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:09:31
 * Last Updated: 2025-12-27T20:31:12
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import XCTest
@testable import McpSwitcher

final class MCPServerTests: XCTestCase {
    
    func testServerCreationWithValidData() throws {
        let config = ServerConfiguration.url(
            url: "https://api.example.com",
            headers: ["Authorization": "Bearer token"]
        )
        
        let server = try MCPServer(
            name: "test-server",
            configuration: config,
            isEnabled: true,
            description: "Test server"
        )
        
        XCTAssertEqual(server.name, "test-server")
        XCTAssertTrue(server.isEnabled)
        XCTAssertEqual(server.description, "Test server")
    }
    
    func testServerCreationFailsWithEmptyName() throws {
        let config = ServerConfiguration.url(
            url: "https://api.example.com",
            headers: [:]
        )
        
        XCTAssertThrowsError(try MCPServer(
            name: "",
            configuration: config
        )) { error in
            guard let domainError = error as? DomainError else {
                XCTFail("Expected DomainError")
                return
            }
            
            if case .invalidServerName = domainError {
                // Success
            } else {
                XCTFail("Expected invalidServerName error")
            }
        }
    }
    
    func testServerToggle() throws {
        let config = ServerConfiguration.url(
            url: "https://api.example.com",
            headers: [:]
        )
        
        let server = try MCPServer(
            name: "test",
            configuration: config,
            isEnabled: false
        )
        
        let toggled = try server.toggle()
        XCTAssertTrue(toggled.isEnabled)
        
        let toggledBack = try toggled.toggle()
        XCTAssertFalse(toggledBack.isEnabled)
    }
    
    func testServerWithConfiguration() throws {
        let config1 = ServerConfiguration.url(
            url: "https://api.example.com",
            headers: [:]
        )
        
        let server = try MCPServer(
            name: "test",
            configuration: config1
        )
        
        let config2 = ServerConfiguration.command(
            command: "npx",
            args: ["@package/server"],
            env: [:]
        )
        
        let updated = try server.withConfiguration(config2)
        
        // Both should represent different configs
        XCTAssertNotEqual(server.configuration, updated.configuration)
    }
}

