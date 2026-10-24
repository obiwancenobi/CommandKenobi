# Generate Social Content — Workflow Diagram

## Command Flow

```mermaid
flowchart TD
    A["/generate-social-content"] --> B["Step 1: Gather Context"]
    B --> B1{"$ARGUMENTS\nprovided?"}
    B1 -->|Yes| B2["Use as topic context"]
    B1 -->|No| B3["Ask user via question tool"]
    B3 --> B4{"Scan README?"}
    B4 -->|Yes| B5["Read README.md"]
    B4 -->|No| B6["User types manually"]
    B5 --> B7["Save {TOPIC}"]
    B2 --> B7
    B6 --> B7

    B7 --> C["Step 2: Ask Timezone"]
    C --> C1["Present timezone options"]
    C1 --> C2["Save {TIMEZONE}"]

    C2 --> D["Step 3: Platform Selection"]
    D --> D1["Multi-select platforms"]
    D1 --> D2["Save {PLATFORMS}"]

    D2 --> E["Step 4: Goal Selection"]
    E --> E1["Present goal options"]
    E1 --> E2["Save {GOAL}"]

    E2 --> F["Step 5: Create Output Directory"]
    F --> F1["mkdir social-content/{slug}/"]

    F1 --> G["Step 6: Launch Parallel Subagents"]
    G --> G1["Task: LinkedIn Subagent"]
    G --> G2["Task: Twitter/X Subagent"]
    G --> G3["Task: Instagram Subagent"]
    G --> G4["Task: Facebook Subagent"]
    G --> G5["Task: TikTok Subagent"]
    G --> G6["Task: Reddit Subagent"]
    G --> G7["Task: YouTube Subagent"]

    G1 --> H1["linkedin.md"]
    G2 --> H2["twitter-x.md"]
    G3 --> H3["instagram.md"]
    G4 --> H4["facebook.md"]
    G5 --> H5["tiktok.md"]
    G6 --> H6["reddit.md"]
    G7 --> H7["youtube.md"]

    H1 --> HZ["Step 6.5: Humanizer Subagent\n(rewrites every platform file)"]
    H2 --> HZ
    H3 --> HZ
    H4 --> HZ
    H5 --> HZ
    H6 --> HZ
    H7 --> HZ

    HZ --> I["Step 7: Generate Summary"]

    I --> I1["summary.md\n(Posting Calendar)"]

    I1 --> J["Step 8: Report to User"]
```

## Subagent Architecture

```mermaid
flowchart LR
    subgraph Main["Main Agent (Orchestrator)"]
        direction TB
        M1["Gather Context"]
        M2["Collect Results"]
        M3["Generate Summary"]
    end

    subgraph S1["Subagent 1"]
        S1a["Receive: topic, goal, timezone"]
        S1b["Generate platform content"]
        S1c["Write .md file"]
    end

    subgraph S2["Subagent 2"]
        S2a["Receive: topic, goal, timezone"]
        S2b["Generate platform content"]
        S2c["Write .md file"]
    end

    subgraph S3["Subagent N"]
        S3a["Receive: topic, goal, timezone"]
        S3b["Generate platform content"]
        S3c["Write .md file"]
    end

    M1 -->|"subagent tool\n(parallel)"| S1
    M1 -->|"subagent tool\n(parallel)"| S2
    M1 -->|"subagent tool\n(parallel)"| S3

    S1 --> S1a --> S1b --> S1c
    S2 --> S2a --> S2b --> S2c
    S3 --> S3a --> S3b --> S3c

    S1c -->|"Done"| M2
    S2c -->|"Done"| M2
    S3c -->|"Done"| M2

    M2 --> M3
```

## Output Structure

```mermaid
graph TD
    ROOT["social-content/"]
    DIR["<topic-slug>/"]
    S["summary.md"]
    LI["linkedin.md"]
    TW["twitter-x.md"]
    IG["instagram.md"]
    FB["facebook.md"]
    TT["tiktok.md"]
    RD["reddit.md"]
    YT["youtube.md"]

    ROOT --> DIR
    DIR --> S
    DIR --> LI
    DIR --> TW
    DIR --> IG
    DIR --> FB
    DIR --> TT
    DIR --> RD
    DIR --> YT
```

## Per-Platform Content Sections

```mermaid
graph LR
    subgraph Template["Each .md File Contains"]
        T1["Hook / Opening"]
        T2["Full Content"]
        T3["Call to Action"]
        T4["Hashtags / Tags"]
        T5["Visual Suggestions"]
        T6["Best Time to Post"]
        T6a["- Days (TZ-aware)"]
        T6b["- Times (TZ-aware)"]
        T6c["- Platform tips"]
    end

    T6 --> T6a
    T6 --> T6b
    T6 --> T6c
```

## Cross-Tool Compatibility

All 11 commands are available across OpenCode, Claude Code, and Kilo Code. Only interaction patterns differ — core workflow logic is shared.

```mermaid
graph TD
    subgraph OpenCode["OpenCode (.opencode/commands/)"]
        OC1["commit-all.md"]
        OC2["commit-staged.md"]
        OC3["push-all.md"]
        OC4["push-staged.md"]
        OC5["create-pr.md"]
        OC6["add-documentation.md"]
        OC7["plan-interview.md"]
        OC8["generate-social-content.md"]
        OC9["generate-onboarding.md"]
        OC10["harness-map.md"]
        OC11["ship.md"]
        OC_Uses["question tool, $ARGUMENTS,\nTask tool"]
    end

    subgraph ClaudeCode["Claude Code (.claude/commands/)"]
        CC1["commit-all.md"]
        CC2["commit-staged.md"]
        CC3["push-all.md"]
        CC4["push-staged.md"]
        CC5["create-pr.md"]
        CC6["add-documentation.md"]
        CC7["plan-interview.md"]
        CC8["generate-social-content.md"]
        CC9["generate-onboarding.md"]
        CC10["harness-map.md"]
        CC11["ship.md"]
        CC_Uses["allowed-tools frontmatter,\ninline prompts, Agent tool"]
    end

    subgraph KiloCode["Kilo Code (.kilocode/workflows/)"]
        KC1["commit-all.md"]
        KC2["commit-staged.md"]
        KC3["push-all.md"]
        KC4["push-staged.md"]
        KC5["create-pr.md"]
        KC6["add-documentation.md"]
        KC7["plan-interview.md"]
        KC8["generate-social-content.md"]
        KC9["generate-onboarding.md"]
        KC10["harness-map.md"]
        KC11["ship.md"]
        KC_Uses["ask_user, execute_command,\nnew_task(), write_to_file"]
    end

    subgraph Core["Shared Core Logic"]
        CL1["Pre-flight checks"]
        CL2["Branch protection"]
        CL3["Change analysis"]
        CL4["Commit message generation"]
        CL5["User approval workflow"]
        CL6["Git execution"]
        CL7["PR creation"]
        CL8["Parallel subagents"]
    end

    OC1 & OC2 & OC3 & OC4 & OC5 & OC6 & OC7 & OC8 & OC9 & OC10 & OC11 --> Core
    CC1 & CC2 & CC3 & CC4 & CC5 & CC6 & CC7 & CC8 & CC9 & CC10 & CC11 --> Core
    KC1 & KC2 & KC3 & KC4 & KC5 & KC6 & KC7 & KC8 & KC9 & KC10 & KC11 --> Core
```
