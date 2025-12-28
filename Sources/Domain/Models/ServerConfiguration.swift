/**
 * Copyright (c) 2025 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2025-12-27T20:27:18
 * Last Updated: 2025-12-28T14:10:50
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation

/// Value Object representing MCP Server Configuration
/// Immutable and can be one of two types: CommandBased or UrlBased
public enum ServerConfiguration {
    /// Command-based configuration (for local execution)
    case command(
        command: String,
        args: [String],
        env: [String: String]
    )
    
    /// URL-based configuration (for HTTP endpoints)
    case url(
        url: String,
        headers: [String: String]
    )
    
    // MARK: - Validation
    
    /// Validate configuration on creation
    /// - Throws: DomainError if configuration is invalid
    public func validate() throws {
        switch self {
        case .command(let command, let args, let env):
            try validateCommandConfig(command: command, args: args, env: env)
        case .url(let url, let headers):
            try validateUrlConfig(url: url, headers: headers)
        }
    }
    
    private func validateCommandConfig(command: String, args: [String], env: [String: String]) throws {
        guard !command.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw DomainError.invalidConfiguration("Command cannot be empty")
        }
        
        // Validate command is a valid executable path or name
        let validChars = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "/-_."))
        guard command.allSatisfy({ validChars.contains($0.unicodeScalars.first ?? UnicodeScalar(0)) }) else {
            throw DomainError.invalidConfiguration("Command contains invalid characters")
        }
    }
    
    private func validateUrlConfig(url: String, headers: [String: String]) throws {
        guard !url.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw DomainError.invalidConfiguration("URL cannot be empty")
        }
        
        guard URL(string: url) != nil else {
            throw DomainError.invalidConfiguration("Invalid URL format")
        }
        
        guard url.starts(with: "http://") || url.starts(with: "https://") else {
            throw DomainError.invalidConfiguration("URL must start with http:// or https://")
        }
    }
    
    // MARK: - Conversion to Dictionary (for JSON export)
    
    /// Convert configuration to dictionary for JSON serialization
    public func toDictionary() -> [String: Any] {
        switch self {
        case .command(let command, let args, let env):
            return [
                "command": command,
                "args": args,
                "env": env
            ]
        case .url(let url, let headers):
            return [
                "url": url,
                "headers": headers
            ]
        }
    }
    
    /// Create configuration from dictionary (for deserialization)
    /// - Throws: DomainError if dictionary format is invalid
    public static func fromDictionary(_ dict: [String: Any]) throws -> ServerConfiguration {
        // Check for URL-based config first
        if let url = dict["url"] as? String {
            let headers = (dict["headers"] as? [String: String]) ?? [:]
            let config = ServerConfiguration.url(url: url, headers: headers)
            try config.validate()
            return config
        }
        
        // Check for command-based config
        if let command = dict["command"] as? String {
            let args = (dict["args"] as? [String]) ?? []
            let env = (dict["env"] as? [String: String]) ?? [:]
            let config = ServerConfiguration.command(command: command, args: args, env: env)
            try config.validate()
            return config
        }
        
        throw DomainError.invalidConfiguration("Configuration must have either 'url' or 'command' field")
    }
}

// MARK: - Equatable
extension ServerConfiguration: Equatable {
    public static func == (lhs: ServerConfiguration, rhs: ServerConfiguration) -> Bool {
        switch (lhs, rhs) {
        case let (.command(cmd1, args1, env1), .command(cmd2, args2, env2)):
            return cmd1 == cmd2 && args1 == args2 && env1 == env2
        case let (.url(url1, headers1), .url(url2, headers2)):
            return url1 == url2 && headers1 == headers2
        default:
            return false
        }
    }
}

// MARK: - Codable
extension ServerConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case command, args, env
        case url, headers
    }
    
    enum ConfigurationType: String, Codable {
        case command, url
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .command(let command, let args, let env):
            try container.encode(ConfigurationType.command, forKey: .type)
            try container.encode(command, forKey: .command)
            try container.encode(args, forKey: .args)
            try container.encode(env, forKey: .env)
        case .url(let url, let headers):
            try container.encode(ConfigurationType.url, forKey: .type)
            try container.encode(url, forKey: .url)
            try container.encode(headers, forKey: .headers)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ConfigurationType.self, forKey: .type)
        
        switch type {
        case .command:
            let command = try container.decode(String.self, forKey: .command)
            let args = try container.decodeIfPresent([String].self, forKey: .args) ?? []
            let env = try container.decodeIfPresent([String: String].self, forKey: .env) ?? [:]
            self = .command(command: command, args: args, env: env)
        case .url:
            let url = try container.decode(String.self, forKey: .url)
            let headers = try container.decodeIfPresent([String: String].self, forKey: .headers) ?? [:]
            self = .url(url: url, headers: headers)
        }
    }
}

