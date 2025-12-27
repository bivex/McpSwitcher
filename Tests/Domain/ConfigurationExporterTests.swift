/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:31:14
 * Last Updated: 2025-12-27T20:31:14
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import XCTest
@testable import McpSwitcher

final class ConfigurationExporterTests: XCTestCase {
    
    func testExportEnabledServersOnly() throws {
        let config1 = ServerConfiguration.url(
            url: "https://api1.example.com",
            headers: [:]
        )
        
        let config2 = ServerConfiguration.url(
            url: "https://api2.example.com",
            headers: [:]
        )
        
        let server1 = try MCPServer(name: "server1", configuration: config1, isEnabled: true)
        let server2 = try MCPServer(name: "server2", configuration: config2, isEnabled: false)
        
        let exported = ConfigurationExporter.exportEnabledServers([server1, server2])
        
        XCTAssertEqual(exported.count, 1)
        XCTAssertNotNil(exported["server1"])
        XCTAssertNil(exported["server2"])
    }
    
    func testExportToJSON() throws {
        let config = ServerConfiguration.url(
            url: "https://api.example.com",
            headers: ["Key": "Value"]
        )
        
        let server = try MCPServer(name: "test", configuration: config, isEnabled: true)
        let exported = ConfigurationExporter.exportEnabledServers([server])
        
        let json = try ConfigurationExporter.toJSON(["mcpServers": exported])
        
        XCTAssertTrue(json.contains("test"))
        XCTAssertTrue(json.contains("api.example.com"))
    }
    
    func testExportWithMetadata() throws {
        let config = ServerConfiguration.url(
            url: "https://api.example.com",
            headers: [:]
        )
        
        let server = try MCPServer(name: "test", configuration: config, isEnabled: true)
        let exported = ConfigurationExporter.exportWithMetadata([server])
        
        if let metadata = exported["metadata"] as? [String: Any] {
            XCTAssertEqual(metadata["total"] as? Int, 1)
            XCTAssertEqual(metadata["enabled"] as? Int, 1)
            XCTAssertEqual(metadata["disabled"] as? Int, 0)
        } else {
            XCTFail("Metadata not found in export")
        }
    }
}

