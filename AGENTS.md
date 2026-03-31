# AGENTS.md

Guidelines for agentic coding agents working in the CommandKenobi repository.

## Repository Overview

This repository contains command specifications for git operations and planning workflows, available in three formats for OpenCode, Claude Code, and Kilo Code. Core workflow logic is shared across all formats — only user interaction patterns differ per tool.

## Cursor/Copilot Rules

No Cursor rules (`.cursor/rules/` or `.cursorrules`) or Copilot rules (`.github/copilot-instructions.md`) found. Follow this document's guidelines.

## Build/Test/Lint Commands

This repository contains Markdown command specs, not executable code. Validate changes with:

### Git Validation
```bash
git config user.name && git config user.email
git branch --show-current
git remote get-url origin
git log --oneline -5
```

### Markdown Validation
```bash
# Check frontmatter structure (must have opening and closing ---)
grep -n "^---" *.md .opencode/commands/*.md .claude/commands/*.md

# Validate YAML frontmatter syntax
yq eval '.' .opencode/commands/*.md .claude/commands/*.md 2>/dev/null || echo "yq not available"

# Check required frontmatter fields in OpenCode command files
for f in .opencode/commands/*.md; do
  grep -q "^description:" "$f" && grep -q "^agent:" "$f" && echo "OK: $f"
done

# Check required frontmatter fields in Claude Code command files
for f in .claude/commands/*.md; do
  grep -q "^description:" "$f" && grep -q "^allowed-tools:" "$f" && echo "OK: $f"
done

# Check Kilo Code workflow files have title headings
for f in .kilocode/workflows/*.md; do
  grep -q "^# " "$f" && echo "OK: $f"
done
```

### Single Test (Validate One Command)
```bash
# Validate a specific command file
f=".opencode/commands/commit-all.md"
head -10 "$f" | grep -E "^(---|description:|agent:)" && echo "Frontmatter OK"
grep -n "## " "$f" | head -5 && echo "Sections OK"
```

## Code Style Guidelines

### File Structure
- Command files: Markdown format with YAML frontmatter
- Required frontmatter: `description`, `agent`
- Naming: `<action>-<target>.md` (e.g., `commit-all.md`, `push-staged.md`, `create-pr.md`)

### Frontmatter Format
```yaml
---
description: Brief description of the command (under 80 chars)
agent: build
---
```

### Imports/Dependencies
- No code dependencies; pure documentation
- Reference git commands directly with inline backticks
- No external tool dependencies for validation

### Formatting
- Use numbered sections with `## ` headers
- Use `### ` for subsections
- Bash commands: inline with backticks or fenced blocks
- Keep line length under 100 characters where possible

### Naming Conventions
- Files: kebab-case only (e.g., `commit-all.md`, `plan-interview.md`)
- Branches: `feat/<short-description>` (lowercase, hyphens)
- Frontmatter: lowercase with colons (e.g., `description:`, `agent:`)

### Error Handling
Always include an `## Error Handling` section with:
- Git config missing: "Git user not configured. Set git config user.name and user.email first."
- Remote missing: "No remote configured. Add a remote with: git remote add origin <url>"
- Nothing to operate on: Clear instruction for next steps
- Push failures: Suggest pull, force push (with caution), or permission denied

### User Interaction
Use the `question` tool for user approval:
```yaml
question: "Clear question about what to do next"
header: "Short context header (max 30 chars)"
options:
  - label: "Accept"
    description: "What this action does"
  - label: "Cancel"
    description: "Abort the operation"
```

## Git Workflow Guidelines

### Conventional Commits
Format: `<type>(<scope>): <subject>`
- Types: feat, fix, docs, style, refactor, test, chore, perf
- Subject: under 72 chars, imperative mood, no period

### Branch Protection
Warn before: main, master, develop, release/*
Require explicit user confirmation for protected branches

## Agent Best Practices

### Parallel Execution
Run independent git commands simultaneously:
```bash
git status && git diff --cached && git log --oneline -5
```

### Parallel Subagents
For content generation commands, launch one subagent per target simultaneously:
- Use the `Task` tool (OpenCode/Claude Code) or `new_task()` (Kilo Code)
- All subagent calls must be in a single message for parallel execution
- Each subagent receives: context, platform, goal, timezone, output path
- Each subagent must include `subagent_type: general`, `description`, and `prompt` parameters
- See [docs/generate-social-content-diagram.md](docs/generate-social-content-diagram.md) for the architecture diagram
- See [docs/generate-onboarding-workflow.md](docs/generate-onboarding-workflow.md) for the onboarding tour architecture

### Safety First
- Always verify git config before operations
- Check current branch for protected warnings
- Present changes for user approval before executing

### Workflow Pattern
Follow: pre-flight → analyze → generate → present → execute

## Adding New Commands

1. Create the OpenCode file in `.opencode/commands/<action>-<target>.md` with `<action>-<target>.md` naming
2. Add required frontmatter: `description` and `agent`
3. Include sections: Pre-flight Checks, Workflow, Error Handling
4. Add user approval steps with the `question` tool
5. Create the Claude Code file in `.claude/commands/<action>-<target>.md`:
   - Replace `agent` with `allowed-tools` in frontmatter
   - Replace `question` tool with inline chat prompts
   - Use `Bash(cmd)` syntax for bash commands
6. Create the Kilo Code file in `.kilocode/workflows/<action>-<target>.md`:
   - No frontmatter — start with `# Title`
   - Replace `question` tool with `ask_user`
   - Use `execute_command` for bash commands
7. Test with single command validation above
8. Verify consistency with existing command files

### Multi-Tool Compatibility

For commands that span OpenCode, Claude Code, and Kilo Code:
- **OpenCode**: `.opencode/commands/` — uses `question` tool, `$ARGUMENTS`, `Task` tool for subagents
- **Claude Code**: `.claude/commands/` — uses `allowed-tools` frontmatter, inline prompts, `Task` tool
- **Kilo Code**: `.kilocode/workflows/` — plain markdown, chat prompts, `new_task()` for subtasks
- Core prompt logic is shared; only interaction patterns differ per tool