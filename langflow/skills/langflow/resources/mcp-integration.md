# MCP Integration in Langflow

Langflow provides comprehensive Model Context Protocol (MCP) integration, enabling both server and client capabilities. This allows Langflow flows to be exposed as MCP tools and to consume external MCP servers within your workflows.

## Langflow as MCP Server

Langflow projects can expose their flows as MCP tools, making them accessible to any MCP-compatible client such as Claude Code, Claude Desktop, or other AI assistants.

### Project-Based MCP Endpoints

Each Langflow project has its own MCP endpoint structure:

```
/api/v1/mcp/project/{project_id}/
```

This allows you to expose specific flows as tools while keeping other projects private.

### Core MCP Endpoints

**Streamable HTTP Transport:**
```
GET  /api/v1/mcp/streamable
POST /api/v1/mcp/streamable
DELETE /api/v1/mcp/streamable
```

The streamable HTTP transport provides a bidirectional communication channel suitable for real-time interactions with MCP clients.

**SSE Transport:**
```
GET /api/v1/mcp/sse
```

Server-Sent Events transport for clients that prefer event-stream based communication.

**Server Installation:**
```
POST /api/v1/mcp/project/{project_id}/install
```

Install an MCP server configuration for a specific project. This registers the project's flows as available MCP tools.

**Installed Servers:**
```
GET /api/v1/mcp/project/{project_id}/installed
```

List all MCP server configurations installed for a project.

**Composer URL:**
```
GET /api/v1/mcp/project/{project_id}/composer-url
```

Retrieve the composer URL for integrating with MCP clients. This URL is used when configuring external clients to connect to your Langflow instance.

## Langflow as MCP Client

Langflow can also consume external MCP servers, allowing your flows to leverage tools provided by other MCP-compatible services.

### MCP Tools Component

The MCP Tools component in the flow editor enables connection to external MCP servers. To configure:

1. Add the MCP Tools component to your flow
2. Specify the MCP server URL (SSE or HTTP endpoint)
3. Configure authentication if required
4. The component will discover and expose available tools from the server

This allows flows to chain external AI capabilities, databases, or custom tools into your workflow.

## V2 MCP Server Management API

Langflow v2 introduces a simplified server management API for configuring MCP servers at the instance level.

**List All Servers:**
```
GET /api/v2/mcp/servers
```

Returns all configured MCP servers with their status and connection details.

**Get Server Details:**
```
GET /api/v2/mcp/servers/{server_name}
```

Retrieve configuration and status for a specific server.

**Create Server:**
```
POST /api/v2/mcp/servers/{server_name}
```

Register a new MCP server configuration.

Example request body:
```json
{
  "url": "http://localhost:8080/mcp",
  "transport": "sse",
  "description": "Custom analysis tools"
}
```

**Update Server:**
```
PATCH /api/v2/mcp/servers/{server_name}
```

Modify an existing server configuration.

**Delete Server:**
```
DELETE /api/v2/mcp/servers/{server_name}
```

Remove an MCP server configuration.

## Transport Types

Langflow supports two primary MCP transport mechanisms:

### SSE (Server-Sent Events)

SSE transport establishes a persistent connection where the server pushes events to the client. This is ideal for:

- Long-running operations
- Real-time updates
- Clients behind restrictive firewalls that allow outbound HTTP

### Streamable HTTP

Streamable HTTP provides bidirectional communication over standard HTTP. Benefits include:

- Better compatibility with load balancers
- Simpler debugging with standard HTTP tools
- Support for request/response patterns

Choose the transport based on your infrastructure requirements and client capabilities.

## Claude Code Integration

Connecting Claude Code to Langflow enables AI-powered workflows directly from your terminal.

### Configuration

Add your Langflow MCP server to Claude Code's configuration file at `~/.claude/mcp.json` or your project's `.mcp.json`:

```json
{
  "mcpServers": {
    "langflow": {
      "type": "sse",
      "url": "http://localhost:7860/api/v1/mcp/sse"
    }
  }
}
```

For project-specific flows:

```json
{
  "mcpServers": {
    "langflow-project": {
      "type": "sse",
      "url": "http://localhost:7860/api/v1/mcp/project/your-project-id/sse"
    }
  }
}
```

### Using Streamable HTTP

If you prefer streamable HTTP transport:

```json
{
  "mcpServers": {
    "langflow": {
      "type": "http",
      "url": "http://localhost:7860/api/v1/mcp/streamable"
    }
  }
}
```

### Authentication

For authenticated Langflow instances, include the API key:

```json
{
  "mcpServers": {
    "langflow": {
      "type": "sse",
      "url": "http://localhost:7860/api/v1/mcp/sse",
      "headers": {
        "x-api-key": "your-langflow-api-key"
      }
    }
  }
}
```

### Verifying Connection

After configuration, restart Claude Code and verify the connection:

1. The Langflow tools should appear in available MCP tools
2. Each exposed flow becomes a callable tool
3. Tool names typically match your flow names

## Practical Examples

### Exposing a RAG Flow as MCP Tool

1. Create a RAG flow in Langflow with document ingestion and query components
2. Navigate to Project Settings and enable MCP exposure
3. Copy the project's MCP URL from the composer-url endpoint
4. Add the URL to your Claude Code configuration
5. Query your documents directly from Claude Code

### Chaining Multiple MCP Servers

Configure Langflow as an MCP client to consume other servers while also exposing its own flows:

1. Add MCP Tools component connected to external servers
2. Build flows that combine external tools with Langflow components
3. Expose the combined flow as an MCP tool
4. Other clients now access the aggregated capabilities

This pattern enables sophisticated tool orchestration where Langflow acts as an MCP hub.

## Troubleshooting

**Connection refused:** Ensure Langflow is running and the port is accessible. Check firewall rules if connecting remotely.

**Tools not appearing:** Verify the project has flows configured for MCP exposure. Check the installed servers endpoint to confirm registration.

**Authentication errors:** Confirm the API key is correct and has appropriate permissions for MCP access.

**Transport issues:** Try switching between SSE and streamable HTTP if one transport type fails. Some network configurations work better with specific transports.
