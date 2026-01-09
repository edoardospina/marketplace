# Langflow Architecture

Langflow is a low-code platform for building and deploying AI applications, structured as a full-stack web application with a React frontend, FastAPI backend, and the `lfx` execution engine.

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Client Layer                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Web Browser                                       │    │
│  │  - React 19 Application                                             │    │
│  │  - @xyflow/react canvas for visual editing                          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Frontend - src/frontend                               │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐          │
│  │   FlowEditor     │  │  Zustand Stores  │  │   API Client     │          │
│  │ Visual Builder   │  │ flowStore        │  │ axios + intercept│          │
│  │                  │  │ flowsManagerStore│  │                  │          │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘          │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │ HTTP/WebSocket
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                   Backend - src/backend/base/langflow                        │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐          │
│  │  FastAPI App     │  │    Chat API      │  │   Flows API      │          │
│  │  main.py         │  │  api/v1/chat.py  │  │  api/v1/flows.py │          │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐          │
│  │ Endpoints API    │  │   Build API      │  │    MCP API       │          │
│  │ api/v1/endpoints │  │  api/v1/build    │  │   api/v1/mcp     │          │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘          │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     Execution Layer - src/lfx                                │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐          │
│  │      Graph       │  │     Vertex       │  │    Component     │          │
│  │ DAG execution    │  │ Node wrapper     │  │ Business logic   │          │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │              Component Registry (component_index.json)               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Services Layer                                      │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│  │ Database     │ │    Cache     │ │     Auth     │ │  Job Queue   │       │
│  │ SQLAlchemy   │ │  async/redis │ │     JWT      │ │   Async      │       │
│  │ + Alembic    │ │              │ │              │ │              │       │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘       │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Data Layer                                         │
│  ┌────────────────────────────────┐  ┌────────────────────────────────┐    │
│  │    SQLite / PostgreSQL         │  │       File Storage             │    │
│  │    langflow.db                 │  │    Local / S3 / GDrive         │    │
│  └────────────────────────────────┘  └────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Frontend Architecture

**Location:** `src/frontend`
**Technology:** React 19 + Vite + TypeScript

### Key Components

| Component | Purpose |
|-----------|---------|
| `FlowEditor` | Main visual flow builder canvas |
| `GenericNode` | Renders individual components on canvas |
| `NodeToolbar` | Component actions and controls |
| `Playground` | Interactive flow testing interface |

### State Management (Zustand)

- **flowStore**: Current flow state, nodes, edges
- **flowsManagerStore**: Multiple flows management
- **typesStore**: Component type definitions
- **authContext**: User authentication state

### API Client

Uses Axios with interceptors for:
- Authentication token injection
- Error handling
- Request/response transformation

## Backend Architecture

**Location:** `src/backend/base/langflow`
**Technology:** FastAPI + SQLAlchemy + Alembic

### API Structure

```
/api/v1/
├── run/           # Flow execution
├── flows/         # Flow CRUD
├── build/         # Flow building
├── mcp/           # MCP protocol
├── files/         # File management
├── monitor/       # Session monitoring
├── api_key/       # API key management
├── login/         # Authentication
└── custom_component/  # Custom component loading
```

### Services

| Service | Purpose |
|---------|---------|
| `DatabaseService` | SQLAlchemy ORM + Alembic migrations |
| `CacheService` | Flow and result caching |
| `AuthService` | JWT authentication and authorization |
| `JobQueueService` | Async job execution |

### Flow Execution Pipeline

1. **Request received** at `/api/v1/run/{flow_id}`
2. **Flow loaded** from database
3. **Graph constructed** from flow JSON
4. **JobQueue creates** async execution job
5. **Vertices executed** in topological order
6. **Results streamed** back via SSE/WebSocket
7. **Response returned** with outputs

## Execution Engine (lfx)

**Location:** `src/lfx`
**Purpose:** Portable, independent flow execution library

### Core Classes

```python
# Graph - DAG representation
class Graph:
    def __init__(self, flow_data: dict)
    def topological_sort() -> List[Vertex]
    async def run() -> Dict[str, Any]

# Vertex - Node wrapper
class Vertex:
    component: Component
    edges: List[Edge]
    async def build() -> VertexBuildResult

# Component - Base class
class Component:
    inputs: List[Input]
    outputs: List[Output]
    def build() -> Any
```

### Component Registry

`component_index.json` contains:
- Component metadata (name, description, icon)
- Input/output definitions
- Embedded Python code
- Category organization

### Execution Flow

```
Flow JSON → Graph → Topological Sort → Execute Vertices → Collect Results
                          │
                          ▼
              ┌───────────────────────┐
              │ For each vertex:      │
              │ 1. Instantiate comp.  │
              │ 2. Set input values   │
              │ 3. Call build()       │
              │ 4. Pass to dependents │
              └───────────────────────┘
```

## lfx CLI

The `lfx` package includes standalone CLI commands:

```bash
# Serve a flow as REST API
lfx serve flow.json --port 8000
# Creates endpoint at /flows/{flow_id}/run

# Run a flow directly
lfx run flow.json --input "Hello"
# Executes and prints output
```

## Database Schema

Key tables in the Langflow database:

| Table | Purpose |
|-------|---------|
| `flow` | Flow definitions (JSON) |
| `user` | User accounts |
| `api_key` | API keys for authentication |
| `message` | Chat message history |
| `variable` | Global variables (encrypted) |
| `folder` | Project/folder organization |

## File Storage

Langflow supports multiple storage backends:
- **Local**: Default, files in config directory
- **S3**: AWS S3 or compatible (MinIO)
- **GCS**: Google Cloud Storage

Configured via `LANGFLOW_STORAGE_*` environment variables.

## MCP Protocol Support

Langflow implements Model Context Protocol:

### As Server
- Each project exposes flows as MCP tools
- Endpoint: `/api/v1/mcp/project/{project_id}/`
- Supports SSE and Streamable HTTP transports

### As Client
- MCP Tools component connects to external servers
- Flows can call tools from any MCP-compatible server

## Development Mode

**Frontend:** `npm run dev` → localhost:3000
**Backend:** `uv run langflow run --dev` → localhost:7860

In development:
- Frontend proxies API calls to backend
- Hot-reloading enabled for both
- Debug logging available

## Production Deployment

Recommended architecture:
```
Internet → Load Balancer → Langflow Instances → PostgreSQL
                                             → Redis (cache)
                                             → S3 (files)
```

Key considerations:
- Use PostgreSQL instead of SQLite
- Enable Redis for caching
- Configure external file storage
- Set proper `LANGFLOW_SECRET_KEY`
- Enable authentication (`LANGFLOW_AUTO_LOGIN=False`)
