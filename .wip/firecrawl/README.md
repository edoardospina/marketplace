# Firecrawl Plugin

A Claude Code plugin for web scraping, crawling, and content extraction using the [Firecrawl API](https://www.firecrawl.dev/).

## Features

- **Scrape** - Extract content from single webpages as markdown/HTML
- **Crawl** - Crawl entire websites and extract all pages
- **Map** - Discover all URLs on a website quickly
- **Search** - Search the web and get full page content
- **Extract** - AI-powered structured data extraction with JSON schema support

## Setup

1. Sign up at [firecrawl.dev](https://www.firecrawl.dev/)
2. Get your API key from the dashboard
3. Set the environment variable:

```bash
export FIRECRAWL_API_KEY="fc-your-api-key"
```

## Usage

This plugin provides the `firecrawl` skill which guides Claude through using the Firecrawl API via curl.

Example prompts:
- "Scrape the documentation at https://docs.example.com"
- "Map all URLs on example.com"
- "Search for recent AI news and get the full content"
- "Extract product information from this page"

## API Reference

- [Firecrawl Documentation](https://docs.firecrawl.dev/)
- [API Reference](https://docs.firecrawl.dev/api-reference)

## Credits

Uses the Firecrawl API - credits consumed per request based on your plan.
