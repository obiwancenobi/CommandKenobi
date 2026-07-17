---
description: Generate an interactive force-graph map of the current agent harness (core tools, deferred tools, MCP servers, agents, all skills)
allowed-tools: Read, Write, Edit, Bash, Artifact
---

Generate an interactive, browsable map of everything available in the current session's harness.

## Steps

1. **Read the template** at `templates/harness-map.html` (repo root; fall back to `~/.claude/templates/harness-map.html` if missing). It contains all rendering code (canvas force-directed graph, search, pinch zoom, collapse/expand, dark+light themes). Do NOT rewrite the rendering code.

2. **Enumerate the live harness from your own system prompt and context** (do not reuse the template's stale example data):
   - Core tools (loaded, callable now)
   - Deferred tools (listed in system reminders, loadable via ToolSearch) — group MCP server tools by server with rough counts
   - Agent types available to the Agent tool
   - ALL skills, grouped by plugin/source prefix (e.g. `posthog:*`, `superpowers:*`, standalone, slash commands, built-in harness skills)

3. **Replace only the section between `// DATA:BEGIN` and `// DATA:END`** in a copy of the template with the fresh data, keeping the same `TREE` structure: `{ label, sub?, count?, collapsed?, scope?, kids? }`. Tag every branch/cluster (and leaf overrides) with `scope`: `built-in` (harness itself), `global` (user-level config: `~/.claude`, `~/.claude.json`), `project` (repo `.claude/`), or `plugin` — check actual file locations on disk, don't guess. Big skill clusters should have `collapsed: true` so the initial view stays readable. Update the hub `label`/`sub` with the current agent and model/session name. Also update the `<title>` and the `.eyebrow` header line — they are hardcoded as "claude code · global scope" in the template; replace with the actual harness name and scope (e.g. "opencode · project scope").

4. **Save & publish:**
   - Save the generated file to `docs/harness-map.html` in the current working directory (create `docs/` if missing; if the project uses a different docs dir name, use that). Do not commit it unless asked.
   - Claude Code: additionally publish it with the Artifact tool (favicon 🗺️) and report the artifact URL.
   - Other harnesses (no Artifact tool): open it in the browser (`open docs/harness-map.html` on macOS). Report the file path.

5. Report a one-line summary: node counts per branch (core / deferred / MCP / agents / skills).
