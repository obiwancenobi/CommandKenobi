# CommandKenobi

A repository of slash command specifications for git operations, planning, documentation, and content generation. Write once, run across three AI coding assistants.

**Supported Tools:** OpenCode | Claude Code | Kilo Code

## Overview

Each command provides a structured workflow for a common development task: safe git operations, feature planning, documentation, onboarding tours, social content, harness maps, and autonomous PR shipping. The same specification ships in three formats so it works across multiple AI coding assistants. Core workflow logic is shared; only the user interaction patterns differ per tool.

### Quick Start

Commands are auto-discovered from these directories — no configuration needed:

| Tool | Per-project directory | Global directory |
|------|-----------------------|------------------|
| **OpenCode** | `.opencode/commands/` | `~/.config/opencode/command/` |
| **Claude Code** | `.claude/commands/` | `~/.claude/commands/` |
| **Kilo Code** | `.kilocode/workflows/` | `~/.kilocode/workflows/` |

**Option A — Install into one project** (commands available in that project only):

```bash
git clone https://github.com/obiwancenobi/CommandKenobi.git /tmp/commandkenobi
cp -r /tmp/commandkenobi/.opencode /tmp/commandkenobi/.claude /tmp/commandkenobi/.kilocode /tmp/commandkenobi/templates /path/to/your-project/
```

**Option B — Install globally** (commands available in every project):

```bash
git clone https://github.com/obiwancenobi/CommandKenobi.git /tmp/commandkenobi
mkdir -p ~/.claude/commands ~/.claude/templates ~/.config/opencode/command ~/.kilocode/workflows
cp /tmp/commandkenobi/.claude/commands/*.md ~/.claude/commands/
cp /tmp/commandkenobi/templates/*.html ~/.claude/templates/
cp /tmp/commandkenobi/.opencode/commands/*.md ~/.config/opencode/command/
cp /tmp/commandkenobi/.kilocode/workflows/*.md ~/.kilocode/workflows/
```

Only copy the directories for the tools you use. `templates/` is shared by all three tools and needed by `/harness-map` (globally it lives at `~/.claude/templates/`, which all formats use as fallback).

Then use in your AI assistant:

```
/commit-all
/push-staged
/create-pr
```

### Key Concepts and Terminology

| Term | Definition |
|------|------------|
| **Command Specification** | A Markdown file that defines a slash command's behavior |
| **Conventional Commit** | A commit message format following `<type>(<scope>): <subject>` pattern |
| **Pre-flight Check** | Validation steps run before executing a command (e.g., git config verification) |
| **Agent** | The AI assistant type that should execute the command (e.g., `build`, `general`) |
| **Frontmatter** | YAML metadata at the top of OpenCode/Claude Code command files |
| **Workflow** | Kilo Code's name for command specifications (plain Markdown, no frontmatter) |
| **Skill** | A folder with a `SKILL.md` plus optional `references/`, `scripts/`, `assets/` |

## Command Specifications

### Available Commands

All 11 commands are available across OpenCode, Claude Code, and Kilo Code.

| Command | Description | OpenCode | Claude Code | Kilo Code |
|---------|-------------|:--------:|:-----------:|:---------:|
| `/commit-all` | Create a conventional commit from all changes with user approval | `.opencode/` | `.claude/` | `.kilocode/` |
| `/commit-staged` | Create a conventional commit from staged changes with user approval | `.opencode/` | `.claude/` | `.kilocode/` |
| `/create-pr` | Commit all changes, push to remote, and create a pull request | `.opencode/` | `.claude/` | `.kilocode/` |
| `/push-all` | Commit all changes and push to remote with user approval | `.opencode/` | `.claude/` | `.kilocode/` |
| `/push-staged` | Commit staged changes and push to remote with user approval | `.opencode/` | `.claude/` | `.kilocode/` |
| `/add-documentation` | Add comprehensive documentation for code/features | `.opencode/` | `.claude/` | `.kilocode/` |
| `/plan-interview` | Interview to expand a spec from prompt | `.opencode/` | `.claude/` | `.kilocode/` |
| `/generate-social-content` | Generate social media content across platforms with parallel subagents | `.opencode/` | `.claude/` | `.kilocode/` |
| `/generate-onboarding` | Generate a guided code tour as a standalone HTML file for project onboarding | `.opencode/` | `.claude/` | `.kilocode/` |
| `/harness-map` | Generate an interactive force-graph map of the current agent harness | `.opencode/` | `.claude/` | `.kilocode/` |
| `/ship` | Create a PR, babysit checks, fix review comments, and merge when green | `.opencode/` | `.claude/` | `.kilocode/` |

