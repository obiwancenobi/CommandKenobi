---
description: Create a PR for the current work, babysit its checks, fix review comments, and merge it when green
argument-hint: [optional notes, e.g. base branch or PR title]
allowed-tools: Bash(git:*), Bash(gh:*), Read, Edit, Write, Grep, Glob
---

You are executing the `/ship` command: ship the current work as a pull request and see it all the way through to merge. Run autonomously. Only stop for a genuine blocker: a merge conflict you cannot resolve, a failing test whose fix is ambiguous, or review feedback that needs a human decision.

Optional extra context from the user: $ARGUMENTS

## Pre-flight Checks

1. **Assess State**
   - Run in parallel:
     - Run: Bash(git status)
     - Run: Bash(git branch --show-current)
     - Run: Bash(gh auth status 2>&1)
   - If `gh` is not installed or not authenticated: "GitHub CLI required. Install with 'brew install gh' and run 'gh auth login'." Stop.

2. **Determine Base Branch**
   - Run: Bash(git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}')
   - Use the repo default (usually main), UNLESS the repo uses an integration branch — if develop exists or the project's CLAUDE.md/AGENTS.md says PRs target develop, use that
   - Respect any base the user named in $ARGUMENTS

## Workflow

### 1. Branch + Commit
- If currently on a protected branch (main, master, develop): create a new branch with Bash(git switch -c TYPE/SHORT-SLUG) — type = feat/fix/chore/etc. inferred from the change. Never commit directly to a protected branch.
- If there are uncommitted changes: stage the real source changes (exclude build artifacts, binaries, and junk) and commit with a Conventional Commits message — concise subject, body only if the "why" isn't obvious
- Run: Bash(git push -u origin BRANCH)

### 2. Open the PR
- Run: Bash(gh pr view 2>/dev/null) — if a PR already exists for this branch, reuse it
- Otherwise: Bash(gh pr create --base BASE_BRANCH --title "TITLE" --body "BODY") with a clear title and a body describing the change, rationale, and verification done
- Immediately report the PR URL to the user (it's clickable) so they can open it while babysitting continues

### 3. Babysit Until Resolved
- Poll status every ~20–30s:
  - Run: Bash(gh pr view PR_NUMBER --json mergeStateStatus,reviewDecision,statusCheckRollup)
  - Run: Bash(gh pr checks PR_NUMBER)
- Fetch review feedback:
  - Run: Bash(gh pr view PR_NUMBER --comments)
  - Run: Bash(gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments) for inline threads

### 4. Fix Feedback
- For each failing check: investigate, fix in code, commit, and push to the same branch, then re-poll
- **Triage every review comment** — crucial (bug, security, data loss, broken behavior) vs non-crucial (style nits, subjective preference, speculative refactors):
  - Crucial → fix it, commit, push, then reply to the thread with what changed
  - Non-crucial → reply briefly explaining why you're skipping it; do not blindly apply it
- AI reviewers (CodeRabbit, Copilot, Gemini, etc.) get the same triage — their comments are suggestions, not orders. If one keeps re-reviewing every push, address only what's crucial and decline the rest; do not chase an endless loop
- Reply to inline threads: Bash(gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments/COMMENT_ID/replies -f body="...")
- Resolve each handled thread via GraphQL: Bash(gh api graphql -f query='mutation { resolveReviewThread(input: {threadId: "THREAD_ID"}) { thread { isResolved } } }') — thread IDs from the PR's reviewThreads query
- If a bot review is stuck in "Changes requested" after its comments are resolved, dismiss it: Bash(gh api -X PUT repos/OWNER/REPO/pulls/PR_NUMBER/reviews/REVIEW_ID/dismissals -f message="Addressed/declined with rationale" -f event="DISMISS") — only dismiss bot reviews, never a human's
- Loop until checks pass AND every review thread is replied to and resolved

### 5. Merge When Green
- When mergeStateStatus is CLEAN (required checks passed, no blocking reviews): merge automatically with Bash(gh pr merge PR_NUMBER --squash --delete-branch) — do NOT ask the user to confirm the merge; a green PR is the go-ahead
- Confirm state is MERGED and report the PR URL and final commit on the base branch

## Error Handling

- **gh not installed/authenticated**: "GitHub CLI required. Install with 'brew install gh' and run 'gh auth login'." Stop.
- **Merge conflict you cannot resolve**: Report the conflicting files and stop for a human decision
- **Failing test with ambiguous fix**: Report the failure and the candidate fixes; stop for a human decision
- **Review feedback needing a human decision**: Summarize the feedback and stop
- **Push rejected**: Never force-push over commits you didn't make; report and stop
- **Branch protection**: Never bypass branch protection or push to a protected branch directly
- **Checks failing at merge time**: Never merge with failing required checks or unresolved blocking reviews

## Rules

- Never force-push over commits you didn't make
- Never merge with failing required checks or unresolved blocking reviews
- Never bypass branch protection or push to a protected branch directly
- Keep going without asking unless truly blocked — then report the blocker clearly and stop
