# CommandKenobi

A repository of slash command specifications for git operations and planning workflows. Write once, run across three AI coding assistants.

**Supported Tools:** OpenCode | Claude Code | Kilo Code

## Overview

This repository provides the same command specifications in three formats so they work across multiple AI coding assistants. Each command provides a structured workflow for common development tasks, ensuring consistent and safe git operations.

### Quick Start

Pick your tool and you're ready to go — no configuration needed.

| Tool | Directory | Setup |
|------|-----------|-------|
| **OpenCode** | `.opencode/commands/` | Clone repo, commands auto-discovered |
| **Claude Code** | `.claude/commands/` | Clone repo, commands auto-discovered |
| **Kilo Code** | `.kilocode/workflows/` | Clone repo, workflows auto-discovered |

```bash
# Clone into any of your projects
git clone <this-repo-url> .

# Then use in your AI assistant:
/commit-all
/push-staged
/create-pr
```

### What This Repository Does

The repository provides pre-defined command specifications that:
- Guide git operations with conventional commit standards
- Ensure safe practices through pre-flight checks
- Provide user approval workflows before destructive operations
- Standardize commit message formatting across projects
- Facilitate feature planning through structured interviews
- Work across OpenCode, Claude Code, and Kilo Code

### Why It Exists

This repository exists to:
1. **Standardize Git Workflows**: Ensure consistent commit messages and git operations across all projects
2. **Prevent Mistakes**: Implement pre-flight checks and user approval steps to prevent accidental commits
3. **Enforce Best Practices**: Use conventional commit formats and protect sensitive branches
4. **Streamline Planning**: Provide structured workflows for feature specification and planning
5. **Multi-Tool Support**: Write once, use across OpenCode, Claude Code, and Kilo Code

### Key Concepts and Terminology

| Term | Definition |
|------|------------|
| **Command Specification** | A Markdown file that defines a slash command's behavior |
| **Conventional Commit** | A commit message format following `<type>(<scope>): <subject>` pattern |
| **Pre-flight Check** | Validation steps run before executing a command (e.g., git config verification) |
| **Agent** | The AI assistant type that should execute the command (e.g., `build`, `general`) |
| **Frontmatter** | YAML metadata at the top of OpenCode/Claude Code command files |
| **Workflow** | Kilo Code's name for command specifications (plain Markdown, no frontmatter) |

## Command Specifications

### Available Commands

All 9 commands are available across OpenCode, Claude Code, and Kilo Code.

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

### Frontmatter Fields

#### OpenCode

| Field | Required | Description |
|-------|----------|-------------|
| `description` | Yes | Brief description shown in command help |
| `agent` | Yes | AI assistant type that should execute (e.g., `build`, `general`) |

#### Claude Code

| Field | Required | Description |
|-------|----------|-------------|
| `description` | Yes | Brief description shown in command help |
| `allowed-tools` | Yes | Space-separated list of allowed tools (e.g., `Bash(git:*), Read, Task`) |

#### Kilo Code

No frontmatter required. Commands are plain Markdown files with a title heading.

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

## API Documentation

### Multi-Tool Compatibility

All commands are available in three formats. Core workflow logic is shared — only user interaction patterns differ per tool.

| Platform | Directory | Frontmatter | User Prompts | Bash | Subagents |
|----------|-----------|-------------|-------------|------|-----------|
| **OpenCode** | `.opencode/commands/` | `description` + `agent` | `question` tool | `Run: cmd` | `Task` tool |
| **Claude Code** | `.claude/commands/` | `description` + `allowed-tools` | Inline chat prompts | `Bash(cmd)` | `Task` tool |
| **Kilo Code** | `.kilocode/workflows/` | None (plain markdown) | `ask_user` | `execute_command` | `new_task()` |

#### Same Command, Three Formats

For example, here's how a user approval step looks in each tool:

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

### Setup Instructions

#### For OpenCode Users

1. Clone or copy this repository to your project
2. Commands are auto-discovered from `.opencode/commands/*.md`
3. Use `/commit-all`, `/push-staged`, etc. in your conversation

#### For Claude Code Users

1. Clone or copy this repository to your project
2. Commands are auto-discovered from `.claude/commands/*.md`
3. Use `/commit-all`, `/push-staged`, etc. in your conversation
4. Commands include `allowed-tools` in frontmatter for permission scoping

#### For Kilo Code Users

1. Clone or copy this repository to your project
2. Workflows are auto-discovered from `.kilocode/workflows/*.md`
3. Use the workflow commands in your conversation