Every command follows the same pattern:

```
1. Pre-flight Checks → 2. Analyze → 3. Generate Output → 4. User Approval → 5. Execute
```

## Skills

Skills are folders with a `SKILL.md` file plus optional `references/`, `scripts/`, and `assets/`. Claude Code and OpenCode load them from `.claude/skills/` in a project, or from `~/.claude/skills/` globally.

| Skill | Description |
|-------|-------------|
| `app-launch-kit` | Produce the complete Google Play launch kit in one pass: store listing copy, screenshots and store cards from a real build, feature graphic and icon, a portrait promo video, a release checklist audited against the code, and launch social content. Uses `/generate-social-content` when installed. macOS host assumed (Chrome, adb, sips). |

Install globally:

```bash
cp -r /tmp/commandkenobi/.claude/skills/* ~/.claude/skills/
```

Related third-party skills that pair well with the launch kit: [`aso`](https://github.com/coreyhaines31/marketingskills/tree/main/skills/aso) and [`launch`](https://github.com/coreyhaines31/marketingskills/tree/main/skills/launch) from `coreyhaines31/marketingskills`. Install them with `npx skills add coreyhaines31/marketingskills`.

## Command Guides

### `/create-pr`

1. Runs pre-flight checks and stages all changes
2. Review and accept the generated commit message
3. Changes are committed and pushed
4. AI generates PR title and body from changes
5. If `gh` is available, creates PR via CLI; otherwise opens browser for manual creation

[See workflow diagram](docs/create-pr-workflow.md) for the gh CLI fallback.

### `/plan-interview <feature-description>`

1. AI assistant asks clarifying questions
2. Review and confirm final spec outline
3. Git branch is created (if in git repo)
4. Spec is written to `plan.md`

### `/generate-social-content <topic>`

1. Execute with a topic (or without args to be prompted)
2. Select your timezone for best-time-to-post recommendations
3. Multi-select target platforms (LinkedIn, Twitter/X, Instagram, Facebook, TikTok, Reddit, YouTube)
4. Select content goal (Awareness, Engagement, Leads, Launch, Education, Community)
5. AI assistant launches parallel subagents — one per platform
6. A humanizer subagent rewrites every file to remove AI-sounding patterns
7. A `summary.md` with posting calendar is generated

**Output:** `social-content/<topic-slug>/` containing per-platform content files and a posting calendar.

[See workflow diagram](docs/generate-social-content-diagram.md) for the full flow and subagent architecture.

### `/generate-onboarding [focus area]`

1. AI assistant scans project structure and identifies languages, frameworks, entry points
2. Launches 5 parallel research subagents (execution flow, data flow, config, patterns, dependencies)
3. Each subagent traces its area and returns findings with file:line references
4. Tour builder generates a self-contained HTML file with Mermaid diagrams

**Output:** `docs/onboarding.html` (or `docs/onboarding-<focus>.html` if a focus area is provided) — open in any browser for a guided code tour. This repo's own tour is checked in at [docs/onboarding.html](docs/onboarding.html) as a sample.

[See workflow diagram](docs/generate-onboarding-workflow.md) for the full pipeline.

### `/harness-map`

1. AI assistant reads the rendering template at `templates/harness-map.html`
2. Enumerates the live session harness: core tools, deferred tools, MCP servers, agent types, and all skills grouped by source
3. Injects the fresh data into the template (rendering code is never rewritten)
4. Saves the result and opens it (Claude Code additionally publishes it as an Artifact)

**Output:** `docs/harness-map.html` — an interactive force-directed graph with search, zoom, collapse/expand, and dark/light themes.

[See workflow diagram](docs/harness-map-workflow.md) for the full flow and template architecture.

### `/ship [notes]`

1. Execute `/ship` (optionally with notes: `/ship base develop` or a PR title)
2. AI assistant branches off protected branches, commits pending work with a Conventional Commits message, and pushes
3. Opens a PR via `gh` (or reuses an existing one) and reports the URL immediately
4. Babysits the PR: polls checks and review comments, fixes failures, pushes updates
5. Triages every review comment: crucial issues (bugs, security, data loss) get fixed; non-crucial nits get a brief reply explaining the skip — AI reviewers (CodeRabbit, Copilot, Gemini) are treated as suggestions, not orders
6. Replies to and resolves every review thread; dismisses bot reviews stuck in "Changes requested" (never a human's)
7. Merges automatically (`--squash --delete-branch`) once checks are green and all threads are resolved

**Autonomous by design** — it only stops for genuine blockers: unresolvable merge conflicts, ambiguous test failures, or review feedback needing a human decision.

[See workflow diagram](docs/ship-workflow.md) for the full flow and review comment triage.

## Multi-Tool Compatibility

All commands are available in three formats. Core workflow logic is shared — only user interaction patterns differ per tool.

| Platform | Directory | Frontmatter | User Prompts | Bash | Subagents |
|----------|-----------|-------------|-------------|------|-----------|
| **OpenCode** | `.opencode/commands/` | `description` + `agent` | `question` tool | `Run: cmd` | `Task` tool |
| **Claude Code** | `.claude/commands/` | `description` + `allowed-tools` | Inline chat prompts | `Bash(cmd)` | `Agent` tool |
| **Kilo Code** | `.kilocode/workflows/` | None (plain markdown) | `ask_user` | `execute_command` | `new_task()` |

### Command File Structure

#### OpenCode Format (`.opencode/commands/`)

```yaml
---
description: Brief description of the command
agent: build
---

## Pre-flight Checks
[Validation steps]

## Workflow
[Step-by-step instructions]

## Error Handling
[Common errors and responses]
```

#### Claude Code Format (`.claude/commands/`)

```yaml
---
description: Brief description of the command
allowed-tools: Bash(git:*), Read, Grep, Glob
---

## Pre-flight Checks
[Validation steps with Bash(cmd) syntax]

## Workflow
[Step-by-step with inline chat prompts for user input]

## Error Handling
[Common errors and responses]
```

`allowed-tools` is a comma-separated list (e.g., `Bash(git:*), Read, Agent`) and scopes the command's permissions.

#### Kilo Code Format (`.kilocode/workflows/`)

```markdown
# Command Title

Brief description of the command.

## Pre-flight Checks
[Validation steps using execute_command]

## Workflow
[Step-by-step with ask_user for user input]

## Error Handling
[Common errors and responses]
```

### Same Command, Three Formats

Here is how a user approval step looks in each tool:

**OpenCode** — uses structured `question` tool:
```yaml
Use question tool to ask user:
- question: "Commit message ready. What would you like to do?"
- header: "Commit Action"
- options:
  - label: "Accept"
    description: "Stage all and commit with this message"
  - label: "Cancel"
    description: "Abort the commit"
```

**Claude Code** — uses inline chat prompts:
```
Ask in chat:
1. Accept — Stage all and commit with this message
2. Suggest Again — Generate an alternative commit message
3. Cancel — Abort the commit

Reply with the number.
```

**Kilo Code** — uses `ask_user`:
```
Use ask_user:
> Commit message ready. What would you like to do?
>
> 1. Accept — Stage all and commit with this message
> 2. Suggest Again — Generate an alternative commit message
> 3. Cancel — Abort the commit
```

## Conventional Commits

All git commands in this repository use conventional commit messages.

### Commit Message Format

```
<type>(<scope>): <subject>
```

### Commit Types

| Type | Description |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only changes |
| `style` | Changes that do not affect the meaning of the code (white-space, formatting, etc) |
| `refactor` | A code change that neither fixes a bug nor adds a feature |
| `test` | Adding missing tests or correcting existing tests |
| `chore` | Changes to the build process or auxiliary tools |
| `perf` | A code change that improves performance |

### Examples

```
feat(auth): add user authentication module
fix(database): resolve connection timeout issue
docs(readme): update installation instructions
refactor(utils): simplify date formatting logic
```

### Subject Line Rules

- Maximum 72 characters
- Use imperative mood (e.g., "add" not "added")
- No period at the end
- Focus on what the change does

### Protected Branches

`main`, `master`, `develop`, and `release/*` trigger a warning with three options: Commit Anyway, Create Branch (`feat/<short-description>`, lowercase, hyphens, 3-5 words), or Cancel.

### Git Commands Reference

| Command | Purpose |
|---------|---------|
| `git config user.name` | Get configured git username |
| `git config user.email` | Get configured git email |
| `git branch --show-current` | Get current branch name |
| `git remote get-url origin` | Get remote repository URL |
| `git status` | Show working tree status |
| `git diff --cached` | Show staged changes |
| `git diff` | Show unstaged changes |
| `git log --oneline -5` | Show recent commits |
| `git add .` | Stage all changes |
| `git commit -m "<msg>"` | Create a commit |
| `git push origin <branch>` | Push to remote |

## Repository Layout

```
CommandKenobi/
├── .opencode/commands/        # OpenCode format (YAML frontmatter + question tool)
├── .claude/
│   ├── commands/              # Claude Code format (allowed-tools + inline prompts)
│   └── skills/app-launch-kit/ # Google Play launch kit skill
├── .kilocode/workflows/       # Kilo Code format (plain markdown + ask_user)
├── templates/harness-map.html # Shared rendering template for /harness-map
├── docs/
│   ├── *-workflow.md          # Mermaid workflow diagrams (see below)
│   ├── onboarding.html        # Sample output of /generate-onboarding for this repo
│   └── superpowers/           # Plans and design specs
├── AGENTS.md                  # Guidelines for agents editing this repo
├── CLAUDE.md                  # Claude Code project instructions
└── README.md
```

Each of the three command directories holds the same 11 files, named `<action>-<target>.md`.

### Workflow Diagrams

| Diagram | Description |
|---------|-------------|
| [Git Commit Workflow](docs/git-commit-workflow.md) | Flow for `/commit-all`, `/commit-staged`, `/push-all`, `/push-staged` |
| [Create PR Workflow](docs/create-pr-workflow.md) | Flow for `/create-pr` including gh CLI fallback |
| [Generate Social Content](docs/generate-social-content-diagram.md) | Parallel subagent architecture for `/generate-social-content` |
| [Generate Onboarding](docs/generate-onboarding-workflow.md) | Code tour generation pipeline for `/generate-onboarding` |
| [Harness Map](docs/harness-map-workflow.md) | Template + live-data injection flow for `/harness-map` |
| [Ship Workflow](docs/ship-workflow.md) | PR-to-merge flow for `/ship` including review comment triage |

### Design Decisions

1. **Markdown with Frontmatter**: Chosen for readability and ease of parsing
2. **User Approval Workflows**: All destructive operations require explicit user confirmation
3. **Parallel Execution**: Independent git commands and subagents run in parallel
4. **Error Handling First**: Pre-flight checks run before any action to fail fast
5. **Multi-Tool Format**: Same core logic in three formats — only interaction patterns differ

This repository has no runtime dependencies. It is documentation only.

## Validation

```bash
# Check OpenCode frontmatter (requires description + agent)
for f in .opencode/commands/*.md; do
  grep -q "^description:" "$f" && grep -q "^agent:" "$f" && echo "OK: $f"
done

# Check Claude Code frontmatter (requires description + allowed-tools)
for f in .claude/commands/*.md; do
  grep -q "^description:" "$f" && grep -q "^allowed-tools:" "$f" && echo "OK: $f"
done

# Check Kilo Code workflows (requires title heading)
for f in .kilocode/workflows/*.md; do
  grep -q "^# " "$f" && echo "OK: $f"
done

# Validate YAML frontmatter syntax
yq eval '.' .opencode/commands/*.md .claude/commands/*.md 2>/dev/null || echo "yq not available"
```

## Contributing

To add or edit a command, follow the "Adding New Commands" steps in [AGENTS.md](AGENTS.md). Every command must exist in all three formats with identical workflow logic.

## License

This repository is used for AI-assisted software engineering workflows.
