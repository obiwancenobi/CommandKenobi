# Generate Onboarding Workflow

Architecture and flow for the `/generate-onboarding` command.

## Pipeline Overview

```mermaid
flowchart TD
    Start["User runs /generate-onboarding"] --> Focus{"Focus area provided?"}
    Focus -->|"Yes"| SaveFocus["Save FOCUS variable"]
    Focus -->|"No"| FullWalk["Save FOCUS = full"]
    SaveFocus --> Discovery
    FullWalk --> Discovery

    Discovery["Phase 1: Discovery Agent"] -->|"Scan tree, configs, entry points"| Profile["Project Profile"]

    Profile --> Flow["Subagent 1: Execution Flow"]
    Profile --> Data["Subagent 2: Data Flow"]
    Profile --> Config["Subagent 3: Configuration"]
    Profile --> Patterns["Subagent 4: Patterns"]
    Profile --> Deps["Subagent 5: Dependencies"]

    Flow -->|"sequence diagram"| Builder
    Data -->|"flowchart"| Builder
    Config -->|"flowchart"| Builder
    Patterns -->|"class diagram"| Builder
    Deps -->|"flowchart"| Builder

    Builder["Phase 3: Tour Builder"] --> HTML["Generate {OUTPUT_FILE}"]
    HTML --> Report["Report + ask to open in browser"]
    Report --> Done["Tour ready"]

    style Discovery fill:#1e1e2e,color:#cdd6f4
    style Builder fill:#1e1e2e,color:#cdd6f4
    style HTML fill:#1e1e2e,color:#cdd6f4
```

## Phase 1: Discovery

Single agent performs a quick scan:

| Action | Command |
|--------|---------|
| File tree | `find . -maxdepth 3 ... \| head -200` |
| Root listing | `ls -la` |
| Config files | `ls package.json go.mod Cargo.toml ...` |
| Entry points | `find . -name "main.*" -o -name "index.*" ...` |

Output: `{DISCOVERY}` — project profile passed to Phase 2.

## Output Filename

The output filename `{OUTPUT_FILE}` is derived from `{FOCUS}`:

| Focus | Output File |
|-------|-------------|
| `full` (no focus) | `docs/onboarding.html` |
| "authentication flow" | `docs/onboarding-authentication-flow.html` |
| "database layer" | `docs/onboarding-database-layer.html` |

Slugify rules: lowercase, replace spaces/underscores with hyphens, strip non-alphanumeric.

## Phase 2: Parallel Research Agents

Five subagents launched simultaneously via `Task` tool:

| Subagent | Focus | Diagram |
|----------|-------|---------|
| Execution Flow | Trace entry point through codebase | Sequence diagram |
| Data Flow | Inputs → transformations → outputs | Flowchart |
| Configuration | Build, run, env vars, testing, deploy | Flowchart (CI/CD) |
| Patterns | Architecture, conventions, design patterns | Class diagram |
| Dependencies | External services, APIs, databases | Flowchart |

Each returns structured findings with `file:line` references and a Mermaid diagram.

## Phase 3: Tour Builder

Takes all research outputs and generates `{OUTPUT_FILE}`:

- If no focus area: `docs/onboarding.html`
- If focus area provided (e.g., "authentication flow"): `docs/onboarding-authentication-flow.html`

```mermaid
flowchart LR
    A[Step 1: Project Overview] --> B[Step 2: Entry Point]
    B --> C[Step 3: Core Flow]
    C --> D[Step 4: Data Layer]
    D --> E[Step 5: Config]
    E --> F[Step 6: Patterns]
    F --> G[Step 7: Dependencies]
```

Each step includes:
- File path badge
- 2-4 paragraph narrative
- Syntax-highlighted code snippet with highlighted lines
- Mermaid diagram (where applicable)
- Key points summary

## HTML Output

Self-contained single-page with:
- Two-panel layout (sidebar + code viewer)
- Dark theme with light mode toggle
- Mermaid.js via CDN for diagram rendering
- Step navigation (prev/next, keyboard, clickable list)
- Copy buttons on code blocks
- Print-friendly styles
