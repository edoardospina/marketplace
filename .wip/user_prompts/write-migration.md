---
model: claude-sonnet-4-5-20250929
description: Generate PostgreSQL migrations from natural language DDL requests
argument-hint: <DDL request description>
---

# Purpose

Generate production-ready, idempotent PostgreSQL migration files for Supabase from natural language DDL requests. Uses the specialized migration-writer agent to create or modify SQL migrations in `supabase/migrations/` following PostgreSQL 17.6 best practices.

## Variables

DDL_REQUEST: $1
AGENT_PATH: ".claude/agents/migration-writer.md"
MIGRATIONS_DIR: "supabase/migrations"

## Codebase Structure

```
project/
├── .claude/
│   ├── commands/            # Slash commands (this file)
│   └── agents/
│       └── migration-writer.md  # PostgreSQL migration expert agent
└── supabase/
    └── migrations/          # PostgreSQL migration files (YYYYMMDDHHmmss_*.sql)
```

## Instructions

- Validate that DDL_REQUEST is provided (not empty)
- Verify the migration-writer agent exists at AGENT_PATH before proceeding
- Do NOT attempt to write migrations directly - always delegate to the migration-writer agent
- The agent will handle all PostgreSQL-specific concerns (idempotency, dependencies, naming)
- Report any errors clearly - either missing arguments or missing agent file
- Allow the agent to determine if new files are needed or existing ones should be modified
- Trust the agent's expertise in PostgreSQL 17.6 and Supabase conventions

## Workflow

1. **Validate Input**: Check if DDL_REQUEST is provided
   - If empty or missing, report error: "Error: DDL request description is required. Usage: /write-migration <DDL request>"
   - Exit workflow if validation fails

2. **Verify Agent**: Check that the migration-writer agent exists
   - Use Read tool to verify AGENT_PATH exists
   - If missing, report error: "Error: Migration writer agent not found at .claude/agents/migration-writer.md"
   - Exit workflow if agent is missing

3. **Invoke Migration Writer**: Use Task tool to delegate to the migration-writer agent
   ```
   Task:
   - subagent_type: migration-writer
   - description: Write DDL migration
   - prompt: Create PostgreSQL migrations for: [DDL_REQUEST]
   ```

4. **Monitor Progress**: The migration-writer agent will:
   - Analyze the DDL requirements
   - Plan migration order and dependencies
   - Generate timestamp-based filenames
   - Write idempotent SQL to MIGRATIONS_DIR
   - Document the migrations with comments
   - Report created/modified files

5. Now follow the `Report` section to report the completed work

## Report

Present the migration results in this format:

## PostgreSQL Migrations Generated

### Request
**DDL Description**: [DDL_REQUEST]

### Summary
- **Migrations created**: [count]
- **Tables affected**: [list of table names]
- **Operations**: [CREATE TABLE, ALTER TABLE, CREATE INDEX, etc.]

### Files Created/Modified

#### [filename]
**Path**: `supabase/migrations/[YYYYMMDDHHmmss_description].sql`
**Purpose**: [What this migration accomplishes]
**Dependencies**: [Other migrations this depends on, if any]

[Repeat for each file]

### Execution Order
1. [First migration file] - [brief description]
2. [Second migration file] - [brief description]
[Continue for all migrations]

### Next Steps
- Run locally: `supabase db reset` (applies all migrations)
- Deploy: `supabase db push` (applies to remote database)
- Rollback strategy: [If complex, note any special considerations]

### Notes
[Any warnings, assumptions, or important details from the migration writer]