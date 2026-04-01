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

    Flow -->|"sequence diagram"| Assembler
    Data -->|"flowchart"| Assembler
    Config -->|"flowchart"| Assembler
    Patterns -->|"class diagram"| Assembler
    Deps -->|"flowchart"| Assembler

    Assembler["Phase 3a: Data Assembler"] --> JSON["Write _onboarding-data.json"]
    JSON --> Builder["Phase 3b: HTML Generator"]
    Builder --> HTML["Generate {OUTPUT_FILE}"]
    HTML --> Cleanup["Delete _onboarding-data.json"]
    Cleanup --> Report["Report + ask to open in browser"]
    Report --> Done["Tour ready"]

    style Discovery fill:#1e1e2e,color:#cdd6f4
    style Assembler fill:#1e1e2e,color:#cdd6f4
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

## Phase 3: Two-Stage Tour Generation

### Phase 3a: Data Assembler

Combines all subagent outputs into `docs/_onboarding-data.json`:

| Field | Source |
|-------|--------|
| `projectName`, `language`, `framework` | Discovery |
| `steps[]` | Subagent 1 (Execution Flow) |
| `steps[].narrative` | Subagents 1, 2, 4, 5 combined |
| `commands` | Subagent 3 (Configuration) |
| `architectureDiagram` | Subagent 4 (Patterns) |
| `dataFlowDiagram` | Subagent 2 (Data Flow) |
| `integrationDiagram` | Subagent 5 (Dependencies) |

### Phase 3b: HTML Generator

Reads `docs/_onboarding-data.json` and generates `{OUTPUT_FILE}` by template-filling the HTML structure from the JSON data. After HTML is written, deletes `_onboarding-data.json`.

## HTML Output

Self-contained single-page with:
- Two-panel layout (sidebar + code viewer)
- Dark theme with light mode toggle
- Mermaid.js via CDN for diagram rendering
- Step navigation (prev/next, keyboard, clickable list)
- Copy buttons on code blocks
- Print-friendly styles
- Mermaid.js pinned to v11 (stable) with `startOnLoad: true`
- `parseError` handler isolates broken diagrams — one failure doesn't break others
- `.mermaid-error` CSS class provides graceful fallback for broken diagrams
- `<noscript>` fallback for non-JS environments
