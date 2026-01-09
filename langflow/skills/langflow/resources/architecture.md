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
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    ServiceManager (Singleton)                         │  │
│  │                  Dependency Injection Container                       │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
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

## Key Design Patterns

Langflow employs several architectural patterns:

| Pattern | Implementation |
|---------|----------------|
| **Visual Editor** | @xyflow/react (ReactFlow v12.3.6) canvas with drag-and-drop nodes |
| **API-Driven Architecture** | REST API at `/api/v1/*` and `/api/v2/*` with WebSocket streaming |
| **Component-Based Extensibility** | Custom components via Python classes in registry |
| **Service Layer with DI** | ServiceManager singleton manages all service dependencies |
| **DAG-Based Execution** | Topological sorting ensures correct execution order |

## Frontend Architecture

**Location:** `src/frontend`
**Technology:** React 19 + Vite + TypeScript
**Dev Port:** 3000 (proxied to backend in production)

### Visual Editor

Built on @xyflow/react (ReactFlow v12.3.6), the flow editor provides:
- Drag-and-drop component placement
- Edge connections with type validation
- Real-time collaboration support
- Interactive node configuration panels

### State Management (Zustand v4.5.2)

Three-tiered store architecture:

| Store | Purpose |
|-------|---------|
| **flowStore** | Current flow state, nodes, edges, build status, real-time updates |
| **flowsManagerStore** | Multiple flows management, undo/redo with snapshot-before-mutate pattern |
| **utilityStore** | Global UI settings, feature flags, user preferences |

The **snapshot-before-mutate pattern** in flowsManagerStore captures state before changes, enabling reliable undo/redo operations across complex flow modifications.

### API Client

Uses Axios with interceptors for:
- Authentication token injection
- Error handling and retry logic
- Request/response transformation

## Backend Architecture

**Location:** `src/backend/base/langflow`
**Technology:** FastAPI + SQLAlchemy + Alembic
**Default Port:** 7860

### API Structure

```
/api/v1/                    /api/v2/
├── run/                    ├── flows/
├── flows/                  ├── components/
├── build/                  └── ...
├── mcp/
├── files/
├── monitor/
├── api_key/
├── login/
└── custom_component/
```

### ServiceManager (Dependency Injection)

The `ServiceManager` singleton acts as a dependency injection container, providing centralized access to all backend services:

```python
class ServiceManager:
    """Singleton managing service dependencies"""
    database_service: DatabaseService
    cache_service: CacheService
    auth_service: AuthService
    job_queue_service: JobQueueService
```

Services are lazily initialized and shared across request handlers, ensuring consistent state and efficient resource usage.

### Flow Execution Pipeline

1. **Request received** at `/api/v1/run/{flow_id}`
2. **Flow loaded** from database via ServiceManager
3. **Graph constructed** from flow JSON (DAG representation)
4. **Topological sort** determines execution order
5. **Vertices executed** in dependency order
6. **Results streamed** via SSE/WebSocket
7. **Response returned** with outputs

## Execution Engine (lfx)

**Location:** `src/lfx`
**Purpose:** Portable, independent, DAG-based flow execution library

### Core Classes

```python
class Graph:
    """DAG representation with topological execution"""
    def __init__(self, flow_data: dict)
    def topological_sort() -> List[Vertex]
    async def run() -> Dict[str, Any]

class Vertex:
    """Node wrapper managing component lifecycle"""
    component: Component
    edges: List[Edge]
    async def build() -> VertexBuildResult

class Component:
    """Base class for all flow components"""
    inputs: List[Input]
    outputs: List[Output]
    def build() -> Any
```

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

### lfx CLI

```bash
lfx serve flow.json --port 8000   # Serve as REST API
lfx run flow.json --input "Hello" # Execute directly
```

## Database Schema

| Table | Purpose |
|-------|---------|
| `flow` | Flow definitions (JSON) |
| `user` | User accounts |
| `api_key` | API keys for authentication |
| `message` | Chat message history |
| `variable` | Global variables (encrypted) |
| `folder` | Project/folder organization |

## MCP Protocol Support

### As Server
- Projects expose flows as MCP tools
- Endpoint: `/api/v1/mcp/project/{project_id}/`
- Supports SSE and Streamable HTTP transports

### As Client
- MCP Tools component connects to external servers
- Flows can call tools from any MCP-compatible server

## Development vs Production

| Aspect | Development | Production |
|--------|-------------|------------|
| **Frontend** | `npm run dev` on port 3000 | Served by backend |
| **Backend** | `uv run langflow run --dev` on port 7860 | Same port, frontend bundled |
| **Database** | SQLite | PostgreSQL recommended |
| **Cache** | In-memory | Redis recommended |
| **Storage** | Local filesystem | S3/GCS recommended |

## Production Architecture

```
Internet → Load Balancer → Langflow Instances → PostgreSQL
                                             → Redis (cache)
                                             → S3 (files)
```

Key configurations:
- `LANGFLOW_SECRET_KEY`: Secure secret for JWT
- `LANGFLOW_AUTO_LOGIN=False`: Enable authentication
- `LANGFLOW_DATABASE_URL`: PostgreSQL connection string
