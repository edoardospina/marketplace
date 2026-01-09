---
name: langflow
description: This skill should be used when the user asks to "create a Langflow flow", "build a Langflow component", "run a Langflow workflow", "configure Langflow server", "deploy Langflow", "use Langflow API", "create custom Langflow component", "connect Langflow to MCP", "debug Langflow flow", "set up Langflow environment variables", mentions "langflow.org", works with Langflow JSON files, or needs guidance on AI workflow automation, LLM application building, RAG pipelines, or agent workflows in Langflow.
---

# Langflow Knowledge Base

Langflow is an open-source, Python-based, low-code platform for building AI applications. It provides a visual editor for creating workflows (called "flows") that can include agents, LLMs, RAG pipelines, and custom components.

**Current Version:** 1.7.1 (as of OpenAPI spec)
**Documentation:** https://docs.langflow.org/
**Repository:** https://github.com/langflow-ai/langflow

## Quick Reference

| Resource | Description |
|----------|-------------|
| `resources/openapi.json` | Full OpenAPI specification - query with `jq` |
| `resources/architecture.md` | System architecture and internals |
| `resources/components-guide.md` | Component system and data types |
| `resources/custom-components.md` | Creating custom Python components |
| `resources/api-reference.md` | REST API usage and endpoints |
| `resources/cli-reference.md` | CLI commands and configuration |

## Architecture Overview

