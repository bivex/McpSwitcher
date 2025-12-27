# Domain Model Documentation

## Entity: MCPServer

The core entity representing a Model Context Protocol server configuration.

### Identity
- **Type**: `String` (UUID)
- **Uniqueness**: Globally unique identifier
- **Immutability**: Set at creation, never changes

### State & Lifecycle

```
Created (DISABLED) → Enable → ENABLED
                  → Disable → DISABLED
                  → Modify Config
                  → Delete → Removed
```

### Invariants (Business Rules)

1. **Name Invariant**
   - Must be non-empty after trimming whitespace
   - Must be less than 255 characters
   - Must be unique across all servers
   - Enforced in: `MCPServer.init()`

2. **ID Invariant**
   - Must be a valid UUID string
   - Cannot be changed after creation
   - Enforced in: `MCPServer.init()`

3. **Configuration Invariant**
   - Must be either command-based or URL-based
   - Configuration must be valid per its type
   - Enforced in: `MCPServer.init()` and `ServerConfiguration.validate()`

4. **State Invariant**
   - Can only be ENABLED or DISABLED
   - No other states exist
   - Enforced in: Type system (Bool)

5. **Timeline Invariant**
   - `createdAt` never changes
   - `modifiedAt` updates on any modification
   - `createdAt` ≤ `modifiedAt` always
   - Enforced in: Constructor and modification methods

### Methods

#### `toggle() throws -> MCPServer`
Creates a new MCPServer with inverted enabled state.

**Pre-conditions**: None (always valid)
**Post-conditions**: Returns new server with toggled state
**Throws**: DomainError if creation fails

**Example**:
```swift
let server = try MCPServer(name: "api", configuration: config, isEnabled: false)
let enabled = try server.toggle()  // enabled.isEnabled == true
```

#### `withEnabled(_ enabled: Bool) throws -> MCPServer`
Creates a new MCPServer with specified enabled state.

**Pre-conditions**: None
**Post-conditions**: Returns new server with specified state
**Throws**: DomainError if creation fails
**Returns same state if already in that state** (idempotent)

**Example**:
```swift
let disabled = try server.withEnabled(false)
```

#### `withConfiguration(_ newConfig: ServerConfiguration) throws -> MCPServer`
Creates a new MCPServer with updated configuration.

**Pre-conditions**: newConfig must be valid
**Post-conditions**: Returns new server with new configuration
**Throws**: DomainError if validation fails
**Preserves all other properties**

**Example**:
```swift
let newConfig = ServerConfiguration.url(url: "...", headers: [:])
let updated = try server.withConfiguration(newConfig)
```

## Value Object: ServerConfiguration

Immutable, interchangeable configuration for MCP servers.

### Types

#### Variant 1: Command-Based
For local execution via CLI commands.

```swift
case command(
    command: String,        // e.g., "npx", "python", "/usr/bin/server"
    args: [String],         // e.g., ["-y", "@package/name"]
    env: [String: String]   // e.g., ["API_KEY": "secret"]
)
```

**Validation Rules**:
- `command` must be non-empty
- `command` must contain only alphanumeric, -, /, _, . characters
- `args` can be empty
- `env` can be empty

#### Variant 2: URL-Based
For HTTP/REST endpoints.

```swift
case url(
    url: String,            // e.g., "https://api.example.com/mcp"
    headers: [String: String] // e.g., ["Authorization": "Bearer token"]
)
```

**Validation Rules**:
- `url` must be non-empty
- `url` must be a valid URL format
- `url` must start with http:// or https://
- `headers` can be empty

### Immutability Contract

Once created, a `ServerConfiguration` cannot be modified. To change configuration:
1. Create new instance with different values
2. Replace old instance
3. Never mutate existing instance

**This ensures**:
- Thread safety
- Predictable behavior
- Easy equality comparison
- No accidental shared state

### Serialization

#### To Dictionary (for JSON export)
```swift
let dict = config.toDictionary()
// Returns: ["command": "...", "args": [...], "env": {...}]
// Or:      ["url": "...", "headers": {...}]
```

#### From Dictionary (deserialization)
```swift
let config = try ServerConfiguration.fromDictionary(dict)
// Validates format during deserialization
// Throws DomainError if invalid
```

#### JSON Codable
```swift
let encoder = JSONEncoder()
let data = try encoder.encode(config)

let decoder = JSONDecoder()
let decoded = try decoder.decode(ServerConfiguration.self, from: data)
```

## Aggregate: MCPServerAggregate

Conceptual grouping (MCPServer is both entity and aggregate root).

```
┌─────────────────────────────┐
│ MCPServer (Aggregate Root)  │  ← Entity
│                             │
│ ┌───────────────────────┐   │
│ │ ServerConfiguration   │   │  ← Value Object
│ │ (immutable)           │   │
│ └───────────────────────┘   │
│                             │
│ Metadata:                   │
│ - id: String                │
│ - name: String              │
│ - isEnabled: Bool           │
│ - createdAt: Date           │
│ - modifiedAt: Date          │
│ - description: String?      │
└─────────────────────────────┘
```

### Aggregate Boundaries

