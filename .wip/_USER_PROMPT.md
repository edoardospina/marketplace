---
tags:
  - claude/code
  - terry
  - prompt/user
  - json
---


## Meta-Template for USER_PROMPT

Based on Anthropic's official guidance and XML best practices.

## Format Selection Guide

### Use Markdown Format When:
- Simple, straightforward tasks
- Quick questions or requests
- Linear instructions without multiple components
- Informal interactions
- Tasks with fewer than 3 distinct sections

### Use XML Format When:
- Complex tasks with multiple components
- Need structured output
- Multiple types of information (context + examples + constraints)
- Want consistent interpretation across sessions
- Planning to parse responses programmatically
- Tasks requiring deep reasoning or planning

## Version A: Markdown Format (Simple Tasks)

```text
### 1. CONTEXT SETTING (Optional)
[Brief situation/background if needed]

### 2. CLEAR DIRECTIVE (Required)
[Active voice, imperative mood]
[Treat Claude like a brilliant new employee]

### 3. SPECIFIC REQUIREMENTS (Required)
- Requirement 1
- Requirement 2
- [Numbered or bulleted]

### 4. CONSTRAINTS/BOUNDARIES (Optional)
- Don't do X
- Must include Y
- Limit to Z

### 5. EXAMPLES (For complex tasks)
Input: [example input]
Output: [expected output]

### 6. SUCCESS CRITERIA (Optional but recommended)
✓ Criteria 1 met
✓ Criteria 2 met

**Key Principles:**
- Be direct and explicit
- Use active voice
- Provide examples for complex tasks
- Include "Think step by step" for reasoning tasks
- Prefer Markdown for structure
```

## Version B: XML Format (Complex Tasks)

```xml
<task>
[Clear, active voice directive - what needs to be done]
</task>

<context>
[Background information, current situation, relevant details]
[Include file paths, tech stack, or system context if relevant]
</context>

<requirements>
- [Specific requirement 1]
- [Specific requirement 2]
- [Additional requirements numbered or bulleted]
</requirements>

<constraints>
- [What NOT to do]
- [Boundaries and limitations]
- [Resources or approach restrictions]
</constraints>

<examples>
<example>
  <input>[Example input]</input>
  <output>[Expected output]</output>
  <explanation>[Why this output is correct]</explanation>
</example>
</examples>

<success_criteria>
- [How to measure successful completion]
- [What the end result should achieve]
- [Quality metrics or acceptance criteria]
</success_criteria>

<output_format>
[Specify if you want: code only, explanations, structured response]
</output_format>
```

## Claude Code Specific Sections

### For File Operations
```xml
<files>
- /path/to/file1.ts
- /path/to/file2.tsx
</files>

<modifications>
[Describe what changes are needed in which files]
</modifications>
```

### For Complex Reasoning Tasks
```xml
<approach>
Please think deeply about this problem.
Consider multiple approaches before implementing.
Use the sequential-thinking MCP if needed.
</approach>
```

### For Testing Requirements
```xml
<test_requirements>
- Unit tests for all new functions
- Integration tests for API endpoints
- Coverage should exceed 80%
</test_requirements>
```

### For Git Operations
```xml
<git_preferences>
- Commit message format: conventional commits
- Create atomic commits
- Don't auto-commit without permission
</git_preferences>
```

## Planning Section (For Complex Tasks)

When tasks require multiple steps or deep analysis, add:

```xml
<planning_request>
Before implementing, please:
1. Analyze the problem thoroughly
2. Consider alternative approaches
3. Identify potential edge cases
4. Create a step-by-step implementation plan
5. Verify the plan before executing
</planning_request>
```

Or use explicit phrases:
- "Think step by step about this problem"
- "Plan before implementing"
- "Consider multiple approaches"
- "Create a detailed plan first"

## Combining Formats

You can mix approaches for optimal results:

```text
### Task Overview
Brief description in markdown

<detailed_requirements>
Complex requirements that benefit from XML structure
</detailed_requirements>

### Quick Notes
- Simple bullets in markdown
- Easy to read points
```