### Usage Instructions

#### Invoking Commands

Once the repository is set up, you can use the slash commands in your conversations:

1. **Start a conversation** with your AI assistant
2. **Type a command** like `/commit-all` or `/push-staged`
3. **The assistant will**:
   - Read the corresponding command file from the tool-specific directory
   - Execute pre-flight checks
   - Present options for your approval
   - Perform the requested operation

#### Command Flow

Each command follows this pattern:

```
1. Pre-flight Checks → 2. Analyze Changes → 3. Generate Output → 4. User Approval → 5. Execute
```

#### Example Usage

```
You: /commit-all

Assistant: Running pre-flight checks...
✓ Git user configured: your-name
✓ Current branch: feature/my-feature
✓ No protected branch warning

Analyzing changes...
Found 3 modified files:
- src/app.ts
- src/utils.ts
- README.md

Generated commit message:
feat(app): add user authentication module

Commit message ready. What would you like to do?
1. Accept — Stage all and commit with this message
2. Suggest Again — Generate an alternative commit message
3. Cancel — Abort the commit

You: 1

Assistant: ✓ Commit created: feat(app): add user authentication module
```

### Tool Execution Syntax

Each tool has its own syntax for executing commands and prompting users:

#### OpenCode

| Syntax | Purpose |
|--------|---------|
| `` `command` `` | Execute a bash command |
| `question` | Prompt the user for input via structured question tool |

#### Claude Code

| Syntax | Purpose |
|--------|---------|
| `Bash(command)` | Execute a bash command |
| Inline chat prompt | Ask user with numbered options in chat |

#### Kilo Code

| Syntax | Purpose |
|--------|---------|
| `execute_command` with backtick-wrapped command | Execute a bash command |
| `ask_user` | Prompt the user with options |
| `new_task()` | Launch a parallel subtask |
| `write_to_file` | Write content to a file |

### Question Tool Parameters (OpenCode)

When user interaction is needed in OpenCode, use the question tool with:

```yaml
question: "Clear question about what to do next"
header: "Short context header"
options:
  - label: "Action 1"
    description: "What this action does"
  - label: "Cancel"
    description: "Abort the operation"
```

### Git Commands Reference

The following git commands are used across commands:

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

## Implementation Details

### Architecture Overview

The repository provides commands in three formats for multi-tool compatibility:

```
CommandKenobi/
├── .opencode/
│   └── commands/              # OpenCode format (YAML frontmatter + question tool)
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
│   └── commands/              # Claude Code format (allowed-tools + inline prompts)
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
│   └── workflows/             # Kilo Code format (plain markdown + ask_user)
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
├── AGENTS.md
├── CLAUDE.md
└── README.md
```

### Workflow Diagrams

| Diagram | Description |
|---------|-------------|
| [Git Commit Workflow](docs/git-commit-workflow.md) | Flow for `/commit-all`, `/commit-staged`, `/push-all`, `/push-staged` |
| [Create PR Workflow](docs/create-pr-workflow.md) | Flow for `/create-pr` including gh CLI fallback |
| [Generate Social Content](docs/generate-social-content-diagram.md) | Parallel subagent architecture for `/generate-social-content` |
| [Generate Onboarding](docs/generate-onboarding-workflow.md) | Code tour generation pipeline for `/generate-onboarding` |

### Design Decisions

1. **Markdown with Frontmatter**: Chosen for readability and ease of parsing
2. **Agent Type Specification**: Ensures commands are executed by appropriate AI assistants
3. **User Approval Workflows**: All destructive operations require explicit user confirmation
4. **Parallel Execution**: Independent git commands run in parallel for efficiency
5. **Error Handling First**: Pre-flight checks run before any action to fail fast
6. **Multi-Tool Format**: Same core logic in three formats — only interaction patterns differ

### Dependencies

This repository has no runtime dependencies. It is a documentation-only repository containing command specifications.

## Usage Examples

### Creating a Commit with `/commit-all`

1. Make changes to your files
2. Execute `/commit-all` command
3. AI assistant runs pre-flight checks
4. Review generated commit message
5. Accept or suggest alternatives
6. Commit is created with approval

### Pushing Changes with `/push-staged`

1. Stage specific files: `git add <file>`
2. Execute `/push-staged` command
3. AI assistant verifies staged changes
4. Generate conventional commit message
5. Get user approval
6. Commit and push to remote

### Creating a PR with `/create-pr`

