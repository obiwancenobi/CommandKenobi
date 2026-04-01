---
description: Generate a guided code tour as a standalone HTML file for project onboarding
allowed-tools: Bash(find:*), Bash(ls:*), Bash(mkdir:*), Bash(head:*), Bash(grep:*), Bash(cat:*), Read, Glob, Grep, Task, Write
---

You are executing the `/generate-onboarding` command. Analyze the current project and generate a self-contained HTML code tour for developer onboarding. Follow this workflow:

## Step 1: Determine Focus Area

Check if `$ARGUMENTS` is provided and non-empty:

- If provided: Use `$ARGUMENTS` as the focus topic (e.g., "authentication flow", "API routing", "database layer")
- If empty: Perform a full project walkthrough

Save the focus area as `{FOCUS}`. If empty, save as "full".

Derive the output filename `{OUTPUT_FILE}`:
- If `{FOCUS}` is "full": set `{OUTPUT_FILE}` to `docs/onboarding.html`
- Otherwise: slugify the focus area (lowercase, replace spaces/underscores with hyphens, strip non-alphanumeric) and set `{OUTPUT_FILE}` to `docs/onboarding-<slug>.html`
  - Example: "authentication flow" → `docs/onboarding-authentication-flow.html`

## Step 2: Discovery — Scan Project Structure

Run the following commands to understand the project:

1. Scan the file tree:
```
Bash(find . -maxdepth 3 -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/vendor/*' -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/.next/*' -not -path '*/__pycache__/*' | head -200)
```

2. List root directory:
```
Bash(ls -la)
```

3. Check for config files to identify languages, frameworks, and dependencies:
```
Bash(ls package.json go.mod Cargo.toml pyproject.toml pom.xml build.gradle Gemfile composer.json Makefile Dockerfile docker-compose.yml .env.example 2>/dev/null)
```

4. Read any found config files to identify:
   - Primary language and framework
   - Key dependencies
   - Build tools and run commands
   - Testing framework

5. Identify entry points by searching for common patterns:
```
Bash(find . -maxdepth 3 \( -name "main.*" -o -name "index.*" -o -name "app.*" -o -name "server.*" \) -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/vendor/*' -not -path '*/dist/*' 2>/dev/null)
```

Also check for `cmd/`, `src/main.*` directories.

Save all discovery results as `{DISCOVERY}` for use by subagents.

## Step 3: Launch Parallel Research Agents

Launch 5 subagents using the Task tool. All subagent Task calls MUST be in a single message to run in parallel.

### Subagent 1: Execution Flow

Call the Task tool with:
- subagent_type: general
- description: "Trace execution flow"
- prompt:

```
You are analyzing a codebase to trace its execution flow.

Focus area: {FOCUS}
Discovery results:
{DISCOVERY}

Your task:
1. Start from the main entry point(s) identified in the discovery
2. Trace the execution path through the codebase
3. Read key files along the path to understand the flow
4. Record file:line references for each significant step
5. Return 5-8 flow steps, each with:
   - Step title (e.g., "Request received by Express router")
   - File path with line range (e.g., "src/index.js:1-30")
   - Brief explanation of what happens at this step

6. Create a Mermaid sequence diagram showing the execution flow:
```mermaid
sequenceDiagram
    participant Entry
    participant Module1
    participant Module2
    Entry->>Module1: call
    Module1->>Module2: invoke
    Module2-->>Module1: result
    Module1-->>Entry: response
```

Mermaid syntax rules — follow these strictly:
- Wrap ALL node labels in double quotes: A["My Label"] not A[My Label]
- No special characters outside quoted labels (no parentheses, colons, ampersands in bare text)
- Use only these diagram types: sequenceDiagram, flowchart, classDiagram
- No subgraphs with special characters in titles
- Keep diagrams under 20 nodes — simplify if needed
- Test mentally: does every arrow have a valid source and target?
- If unsure about syntax, use a simpler diagram rather than a complex broken one

If focus is not "full", prioritize the focus area in your trace.

Output your findings as a structured list that can be used to build an HTML tour. Include the Mermaid diagram.
```

### Subagent 2: Data Flow

Call the Task tool with:
- subagent_type: general
- description: "Map data flow"
- prompt:

```
You are analyzing a codebase to map its data flow.

Focus area: {FOCUS}
Discovery results:
{DISCOVERY}

Your task:
1. Identify data inputs (API endpoints, CLI args, file reads, env vars, database queries)
2. Find key data structures, types, and interfaces
3. Trace data transformations through the code
4. Identify data outputs (responses, file writes, side effects)
5. Record file:line references for each finding

6. Create a Mermaid flowchart showing how data moves through the system:
```mermaid
flowchart LR
    Input[Input] --> Transform[Transform]
    Transform --> Store[Store]
    Store --> Output[Output]
```

Mermaid syntax rules — follow these strictly:
- Wrap ALL node labels in double quotes: A["My Label"] not A[My Label]
- No special characters outside quoted labels (no parentheses, colons, ampersands in bare text)
- Use only these diagram types: sequenceDiagram, flowchart, classDiagram
- No subgraphs with special characters in titles
- Keep diagrams under 20 nodes — simplify if needed
- Test mentally: does every arrow have a valid source and target?
- If unsure about syntax, use a simpler diagram rather than a complex broken one

Return a structured summary with:
- Data inputs (with file:line)
- Key structures/types (with file:line)
- Transformation points (with file:line)
- Data outputs (with file:line)
- The Mermaid data flow diagram

If focus is not "full", prioritize the focus area.
```

### Subagent 3: Configuration & Setup

Call the Task tool with:
- subagent_type: general
- description: "Analyze configuration and setup"
- prompt:

```
You are analyzing a codebase to document its configuration and setup.

Discovery results:
{DISCOVERY}

Your task:
1. Document build tools and how to build the project
2. Document run commands (dev, start, test)
3. List environment variables (check .env.example, config files, process.env references)
4. Identify testing framework and how to run tests
5. Document deployment setup if visible (Dockerfile, CI config, deploy scripts)

6. If there is a deployment or CI/CD pipeline, create a Mermaid flowchart showing the build/deploy flow:
```mermaid
flowchart TD
    Code[Code Push] --> Build[Build]
    Build --> Test[Test]
    Test --> Deploy[Deploy]
```

Mermaid syntax rules — follow these strictly:
- Wrap ALL node labels in double quotes: A["My Label"] not A[My Label]
- No special characters outside quoted labels (no parentheses, colons, ampersands in bare text)
- Use only these diagram types: sequenceDiagram, flowchart, classDiagram
- No subgraphs with special characters in titles
- Keep diagrams under 20 nodes — simplify if needed
- Test mentally: does every arrow have a valid source and target?
- If unsure about syntax, use a simpler diagram rather than a complex broken one

Return a structured summary covering:
- Build & Run commands
- Environment variables
- Testing setup
- Deployment (if applicable)
- Mermaid deployment diagram (if applicable)

Include file:line references where relevant.
```

### Subagent 4: Patterns & Conventions

Call the Task tool with:
- subagent_type: general
- description: "Identify patterns and conventions"
- prompt:

```
You are analyzing a codebase to identify its architecture patterns and coding conventions.

Discovery results:
{DISCOVERY}

Your task:
1. Identify the architecture pattern (MVC, layered, microservices, hexagonal, etc.)
2. Note coding conventions: naming, file organization, import style
3. Find error handling patterns
4. Identify design patterns in use (factory, singleton, middleware, observer, etc.)
5. Note any notable testing patterns

6. Create a Mermaid class diagram or component diagram showing the architecture:
```mermaid
classDiagram
    Controller --> Service : uses
    Service --> Repository : uses
    Repository --> Database : connects
```

Mermaid syntax rules — follow these strictly:
- Wrap ALL node labels in double quotes: A["My Label"] not A[My Label]
- No special characters outside quoted labels (no parentheses, colons, ampersands in bare text)
- Use only these diagram types: sequenceDiagram, flowchart, classDiagram
- No subgraphs with special characters in titles
- Keep diagrams under 20 nodes — simplify if needed
- Test mentally: does every arrow have a valid source and target?
- If unsure about syntax, use a simpler diagram rather than a complex broken one

Return a structured summary with:
- Architecture pattern
- File/directory organization
- Coding conventions
- Error handling approach
- Design patterns observed
- Mermaid architecture diagram

Include file:line references for key examples of each pattern.
```

### Subagent 5: External Dependencies

Call the Task tool with:
- subagent_type: general
- description: "Map external dependencies"
- prompt:

