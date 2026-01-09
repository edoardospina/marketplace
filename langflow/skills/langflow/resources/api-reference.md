# Langflow API Reference

This document provides a comprehensive reference for the Langflow REST API (v1.7.1).

## Base URL

```
https://your-langflow-instance.com/api/v1
```

## Authentication

Langflow supports two authentication methods:

### API Key Authentication (Recommended for Programmatic Access)

Include your API key in the request header:

```bash
curl -H "x-api-key: YOUR_API_KEY" https://your-instance.com/api/v1/flows/
```

Or as a query parameter:

```bash
curl "https://your-instance.com/api/v1/flows/?x-api-key=YOUR_API_KEY"
```

### Session Authentication (Browser-Based)

For browser-based access, use OAuth2 password flow:

```bash
curl -X POST https://your-instance.com/api/v1/login \
  -d "username=YOUR_USERNAME&password=YOUR_PASSWORD"
```

---

## Run Endpoints

Execute flows programmatically.

### Run Flow (Simplified)

Execute a flow by ID or name with simplified request format.

```
POST /api/v1/run/{flow_id_or_name}
```

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `flow_id_or_name` | string | Yes | The flow UUID or endpoint name |

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `stream` | boolean | `false` | Enable streaming response |
| `user_id` | string/uuid | null | Optional user ID |

#### Request Body

```json
{
  "input_request": {
    "input_value": "Hello, how can you help me?",
    "input_type": "chat",
    "output_type": "chat",
    "output_component": "",
    "tweaks": {},
    "session_id": "optional-session-id"
  },
  "context": {
    "custom_key": "custom_value"
  }
}
```

#### Input Request Fields

| Field | Type | Description |
|-------|------|-------------|
| `input_value` | string | The input text to process |
| `input_type` | string | Input type: `chat`, `text`, or `any` |
| `output_type` | string | Output type: `chat`, `text`, `any`, or `debug` |
| `output_component` | string | Specific output component to retrieve results from |
| `tweaks` | object | Runtime parameter overrides (see Tweaks section) |
| `session_id` | string | Session ID for conversation continuity |

#### Example: Basic Request

```bash
curl -X POST "https://your-instance.com/api/v1/run/my-chatbot" \
  -H "x-api-key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input_request": {
      "input_value": "What is the weather today?",
      "input_type": "chat",
      "output_type": "chat"
    }
  }'
```

#### Example: Streaming Request

```bash
curl -X POST "https://your-instance.com/api/v1/run/my-chatbot?stream=true" \
  -H "x-api-key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input_request": {
      "input_value": "Tell me a story",
      "input_type": "chat",
      "output_type": "chat"
    }
  }'
```

#### Response (Non-Streaming)

```json
{
  "outputs": [
    {
      "inputs": { "input_value": "What is the weather today?" },
      "outputs": [
        {
          "results": { "message": { "text": "I don't have access to real-time weather data..." } },
          "artifacts": {}
        }
      ]
    }
  ],
  "session_id": "abc123-session-id"
}
```

#### Streaming Response

When `stream=true`, the response is a Server-Sent Events (SSE) stream:

```
event: add_message
data: {"message": "Starting..."}

event: token
data: {"token": "Hello"}

event: token
data: {"token": " there"}

event: end
data: {"result": {...}}
```

#### Streaming Events

| Event | Description |
|-------|-------------|
| `add_message` | New messages during execution |
| `token` | Individual tokens during streaming |
| `end` | Final execution result |

---

### Run Flow (Advanced)

Execute a flow with advanced options including multiple inputs, output selection, and tweaks.

```
POST /api/v1/run/advanced/{flow_id_or_name}
```

#### Request Body

```json
{
  "inputs": [
    {
      "components": ["ChatInput-abc123"],
      "input_value": "Hello!",
      "type": "chat"
    }
  ],
  "outputs": ["ChatOutput-xyz789"],
  "tweaks": {
    "OpenAI-model": {
      "model_name": "gpt-4",
      "temperature": 0.7
    }
  },
  "stream": false,
  "session_id": "optional-session-id"
}
```

#### Input Value Request Fields

| Field | Type | Description |
|-------|------|-------------|
| `components` | array | Target component IDs or names |
| `input_value` | string | The input value |
| `session` | string | Session identifier |
| `type` | string | Input type: `chat`, `text`, `any`, or `json` |

#### Example: Multiple Inputs with Tweaks

