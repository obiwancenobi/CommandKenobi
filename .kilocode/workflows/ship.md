# Ship

Create a PR for the current work, babysit its checks, fix review comments, and merge it when green. Run autonomously. Only stop for a genuine blocker: a merge conflict you cannot resolve, a failing test whose fix is ambiguous, or review feedback that needs a human decision.

## Pre-flight Checks

1. **Assess State**
   - Use `execute_command` to run:
     - `git status`
     - `git branch --show-current`
     - `gh auth status 2>&1`
   - If `gh` is not installed or not authenticated: "GitHub CLI required. Install with 'brew install gh' and run 'gh auth login'." Stop.

2. **Determine Base Branch**
   - Use `execute_command` to run `git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}'`
   - Use the repo default (usually main), UNLESS the repo uses an integration branch — if develop exists or the project's CLAUDE.md/AGENTS.md says PRs target develop, use that
   - Respect any base the user named when invoking the workflow

## Workflow

### 1. Branch + Commit
- If currently on a protected branch (main, master, develop): create a new branch with `execute_command` running `git switch -c TYPE/SHORT-SLUG` — type = feat/fix/chore/etc. inferred from the change. Never commit directly to a protected branch.
- If there are uncommitted changes: stage the real source changes (exclude build artifacts, binaries, and junk) and commit with a Conventional Commits message — concise subject, body only if the "why" isn't obvious
- Use `execute_command` to run `git push -u origin BRANCH`

### 2. Open the PR
- Use `execute_command` to run `gh pr view 2>/dev/null` — if a PR already exists for this branch, reuse it
- Otherwise use `execute_command` to run `gh pr create --base BASE_BRANCH --title "TITLE" --body "BODY"` with a clear title and a body describing the change, rationale, and verification done
- Immediately report the PR URL to the user (it's clickable) so they can open it while babysitting continues

### 3. Babysit Until Resolved
- Poll status every ~20–30s with `execute_command`:
  - `gh pr view PR_NUMBER --json mergeStateStatus,reviewDecision,statusCheckRollup`
  - `gh pr checks PR_NUMBER`
- Fetch review feedback with `execute_command`:
  - `gh pr view PR_NUMBER --comments`
  - `gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments` for inline threads

### 4. Fix Feedback
- For each failing check or actionable review comment: investigate, fix in code, commit, and push to the same branch
- Resolve/reply to threads where appropriate, then re-poll
- Loop until checks pass AND there are no unresolved blocking review comments

### 5. Merge When Green
- When mergeStateStatus is CLEAN (required checks passed, no blocking reviews): merge automatically with `execute_command` running `gh pr merge PR_NUMBER --squash --delete-branch` — do NOT ask the user to confirm the merge; a green PR is the go-ahead
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