```
You are analyzing a codebase to map its external dependencies and integrations.

Discovery results:
{DISCOVERY}

Your task:
1. Identify external services (APIs, cloud services, payment processors, etc.)
2. Find database connections and ORM usage
3. Map third-party SDKs and their purpose
4. Identify authentication/authorization integrations
5. Note any message queues, caches, or other infrastructure

6. Create a Mermaid flowchart showing external integrations:
```mermaid
flowchart LR
    App[Your App] --> DB[(Database)]
    App --> API[External API]
    App --> Cache[(Cache)]
```

Mermaid syntax rules — follow these strictly:
- Wrap ALL node labels in double quotes: A["My Label"] not A[My Label]
- No special characters outside quoted labels (no parentheses, colons, ampersands in bare text)
- Use only these diagram types: sequenceDiagram, flowchart, classDiagram
- No subgraphs with special characters in titles
- Keep diagrams under 20 nodes — simplify if needed
- Test mentally: does every arrow have a valid source and target?
- If unsure about syntax, use a simpler diagram rather than a complex broken one

Return a structured summary with:
- External services (with file:line references showing integration points)
- Database setup
- Third-party libraries and their roles
- Auth/Authz setup
- Infrastructure components
- Mermaid integration diagram
```

## Step 4: Generate HTML Tour

After ALL subagents complete, generate the onboarding HTML file in two stages.

### Stage A: Assemble Tour Data

1. Create the docs directory:
```
Bash(mkdir -p docs)
```

2. Combine all subagent outputs into a structured JSON file at `docs/_onboarding-data.json`. The JSON must follow this schema:

```json
{
  "projectName": "string — from directory name or package config",
  "language": "string — primary language",
  "framework": "string — primary framework or 'None'",
  "description": "string — brief project description from README or config",
  "dependencies": ["string — top 5-10 key dependencies"],
  "commands": {
    "build": "string or null",
    "dev": "string or null",
    "test": "string or null"
  },
  "steps": [
    {
      "title": "string — step title from execution flow",
      "filePath": "string — e.g. src/index.ts:1-30",
      "narrative": "string — 2-4 paragraphs explaining the step",
      "code": "string — 10-50 lines of source code",
      "highlightLines": [1, 5, 8],
      "keyPoints": ["string — 2-3 bullet points"],
      "diagram": "string — raw Mermaid source, or null"
    }
  ],
  "architectureDiagram": "string — raw Mermaid source from Subagent 4, or null",
  "dataFlowDiagram": "string — raw Mermaid source from Subagent 2, or null",
  "integrationDiagram": "string — raw Mermaid source from Subagent 5, or null"
}
```

Use data from all 5 subagents:
- Steps array: from Subagent 1 (Execution Flow) — each flow step becomes one entry
- Narrative for each step: weave in findings from Subagent 2 (data flow), Subagent 4 (patterns), and Subagent 5 (dependencies)
- Commands: from Subagent 3 (Configuration)
- Diagrams: from each respective subagent

If a subagent failed, set its fields to `null` and note the gap in the relevant step's narrative.

### Stage B: Generate HTML from Data

Read `docs/_onboarding-data.json` and generate `{OUTPUT_FILE}` as a self-contained single-page HTML file.

The HTML generation is template-filling from the JSON data. For each field in the JSON:
- `projectName`, `language`, `framework`, `description` → Step 1: Project Overview content
- `dependencies` → Project Overview dependency list
- `commands` → Project Overview "How to Run" section
- `steps[]` → Steps 2-N, one tour step per entry
- `steps[].code` → Syntax-highlighted code block with `highlightLines` applied
- `steps[].diagram` → `<pre class="mermaid">` block (skip if null)
- `architectureDiagram`, `dataFlowDiagram`, `integrationDiagram` → Mermaid blocks in Project Overview

### Stage C: Cleanup

Delete the temporary data file:
```
Bash(rm -f docs/_onboarding-data.json)
```

### HTML Requirements

The HTML file MUST be completely self-contained with ALL CSS and JavaScript inlined. The ONE exception is Mermaid.js — include it via CDN and initialize properly:

```html
<script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"></script>
<script>
  mermaid.initialize({
    startOnLoad: true,
    theme: 'dark',
    securityLevel: 'loose'
  });
  mermaid.parseError = function(err, hash) {
    console.warn('Mermaid parse error:', err);
  };
  window.addEventListener('load', function() {
    document.querySelectorAll('.mermaid[data-processed="true"]').forEach(function(el) {
      if (!el.querySelector('svg')) {
        el.classList.add('mermaid-error');
        el.setAttribute('title', 'Diagram could not render — showing source');
      }
    });
  });
</script>
```

