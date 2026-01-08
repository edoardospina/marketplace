# GitHub Fallback Guide

When DeepWiki lacks coverage for a repository (private repos, very new repos, or obscure projects), use GitHub API with AI analysis as a fallback.

## Prerequisites

Ensure the `gh` CLI is authenticated:
```bash
gh auth status
```

## Repository Overview

Get basic repo metadata:
```bash
gh api repos/owner/repo | jq '{
  description,
  language,
  topics,
  stars: .stargazers_count,
  forks: .forks_count,
  license: .license.name,
  created: .created_at,
  updated: .updated_at
}'
```

## README Content

Fetch and decode the README:
```bash
gh api repos/owner/repo/readme --jq '.content' | base64 -d
```

## File Structure

Get repository tree (first 100 files):
```bash
gh api "repos/owner/repo/git/trees/main?recursive=1" | \
  jq -r '.tree[] | select(.type == "blob") | .path' | head -100
```

For non-main branches, replace `main` with the branch name:
```bash
gh api "repos/owner/repo/git/trees/master?recursive=1" | \
  jq -r '.tree[] | select(.type == "blob") | .path' | head -100
```

## Directory-Level Structure

Get only top-level directories:
```bash
gh api "repos/owner/repo/git/trees/main" | \
  jq -r '.tree[] | select(.type == "tree") | .path'
```

## Specific File Content

Fetch any file by path:
```bash
gh api "repos/owner/repo/contents/path/to/file.py" --jq '.content' | base64 -d
```

## Recent Commits

Get recent commit history for context:
```bash
gh api "repos/owner/repo/commits?per_page=10" | \
  jq -r '.[] | "\(.sha[0:7]) \(.commit.message | split("\n")[0])"'
```

## Open Issues and PRs

Get active issues for understanding current work:
```bash
gh api "repos/owner/repo/issues?state=open&per_page=10" | \
  jq -r '.[] | "#\(.number) \(.title)"'
```

## Release Information

Get latest releases:
```bash
gh api "repos/owner/repo/releases?per_page=5" | \
  jq -r '.[] | "\(.tag_name): \(.name)"'
```

## Combined Analysis Command

For a comprehensive repo overview, run these in parallel:
```bash
# Run all three in parallel
gh api repos/owner/repo | jq '{description, language, topics}' &
gh api repos/owner/repo/readme --jq '.content' | base64 -d | head -100 &
gh api "repos/owner/repo/git/trees/main?recursive=1" | jq -r '.tree[] | select(.type == "blob") | .path' | head -50 &
wait
```

## When to Use Fallback

Use GitHub API fallback when:
- DeepWiki returns "repo not found" or empty results
- Repository is private (requires authenticated `gh`)
- Repository is very new (not yet indexed by DeepWiki)
- DeepWiki's coverage seems incomplete for specific files

## Limitations

- Private repos require proper `gh` authentication
- Very large repos may have truncated tree responses
- Binary files cannot be displayed via this method
- Rate limits apply (5000 requests/hour for authenticated users)
