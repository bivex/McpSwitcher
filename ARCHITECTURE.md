# MCP Switcher - Architecture Document

## Domain Overview

**Product:** MCP Switcher
**Purpose:** A configuration management tool that simplifies enabling/disabling MCP (Model Context Protocol) servers without manually editing JSON files and managing comments issues.

## Core Domain Model

### Ubiquitous Language

- **MCP Server**: A Model Context Protocol server configuration that can be toggled on/off
- **Server Configuration**: The complete settings needed to connect to an MCP server (command, args, environment variables, or URL-based config)
- **Server State**: Whether a server is enabled or disabled
- **Configuration Store**: The persisted location (SQLite DB) holding server definitions
- **Export**: The process of generating a JSON file from the active server configurations
- **Configuration Profile**: A named set of enabled/disabled server states

### Domain Entities

#### MCPServer
- **Identity**: `serverId` (unique identifier, UUID)
- **Invariants**:
  - Name must be non-empty and unique
  - Server is either ENABLED or DISABLED
  - Configuration must be valid (either command-based or URL-based)
  - Created date cannot be changed after creation
- **Responsibilities**:
  - Maintain server identity and metadata
  - Validate configuration format
  - Report enabled/disabled status

#### ServerConfiguration
- **Type**: Value Object (immutable)
- **Variants**:
  - **CommandBased**: `command`, `args`, `env` (for local execution)
  - **UrlBased**: `url`, `headers` (for HTTP endpoints)
- **Responsibilities**:
  - Encapsulate configuration details
  - Validate format on creation

#### MCPServerAggregate
- **Root**: MCPServer
- **Children**: ServerConfiguration
- **Responsibilities**:
  - Manage server lifecycle (create, enable, disable, delete)
  - Ensure configuration consistency
  - Generate export representation

### Domain Services

#### ConfigurationExporter
- **Purpose**: Generate JSON export from enabled servers
- **Responsibility**: Transform domain model to JSON format
- **Note**: Stateless service, no dependencies on persistence

#### ServerRepository (Interface)
- **Purpose**: Hide persistence from domain logic
- **Methods**:
  - `findById(id: String) -> MCPServer?`
  - `findAll() -> [MCPServer]`
  - `findEnabled() -> [MCPServer]`
  - `save(server: MCPServer) -> Result`
  - `delete(id: String) -> Result`
  - `toggle(id: String) -> Result`

#### StateManager (Interface)
- **Purpose**: Track enable/disable state changes
- **Methods**:
  - `enable(id: String) -> Result`
  - `disable(id: String) -> Result`
  - `getCurrentState() -> [String: Bool]`

### Domain Events

- **ServerCreated**: When a new MCP server is added
- **ServerToggled**: When a server is enabled/disabled
- **ServerDeleted**: When a server is removed
- **ConfigurationExported**: When JSON is generated
- **StateChanged**: When any server state changes

## Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (CLI / SwiftUI Interface)              │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Application Layer                  │
│  (Use Cases / Command Handlers)         │
│  - EnableServerUseCase                  │
│  - DisableServerUseCase                 │
│  - CreateServerUseCase                  │
│  - ExportConfigurationUseCase           │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Domain Layer                    │
│  - MCPServer (Entity)                   │
│  - ServerConfiguration (VO)             │
│  - Domain Exceptions & Rules            │
│  - Domain Services (Interfaces)         │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│    Infrastructure Layer                 │
│  - SQLiteServerRepository               │
│  - FileSystemConfigExporter             │
│  - SQLiteDatabase                       │
│  - JSONFileManager                      │
└─────────────────────────────────────────┘
```

### Layer Responsibilities

#### Domain Layer
- Pure business logic
- No framework dependencies
- Defines entity behaviors and invariants
- Declares interfaces for repositories (ports)
- Defines domain exceptions

#### Application Layer
- Orchestrates domain logic for use cases
- Translates external inputs to domain commands
- Handles transaction coordination
- Converts domain objects to DTOs for output

#### Infrastructure Layer
- Implements repository interfaces (adapters)
- Manages database connections
- File I/O operations
- External service calls
- No direct business logic

#### Presentation Layer
- CLI commands or SwiftUI interface
- Input validation and formatting
- Display results to user
- No business logic

## Dependency Injection Strategy

```
Application Layer
    ↓
    ├─→ Domain Services (interfaces)
    └─→ Repositories (interfaces)
        ↓
    Infrastructure Layer
        ├─→ SQLiteDatabase
        ├─→ FileSystem
        └─→ JSON Encoder/Decoder
```

## Database Schema (SQLite)

### tables
- **mcp_servers**: Core server definitions
- **server_states**: Enable/disable state (for audit trail)
- **configurations**: Configuration versions (for history)

## Folder Structure

```
McpSwitcher/
├── Domain/
│   ├── Models/
│   │   ├── MCPServer.swift
│   │   └── ServerConfiguration.swift
│   ├── Services/
│   │   ├── ConfigurationExporter.swift
│   │   └── StateManager.swift
│   ├── Repositories/
│   │   └── ServerRepository.swift
│   └── Exceptions/
│       └── DomainErrors.swift
├── Application/
│   ├── UseCases/
│   │   ├── EnableServerUseCase.swift
│   │   ├── DisableServerUseCase.swift
│   │   ├── CreateServerUseCase.swift
│   │   └── ExportConfigurationUseCase.swift
│   ├── DTOs/
│   │   ├── ServerDTO.swift
│   │   └── ConfigurationDTO.swift
│   └── CommandHandlers/
│       └── CLICommandHandler.swift
├── Infrastructure/
│   ├── Persistence/
│   │   ├── SQLiteDatabase.swift
│   │   ├── SQLiteServerRepository.swift
│   │   └── Migrations.swift
│   ├── FileIO/
│   │   ├── JSONFileManager.swift
│   │   └── FileSystemExporter.swift
│   └── Configuration/
│       └── Config.swift
├── Presentation/
│   ├── CLI/
│   │   ├── CLIApp.swift
│   │   └── Commands.swift
│   ├── UI/
│   │   └── MainView.swift
│   └── Formatters.swift
└── Package.swift
```

## Key Design Decisions

1. **Repository Pattern**: Abstracts persistence, allows SQLite to be swapped
2. **Domain-Driven**: Business logic isolated from frameworks
3. **Immutable Value Objects**: ServerConfiguration never changes, new version created
4. **Events-Driven**: State changes publish events for side effects
5. **Hexagonal Architecture**: Clear ports (interfaces) and adapters (implementations)
6. **Configuration as Code**: All settings externalized, no hardcoding

## Non-Functional Requirements

- **Performance**: Load/save 100+ servers in <1s
- **Reliability**: ACID transactions for state changes
- **Usability**: Toggle any server state in one command
- **Maintainability**: Clear separation of concerns
- **Testability**: Domain logic testable without database
- **Data Safety**: Automatic backups before exports