```bash
curl -X POST "https://your-instance.com/api/v1/run/advanced/my-flow" \
  -H "x-api-key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "inputs": [
      {"components": ["component1"], "input_value": "First input"},
      {"components": ["component2"], "input_value": "Second input"}
    ],
    "outputs": ["OutputComponent"],
    "tweaks": {
      "OpenAI-model": {"temperature": 0.5}
    }
  }'
```

---

### Run Flow (Session-Based)

Execute a flow using session authentication (cookies). Requires the `agentic_experience` feature flag.

```
POST /api/v1/run/session/{flow_id_or_name}
```

Same parameters and body as the simplified run endpoint, but uses session cookies for authentication.

---

## Tweaks

Tweaks allow runtime customization of flow component parameters without modifying the flow definition.

### Tweak Format

```json
{
  "tweaks": {
    "parameter_name": "global_value",
    "Component Name": {
      "parameter_name": "component_specific_value"
    },
    "component_id": {
      "parameter_name": "value_by_id"
    }
  }
}
```

### Tweak Examples

```json
{
  "tweaks": {
    "OpenAI-model-abc123": {
      "model_name": "gpt-4",
      "temperature": 0.7,
      "max_tokens": 2000
    },
    "PromptTemplate-xyz789": {
      "template": "You are a helpful assistant. {context}"
    }
  }
}
```

### Global Variables via Headers

You can pass global variables through HTTP headers with the prefix `X-LANGFLOW-GLOBAL-VAR-*`:

```bash
curl -X POST "https://your-instance.com/api/v1/run/my-flow" \
  -H "x-api-key: YOUR_API_KEY" \
  -H "X-LANGFLOW-GLOBAL-VAR-API_KEY: external-api-key" \
  -H "X-LANGFLOW-GLOBAL-VAR-USER_ID: user123" \
  -H "Content-Type: application/json" \
  -d '{"input_request": {"input_value": "Hello"}}'
```

---

## Flow Management Endpoints

CRUD operations for flow resources.

### List Flows

Retrieve all flows with optional pagination and filtering.

```
GET /api/v1/flows/
```

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `remove_example_flows` | boolean | `false` | Exclude example flows |
| `components_only` | boolean | `false` | Return only components |
| `get_all` | boolean | `true` | Return all flows (no pagination) |
| `folder_id` | uuid | null | Filter by folder/project |
| `header_flows` | boolean | `false` | Return only flow headers |
| `page` | integer | 1 | Page number (min: 1) |
| `size` | integer | 50 | Page size (min: 1, max: 100) |

#### Example: List All Flows

```bash
curl -X GET "https://your-instance.com/api/v1/flows/" \
  -H "x-api-key: YOUR_API_KEY"
```

#### Example: Paginated with Folder Filter

```bash
curl -X GET "https://your-instance.com/api/v1/flows/?folder_id=abc123&page=1&size=20" \
  -H "x-api-key: YOUR_API_KEY"
```

#### Response

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "My Chatbot",
    "description": "A helpful chatbot",
    "user_id": "user-uuid",
    "folder_id": "folder-uuid",
    "is_component": false,
    "webhook": true,
    "endpoint_name": "my-chatbot",
    "mcp_enabled": false,
    "access_type": "PRIVATE",
    "updated_at": "2024-01-15T10:30:00Z",
    "data": { ... }
  }
]
```

---

### Get Flow

Retrieve a specific flow by ID.

```
GET /api/v1/flows/{flow_id}
```

#### Example

```bash
curl -X GET "https://your-instance.com/api/v1/flows/550e8400-e29b-41d4-a716-446655440000" \
  -H "x-api-key: YOUR_API_KEY"
```

---

### Create Flow

Create a new flow.

```
POST /api/v1/flows/
```

#### Request Body

```json
{
  "name": "New Chatbot",
  "description": "My new chatbot flow",
  "data": {
    "nodes": [...],
    "edges": [...]
  },
  "is_component": false,
  "webhook": true,
  "endpoint_name": "new-chatbot",
  "mcp_enabled": false,
  "folder_id": "folder-uuid",
  "tags": ["chatbot", "production"]
}
```

#### Example

```bash
curl -X POST "https://your-instance.com/api/v1/flows/" \
  -H "x-api-key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Chatbot",
    "description": "A helpful assistant",
    "webhook": true,
    "endpoint_name": "new-chatbot"
  }'