Each Mermaid diagram in the HTML must be in a `<pre class="mermaid">` block with the raw Mermaid source as text content.

**Layout:**
- Two-panel layout: fixed sidebar (320px) on the left for navigation, main content area on the right
- Sidebar shows step list with clickable items and current step indicator
- Main area shows the current step content

**Theme:**
- Dark theme by default: background `#1e1e2e`, text `#cdd6f4`, accent `#89b4fa`, secondary `#585b70`
- Light mode toggle button in the sidebar header
- Light theme: background `#eff1f5`, text `#4c4f69`, accent `#1e66f5`, secondary `#9ca0b0`

**Diagram Error Fallback:**
- `.mermaid-error` class: dashed border using `var(--secondary)`, monospace font, `white-space: pre-wrap`, `opacity: 0.7`
- `.mermaid-error::before` pseudo-element displays: "Diagram could not render — raw source shown below" in `var(--accent)` color
- `<noscript>` block: sets `.mermaid` to `pre-wrap` monospace and shows "JavaScript is required for interactive navigation and diagram rendering."

**Code Blocks:**
- Syntax highlighting implemented via CSS class-based tokenizer (support JS/TS, Python, Go, Rust, Java, Ruby, Shell, HTML, CSS at minimum)
- Monospace font, line numbers
- File path badge above each code block (e.g., `src/index.js:1-30`)
- Copy button on each code block that copies the code to clipboard

**Navigation:**
- Prev/Next buttons at the bottom of each step
- Keyboard support: left/right arrow keys to navigate steps
- Clickable step list in sidebar
- Step progress indicator

**Print:**
- Print-friendly styles: white background, black text, no sidebar
- Code blocks with borders instead of backgrounds

**Responsive:**
- On screens under 768px, sidebar collapses to a top navigation bar
- Code blocks scroll horizontally instead of overflowing

### Tour Structure

**Step 1: Project Overview**
- Title: "Project Overview"
- Content includes:
  - Project name (from directory name or package config)
  - Primary language and framework
  - Brief description (derived from README or config)
  - Key dependencies (top 5-10)
  - How to run: build, dev, test commands
  - Architecture overview with a Mermaid flowchart or C4 container diagram showing the high-level system structure

**Steps 2-N: Execution Flow Walkthrough**

Each step from Subagent 1's output becomes a tour step. For each step:

- **Title:** The step title from the execution flow
- **File Path:** Displayed as a badge (e.g., `src/router/index.js:15-42`)
- **Narrative:** 2-4 paragraphs explaining:
  1. What this step does in the overall flow
  2. Why it's structured this way (reference patterns from Subagent 4)
  3. How data enters/transforms/exits (reference Subagent 2)
  4. Any external service interactions (reference Subagent 5)
- **Code Snippet:** 10-50 lines from the referenced file, with the most relevant sections visually highlighted (use a CSS class like `.highlight-line` with a left border accent)
- **Key Points:** 2-3 bullet points summarizing takeaways

If a subagent failed or returned incomplete data, note it in the relevant step but continue building the tour.

### Generating the HTML

Write the complete HTML to `{OUTPUT_FILE}`. The file should be ready to open in any browser without any server or build step.

## Step 5: Report Completion & Open in Browser

After generating the HTML file:

1. Report to the user:
   - Confirm file created at `{OUTPUT_FILE}`
   - State the total number of steps in the tour
   - List any subagents that failed or returned incomplete data

2. Ask the user:
   "Onboarding tour generated at {OUTPUT_FILE}. Open it in your browser now? Reply 'yes' to open, or 'no' to skip."

3. If the user replies yes, run:
   Bash(open {OUTPUT_FILE})

4. Remind the user they can re-run with a focus argument for a targeted tour (e.g., `/generate-onboarding authentication flow`)

## Error Handling

- **No entry point found:** Focus the tour on the largest/most files-containing directory. Note in the overview that no clear entry point was found.
- **Subagent failed:** Continue with available data. Note the missing analysis in the tour introduction or relevant step. Do not abort the entire command.
- **Existing {OUTPUT_FILE}:** Overwrite silently.
- **Very large repo:** The discovery step caps at 200 files. Note in the overview if the project appears larger than what was scanned.
- **Empty or minimal project:** Generate a tour with available info and note that the project appears to be in early stages.
