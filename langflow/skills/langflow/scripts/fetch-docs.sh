#!/bin/bash
#
# fetch-docs.sh - Fetch latest Langflow documentation
#
# This script fetches documentation from docs.langflow.org and stores it
# in the resources directory for the Langflow skill.
#
# Usage:
#   ./fetch-docs.sh                    # Fetch all documentation
#   ./fetch-docs.sh --section <name>   # Fetch specific section
#   ./fetch-docs.sh --openapi          # Fetch latest OpenAPI spec
#   ./fetch-docs.sh --help             # Show help
#
# Requirements:
#   - curl (fallback)
#   - firecrawl MCP (preferred, if available via Claude Code)
#   - jq (for OpenAPI processing)

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOURCES_DIR="${SCRIPT_DIR}/../resources"
DOCS_BASE_URL="https://docs.langflow.org"
OPENAPI_URL="https://raw.githubusercontent.com/langflow-ai/langflow/main/src/backend/base/langflow/openapi.json"
LANGFLOW_REPO="langflow-ai/langflow"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Show help
show_help() {
    cat << 'EOF'
fetch-docs.sh - Fetch latest Langflow documentation

USAGE:
    ./fetch-docs.sh [OPTIONS]

OPTIONS:
    --all, -a           Fetch all documentation (default)
    --openapi, -o       Fetch latest OpenAPI specification
    --section <name>    Fetch specific documentation section
    --list-sections     List available documentation sections
    --check-version     Check latest Langflow version
    --help, -h          Show this help message

EXAMPLES:
    # Fetch the latest OpenAPI spec
    ./fetch-docs.sh --openapi

    # Check what version is current
    ./fetch-docs.sh --check-version

    # List available doc sections
    ./fetch-docs.sh --list-sections

    # Fetch specific section
    ./fetch-docs.sh --section components

NOTES:
    For comprehensive documentation fetching, use Claude Code with firecrawl:

    # In Claude Code, ask:
    "Use firecrawl to scrape docs.langflow.org and extract the components guide"

    This script provides basic curl-based fetching as a fallback.

EOF
}

# Known documentation sections
SECTIONS=(
    "getting-started"
    "components"
    "configuration"
    "deployment"
    "administration"
    "api"
    "integrations"
    "agents"
    "workspace"
    "flows"
)

# List available sections
list_sections() {
    info "Available documentation sections:"
    echo ""
    for section in "${SECTIONS[@]}"; do
        echo "  - $section"
    done
    echo ""
    info "Fetch with: ./fetch-docs.sh --section <name>"
}

