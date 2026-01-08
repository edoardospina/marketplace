---
model: claude-sonnet-4-5-20250929
description: Quickly generate PostgreSQL migration from natural language DDL request
argument-hint: <DDL request>
---

# Purpose

Rapidly generate a PostgreSQL migration file from a natural language DDL request, optimizing for speed and iteration during development.

## Variables

DDL_REQUEST: $1
MIGRATIONS_DIR: "supabase/migrations"

## Instructions

- If DDL_REQUEST is empty or not provided, immediately report error: "Error: DDL request is required. Usage: /quick-migration <DDL request>" and exit
- Generate idempotent PostgreSQL 17.6 compatible migrations
- Use CREATE TABLE IF NOT EXISTS for new tables
- Use CREATE INDEX IF NOT EXISTS for indexes
- Use CREATE OR REPLACE FUNCTION for functions
- For triggers, use DROP TRIGGER IF EXISTS before CREATE TRIGGER
- Never use DROP TABLE or other destructive operations without safeguards
- Follow snake_case naming conventions for all database objects
- Use lowercase SQL keywords throughout
- Generate timestamp-based filename: YYYYMMDDHHmmss_description.sql
- Include helpful comments in the SQL explaining what each section does
- Check if similar migration exists and offer to edit instead of creating duplicate
- Support common operations: table creation, indexes, functions, triggers, views, enums, constraints
- Ensure all tables have standard audit fields: created_at, updated_at
- Use uuid as primary key type with gen_random_uuid() as default
- For foreign keys, use ON DELETE CASCADE or RESTRICT as appropriate

## Workflow

1. **Validate Input**: Check if DDL_REQUEST is provided
   - If empty, report: "Error: DDL request is required. Usage: /quick-migration <DDL request>"
   - Exit immediately if no argument provided

2. **Parse Request**: Analyze the natural language DDL_REQUEST to understand:
   - What type of database object (table, index, function, etc.)
   - Object names and relationships
   - Required fields and constraints
   - Any special requirements mentioned

3. **Check Existing Migrations**: Use Glob to list files in MIGRATIONS_DIR
   - Pattern: `supabase/migrations/*.sql`
   - Look for migrations that might conflict or duplicate the request
   - If potential conflict found, suggest editing existing migration

4. **Generate SQL**: Create idempotent PostgreSQL migration based on request type:
   - For tables: Include id (uuid primary key), created_at, updated_at
   - For indexes: Use appropriate index type (btree, gin, gist)
   - For functions: Include proper return types and language specification
   - For triggers: Ensure trigger function exists before creating trigger
   - Add descriptive comments above each major SQL statement

5. **Create Filename**: Generate timestamp-based filename
   - Format: `YYYYMMDDHHmmss_descriptive_name.sql`
   - Extract descriptive name from DDL_REQUEST (snake_case, max 50 chars)
   - Example: `20241117120000_create_users_table.sql`

6. **Write Migration**: Save the SQL to MIGRATIONS_DIR/[filename]
   - Use Write tool to create the new migration file
   - Ensure proper formatting with consistent indentation

7. **Report Success**: Provide clear feedback about what was created

## Report

Present the result based on the outcome:

### If successful:

## ✅ Migration Created Successfully

**File**: `supabase/migrations/[filename]`
**Type**: [Table/Index/Function/Trigger/View/etc.]
**Description**: [Brief summary of what was created]

### Generated SQL:
```sql
[Display the complete SQL or first 30 lines if very long]
```

**Next steps**:
- Review the migration file for correctness
- Run `supabase db reset` to apply all migrations
- Or run `supabase migration up` to apply only new migrations

---

### If error (missing argument):

## ❌ Error: Missing DDL Request

**Usage**: `/quick-migration <DDL request>`

**Examples**:
- `/quick-migration "create users table with email, name, and role"`
- `/quick-migration "add unique index on users email"`
- `/quick-migration "create function to calculate user statistics"`

Please provide a DDL request describing what you want to create or modify.

---

### If potential conflict:

## ⚠️ Potential Conflict Detected

**Existing migration found**: `[existing_file]`
This migration appears to already handle similar operations.

**Options**:
1. Edit the existing migration instead
2. Create a new migration anyway (if the operations are different)
3. Review the existing file first: `supabase/migrations/[existing_file]`

**Generated SQL** (not saved):
```sql
[Display what would have been created]
```

Would you like me to create a new migration or edit the existing one?