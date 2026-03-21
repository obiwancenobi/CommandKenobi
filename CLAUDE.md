# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains command specifications for git operations and planning workflows. Files are Markdown documents with YAML frontmatter defining slash commands that follow structured workflows.

## Architecture

```
opencode-commands/
├── .opencode/
│   ├── commands/          # Command specification files (*.md)
│   │   ├── commit-all.md
│   │   ├── commit-staged.md
│   │   ├── create-pr.md
│   │   ├── push-all.md
│   │   ├── push-staged.md
│   │   ├── add-documentation.md
│   │   └── plan-interview.md
│   ├── node_modules/      # If developing/testing locally
│   └── package.json       # Empty (documentation-only repository)
├── AGENTS.md              # Detailed agent guidelines (primary reference)
├── README.md              # User-facing documentation
└── CLAUDE.md              # This file
```

**Key Concept**: This repository is documentation-only. There is no executable code—only Markdown command specifications that AI assistants read and execute.

## Command Files Structure

Each command specification follows:

```markdown
---
description: Brief description (under 80 chars)
agent: build
---

## Pre-flight Checks
[Validation steps: git config, branch protection, remote status]

## Workflow
[Step-by-step instructions with parallel commands where possible]

## Error Handling
[Specific error messages and recovery suggestions]
```

Required frontmatter fields:
- `description` — shown in command help
- `agent` — AI assistant type that should execute (always `build` in this repo)

Standard workflow pattern:
1. Pre-flight checks → 2. Analyze changes → 3. Generate commit message → 4. Present to user → 5. Execute

## Validation & Testing Commands

Since this is a documentation repository, "tests" are manual validation of command files:

```bash
# Verify required frontmatter fields exist
for f in .opencode/commands/*.md; do
  grep -q "^description:" "$f" && grep -q "^agent:" "$f" && echo "OK: $f"
done

# Check frontmatter structure (opening and closing ---)
grep -n "^---" *.md .opencode/commands/*.md

# Validate YAML frontmatter syntax (requires yq)
yq eval '.' .opencode/commands/*.md 2>/dev/null || echo "yq not available"

# Validate a single command file
f=".opencode/commands/commit-all.md"
head -10 "$f" | grep -E "^(---|description:|agent:)" && echo "Frontmatter OK"
grep -n "## " "$f" | head -5 && echo "Sections OK"
```

## Git Workflow & Conventions

- **Conventional Commits**: `<type>(<scope>): <subject>` (72 char limit, imperative, no period)
- **Commit Types**: feat, fix, docs, style, refactor, test, chore, perf
- **Protected Branches**: main, master, develop, release/* (require explicit user confirmation)
- **Branch Naming**: `feat/<short-description>` (lowercase, hyphens, 3-5 words)
- **User Approval**: All destructive operations use the `question` tool with Accept/Suggest Again/Cancel options

Refer to README.md sections:
- "Conventional Commits" for full format details
- "Command Specifications" for available commands
- "Git Commands Reference" for git commands used across specs

## Editing Existing Commands

When modifying command files:

1. Preserve the three-section structure (Pre-flight Checks, Workflow, Error Handling)
2. Maintain parallel execution where independent git commands can run simultaneously
3. Ensure all error paths provide actionable suggestions
4. Keep imperative, concise language in workflow steps
5. Always display changes to the user before execution with the question tool

## Adding New Commands

Follow AGENTS.md "Adding New Commands" section:

1. Create `.opencode/commands/<action>-<target>.md` (kebab-case)
2. Include required frontmatter: `description` and `agent`
3. Include sections: Pre-flight Checks, Workflow, Error Handling
4. Add user approval steps with `question` tool
5. Test with single command validation above
6. Verify consistency with existing command files

## Important Patterns

- **Git command execution**: Always use fenced code blocks with `git <command>` syntax
- **Parallel execution**: Run `git status && git diff --cached && git log --oneline -5` simultaneously
- **Error messages**: Be specific and suggest concrete fixes
- **Protected branches**: Warn and present three options (Commit Anyway, Create Branch, Cancel)

See individual command files for complete examples of these patterns.

## Reference Files

Primary reference for development:
- `AGENTS.md` — Comprehensive guidelines for agents (code style, workflow patterns, safety)
- `README.md` — User documentation and API compatibility

Other important files:
- `.opencode/commands/*.md` — All command specifications (use as templates)
- `.gitignore` — Lists: node_modules, package.json, bun.lock (don't commit generated artifacts)

## Dependencies & Tooling

This repository has no runtime dependencies. For local validation, optionally install `yq` to verify YAML frontmatter.

No build, test, or lint commands exist—the repository is static documentation.