# Check latest Langflow version from GitHub
check_version() {
    info "Checking latest Langflow version..."

    # Try GitHub API
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/${LANGFLOW_REPO}/releases/latest" | \
        grep '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/' || echo "unknown")

    if [ "$LATEST_VERSION" != "unknown" ]; then
        success "Latest Langflow version: $LATEST_VERSION"

        # Check current version in our OpenAPI spec
        if [ -f "${RESOURCES_DIR}/openapi.json" ]; then
            CURRENT_VERSION=$(jq -r '.info.version // "unknown"' "${RESOURCES_DIR}/openapi.json" 2>/dev/null || echo "unknown")
            info "Current spec version: $CURRENT_VERSION"

            if [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
                warn "Version mismatch! Consider updating with: ./fetch-docs.sh --openapi"
            else
                success "OpenAPI spec is up to date"
            fi
        fi
    else
        error "Could not fetch latest version"
    fi
}

# Fetch OpenAPI specification
fetch_openapi() {
    info "Fetching OpenAPI specification..."

    # Create backup of existing spec
    if [ -f "${RESOURCES_DIR}/openapi.json" ]; then
        cp "${RESOURCES_DIR}/openapi.json" "${RESOURCES_DIR}/openapi.json.bak"
        info "Backed up existing spec to openapi.json.bak"
    fi

    # Try multiple sources
    SOURCES=(
        "https://raw.githubusercontent.com/langflow-ai/langflow/main/src/backend/base/langflow/openapi.json"
        "https://raw.githubusercontent.com/langflow-ai/langflow/dev/src/backend/base/langflow/openapi.json"
    )

    for url in "${SOURCES[@]}"; do
        info "Trying: $url"
        if curl -sfL "$url" -o "${RESOURCES_DIR}/openapi.json.tmp"; then
            # Validate JSON
            if jq empty "${RESOURCES_DIR}/openapi.json.tmp" 2>/dev/null; then
                mv "${RESOURCES_DIR}/openapi.json.tmp" "${RESOURCES_DIR}/openapi.json"
                NEW_VERSION=$(jq -r '.info.version // "unknown"' "${RESOURCES_DIR}/openapi.json")
                success "OpenAPI spec updated to version: $NEW_VERSION"
                return 0
            else
                rm -f "${RESOURCES_DIR}/openapi.json.tmp"
                warn "Invalid JSON from $url"
            fi
        fi
    done

    # Fallback: try to get from a running Langflow instance
    if [ -n "${LANGFLOW_URL:-}" ]; then
        info "Trying local Langflow instance: ${LANGFLOW_URL}/openapi.json"
        if curl -sfL "${LANGFLOW_URL}/openapi.json" -o "${RESOURCES_DIR}/openapi.json.tmp"; then
            if jq empty "${RESOURCES_DIR}/openapi.json.tmp" 2>/dev/null; then
                mv "${RESOURCES_DIR}/openapi.json.tmp" "${RESOURCES_DIR}/openapi.json"
                success "OpenAPI spec fetched from local instance"
                return 0
            fi
        fi
    fi

    error "Could not fetch OpenAPI spec from any source"
    warn "You can manually download from a running Langflow instance:"
    echo "  curl http://localhost:7860/openapi.json > ${RESOURCES_DIR}/openapi.json"
    return 1
}

# Fetch documentation section using curl
fetch_section() {
    local section="$1"
    local output_file="${RESOURCES_DIR}/${section}.md"

    info "Fetching section: $section"

    # Note: docs.langflow.org may not have raw markdown endpoints
    # This is a basic implementation - for better results use firecrawl via Claude Code

    local url="${DOCS_BASE_URL}/${section}"

    # Try to fetch and convert HTML to basic text
    if command -v pandoc &> /dev/null; then
        info "Using pandoc for HTML to Markdown conversion"
        curl -sL "$url" | pandoc -f html -t markdown -o "$output_file" && \
            success "Saved to $output_file" || \
            error "Failed to fetch $section"
    else
        warn "pandoc not found - saving raw HTML"
        curl -sL "$url" -o "${output_file%.md}.html" && \
            success "Saved HTML to ${output_file%.md}.html" || \
            error "Failed to fetch $section"
        echo ""
        info "For better results, use Claude Code with firecrawl:"
        echo "  \"Scrape ${url} and save the content as markdown\""
    fi
}

# Fetch all documentation
fetch_all() {
    info "Fetching all documentation..."
    warn "This is a basic implementation. For comprehensive docs, use Claude Code:"
    echo ""
    echo "  # In Claude Code:"
    echo "  \"Use firecrawl to crawl docs.langflow.org and extract documentation\""
    echo ""

    # Fetch OpenAPI spec (most reliable)
    fetch_openapi

    echo ""
    info "For additional documentation, manually fetch sections:"
    for section in "${SECTIONS[@]}"; do
        echo "  ./fetch-docs.sh --section $section"
    done
}

# Generate firecrawl commands for Claude Code
generate_firecrawl_commands() {
    info "Firecrawl commands for Claude Code:"
    echo ""
    cat << 'EOF'
# Map all URLs on docs.langflow.org
Use firecrawl_map to discover all URLs on docs.langflow.org

# Scrape the getting started guide
Use firecrawl_scrape to get https://docs.langflow.org/getting-started

# Crawl the components documentation
Use firecrawl_crawl on https://docs.langflow.org/components with maxDiscoveryDepth=2 and limit=20

# Search for specific topics
Use firecrawl_search with query "Langflow custom components tutorial"

# Extract structured data about API endpoints
Use firecrawl_extract on docs.langflow.org/api with a schema for endpoint details

EOF
}

# Main execution
main() {
    # Ensure resources directory exists
    mkdir -p "$RESOURCES_DIR"

    # Parse arguments
    case "${1:-}" in
        --help|-h)
            show_help
            ;;
        --openapi|-o)
            fetch_openapi
            ;;
        --check-version|-v)
            check_version
            ;;
        --section|-s)
            if [ -z "${2:-}" ]; then
                error "Section name required"
                list_sections
                exit 1
            fi
            fetch_section "$2"
            ;;
        --list-sections|-l)
            list_sections
            ;;
        --firecrawl|-f)
            generate_firecrawl_commands
            ;;
        --all|-a|"")
            fetch_all
            ;;
        *)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