**What's in the aggregate**:
- MCPServer entity
- ServerConfiguration value object
- Metadata (timestamps, description)

**What's outside** (other aggregates):
- Other MCPServer instances
- Repository (handles multiple aggregates)
- Export configuration (handled by service)

### Modification Rules

Only through aggregate root methods:
- Cannot directly modify ServerConfiguration
- Cannot directly modify state
- Create new instances instead

This ensures:
- Invariants always held
- No partial updates
- Transactional consistency

## Domain Services

### ConfigurationExporter
Pure domain service for exporting configurations.

**Responsibility**: Transform domain model to exportable format

**Key Methods**:
- `exportEnabledServers([MCPServer]) -> [String: [String: Any]]`
- `exportWithMetadata([MCPServer]) -> [String: Any]`
- `toJSON([String: Any], pretty: Bool) -> String`

**No Dependencies**: Completely stateless
**Pure Function**: Same input always produces same output

## Repository Interface

### ServerRepository Port

**Responsibility**: Hide persistence details from domain

**Methods**:
```swift
protocol ServerRepository {
    func findById(_ id: String) async throws -> MCPServer?
    func findAll() async throws -> [MCPServer]
    func findEnabled() async throws -> [MCPServer]
    func findByName(_ name: String) async throws -> [MCPServer]
    func save(_ server: MCPServer) async throws
    func delete(_ id: String) async throws
    func count() async throws -> Int
    func enabledCount() async throws -> Int
}
```

**Invariant Enforcement**:
- `save()` checks unique name constraint
- `findById()`, `delete()` validate existence
- Throws appropriate DomainError

## Domain Events

Events represent state changes in the domain.

### ServerStateChangedEvent
```swift
struct ServerStateChangedEvent {
    let serverId: String
    let previousState: Bool
    let newState: Bool
    let timestamp: Date
}
```

**Fired when**: Server isEnabled changes
**Subscribers**: Application layer, Infrastructure adapters
**Use cases**: Logging, audit trail, side effects

### ServerCreatedEvent
```swift
struct ServerCreatedEvent {
    let serverId: String
    let name: String
    let timestamp: Date
}
```

**Fired when**: New server created and persisted
**Use cases**: Audit log, notification system

### ServerDeletedEvent
```swift
struct ServerDeletedEvent {
    let serverId: String
    let name: String
    let timestamp: Date
}
```

**Fired when**: Server removed from system
**Use cases**: Cleanup, audit trail, notifications

## Error Handling

### DomainError Enum

```swift
enum DomainError: Error {
    case invalidServerName(String)      // Name validation failed
    case invalidServerId(String)        // ID validation failed
    case invalidConfiguration(String)   // Config validation failed
    case serverNotFound(String)         // Server doesn't exist
    case serverAlreadyExists(String)    // Duplicate name
    case stateConflict(String)          // Concurrent modification
    case operationFailed(String)        // Generic business failure
}
```

**When to throw**:
- Invariant violations → throw DomainError
- Invalid input → throw DomainError
- Business rule violations → throw DomainError

**Never throw**:
- Implementation details
- Framework errors (wrap if necessary)
- Unrecoverable system errors (let them propagate)

## Design Patterns Applied

### 1. Entity Pattern
- MCPServer with identity and lifecycle
- Mutable, but only through controlled methods
- Responsible for enforcing invariants

### 2. Value Object Pattern
- ServerConfiguration is immutable
- Equality based on content, not identity
- Never has separate identity

### 3. Aggregate Pattern
- MCPServer is aggregate root
- ServerConfiguration is part of aggregate
- Modifications only through root

### 4. Repository Pattern
- ServerRepository abstracts persistence
- Allows swapping implementations
- Enforces consistency at boundaries

### 5. Domain Service Pattern
- ConfigurationExporter is stateless
- Pure function semantics
- No dependencies on infrastructure

## Behavioral Examples

### Creating a Server
```swift
let config = ServerConfiguration.url(
    url: "https://api.example.com",
    headers: ["Authorization": "Bearer token"]
)

let server = try MCPServer(
    name: "api-server",
    configuration: config,
    isEnabled: false,
    description: "My API server"
)
// Created at: now
// Modified at: now
// ID: auto-generated UUID
```

### Enabling a Server
```swift
let enabled = try server.withEnabled(true)
// enabled.isEnabled == true
// enabled.modifiedAt > server.modifiedAt
// enabled.id == server.id (same identity)
```

### Exporting Configuration
```swift
let servers = [server1, server2, server3]  // Some enabled, some disabled

// Export only enabled servers
let exported = ConfigurationExporter.exportEnabledServers(servers)
// Result: {
//   "server1": { "url": "...", "headers": {...} },
//   "server3": { "command": "...", "args": [...], "env": {...} }
// }

// Convert to JSON
let json = try ConfigurationExporter.toJSON(["mcpServers": exported])
```

## Testing Strategies

### Unit Tests (Domain Logic)
- No database needed
- Test invariants
- Test error cases
- Test value object equality

### Integration Tests
- Test with real repository
- Test persistence
- Test unique constraint
- Test query operations

### End-to-End Tests
- Full use case flow
- Export to actual file
- Verify JSON output format
- Test CLI commands

