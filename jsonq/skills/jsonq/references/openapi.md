# OpenAPI/Swagger JSON Querying Patterns

> Specialized jq patterns for analyzing OpenAPI 3.x and Swagger 2.x API specifications. For general jq usage, see SKILL.md.

## OpenAPI Document Structure

OpenAPI specs follow this hierarchy:

```
{
  "openapi": "3.1.x",     # Version (or "swagger": "2.0" for older specs)
  "info": {},             # API metadata (title, version, description)
  "servers": [],          # Base URLs
  "paths": {},            # Endpoints (the main content)
  "components": {},       # Reusable schemas, parameters, responses
  "security": [],         # Global security requirements
  "tags": []              # Grouping tags
}
```

## Quick Discovery Commands

```bash
# Check OpenAPI version
jq '.openapi // .swagger' spec.json

# Get API info
jq '.info | {title, version, description}' spec.json

# List all endpoints
jq '.paths | keys' spec.json

# Count total endpoints
jq '.paths | keys | length' spec.json

# List all component schemas
jq '.components.schemas | keys' spec.json
```

## Endpoint Analysis

### List All Operations

```bash
# All endpoints with their HTTP methods
jq '.paths | to_entries | map({path: .key, methods: (.value | keys | map(select(. != "parameters" and . != "servers")))})' spec.json

# Flat list: METHOD /path
jq -r '.paths | to_entries[] | .key as $path | .value | to_entries[] | select(.key | test("get|post|put|delete|patch")) | "\(.key | ascii_upcase) \($path)"' spec.json

# Endpoints grouped by tag
jq '.paths | to_entries | map(.key as $p | .value | to_entries | map(select(.value.tags?) | {path: $p, method: .key, tags: .value.tags})) | flatten | group_by(.tags[0])' spec.json
```

### Find Specific Endpoints

```bash
# Find endpoints containing a keyword
jq --arg kw "user" '.paths | to_entries | map(select(.key | contains($kw))) | from_entries | keys' spec.json

# Find endpoints by tag
jq --arg tag "pets" '.paths | to_entries | map(.key as $p | .value | to_entries | map(select(.value.tags? and (.value.tags | contains([$tag]))) | {path: $p, method: .key})) | flatten' spec.json

# Find all GET endpoints
jq '.paths | to_entries | map(select(.value.get)) | map(.key)' spec.json

# Find endpoints requiring authentication
jq '.paths | to_entries | map(.key as $p | .value | to_entries | map(select(.value.security?) | {path: $p, method: .key})) | flatten' spec.json
```

### Endpoint Details

```bash
# Get full details of a specific endpoint
jq '.paths["/pets/{petId}"].get' spec.json

# Get operation summary and description
jq '.paths | to_entries[] | .key as $p | .value | to_entries[] | select(.key | test("get|post|put|delete|patch")) | {path: $p, method: .key, summary: .value.summary, description: .value.description}' spec.json

# List all operationIds
jq -r '[.paths[][]] | map(select(.operationId?)) | map(.operationId) | unique[]' spec.json
```

## Parameters Analysis

```bash
# All path parameters across endpoints
jq '[.paths | to_entries[] | .value | to_entries[] | .value.parameters? // [] | .[] | select(.in == "path")] | unique_by(.name)' spec.json

# All query parameters
jq '[.paths | to_entries[] | .value | to_entries[] | .value.parameters? // [] | .[] | select(.in == "query")] | map({name, required, type: .schema.type?}) | unique_by(.name)' spec.json

# Parameters for a specific endpoint
jq '.paths["/pets"].get.parameters' spec.json

# Find required parameters
jq '[.paths[][].parameters? // [] | .[] | select(.required == true)] | map(.name) | unique' spec.json
```

## Schema Analysis

### Exploring Components

```bash
# List all schema names
jq '.components.schemas | keys' spec.json

# Get a specific schema
jq '.components.schemas.Pet' spec.json

# Schema properties only
jq '.components.schemas.Pet.properties | keys' spec.json

# Required fields for a schema
jq '.components.schemas.Pet.required' spec.json

# Find schemas with a specific property
jq --arg prop "id" '.components.schemas | to_entries | map(select(.value.properties[$prop]?)) | map(.key)' spec.json
```

### Schema Details

