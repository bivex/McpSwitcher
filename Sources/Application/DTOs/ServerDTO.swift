/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:09:48
 * Last Updated: 2025-12-27T20:31:17
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import Domain

/// Data Transfer Object for server (for output to UI/API)
public struct ServerDTO: Codable {
    public let id: String
    public let name: String
    public let isEnabled: Bool
    public let description: String?
    public let createdAt: String
    public let modifiedAt: String
    
    public init(from server: MCPServer) {
        self.id = server.id
        self.name = server.name
        self.isEnabled = server.isEnabled
        self.description = server.description
        let formatter = ISO8601DateFormatter()
        self.createdAt = formatter.string(from: server.createdAt)
        self.modifiedAt = formatter.string(from: server.modifiedAt)
    }
}

/// Extended DTO with configuration details
public struct ServerDetailDTO: Codable {
    public let id: String
    public let name: String
    public let isEnabled: Bool
    public let description: String?
    public let configuration: [String: AnyCodable]
    public let createdAt: String
    public let modifiedAt: String
    
    public init(from server: MCPServer) {
        self.id = server.id
        self.name = server.name
        self.isEnabled = server.isEnabled
        self.description = server.description
        self.configuration = server.configuration.toDictionary().mapValues(AnyCodable.init)
        let formatter = ISO8601DateFormatter()
        self.createdAt = formatter.string(from: server.createdAt)
        self.modifiedAt = formatter.string(from: server.modifiedAt)
    }
}

/// Wrapper for any JSON-encodable value
public enum AnyCodable: Codable {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([AnyCodable])
    case object([String: AnyCodable])
    
    public init(_ value: Any) {
        if value is NSNull {
            self = .null
        } else if let value = value as? Bool {
            self = .bool(value)
        } else if let value = value as? Int {
            self = .int(value)
        } else if let value = value as? Double {
            self = .double(value)
        } else if let value = value as? String {
            self = .string(value)
        } else if let value = value as? [Any] {
            self = .array(value.map(AnyCodable.init))
        } else if let value = value as? [String: Any] {
            self = .object(value.mapValues(AnyCodable.init))
        } else {
            self = .null
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .bool(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: AnyCodable].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode AnyCodable")
        }
    }
}

