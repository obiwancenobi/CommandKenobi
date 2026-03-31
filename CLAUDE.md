# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains command specifications for git operations and planning workflows, available in three formats for OpenCode, Claude Code, and Kilo Code. Core workflow logic is shared across all formats — only user interaction patterns differ per tool.

## Architecture

```
CommandKenobi/
├── .opencode/
│   └── commands/              # OpenCode format
│       ├── commit-all.md
│       ├── commit-staged.md
│       ├── create-pr.md
│       ├── push-all.md
│       ├── push-staged.md
│       ├── add-documentation.md
│       ├── plan-interview.md
│       ├── generate-social-content.md
│       └── generate-onboarding.md
├── .claude/
│   └── commands/              # Claude Code format (you are here)
│       ├── commit-all.md
│       ├── commit-staged.md
│       ├── create-pr.md
│       ├── push-all.md
│       ├── push-staged.md
│       ├── add-documentation.md
│       ├── plan-interview.md
│       ├── generate-social-content.md
│       └── generate-onboarding.md
├── .kilocode/
│   └── workflows/             # Kilo Code format
│       ├── commit-all.md
│       ├── commit-staged.md
│       ├── create-pr.md
│       ├── push-all.md
│       ├── push-staged.md
│       ├── add-documentation.md
│       ├── plan-interview.md
│       ├── generate-social-content.md
│       └── generate-onboarding.md
├── docs/
│   ├── git-commit-workflow.md
│   ├── create-pr-workflow.md
│   ├── generate-social-content-diagram.md
│   └── generate-onboarding-workflow.md
├── AGENTS.md                  # Detailed agent guidelines (primary reference)
├── README.md                  # User-facing documentation
└── CLAUDE.md                  # This file
```

**Key Concept**: This repository is documentation-only. There is no executable code — only command specifications that AI assistants read and execute.

**Multi-Tool Compatibility**: All 9 commands are available in three formats for OpenCode, Claude Code, and Kilo Code. Core logic is shared; only interaction patterns (user prompts, bash syntax, subagent invocation) differ per tool.

## Command Files Structure

This repository provides commands in three formats. You are reading the Claude Code format.

#### Claude Code Format (`.claude/commands/`) — this directory

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

#### OpenCode Format (`.opencode/commands/`)

```yaml
---
description: Brief description
agent: build
---
```
Uses `question` tool and `$ARGUMENTS` for interaction.

#### Kilo Code Format (`.kilocode/workflows/`)

Plain markdown — no frontmatter. Uses `ask_user`, `execute_command`, `new_task()`.

Standard workflow pattern (shared across all formats):
1. Pre-flight checks → 2. Analyze changes → 3. Generate commit message → 4. Present to user → 5. Execute

## Validation & Testing Commands

Since this is a documentation repository, "tests" are manual validation of command files:

```bash
# Verify required frontfields in Claude Code files
for f in .claude/commands/*.md; do
  grep -q "^description:" "$f" && grep -q "^allowed-tools:" "$f" && echo "OK: $f"
done

# Verify required frontfields in OpenCode files
for f in .opencode/commands/*.md; do
  grep -q "^description:" "$f" && grep -q "^agent:" "$f" && echo "OK: $f"
done

# Verify Kilo Code workflow files have title headings
for f in .kilocode/workflows/*.md; do
  grep -q "^# " "$f" && echo "OK: $f"
done

# Check frontmatter structure (opening and closing ---)
grep -n "^---" *.md .opencode/commands/*.md .claude/commands/*.md

# Validate YAML frontmatter syntax (requires yq)
yq eval '.' .opencode/commands/*.md .claude/commands/*.md 2>/dev/null || echo "yq not available"

# Validate a single command file
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
5. Always display changes to the user before execution
6. Keep all three formats (OpenCode, Claude Code, Kilo Code) in sync

## Adding New Commands

Follow AGENTS.md "Adding New Commands" section:

1. Create `.opencode/commands/<action>-<target>.md` (kebab-case)
2. Include required frontmatter: `description` and `agent`
3. Create `.claude/commands/<action>-<target>.md`:
   - Use `allowed-tools` instead of `agent`
   - Replace `question` tool with inline chat prompts
   - Use `Bash(cmd)` syntax
4. Create `.kilocode/workflows/<action>-<target>.md`:
   - No frontmatter — start with `# Title`
   - Replace `question` tool with `ask_user`
   - Use `execute_command` for bash
5. Include sections: Pre-flight Checks, Workflow, Error Handling
6. Test with single command validation above
7. Verify consistency with existing command files across all 3 formats

## Important Patterns

- **Git command execution**: Use `Bash(cmd)` syntax for all git commands
- **Parallel execution**: Run `Bash(git status && git diff --cached && git log --oneline -5)` simultaneously
- **Error messages**: Be specific and suggest concrete fixes
- **Protected branches**: Warn and present three options (Commit Anyway, Create Branch, Cancel) via inline chat prompt
- **Parallel subagents**: For content generation, launch one subagent per platform simultaneously via the `Task` tool
- **User approval**: Present changes in chat with numbered options (1. Accept, 2. Suggest Again, 3. Cancel)

### Multi-Tool Interaction Patterns

| Action | Claude Code (this file) | OpenCode | Kilo Code |
|--------|------------------------|----------|-----------|
| Run bash | `Bash(git status)` | `Run: git status` | `execute_command` with backticks |
| Ask user | Inline chat prompt with numbers | `question` tool with YAML | `ask_user` |
| Subagent | `Task` tool | `Task` tool | `new_task()` |
| Write file | `Write` tool | Agent handles | `write_to_file` |

See individual command files for complete examples of these patterns.

## Reference Files

Primary reference for development:
- `AGENTS.md` — Comprehensive guidelines for agents (code style, workflow patterns, safety)
- `README.md` — User documentation and multi-tool compatibility

Workflow diagrams:
- [docs/git-commit-workflow.md](docs/git-commit-workflow.md) — Flow for commit/push commands
- [docs/create-pr-workflow.md](docs/create-pr-workflow.md) — Flow for `/create-pr` with gh fallback
- [docs/generate-social-content-diagram.md](docs/generate-social-content-diagram.md) — Parallel subagent architecture
- [docs/generate-onboarding-workflow.md](docs/generate-onboarding-workflow.md) — Code tour generation pipeline

Other important files:
- `.opencode/commands/*.md` — OpenCode command specifications
- `.claude/commands/*.md` — Claude Code command specifications (this directory)
- `.kilocode/workflows/*.md` — Kilo Code workflow specifications
- `.gitignore` — Lists: node_modules, package.json, bun.lock (don't commit generated artifacts)

## Dependencies & Tooling

This repository has no runtime dependencies. For local validation, optionally install `yq` to verify YAML frontmatter.

No build, test, or lint commands exist—the repository is static documentation.
