# AGENTS.md

Guidelines for agentic coding agents working in the opencode-commands repository.

## Repository Overview

This repository contains command specifications for git operations and planning workflows. Files are Markdown documents with YAML frontmatter defining slash commands that follow structured workflows.

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
grep -n "^---" *.md .opencode/commands/*.md

# Validate YAML frontmatter syntax
yq eval '.' .opencode/commands/*.md 2>/dev/null || echo "yq not available"

# Check required frontmatter fields in all command files
for f in .opencode/commands/*.md; do
  grep -q "^description:" "$f" && grep -q "^agent:" "$f" && echo "OK: $f"
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

### Safety First
- Always verify git config before operations
- Check current branch for protected warnings
- Present changes for user approval before executing

### Workflow Pattern
Follow: pre-flight → analyze → generate → present → execute

## Adding New Commands

1. Create file in `.opencode/commands/` with `<action>-<target>.md` naming
2. Add required frontmatter: `description` and `agent`
3. Include sections: Pre-flight Checks, Workflow, Error Handling
4. Add user approval steps with question tool
5. Test with single command validation above
6. Verify consistency with existing command files