```

#### Response (201 Created)

```json
{
  "id": "new-flow-uuid",
  "name": "New Chatbot",
  "description": "A helpful assistant",
  ...
}
```

---

### Update Flow

Update an existing flow.

```
PATCH /api/v1/flows/{flow_id}
```

#### Example

```bash
curl -X PATCH "https://your-instance.com/api/v1/flows/550e8400-e29b-41d4-a716-446655440000" \
  -H "x-api-key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Chatbot Name",
    "description": "Updated description"
  }'
```

---

### Delete Flow

Delete a flow by ID.

```
DELETE /api/v1/flows/{flow_id}
```

#### Example

```bash
curl -X DELETE "https://your-instance.com/api/v1/flows/550e8400-e29b-41d4-a716-446655440000" \
  -H "x-api-key: YOUR_API_KEY"
```

---

### Delete Multiple Flows

Delete multiple flows in a single request.

```
DELETE /api/v1/flows/
```

#### Request Body

```json
["flow-uuid-1", "flow-uuid-2", "flow-uuid-3"]
```

#### Example

```bash
curl -X DELETE "https://your-instance.com/api/v1/flows/" \
  -H "x-api-key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '["550e8400-e29b-41d4-a716-446655440000", "660e8400-e29b-41d4-a716-446655440001"]'
```

---

### Upload Flows

Upload flows from a JSON file.

```
POST /api/v1/flows/upload/
```

#### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `folder_id` | uuid | Target folder for uploaded flows |

#### Example

```bash
curl -X POST "https://your-instance.com/api/v1/flows/upload/?folder_id=folder-uuid" \
  -H "x-api-key: YOUR_API_KEY" \
  -F "file=@my-flows.json"
```

---

### Download Flows

Download multiple flows as a zip file.

```
POST /api/v1/flows/download/
```

#### Example

```bash
curl -X POST "https://your-instance.com/api/v1/flows/download/" \
  -H "x-api-key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '["flow-uuid-1", "flow-uuid-2"]' \
  -o flows.zip
```

---

## Build Endpoints

Build and execute flow graphs with fine-grained control.

### Build Flow

Build and process a flow, returning a job ID for event polling.

```
POST /api/v1/build/{flow_id}/flow
```

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `stop_component_id` | string | null | Stop execution at this component |
| `start_component_id` | string | null | Start execution from this component |
| `log_builds` | boolean | `true` | Log the build process |
| `flow_name` | string | null | Optional flow name |
| `event_delivery` | string | `polling` | Event delivery type: `polling` or `streaming` |

#### Example

```bash
curl -X POST "https://your-instance.com/api/v1/build/550e8400-e29b-41d4-a716-446655440000/flow" \
  -H "x-api-key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "inputs": {"key": "value"},
    "data": {}
  }'
```

#### Response

```json
{
  "job_id": "job-uuid-for-polling"
}
```

---

### Get Build Events

Get events for a specific build job.

```
GET /api/v1/build/{job_id}/events
```

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `event_delivery` | string | `streaming` | Event delivery type |

#### Example

```bash
curl -X GET "https://your-instance.com/api/v1/build/job-uuid/events" \
  -H "x-api-key: YOUR_API_KEY"
```

---

### Cancel Build Job

Cancel an in-progress build job.

```
POST /api/v1/build/{job_id}/cancel
```

#### Example

```bash
curl -X POST "https://your-instance.com/api/v1/build/job-uuid/cancel" \
  -H "x-api-key: YOUR_API_KEY"
```

---

## Webhook Endpoints

Trigger flows via webhooks for external integrations.

### Webhook Run Flow

Execute a flow via webhook. No authentication required for public webhooks.

```
POST /api/v1/webhook/{flow_id_or_name}
```

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `flow_id_or_name` | string | Flow UUID or endpoint name |

#### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `user_id` | string/uuid | Optional user ID |

#### Notes

- The flow must have `webhook: true` enabled
- Request body is passed directly to the flow
- Returns a 202 Accepted response (async processing)

#### Example: Simple Webhook

```bash
curl -X POST "https://your-instance.com/api/v1/webhook/my-webhook-flow" \
  -H "Content-Type: application/json" \
  -d '{
    "event": "user.created",
    "data": {
      "user_id": "12345",
      "email": "user@example.com"
    }
  }'
