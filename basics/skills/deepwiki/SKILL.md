---
name: deepwiki
version: 1.0.0
description: This skill should be used when the user asks to "analyze a GitHub repo", "understand a repo architecture", "explain how a feature works in a repo", "explore a third-party codebase", "what does this repo do", "research a library", "how does this package work", "generate architecture diagram", "compare two repos", "use deepwiki", or when Claude Code needs to understand information from a public repository (GitHub, GitLab, Bitbucket) not locally cloned.
---

# DeepWiki - Repository Documentation & Analysis

Query DeepWiki for AI-generated documentation about any public repository. DeepWiki indexes 50,000+ popular repos with architecture docs, API references, code explanations, and Mermaid diagrams.

## When to Use DeepWiki

| Scenario                                  | Use DeepWiki?      |
| ----------------------------------------- | ------------------ |
| Exploring unfamiliar open-source codebase | Yes                |
| Understanding project architecture        | Yes                |
| Finding how a feature is implemented      | Yes                |
| Generating architecture diagrams          | Yes                |
| Comparing implementations across repos    | Yes                |
| Working with local code already cloned    | No - use Glob/Grep |
| Quick file lookups in known structure     | No - use Read tool |

## Supported Platforms

| Platform  | URL Format                 | Example                                    |
| --------- | -------------------------- | ------------------------------------------ |
| GitHub    | `github.com/owner/repo`    | `github.com/vercel/next.js`                |
| GitLab    | `gitlab.com/owner/repo`    | `gitlab.com/gitlab-org/gitlab`             |
| Bitbucket | `bitbucket.org/owner/repo` | `bitbucket.org/atlassian/python-bitbucket` |

## Method Selection

| Task                            | Best Method                          |
| ------------------------------- | ------------------------------------ |
| Quick architecture overview     | `WebFetch`                           |
| Check what documentation exists | `mcp__deepwiki__read_wiki_structure` |
| Specific technical questions    | `mcp__deepwiki__ask_question`        |
| Deep dive with file references  | `mcp__deepwiki__ask_question`        |
| Generate Mermaid diagrams       | `mcp__deepwiki__ask_question`        |
| Private/unindexed repos         | GitHub API fallback                  |

## MCP Tools (Recommended)

### Get Documentation Structure

```
mcp__deepwiki__read_wiki_structure(repoName: "owner/repo")
```

Returns table of contents showing indexed sections. **Check structure first** to understand coverage.

### Ask Specific Questions

```
mcp__deepwiki__ask_question(
  repoName: "vercel/next.js",
  question: "How does the routing system work?"
)
```

Returns detailed answers with file path references, code explanations, and wiki page suggestions.

### Get Full Documentation

```
mcp__deepwiki__read_wiki_contents(repoName: "owner/repo")
```

**Note**: Returns large content. Prefer `ask_question` for specific queries.

## WebFetch Alternative

For quick summaries:

```
WebFetch https://deepwiki.com/owner/repo "Summarize the architecture"
```

## Query Best Practices

### Be Specific (Better Results)

**Good** - specific question:

```
"How does the caching system work in vercel/swr?"
```

**Less effective** - too broad:

```
"Tell me about vercel/swr"
```

### Reference Specific Paths

```
"Explain the src/core directory in pmndrs/zustand"
"How is middleware implemented in pmndrs/zustand?"
```

### Request Architecture Diagrams

```
"Generate an architecture diagram for prisma/prisma"
"Show the data flow in trpc/trpc"
```

### Compare Implementations

```
"Compare how tanstack/query and vercel/swr handle cache invalidation"
```

## Common Use Cases

### Learning a New Framework

1. "Explain the core concepts of honojs/hono"
2. "How do I add middleware in honojs/hono?"
3. "Show example route handlers"

### Feature Investigation

- "How does streaming work in openai/openai-python?"
- "Where is authentication handled in better-auth/better-auth?"

### Preparing for Contributions

- "What's the contribution workflow for anthropics/claude-code?"
- "What testing patterns are used?"

## Troubleshooting

### WebFetch Returns Minified JavaScript

1. Verify repo name matches exactly (owner/repo)
2. Try MCP `ask_question` instead
3. Check if indexed via `read_wiki_structure`

### Empty or Sparse Results

- Very new repositories (not yet crawled)
- Private repositories (requires Devin API key)
- Small/niche projects (not prioritized)

Use GitHub API fallback - see `references/github-fallback.md`.

## Limitations

- **Public repos**: Private repos require Devin.ai API key
- **Rate limits**: Public endpoint has usage limits
- **Large repos**: May take time to analyze
- **Cache lag**: Analysis may not reflect latest commits
- **Coverage**: 50,000+ repos indexed; niche repos may lack coverage

## Resources

- Website: https://deepwiki.com
- Docs: https://docs.devin.ai/work-with-devin/deepwiki