1. Execute `/create-pr` command
2. AI assistant runs pre-flight checks and stages all changes
3. Review generated commit message
4. Accept or suggest alternatives
5. Changes are committed and pushed
6. AI generates PR title and body from changes
7. If `gh` is available, creates PR via CLI; otherwise opens browser for manual creation
8. Get confirmation with PR URL

### Planning a Feature with `/plan-interview`

1. Execute `/plan-interview <feature-description>`
2. AI assistant asks clarifying questions
3. Review and confirm final spec outline
4. Git branch is created (if in git repo)
5. Spec is written to `plan.md`

### Generating Social Content with `/generate-social-content`

1. Execute `/generate-social-content <topic>` (or without args to be prompted)
2. Select your timezone for best-time-to-post recommendations
3. Multi-select target platforms (LinkedIn, Twitter/X, Instagram, Facebook, TikTok, Reddit, YouTube)
4. Select content goal (Awareness, Engagement, Leads, Launch, Education, Community)
5. AI assistant launches parallel subagents — one per platform
6. Each subagent generates platform-specific content in its own `.md` file
7. A `summary.md` with posting calendar is generated

**Output:** `social-content/<topic-slug>/` containing per-platform content files and a posting calendar.

[See workflow diagram](docs/generate-social-content-diagram.md) for the full flow and subagent architecture.

### Generating Onboarding Tour with `/generate-onboarding`

1. Execute `/generate-onboarding` (or with a focus area: `/generate-onboarding authentication flow`)
2. AI assistant scans project structure and identifies languages, frameworks, entry points
3. Launches 5 parallel research subagents (execution flow, data flow, config, patterns, dependencies)
4. Each subagent traces its area and returns findings with file:line references
5. Tour builder generates a self-contained HTML file with Mermaid diagrams

**Output:** `docs/onboarding.html` (or `docs/onboarding-<focus>.html` if a focus area is provided, e.g., `docs/onboarding-authentication-flow.html`) — open in any browser for a guided code tour with syntax-highlighted code and diagrams.

[See workflow diagram](docs/generate-onboarding-workflow.md) for the full pipeline.

## Best Practices

### Writing New Commands

1. **Always include pre-flight checks**: Verify git config, branch status, and remote availability
2. **Use user approval workflows**: Never perform destructive operations without confirmation
3. **Follow conventional commits**: Use standardized commit message format
4. **Handle errors gracefully**: Provide clear error messages and suggestions
5. **Use parallel execution**: Run independent commands simultaneously
6. **Maintain all three formats**: Every command must exist in OpenCode, Claude Code, and Kilo Code directories with identical workflow logic

### Branch Naming

- Feature branches: `feat/<short-description>`
- Use lowercase, hyphens only
- Keep descriptions to 3-5 words

### Protected Branches

The following branches are protected and trigger warnings:
- `main`
- `master`
- `develop`
- `release/*`

## Common Pitfalls to Avoid

### Git Configuration

**Don't**: Skip git config verification
**Do**: Always verify `user.name` and `user.email` before operations

### Commit Message Format

**Don't**: Use vague messages like "fixed stuff" or "update"
**Do**: Follow conventional commit format with clear subject lines

### Branch Protection

**Don't**: Commit directly to protected branches
**Do**: Warn users and require explicit confirmation

### User Interaction

**Don't**: Skip user approval for destructive operations
**Do**: Always present changes for review before executing

### Error Handling

**Don't**: Ignore errors or provide unhelpful messages
**Do**: Provide clear error messages with suggestions for resolution

## Validation

### Markdown Validation

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

### Git Validation

```bash
# Verify git configuration
git config user.name && git config user.email

# Check current branch
git branch --show-current

# Verify remote exists
git remote get-url origin
```

## Contributing

To add a new command:

1. Create the OpenCode format in `.opencode/commands/<action>-<target>.md` (kebab-case)
2. Include YAML frontmatter with `description` and `agent`
3. Follow the established workflow format with Pre-flight Checks, Workflow, Error Handling
4. Add user approval steps with the `question` tool
5. Create the Claude Code format in `.claude/commands/<action>-<target>.md`:
   - Replace `agent` with `allowed-tools` in frontmatter
   - Replace `question` tool with inline chat prompts
   - Use `Bash(cmd)` syntax for commands
6. Create the Kilo Code format in `.kilocode/workflows/<action>-<target>.md`:
   - No frontmatter — start with a title heading
   - Replace `question` tool with `ask_user`
   - Use `execute_command` for bash commands
7. Test the workflow manually across all three tools
8. Verify consistency with existing command files

## License

This repository is used for AI-assisted software engineering workflows.