Langflow is a full-stack application with three main layers:

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend (React 19 + Vite)               │
│  - Visual flow editor using @xyflow/react                   │
│  - State management with Zustand                            │
│  - Runs on port 3000 (dev) or served by backend (prod)      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Backend (FastAPI)                        │
│  - REST API at /api/v1/*                                    │
│  - WebSocket support for streaming                          │
│  - SQLAlchemy + Alembic for database                        │
│  - Default port: 7860                                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Execution Engine (lfx)                   │
│  - Graph-based DAG execution                                │
│  - Component registry and loading                           │
│  - Vertex building and result passing                       │
│  - Can run standalone via `lfx serve` or `lfx run`          │
└─────────────────────────────────────────────────────────────┘
```

## Core Concepts

### Flows
A **flow** is a directed acyclic graph (DAG) of components that process data. Flows are:
- Created visually in the editor or via API
- Serializable to JSON for export/import
- Executed via the Playground or API endpoints
- Stored in the Langflow database (SQLite by default, PostgreSQL supported)

### Components
**Components** are the building blocks of flows. Each component:
- Inherits from the `Component` base class
- Defines inputs, outputs, and parameters
- Has a `build()` method for execution logic
- Can be connected via typed ports (color-coded)

**Port Colors (Data Types):**
| Type | Color | Description |
|------|-------|-------------|
| Data | Red | Structured key-value data |
| DataFrame | Pink | Tabular pandas data |
| Embeddings | Emerald | Vector embeddings |
| LanguageModel | Fuchsia | LLM instance |
| Memory | Orange | Chat memory |
| Message | Indigo | Chat messages |
| Tool | Cyan | Agent tools |
| Unknown | Gray | Multiple types |

### Agents
The **Agent** component is central to agentic flows:
- Supports multiple LLM providers (OpenAI, Anthropic, etc.)
- Tools are attached via **Tool Mode** on components
- Built-in chat memory with session ID support
- Outputs `Message` data to Chat Output

### Data Types
Langflow uses structured data types for flow communication:

- **`Message`**: Chat messages with sender, text, timestamp, session_id
- **`Data`**: Generic key-value store with `text_key` for primary text
- **`DataFrame`**: Pandas DataFrame wrapper for tabular data
- **`Tool`**: LangChain StructuredTool for agent use

## API Quick Reference

### Running Flows

**Simple Run:**
```bash
curl -X POST "$LANGFLOW_URL/api/v1/run/$FLOW_ID" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $LANGFLOW_API_KEY" \
  -d '{
    "input_value": "Hello!",
    "input_type": "chat",
    "output_type": "chat",
    "session_id": "my-session"
  }'
```

**With Streaming:**
```bash
curl -X POST "$LANGFLOW_URL/api/v1/run/$FLOW_ID?stream=true" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $LANGFLOW_API_KEY" \
  -d '{"input_value": "Tell me a story"}'
```

**With Tweaks (runtime overrides):**
```bash
curl -X POST "$LANGFLOW_URL/api/v1/run/$FLOW_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "input_value": "Hello",
    "tweaks": {
      "ComponentName-abc123": {
        "parameter_name": "new_value"
      }
    }
  }'
```

### Key API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/run/{flow_id}` | POST | Run a flow |
| `/api/v1/flows/` | GET, POST | List/create flows |
| `/api/v1/flows/{flow_id}` | GET, PATCH, DELETE | Manage flow |
| `/api/v1/build/{flow_id}/flow` | POST | Build entire flow |
| `/api/v1/mcp/` | POST | MCP message handling |
| `/api/v1/custom_component` | POST | Load custom component |

## CLI Commands

```bash
# Start Langflow server
uv run langflow run --port 7860

# Start backend only (headless mode)
uv run langflow run --backend-only

# Use specific .env file
uv run langflow run --env-file /path/to/.env

# Create superuser
uv run langflow superuser --username admin --password secret

# Run database migrations
uv run langflow migration --fix
```

## Environment Variables

**Server Configuration:**
- `LANGFLOW_HOST` - Host address (default: localhost)
- `LANGFLOW_PORT` - Port number (default: 7860)
- `LANGFLOW_WORKERS` - Worker processes (default: 1)
- `LANGFLOW_BACKEND_ONLY` - Headless mode (default: False)

**Database:**
- `LANGFLOW_DATABASE_URL` - Database connection string
- `LANGFLOW_CONFIG_DIR` - Config directory path

**Components:**
- `LANGFLOW_COMPONENTS_PATH` - Custom components directory

**Security:**
- `LANGFLOW_SECRET_KEY` - Secret key for encryption
- `LANGFLOW_AUTO_LOGIN` - Skip auth (default: True for local)

## Custom Components

Custom components extend Langflow with new functionality:

```python
from lfx.custom.custom_component.component import Component
from lfx.io import StrInput, Output

class MyComponent(Component):
    display_name = "My Component"
    description = "Does something useful"
    icon = "Sparkles"

    inputs = [
        StrInput(
            name="input_text",
            display_name="Input Text",
            info="Text to process"
        )
    ]

    outputs = [
        Output(
            name="result",
            display_name="Result",
            method="process"
        )
    ]

    def process(self) -> Message:
        # Access input with self.input_text
        result = self.input_text.upper()
        return Message(text=result)
```

**Save Location:** `src/lfx/src/lfx/components/{category}/`

## MCP Integration

Langflow supports the Model Context Protocol (MCP):

**As MCP Server:** Each project exposes flows as tools at `/api/v1/mcp/`
**As MCP Client:** Use the MCP Tools component to connect to external MCP servers

## Querying the OpenAPI Spec

Use `jq` to explore the API specification:

```bash
# List all endpoints
jq '.paths | keys' resources/openapi.json

# Get run endpoint details
jq '.paths["/api/v1/run/{flow_id_or_name}"]' resources/openapi.json

# List schema types
jq '.components.schemas | keys' resources/openapi.json

# Get Flow schema
jq '.components.schemas.Flow' resources/openapi.json
```

## Common Patterns

### RAG Pipeline
1. **File/URL Input** → Load documents
2. **Text Splitter** → Chunk documents
3. **Embedding Model** → Generate embeddings
4. **Vector Store** → Store/retrieve vectors
5. **Agent/LLM** → Generate response

### Agent with Tools
1. **Chat Input** → User message
2. **Agent** → Reasoning engine
3. **Tool Components** (Tool Mode enabled) → Connected to Agent
4. **Chat Output** → Response

### Batch Processing
1. **Data Input** → Load data
2. **Loop** → Iterate over items
3. **Processing Component** → Transform each item
4. **Data Output** → Collect results

## Troubleshooting

**Flow not running:**
- Check component connections (matching port colors)
- Verify API keys in Global Variables
- Check logs: `LANGFLOW_LOG_LEVEL=debug`

**Custom component not loading:**
- Ensure `__init__.py` exists in category folder
- Check import path: `from lfx.custom...`
- Rebuild: `make install_backend`

**API authentication errors:**
- Set `x-api-key` header with valid Langflow API key
- Or disable auth: `LANGFLOW_AUTO_LOGIN=True`

## Further Reading

- **Architecture Details:** `resources/architecture.md`
- **Component Deep Dive:** `resources/components-guide.md`
- **Custom Components:** `resources/custom-components.md`
- **API Reference:** `resources/api-reference.md`
- **CLI Reference:** `resources/cli-reference.md`
- **Official Docs:** https://docs.langflow.org/
