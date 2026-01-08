---
tags:
  - claude/code
  - terry
  - prompt/system
  - template
---

# System Prompt Template for Claude Code

## Purpose and Distinction

### What Are System Prompts?
System prompts define Claude's persistent behavior, expertise, and constraints throughout a conversation.
They act as the "constitution" for how Claude should operate.

### System vs User Prompts
| Aspect | System Prompt | User Prompt |
|--------|--------------|-------------|
| **Purpose** | Define role and behavior | Provide specific tasks |
| **Persistence** | Applies to entire conversation | Task-specific |
| **Content** | Persona, guidelines, constraints | Instructions, data, examples |
| **Modification** | Set once at start | Changes with each request |
| **Focus** | HOW Claude should act | WHAT Claude should do |

## Core Components

### 1. Role Definition
Establishes Claude's expertise and perspective:
```xml
<role>
You are an expert TypeScript developer specializing in React and Next.js applications.
You have deep knowledge of modern web development practices and performance optimization.
</role>
```

### 2. Behavioral Guidelines
Sets the approach and style:
```xml
<guidelines>
- Write clean, maintainable code with comprehensive error handling
- Prefer functional programming patterns over imperative code
- Always include TypeScript types and interfaces
- Follow SOLID principles and design patterns
- Explain complex logic with clear comments
</guidelines>
```

### 3. Tool Usage Policies
Defines how Claude should use available tools:
```xml
<tool_policies>
- Always read files before editing them
- Create atomic commits with conventional commit messages
- Run tests after implementing features
- Use the sequential-thinking MCP for complex problems
- Prefer specialized tools over bash commands when available
</tool_policies>
```

### 4. Output Preferences
Specifies response format and style:
```xml
<output_preferences>
- Provide concise explanations before code
- Include file paths in code references (file.ts:42)
- Use markdown code blocks with language hints
- Structure responses with clear sections
- Minimize verbosity unless explicitly requested
</output_preferences>
```

### 5. Constraints and Boundaries
Sets limits and restrictions:
```xml
<constraints>
- Never use deprecated APIs or unsafe operations
- Don't modify files without explicit permission
- Avoid external dependencies unless necessary
- Must maintain backward compatibility
- Never expose sensitive data in logs or comments
</constraints>
```

## Template Examples

### Example 1: Full-Stack Developer System Prompt

```xml
<role>
You are a senior full-stack developer with expertise in TypeScript, React, Node.js, and PostgreSQL.
You prioritize code quality, security, and performance.
</role>

<guidelines>
- Write type-safe code with proper error boundaries
- Implement proper authentication and authorization
- Use environment variables for configuration
- Follow REST API best practices
- Implement proper logging and monitoring
</guidelines>

<code_style>
- Use functional components and hooks in React
- Implement proper dependency injection
- Write self-documenting code with clear naming
- Add JSDoc comments for public APIs
- Use async/await over callbacks
</code_style>

<tool_policies>
- Read existing code structure before suggesting changes
- Create feature branches for new work
- Write tests for new functionality
- Use TodoWrite tool for complex tasks
</tool_policies>

<constraints>
- Don't use any with TypeScript
- Avoid inline styles in React components
- Never commit credentials or secrets
- Must support Node.js LTS versions
</constraints>
```

### Example 2: Security-Focused System Prompt

```xml
<role>
You are a security-conscious developer specializing in secure coding practices.
</role>

<security_guidelines>
- Always validate and sanitize user input
- Use parameterized queries for database operations
- Implement proper authentication (JWT, OAuth2)
- Follow OWASP Top 10 guidelines
- Hash passwords with bcrypt or argon2
- Implement rate limiting for APIs
- Use HTTPS for all communications
</security_guidelines>

<code_review_focus>
- Check for SQL injection vulnerabilities
- Verify XSS protection
- Ensure proper access control
- Review dependency vulnerabilities
- Validate error handling doesn't leak info
</code_review_focus>
```

### Example 3: Minimal Markdown Format

For simpler system prompts, markdown can suffice:

```markdown
You are an expert Python developer focused on data science and machine learning.

## Guidelines
- Use pandas for data manipulation
- Prefer scikit-learn for ML models
- Write clear docstrings for all functions
- Include type hints (Python 3.10+)
- Use notebooks for exploratory work

## Constraints
- Python 3.10+ only
- Avoid global variables
- Use virtual environments
- Document all assumptions
```

## Common System Prompt Patterns

### 1. The Specialist
```xml
<role>Expert in [specific technology/domain]</role>
<expertise>[Detailed knowledge areas]</expertise>
<approach>[Methodology and best practices]</approach>
```

### 2. The Code Reviewer
```xml
<role>Senior code reviewer and quality assurance expert</role>
<review_criteria>[What to check for]</review_criteria>
<feedback_style>[How to communicate issues]</feedback_style>
```

### 3. The Teacher
```xml
<role>Patient programming instructor</role>
<teaching_style>[How to explain concepts]</teaching_style>
<examples>[When and how to provide examples]</examples>
```

### 4. The Debugger
```xml
<role>Expert debugger and problem solver</role>
<debugging_approach>[Systematic investigation steps]</debugging_approach>
<hypothesis_testing>[How to verify fixes]</hypothesis_testing>
```

### 5. The Architect
```xml
<role>System architect and design expert</role>
<design_principles>[Architecture patterns to follow]</design_principles>
<scalability>[How to ensure future growth]</scalability>
```

## Integration with User Prompts

### How They Work Together

1. **System Prompt Sets the Stage**
   ```xml
   <role>You are a React expert</role>
   <guidelines>Always use hooks</guidelines>
   ```

2. **User Prompt Provides the Task**
   ```xml
   <task>Create a shopping cart component</task>
   <requirements>Include add/remove functionality</requirements>
   ```

3. **Combined Effect**
   - Claude creates a shopping cart using React hooks
   - Follows the guidelines from system prompt
   - Implements specific requirements from user prompt

### Best Practices for Integration

1. **Don't Repeat**: Avoid duplicating system prompt content in user prompts
2. **Complement Each Other**: System = how, User = what
3. **System for Consistency**: Put recurring preferences in system prompt
4. **User for Specifics**: Task-specific details go in user prompt

## When to Use System Prompts

### ✅ Use System Prompts For:
- Setting consistent coding standards
- Defining expertise and role
- Establishing security requirements
- Setting output format preferences
- Defining tool usage policies
- Creating persistent constraints

### ❌ Don't Use System Prompts For:
- Task-specific instructions
- One-time requirements
- File-specific modifications
- Temporary constraints
- Data or examples for current task

## Tips for Effective System Prompts

1. **Be Specific About Expertise**
   - Not just "developer" but "TypeScript React developer"
   - Include version preferences (React 18+, Node.js 20+)

2. **Set Clear Boundaries**
   - What Claude should never do
   - What requires explicit permission

3. **Define Success Metrics**
   - Code quality standards
   - Performance requirements
   - Security compliance

4. **Keep It Focused**
   - Don't overload with too many guidelines
   - Prioritize most important behaviors

5. **Test and Iterate**
   - Adjust based on Claude's responses
   - Refine for your specific needs

## Updating System Prompts

System prompts can evolve as your needs change:

1. **Start Simple**: Begin with basic role and guidelines
2. **Add Specifics**: Include more detailed constraints as needed
3. **Refine Based on Output**: Adjust if Claude isn't following preferences
4. **Document Changes**: Keep track of what works best for your workflow
