---
name: jsonq
description: This skill should be used when the user asks to "read a JSON file", "analyse a JSON file", "explain the structure of a JSON file", "show the schema of a JSON", "parse JSON", "query JSON", "extract data from JSON", "filter JSON", "transform JSON data", "jq command", "jq query", "jq filter", "merge JSON files", "aggregate JSON data", "validate JSON", "OpenAPI spec", "swagger file", or mentions working with .json files in any capacity.
---

# JSON Query Skill (jsonq)

## Critical Requirement

**NEVER read JSON files directly using the Read tool.** Always use the `jq` command-line tool for all JSON operations.

This requirement exists because:
- JSON files can be extremely large and consume excessive context
- `jq` provides efficient streaming and filtering
- `jq` outputs only what is needed, reducing noise
- It prevents accidental modification or formatting issues

## Purpose

Provide guidance for querying, analyzing, and transforming JSON data using `jq`, a lightweight and powerful command-line JSON processor.

## Core Workflow

### Reading JSON Content

```bash
# View entire file (pretty-printed)
jq '.' file.json

# View with compact output
jq -c '.' file.json

# View with sorted keys
jq -S '.' file.json
```

### Extracting Structure/Schema

To understand JSON structure without reading all data:

```bash
# Get top-level keys
jq 'keys' file.json

# Get structure with types (first array element only)
jq 'if type == "array" then .[0] | keys else keys end' file.json

# Recursive key discovery
jq '[.. | objects | keys[]] | unique' file.json

# Show types at each level
jq 'to_entries | map({key, type: .value | type})' file.json
```

### Field Access

```bash
# Access single field
jq '.fieldname' file.json

# Access nested fields
jq '.user.profile.name' file.json

# Access with special characters
jq '.["field-with-dashes"]' file.json

# Optional access (no error if missing)
jq '.field?' file.json
```

### Array Operations

```bash
# Get all array elements
jq '.[]' file.json

# Get specific index
jq '.[0]' file.json

# Get range (slice)
jq '.[2:5]' file.json

# Get array length
jq 'length' file.json

# Filter array elements
jq '.[] | select(.active == true)' file.json
```

### Common Analysis Patterns

```bash
# Count items
jq 'length' file.json
jq '[.items[]] | length' file.json

# Unique values
jq '[.items[].category] | unique' file.json

# Group by field
jq 'group_by(.category)' file.json

# Sort by field
jq 'sort_by(.name)' file.json

# Map to extract fields
jq '.users | map({name, email})' file.json
```

## Essential Options

| Option | Description |
|--------|-------------|
| `-r` | Raw output (no quotes on strings) |
| `-c` | Compact output (single line) |
| `-S` | Sort object keys |
| `-e` | Exit with error if output is null/false |
| `-n` | Null input (don't read stdin) |
| `-s` | Slurp mode (read all into array) |
| `--arg name val` | Pass string variable |
| `--argjson name val` | Pass JSON variable |

## Best Practices

1. **Start with structure discovery** - Run `jq 'keys'` or `jq 'type'` first
2. **Use streaming for large files** - Use `jq --stream` for files > 100MB
3. **Prefer select over grep** - Use `jq 'select()'` instead of piping to grep
4. **Quote field names properly** - Use `.["field"]` for special characters
5. **Use raw output for scripts** - Add `-r` when piping to other commands
6. **Test filters incrementally** - Build complex filters step by step

## Things to Avoid

1. **Never read JSON directly** - Always use `jq`
2. **Avoid `cat file.json | jq`** - Use `jq '.' file.json` directly
3. **Don't assume array** - Check type with `jq 'type'` first
4. **Avoid deep recursion without limits** - Use `limit()` or `first()`
5. **Don't modify original files** - Use redirection to new file

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Missing quotes on strings | Use `--arg` for string variables |
| Null errors on missing keys | Use `.key?` with optional operator |
| Empty output on arrays | Use `.[]` to iterate |
| Type errors in comparisons | Check types with `type` filter |
| Memory issues on large files | Use `--stream` flag |

## Error Handling

```bash
# Handle missing keys gracefully
jq '.missing // "default"' file.json

# Try-catch pattern
jq 'try .field catch "error"' file.json

# Check if key exists
jq 'has("fieldname")' file.json

# Filter out nulls
jq '.items | map(select(. != null))' file.json
```

## Additional Resources

For detailed patterns, advanced filters, and troubleshooting:
- **`references/patterns.md`** - Advanced jq patterns: multi-condition filtering, aggregation (sum/avg/group), data transformation, streaming for large files, working with multiple files, custom functions, and troubleshooting
- **`references/openapi.md`** - Specialized patterns for querying OpenAPI/Swagger JSON specifications: endpoints, schemas, parameters, and API structure analysis