```

#### Response (202 Accepted)

```json
{
  "status": "processing",
  "task_id": "task-uuid"
}
```

---

## MCP Endpoints

Model Context Protocol (MCP) integration endpoints for exposing flows as tools.

### MCP Messages Handler

Handle MCP protocol messages.

```
POST /api/v1/mcp/
```

---

### MCP SSE (Server-Sent Events)

Connect to MCP via SSE transport.

```
GET /api/v1/mcp/sse
```

#### Example

```bash
curl -N "https://your-instance.com/api/v1/mcp/sse" \
  -H "x-api-key: YOUR_API_KEY"
```

---

### MCP Streamable HTTP

Connect to MCP via streamable HTTP transport (new protocol).

```
GET/POST/DELETE /api/v1/mcp/streamable
```

---

### Project-Specific MCP Endpoints

#### Project SSE

```
GET /api/v1/mcp/project/{project_id}/sse
```

#### Project Streamable

```
GET/POST /api/v1/mcp/project/{project_id}/streamable
```

---

### Install MCP Configuration

Install MCP server configuration for Cursor, Windsurf, or Claude.

```
POST /api/v1/mcp/project/{project_id}/install
```

#### Example

```bash
curl -X POST "https://your-instance.com/api/v1/mcp/project/project-uuid/install" \
  -H "x-api-key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "target": "cursor"
  }'
```

---

### Check Installed MCP Servers

Check if MCP server configuration is installed for a project.

```
GET /api/v1/mcp/project/{project_id}/installed
```

#### Example

```bash
curl -X GET "https://your-instance.com/api/v1/mcp/project/project-uuid/installed" \
  -H "x-api-key: YOUR_API_KEY"
```

---

## Error Responses

### Standard Error Format

```json
{
  "detail": "Error message describing the issue"
}
```

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 202 | Accepted (async processing) |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Missing or invalid authentication |
| 404 | Not Found - Resource doesn't exist |
| 422 | Validation Error - Invalid request format |
| 500 | Internal Server Error |

### Validation Error Response (422)

```json
{
  "detail": [
    {
      "loc": ["body", "input_request", "input_value"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

---

## Complete Examples

### Full Chat Flow Integration

```bash
#!/bin/bash

API_URL="https://your-instance.com/api/v1"
API_KEY="your-api-key"
FLOW_ID="your-flow-id"
SESSION_ID="user-session-$(date +%s)"

# Function to send a message
send_message() {
  local message="$1"

  curl -s -X POST "${API_URL}/run/${FLOW_ID}" \
    -H "x-api-key: ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{
      \"input_request\": {
        \"input_value\": \"${message}\",
        \"input_type\": \"chat\",
        \"output_type\": \"chat\",
        \"session_id\": \"${SESSION_ID}\"
      }
    }"
}

# Send messages
send_message "Hello!"
send_message "What can you help me with?"
```

### Streaming with Python

```python
import requests
import json

API_URL = "https://your-instance.com/api/v1"
API_KEY = "your-api-key"
FLOW_ID = "your-flow-id"

def stream_response(message):
    response = requests.post(
        f"{API_URL}/run/{FLOW_ID}",
        params={"stream": "true"},
        headers={
            "x-api-key": API_KEY,
            "Content-Type": "application/json"
        },
        json={
            "input_request": {
                "input_value": message,
                "input_type": "chat",
                "output_type": "chat"
            }
        },
        stream=True
    )

    for line in response.iter_lines():
        if line:
            line = line.decode('utf-8')
            if line.startswith('data: '):
                data = json.loads(line[6:])
                if 'token' in data:
                    print(data['token'], end='', flush=True)
    print()

stream_response("Tell me a short story")
```

### Flow with Runtime Tweaks

```bash
curl -X POST "https://your-instance.com/api/v1/run/my-flow" \
  -H "x-api-key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input_request": {
      "input_value": "Explain quantum computing",
      "tweaks": {
        "OpenAIModel-abc123": {
          "model_name": "gpt-4-turbo",
          "temperature": 0.3,
          "max_tokens": 1000
        },
        "PromptTemplate-xyz789": {
          "system_message": "You are a physics professor. Explain concepts clearly."
        }
      }
    }
  }'
```

---

## Rate Limiting

Rate limits vary by deployment. Check response headers for rate limit information:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1704067200
```

---

## See Also

- [Architecture Guide](./architecture.md) - Understanding Langflow's architecture
- [Components Guide](./components-guide.md) - Available components and their usage
- [Custom Components](./custom-components.md) - Building custom components
