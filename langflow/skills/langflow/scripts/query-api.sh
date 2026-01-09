#!/bin/bash
#
# query-api.sh - Query the Langflow OpenAPI specification
#
# This script provides common jq queries for exploring the Langflow API.
# It wraps jq commands for convenient access to endpoints, schemas, and operations.
#
# Usage:
#   ./query-api.sh endpoints              # List all API endpoints
#   ./query-api.sh endpoint <path>        # Get details for specific endpoint
#   ./query-api.sh schemas                # List all schema types
#   ./query-api.sh schema <name>          # Get specific schema
#   ./query-api.sh search <term>          # Search for operations
#   ./query-api.sh tags                   # List all API tags/categories
#   ./query-api.sh by-tag <tag>           # List endpoints by tag
#   ./query-api.sh help                   # Show all commands

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENAPI_FILE="${SCRIPT_DIR}/../resources/openapi.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Print functions
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}$1${NC}"; }
header() { echo -e "${CYAN}=== $1 ===${NC}"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check dependencies
check_deps() {
    if ! command -v jq &> /dev/null; then
        error "jq is required but not installed"
        echo "Install with: brew install jq"
        exit 1
    fi

    if [ ! -f "$OPENAPI_FILE" ]; then
        error "OpenAPI spec not found at: $OPENAPI_FILE"
        echo "Run: ./fetch-docs.sh --openapi"
        exit 1
    fi
}

# Show help
show_help() {
    cat << 'EOF'
query-api.sh - Query the Langflow OpenAPI specification

USAGE:
    ./query-api.sh <command> [arguments]

COMMANDS:
    info                        Show API info (title, version, etc.)
    endpoints                   List all API endpoints
    endpoint <path>             Get details for a specific endpoint
    schemas                     List all schema/model types
    schema <name>               Get a specific schema definition
    search <term>               Search endpoints by path, summary, or operationId
    tags                        List all API tags/categories
    by-tag <tag>                List all endpoints for a tag
    methods <path>              List HTTP methods for an endpoint
    params <path> [method]      Show parameters for an endpoint
    responses <path> [method]   Show response schemas for an endpoint
    deprecated                  List deprecated endpoints
    security                    Show security schemes
    raw <jq-query>              Run a custom jq query
    examples                    Show example jq queries

EXAMPLES:
    # List all endpoints
    ./query-api.sh endpoints

    # Get details about the run endpoint
    ./query-api.sh endpoint "/api/v1/run/{flow_id_or_name}"

    # Search for flow-related endpoints
    ./query-api.sh search flow

    # List all endpoints in the Flows category
    ./query-api.sh by-tag Flows

    # Get the Flow schema
    ./query-api.sh schema Flow

    # Run custom jq query
    ./query-api.sh raw '.paths | keys | length'

EOF
}

# Show API info
show_info() {
    header "Langflow API Information"
    jq -r '.info | "Title: \(.title)\nVersion: \(.version)\nDescription: \(.description // "N/A")"' "$OPENAPI_FILE"
}

# List all endpoints
list_endpoints() {
    header "API Endpoints"
    jq -r '.paths | keys[]' "$OPENAPI_FILE" | sort
    echo ""
    info "Total endpoints: $(jq '.paths | keys | length' "$OPENAPI_FILE")"
}

# Get endpoint details
get_endpoint() {
    local path="$1"
    header "Endpoint: $path"

    # Check if endpoint exists
    if ! jq -e ".paths[\"$path\"]" "$OPENAPI_FILE" > /dev/null 2>&1; then
        error "Endpoint not found: $path"
        echo ""
        info "Available endpoints containing '$(basename "$path")':"
        jq -r ".paths | keys[] | select(contains(\"$(basename "$path")\"))" "$OPENAPI_FILE"
        return 1
    fi

    # Show methods and summaries
    jq -r ".paths[\"$path\"] | to_entries[] | \"[\(.key | ascii_upcase)] \(.value.summary // \"No summary\")\"" "$OPENAPI_FILE"

    echo ""
    info "For full details:"
    echo "  ./query-api.sh raw '.paths[\"$path\"]'"
}

# List all schemas
list_schemas() {
    header "Schema Types"
    jq -r '.components.schemas | keys[]' "$OPENAPI_FILE" | sort
    echo ""
    info "Total schemas: $(jq '.components.schemas | keys | length' "$OPENAPI_FILE")"
}

# Get specific schema
get_schema() {
    local name="$1"
    header "Schema: $name"

    if ! jq -e ".components.schemas[\"$name\"]" "$OPENAPI_FILE" > /dev/null 2>&1; then
        error "Schema not found: $name"
        echo ""
        info "Similar schemas:"
        jq -r ".components.schemas | keys[] | select(ascii_downcase | contains(\"$(echo "$name" | tr '[:upper:]' '[:lower:]')\"))" "$OPENAPI_FILE" | head -10
        return 1
    fi

    jq ".components.schemas[\"$name\"]" "$OPENAPI_FILE"
}

# Search for endpoints
search_endpoints() {
    local term="$1"
    local lower_term=$(echo "$term" | tr '[:upper:]' '[:lower:]')

    header "Search Results for: $term"

    echo ""
    echo "Matching paths:"
    jq -r ".paths | to_entries[] | select(.key | ascii_downcase | contains(\"$lower_term\")) | .key" "$OPENAPI_FILE"

    echo ""
    echo "Matching summaries:"
    jq -r ".paths | to_entries[] | .value | to_entries[] | select(.value.summary? | ascii_downcase | contains(\"$lower_term\")) | \"\(.key | ascii_upcase) - \(.value.summary)\"" "$OPENAPI_FILE" 2>/dev/null || true

    echo ""
    echo "Matching operationIds:"
    jq -r ".paths[][] | select(.operationId? | ascii_downcase | contains(\"$lower_term\")) | .operationId" "$OPENAPI_FILE" 2>/dev/null || true
}

# List all tags
list_tags() {
    header "API Tags/Categories"
    jq -r '[.paths[][] | .tags[]?] | unique | sort[]' "$OPENAPI_FILE"
}

# List endpoints by tag
by_tag() {
    local tag="$1"
    header "Endpoints tagged: $tag"

    jq -r '.paths | to_entries[] | .key as $path | .value | to_entries[] | select(.value.tags? | index("'"$tag"'")) | "[\(.key | ascii_upcase)] \($path) - \(.value.summary // "No summary")"' "$OPENAPI_FILE"
}

# List HTTP methods for endpoint
list_methods() {
    local path="$1"
    header "Methods for: $path"
    jq -r ".paths[\"$path\"] | keys[]" "$OPENAPI_FILE" 2>/dev/null || error "Endpoint not found"
}

# Show parameters for endpoint
show_params() {
    local path="$1"
    local method="${2:-get}"

    header "Parameters for: [$method] $path"

    jq -r ".paths[\"$path\"][\"$method\"].parameters // [] | .[] | \"- \(.name) (\(.in)): \(.description // \"No description\") [required: \(.required // false)]\"" "$OPENAPI_FILE" 2>/dev/null || true

    # Also show request body schema if present
    local has_body=$(jq -r ".paths[\"$path\"][\"$method\"].requestBody // empty" "$OPENAPI_FILE" 2>/dev/null)
    if [ -n "$has_body" ]; then
        echo ""
        echo "Request Body:"
        jq ".paths[\"$path\"][\"$method\"].requestBody.content[\"application/json\"].schema" "$OPENAPI_FILE" 2>/dev/null
    fi
}

# Show response schemas
show_responses() {
    local path="$1"
    local method="${2:-get}"

    header "Responses for: [$method] $path"

    jq ".paths[\"$path\"][\"$method\"].responses" "$OPENAPI_FILE" 2>/dev/null || error "Endpoint/method not found"
}

# List deprecated endpoints
list_deprecated() {
    header "Deprecated Endpoints"
    jq -r '.paths | to_entries[] | .key as $path | .value | to_entries[] | select(.value.deprecated == true) | "[\(.key | ascii_upcase)] \($path) - \(.value.summary // "No summary")"' "$OPENAPI_FILE"
}

# Show security schemes
show_security() {
    header "Security Schemes"
    jq '.components.securitySchemes' "$OPENAPI_FILE"
}

# Run raw jq query
raw_query() {
    local query="$1"
    jq "$query" "$OPENAPI_FILE"
}

# Show example queries
show_examples() {
    cat << 'EOF'
=== Example jq Queries for Langflow OpenAPI ===

# Basic Information
jq '.info' resources/openapi.json
jq '.info.version' resources/openapi.json

# Endpoint Discovery
jq '.paths | keys' resources/openapi.json                    # All endpoints
jq '.paths | keys | length' resources/openapi.json           # Count endpoints
jq '.paths | keys | map(select(contains("flow")))' resources/openapi.json  # Flow endpoints

# Endpoint Details
jq '.paths["/api/v1/run/{flow_id_or_name}"]' resources/openapi.json
jq '.paths["/api/v1/run/{flow_id_or_name}"].post.summary' resources/openapi.json
jq '.paths["/api/v1/flows/"].get.parameters' resources/openapi.json

# Schema Exploration
jq '.components.schemas | keys' resources/openapi.json       # All schemas
jq '.components.schemas.Flow' resources/openapi.json         # Flow schema
jq '.components.schemas.Flow.properties | keys' resources/openapi.json  # Flow properties
jq '.components.schemas | keys | map(select(contains("Message")))' resources/openapi.json

# Find by Tag
jq '[.paths[][] | select(.tags | index("Flows"))] | length' resources/openapi.json
jq '.paths | to_entries[] | .key as $p | .value | to_entries[] | select(.value.tags | index("Chat")) | "\(.key) \($p)"' resources/openapi.json

# Security
jq '.components.securitySchemes' resources/openapi.json
jq '.paths["/api/v1/run/{flow_id_or_name}"].post.security' resources/openapi.json

# Find Required Parameters
jq '.paths["/api/v1/run/{flow_id_or_name}"].post.parameters | map(select(.required))' resources/openapi.json

# Response Schemas
jq '.paths["/api/v1/flows/"].get.responses["200"].content["application/json"].schema' resources/openapi.json

# Complex: List all POST endpoints with their summaries
jq -r '.paths | to_entries[] | .key as $path | .value | to_entries[] | select(.key == "post") | "\($path): \(.value.summary)"' resources/openapi.json

# Complex: Find endpoints that accept a specific schema
jq -r '.paths | to_entries[] | .key as $path | .value | to_entries[] | select(.value.requestBody?.content?["application/json"]?.schema?["$ref"]? | contains("FlowDataRequest")?) | "\(.key | ascii_upcase) \($path)"' resources/openapi.json

# Complex: Get all operationIds
jq '[.paths[][] | .operationId] | sort | unique[]' resources/openapi.json

EOF
}

# Main execution
main() {
    check_deps

    case "${1:-help}" in
        info)
            show_info
            ;;
        endpoints|ep)
            list_endpoints
            ;;
        endpoint)
            [ -z "${2:-}" ] && { error "Path required"; exit 1; }
            get_endpoint "$2"
            ;;
        schemas|models)
            list_schemas
            ;;
        schema|model)
            [ -z "${2:-}" ] && { error "Schema name required"; exit 1; }
            get_schema "$2"
            ;;
        search|find)
            [ -z "${2:-}" ] && { error "Search term required"; exit 1; }
            search_endpoints "$2"
            ;;
        tags)
            list_tags
            ;;
        by-tag|tag)
            [ -z "${2:-}" ] && { error "Tag name required"; exit 1; }
            by_tag "$2"
            ;;
        methods)
            [ -z "${2:-}" ] && { error "Path required"; exit 1; }
            list_methods "$2"
            ;;
        params|parameters)
            [ -z "${2:-}" ] && { error "Path required"; exit 1; }
            show_params "$2" "${3:-get}"
            ;;
        responses|resp)
            [ -z "${2:-}" ] && { error "Path required"; exit 1; }
            show_responses "$2" "${3:-get}"
            ;;
        deprecated)
            list_deprecated
            ;;
        security|auth)
            show_security
            ;;
        raw|jq)
            [ -z "${2:-}" ] && { error "jq query required"; exit 1; }
            raw_query "$2"
            ;;
        examples|ex)
            show_examples
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
