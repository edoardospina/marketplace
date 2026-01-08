# Advanced jq Patterns and Troubleshooting

## Complex Filtering Patterns

### Nested Object Queries

```bash
# Find deeply nested values
jq '.. | .email? // empty' file.json

# Recursive descent with filtering
jq '.. | objects | select(.type == "user")' file.json

# Get all values at specific path pattern
jq 'paths(scalars) as $p | "\($p | join(".")): \(getpath($p))"' file.json
```

### Multi-Condition Filtering

```bash
# AND conditions
jq '.[] | select(.age > 18 and .active == true)' file.json

# OR conditions
jq '.[] | select(.role == "admin" or .role == "moderator")' file.json

# NOT conditions
jq '.[] | select(.deleted | not)' file.json

# Complex boolean logic
jq '.[] | select((.age > 21 and .country == "US") or .verified == true)' file.json
```

### Aggregation Patterns

```bash
# Sum values
jq '[.items[].price] | add' file.json

# Average
jq '[.items[].score] | add / length' file.json

# Min/Max
jq '[.items[].value] | min' file.json
jq '[.items[].value] | max' file.json

# Group and count
jq 'group_by(.category) | map({category: .[0].category, count: length})' file.json

# Reduce pattern
jq 'reduce .items[] as $item (0; . + $item.quantity)' file.json
```

## Data Transformation Patterns

### Restructuring Objects

```bash
# Rename keys
jq '.items | map({id: .item_id, title: .item_name})' file.json

# Flatten nested structures
jq '.users | map(. + .profile) | map(del(.profile))' file.json

# Merge objects
jq '.defaults * .overrides' file.json

# Convert object to array of key-value pairs
jq 'to_entries' file.json

# Convert array back to object
jq 'from_entries' file.json
```

### Array Manipulations

```bash
# Flatten nested arrays
jq 'flatten' file.json
jq 'flatten(1)' file.json  # one level only

# Transpose arrays
jq 'transpose' file.json

# Zip arrays together
jq '[.[0], .[1]] | transpose | map({key: .[0], value: .[1]})' file.json

# Split into chunks
jq 'def chunk(n): if length <= n then [.] else [.[:n]] + (.[n:] | chunk(n)) end; chunk(3)' file.json
```

### String Operations

```bash
# Split and join
jq '.name | split(" ")' file.json
jq '.tags | join(", ")' file.json

# String interpolation
jq '.items[] | "\(.name): $\(.price)"' file.json

# Regex matching
jq '.items[] | select(.email | test("@gmail.com$"))' file.json

# Regex capture
jq '.url | capture("https://(?<domain>[^/]+)/(?<path>.*)")' file.json

# Replace patterns
jq '.text | gsub("foo"; "bar")' file.json
```

## Working with Multiple Files

```bash
# Merge multiple JSON files
jq -s 'add' file1.json file2.json

# Compare two files
jq -s '.[0] == .[1]' file1.json file2.json

# Find differences (keys in first not in second)
jq -s '.[0] | keys - (.[1] | keys)' file1.json file2.json

# Join data from multiple files
jq -s '.[0] as $a | .[1] | map(. + ($a[] | select(.id == .user_id)))' users.json orders.json
```

## Streaming for Large Files

```bash
# Stream mode for memory efficiency
jq --stream 'select(.[0][0] == "items")' large.json

# Reconstruct from stream
jq --stream 'fromstream(select(.[0][0] == "users"))' large.json

# Count items without loading entire file
jq --stream 'select(.[0] == ["items"] and .[1] == null) | .[0] | length - 1' large.json

# Extract specific paths from stream
jq -c --stream 'select(.[0][-1] == "email") | .[1]' large.json
```

## Variable and Function Patterns

### Using Variables

```bash
# String variables
jq --arg name "John" '.users[] | select(.name == $name)' file.json

# JSON variables
jq --argjson ids '[1,2,3]' '.items | map(select(.id | IN($ids[])))' file.json

# Environment variables
jq --arg home "$HOME" '.path | gsub("~"; $home)' file.json

# File as variable
jq --slurpfile config config.json '.settings | . * $config[0]' file.json
```

### Custom Functions

```bash
# Define inline function
jq 'def double: . * 2; .values | map(double)' file.json

# Recursive function
jq 'def flatten_all: if type == "array" then map(flatten_all) | add else . end; flatten_all' file.json

# Function with arguments
jq 'def scale(n): . * n; .prices | map(scale(1.1))' file.json
```

## Troubleshooting Guide

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `Cannot index null` | Missing key in path | Use optional `.key?` |
| `Cannot iterate over null` | `.[]` on null | Add `// []` default |
| `string cannot be parsed as JSON` | Input not valid JSON | Validate with `jq empty file.json` |
| `Argument list too long` | Too many files | Use `find -exec` or xargs |
| `parse error: Invalid numeric literal` | Trailing comma or syntax | Check JSON validity |

### Debugging Techniques

```bash
# Validate JSON syntax
jq empty file.json && echo "Valid" || echo "Invalid"

# Debug with intermediate output
jq '.items | debug | map(.name)' file.json

# Show path to each value
jq 'path(..) as $p | "\($p): \(getpath($p))"' file.json

# Type checking
jq '.data | if type != "array" then error("Expected array") else . end' file.json
```

### Performance Tips

1. **Use specific paths** - `.users[0].name` is faster than `.. | .name?`
2. **Limit early** - `limit(10; .items[])` stops after 10 results
3. **Avoid duplicate iterations** - Store intermediate results with `as $var`
4. **Use streaming** - `--stream` for files > 100MB
5. **Compact output** - `-c` reduces I/O overhead

### Memory Management

```bash
# Process line by line (JSONL format)
jq -c '.' file.jsonl

# Stream large arrays
jq -c '.items[]' large.json | while read -r item; do
  echo "$item" | jq '.name'
done

# Limit results
jq 'limit(100; .items[])' file.json
```

## Output Formatting

```bash
# Raw strings (no quotes)
jq -r '.message' file.json

# Tab-separated values
jq -r '.users[] | [.name, .email] | @tsv' file.json

# CSV format
jq -r '.users[] | [.name, .email] | @csv' file.json

# URI encoding
jq -r '.query | @uri' file.json

# Base64 encoding
jq -r '.data | @base64' file.json

# HTML escaping
jq -r '.content | @html' file.json

# Custom formatting
jq -r '.items[] | "- \(.name) (\(.category))"' file.json
```

## Integration with Other Tools

```bash
# With curl
curl -s api.example.com/data | jq '.results'

# With find
find . -name "*.json" -exec jq '.version' {} \;

# With xargs for many files
ls *.json | xargs -I {} jq '.id' {}

# Writing back (to new file)
jq '.version = "2.0"' config.json > config.new.json && mv config.new.json config.json

# In-place editing alternative
tmp=$(mktemp) && jq '.updated = true' file.json > "$tmp" && mv "$tmp" file.json
```
