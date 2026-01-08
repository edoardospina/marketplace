---
name: markitdown
description: |
  This skill should be used when the user asks to "convert this PDF to markdown", "read this Word document", "extract text from this image", "analyze this spreadsheet", "transcribe this audio file", "transcribe this YouTube video", "what does this document say", "parse this Excel file", "OCR this image", "summarize this PDF", "convert to markdown", "what's in this file", "help me read this PPTX", or needs to process binary documents for analysis. Supports PDF, DOCX, PPTX, XLSX, XLS, HTML (local files), CSV, JSON, XML, images (OCR), audio (transcription), YouTube URLs (for transcription), EPUB, and ZIP files.

  This skill should NOT be used when the user asks to "fetch this webpage", "scrape this URL", "get content from this website", "read this website", or needs to retrieve and convert content from http:// or https:// web page URLs. For web page retrieval, use Claude Code's native WebFetch tool, or use firecrawl-mcp/firecrawl skills if installed. Note: YouTube URLs are supported for video transcription—this is the only web URL type markitdown handles directly.
version: 1.0.0
---

# MarkItDown Skill

Convert documents to clean markdown for LLM analysis. Preserves structure (headings, tables, lists) while maximizing token efficiency.

## Supported Formats

PDF, DOCX, PPTX, XLSX, XLS, HTML, CSV, JSON, XML, images (OCR), audio (transcription), YouTube URLs, EPUB, ZIP

## Core Workflow

To convert and analyze a document:

1. Convert the file to markdown:

   ```bash
   markitdown /path/to/file.pdf -o /tmp/converted.md
   ```

2. Read the converted markdown using the Read tool

3. Proceed with analysis on the markdown content

## Command Reference

```bash
# Basic conversion (outputs to stdout)
markitdown file.pdf

# Save to file (recommended for large documents)
markitdown file.pdf -o output.md

# Pipe from stdin
cat file.pdf | markitdown

# Pipe from URL
curl -s https://example.com/doc.pdf | markitdown

# Batch processing
for f in *.pdf; do markitdown "$f" -o "${f%.pdf}.md"; done
```

## Guidelines

**Do:**

- Convert once, read the `.md` multiple times
- Use `-o` to save output for documents over 1000 lines
- Convert before starting analysis tasks
- Check file extension to verify format is supported

**Avoid:**

- Re-converting the same file repeatedly
- Relying only on stdout for very large documents
- Attempting to parse binary formats directly without conversion

## Output Format Notes

| Format     | Output Characteristics                     |
| ---------- | ------------------------------------------ |
| Excel      | Each sheet as a separate section           |
| PowerPoint | Slide-by-slide with speaker notes included |
| Images     | OCR-extracted text plus EXIF metadata      |
| Tables     | Converted to markdown table syntax         |
| HTML       | Clean markdown with preserved hierarchy    |
