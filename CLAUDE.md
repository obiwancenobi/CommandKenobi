# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains slash command specifications for git operations, planning, documentation, and content generation, available in three formats for OpenCode, Claude Code, and Kilo Code, plus skills under `.claude/skills/`. Core workflow logic is shared across all formats — only user interaction patterns differ per tool.

**Key Concept**: This repository is documentation-only. There is no executable code — only command specifications that AI assistants read and execute. No build, test, or lint commands exist.

## Architecture

```
CommandKenobi/
├── .opencode/commands/        # OpenCode format (description + agent, question tool)
├── .claude/
│   ├── commands/              # Claude Code format (description + allowed-tools, inline prompts) — you are here
│   └── skills/app-launch-kit/ # Google Play launch kit skill (SKILL.md + references/ scripts/ assets/)
├── .kilocode/workflows/       # Kilo Code format (no frontmatter, ask_user, execute_command)
├── templates/harness-map.html # Shared rendering template for /harness-map (all tools)
├── docs/
│   ├── *-workflow.md, generate-social-content-diagram.md   # Mermaid workflow diagrams
│   ├── onboarding.html        # Sample /generate-onboarding output for this repo
│   └── superpowers/           # Plans and design specs
├── AGENTS.md                  # Detailed agent guidelines (primary reference)
├── README.md                  # User-facing documentation
└── CLAUDE.md                  # This file
```

Each command directory holds the same 11 files: `commit-all`, `commit-staged`, `create-pr`, `push-all`, `push-staged`, `add-documentation`, `plan-interview`, `generate-social-content`, `generate-onboarding`, `harness-map`, `ship`.

## Claude Code Command Format (`.claude/commands/`)

```markdown
---
description: Brief description (under 80 chars)
allowed-tools: Bash(git:*), Read, Grep, Glob
---

## Pre-flight Checks
[Validation steps with Bash(cmd) syntax]

## Workflow
[Step-by-step with inline chat prompts for user input]

## Error Handling
[Specific error messages and recovery suggestions]
```

Standard workflow pattern (shared across all formats):
1. Pre-flight checks → 2. Analyze changes → 3. Generate output → 4. Present to user → 5. Execute

## Validation

Run the validation loops in AGENTS.md "Build/Test/Lint Commands" (also in README.md "Validation"). Quick check for one Claude Code file:

```bash
f=".claude/commands/commit-all.md"
head -10 "$f" | grep -E "^(---|description:|allowed-tools:)" && echo "Frontmatter OK"
grep -n "## " "$f" | head -5 && echo "Sections OK"
```

## Git Workflow & Conventions

- **Conventional Commits**: `<type>(<scope>): <subject>` (72 char limit, imperative, no period)
- **Commit Types**: feat, fix, docs, style, refactor, test, chore, perf
- **Protected Branches**: main, master, develop, release/* (require explicit user confirmation)
- **Branch Naming**: `feat/<short-description>` (lowercase, hyphens, 3-5 words)
- **User Approval**: All destructive operations present options in chat (Accept/Suggest Again/Cancel)

## Editing or Adding Commands

Follow AGENTS.md "Adding New Commands". In short:

1. Preserve the three-section structure (Pre-flight Checks, Workflow, Error Handling)
2. Keep all three formats (OpenCode, Claude Code, Kilo Code) in sync — same workflow logic, different interaction syntax
3. Maintain parallel execution where independent git commands can run simultaneously
4. Ensure all error paths provide actionable suggestions
5. Always display changes to the user before execution
6. Run the validation loops before committing

## Important Patterns

- **Git command execution**: Use `Bash(cmd)` syntax for all git commands
- **Parallel execution**: Run `Bash(git status && git diff --cached && git log --oneline -5)` simultaneously
- **Error messages**: Be specific and suggest concrete fixes
- **Protected branches**: Warn and present three options (Commit Anyway, Create Branch, Cancel) via inline chat prompt
- **Parallel subagents**: For content generation, launch one subagent per platform simultaneously via the `Agent` tool, all calls in a single message
- **User approval**: Present changes in chat with numbered options (1. Accept, 2. Suggest Again, 3. Cancel)

### Multi-Tool Interaction Patterns

| Action | Claude Code (this file) | OpenCode | Kilo Code |
|--------|------------------------|----------|-----------|
| Run bash | `Bash(git status)` | `Run: git status` | `execute_command` with backticks |
| Ask user | Inline chat prompt with numbers | `question` tool with YAML | `ask_user` |
| Subagent | `Agent` tool | `Task` tool | `new_task()` |
| Write file | `Write` tool | Agent handles | `write_to_file` |

See individual command files for complete examples of these patterns.

## Reference Files

- `AGENTS.md` — Comprehensive guidelines for agents (code style, validation, adding commands, safety)
- `README.md` — User documentation, command guides, Conventional Commits, Git Commands Reference
- `docs/*.md` — Workflow diagrams, one per command family (see README "Workflow Diagrams")
- `.gitignore` — Ignores `social-content/` output, local Claude settings, `.memsearch/`, and OpenCode's generated `package.json`, `package-lock.json`, `bun.lock`, `node_modules/`