```bash
# Property types for a schema
jq '.components.schemas.Pet.properties | to_entries | map({name: .key, type: .value.type, format: .value.format?})' spec.json

# Find all enums in schemas
jq '[.components.schemas | .. | .enum? // empty] | unique' spec.json

# Schemas with required fields
jq '.components.schemas | to_entries | map(select(.value.required?)) | map({name: .key, required: .value.required})' spec.json
```

## Request/Response Analysis

```bash
# Response codes for an endpoint
jq '.paths["/pets"].get.responses | keys' spec.json

# Success response schema
jq '.paths["/pets"].get.responses["200"].content["application/json"].schema' spec.json

# All endpoints returning a specific schema
jq --arg schema "Pet" '.paths | to_entries | map(.key as $p | .value | to_entries | map(select(.value.responses?["200"]?.content?["application/json"]?.schema?["$ref"]? | . and contains($schema))) | map({path: $p, method: .key})) | flatten' spec.json

# Request body schema for POST endpoints
jq '.paths | to_entries | map(.key as $p | .value.post? | select(.) | {path: $p, requestBody: .requestBody.content["application/json"].schema})' spec.json
```

## Reference Resolution

OpenAPI uses `$ref` for reusable components. These point to paths like `#/components/schemas/Pet`.

```bash
# Find all $ref usages
jq '[.. | ."$ref"? // empty] | unique' spec.json

# Count references per schema
jq --arg schema "#/components/schemas/Pet" '[.. | ."$ref"? // empty | select(. == $schema)] | length' spec.json

# List schemas and their reference count
jq '.components.schemas | keys | map(. as $name | {name: $name, refs: ([.. | ."$ref"? // empty | select(contains($name))] | length)}) | sort_by(-.refs)' spec.json
```

## Security Analysis

```bash
# List security schemes
jq '.components.securitySchemes | keys' spec.json

# Security scheme details
jq '.components.securitySchemes | to_entries | map({name: .key, type: .value.type, scheme: .value.scheme?})' spec.json

# Global security requirements
jq '.security' spec.json

# Endpoints with specific security overrides
jq '.paths | to_entries | map(.key as $p | .value | to_entries | map(select(.value.security?) | {path: $p, method: .key, security: .value.security})) | flatten' spec.json
```

## Server and Base URL

```bash
# List all servers
jq '.servers' spec.json

# Extract base URLs
jq -r '.servers[].url' spec.json

# Servers with variables
jq '.servers | map(select(.variables?))' spec.json
```

## Validation and Inspection

```bash
# Check if valid OpenAPI 3.x
jq 'if .openapi then "OpenAPI \(.openapi)" elif .swagger then "Swagger \(.swagger)" else "Unknown format" end' spec.json

# Find missing descriptions
jq '.paths | to_entries | map(.key as $p | .value | to_entries | map(select(.value | type == "object" and (.description | not)) | {path: $p, method: .key})) | flatten' spec.json

# Find deprecated endpoints
jq '.paths | to_entries | map(.key as $p | .value | to_entries | map(select(.value.deprecated? == true) | {path: $p, method: .key})) | flatten' spec.json

# Count operations by tag
jq '[.paths[][]] | map(select(.tags?)) | map(.tags[]) | group_by(.) | map({tag: .[0], count: length}) | sort_by(-.count)' spec.json
```

## Swagger 2.0 Differences

For older Swagger 2.0 specs, some paths differ:

```bash
# Swagger 2.0: definitions instead of components/schemas
jq '.definitions | keys' swagger.json

# Swagger 2.0: basePath and host instead of servers
jq '{host, basePath, schemes}' swagger.json

# Swagger 2.0: produces/consumes at operation or root level
jq '.produces // .paths[][].produces | unique' swagger.json
```

## Common Workflows

### Generate Endpoint Documentation

```bash
jq -r '.paths | to_entries[] | .key as $p | .value | to_entries[] | select(.key | test("get|post|put|delete|patch")) | "## \(.key | ascii_upcase) \($p)\n\(.value.summary // "No summary")\n"' spec.json
```

### Export Schema as TypeScript-like Interface

```bash
jq -r '.components.schemas.Pet | "interface Pet {\n" + ([.properties | to_entries[] | "  \(.key): \(.value.type);"] | join("\n")) + "\n}"' spec.json
```

### Find All Endpoints That Return Arrays

```bash
jq '.paths | to_entries | map(.key as $p | .value | to_entries | map(select(.value.responses?["200"]?.content?["application/json"]?.schema?.type? == "array") | {path: $p, method: .key})) | flatten' spec.json
```
