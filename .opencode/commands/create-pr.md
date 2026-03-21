---
description: Commit all changes, push to remote, and create a pull request with user approval
agent: build
---

You are executing the `/create-pr` command to commit all changes, push, and create a pull request. Follow this workflow:

## Pre-flight Checks

1. **Verify Git Configuration**
   - Run: git config user.name
     If empty: "Git user not configured. Set git config user.name first."
   - Run: git config user.email
     If empty: "Git user not configured. Set git config user.email first."

2. **Check Branch and Remote**
   - Run: git branch --show-current
   - Run: git remote get-url origin 2>/dev/null || echo "no-remote"
   - If branch is main, master, develop, or release/*: warn user before proceeding
   - If no remote: "No remote configured. Add a remote with: git remote add origin YOUR_URL"

   **If on Protected Branch:**
   Present options:
   - label: "Push Anyway"
     description: "Push directly from protected branch"
   - label: "Create Branch"
     description: "Create a new branch with conventional naming and push there"
   - label: "Cancel"
     description: "Abort the operation"

   If user chooses "Create Branch":
   - Suggest branch name: feat/short-description (infer from commit intent)
   - Confirm branch name with user
   - Run: git checkout -b feat/your-branch-name
   - Proceed with push workflow on new branch

## Phase 1: Push All Changes

### 1. Read All Changes
Run in parallel:
- Run: git status
- Run: git diff --cached --stat
- Run: git diff --cached
- Run: git diff --stat
- Run: git diff
- Run: git log --oneline -5

### 2. Analyze Changes
- All files changed (staged and unstaged)
- Full diff of all changes
- Remote URL context

### 3. Generate Commit Message
- Format: type(scope): subject
- Types: feat, fix, docs, style, refactor, test, chore, perf
- Subject: under 72 chars, imperative mood, no period

### 4. Present Push Confirmation
Use question tool to ask user:
- question: "Commit message ready. Stage all, commit, and push?"
- header: "Push Action"
- options:
  - label: "Accept"
    description: "Stage all, commit, and push to remote"
  - label: "Suggest Again"
    description: "Generate an alternative commit message"
  - label: "Cancel"
    description: "Abort the operation"

### 5. Handle Push Response
- If response = "Accept": Run git add . && git commit -m "YOUR_COMMIT_MESSAGE" && git push origin $(git branch --show-current)
- If upstream missing: git push -u origin $(git branch --show-current)
- If response = "Suggest Again": Generate new message, present again
- If response = "Cancel": Abort with "Operation cancelled."

### 6. Skip Push If Already Clean
- If nothing to commit and already pushed: skip to Phase 2

## Phase 2: Create Pull Request

### 7. Gather PR Context
Run in parallel:
- Run: git branch --show-current
- Run: git log --oneline origin/main..HEAD 2>/dev/null || git log --oneline origin/master..HEAD 2>/dev/null || git log --oneline -10
- Run: git diff origin/main...HEAD 2>/dev/null || git diff origin/master...HEAD 2>/dev/null || git diff --stat -10
- Run: git diff --stat origin/main...HEAD 2>/dev/null || git diff --stat origin/master...HEAD 2>/dev/null || echo ""

### 8. Detect Base Branch
- Run: git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}'
- Default to main if not found

### 9. Generate PR Title and Body
- Title: Same as commit message subject line (type(scope): subject)
- Body sections:
  - ## Summary: Brief description of changes
  - ## Changes: Bullet list of key changes from diff
  - ## Test Plan: Suggested testing steps

### 10. Check GitHub CLI Availability
- Run: which gh 2>/dev/null
- If not found:
  - Run: brew --version 2>/dev/null (check if Homebrew available)
  - Present options:
    - label: "Install gh"
      description: "Run 'brew install gh' to install GitHub CLI (requires 'gh auth login' after)"
    - label: "Open in Browser"
      description: "Skip gh, open PR compare URL in browser to create manually"
    - label: "Cancel"
      description: "Abort without creating PR"
  - If user chooses "Install gh": Run brew install gh, then check auth
  - If install fails or user chooses "Open in Browser": go to step 13
- If found, check auth:
  - Run: gh auth status 2>&1
  - If not authenticated:
    Present options:
    - label: "Login to gh"
      description: "Run 'gh auth login' to authenticate"
    - label: "Open in Browser"
      description: "Skip gh, open PR compare URL in browser to create manually"
    - label: "Cancel"
      description: "Abort without creating PR"
  - If user chooses "Login to gh": Run gh auth login, then proceed
  - If auth fails or user chooses "Open in Browser": go to step 13

### 11. Present PR Confirmation (with gh)
Use question tool to ask user:
- question: "PR ready to create. Review the details above."
- header: "Create PR"
- options:
  - label: "Create PR"
    description: "Create the pull request with the generated title and body"
  - label: "Edit Title"
    description: "Provide a custom PR title"
  - label: "Edit Body"
    description: "Provide a custom PR body"
  - label: "Cancel"
    description: "Abort without creating PR"

### 12. Create the PR via gh
- Run: gh pr create --title "TITLE" --body "BODY" --base BASE_BRANCH
- If user chose "Edit Title": Ask for new title, then create
- If user chose "Edit Body": Ask for new body, then create
- Show PR URL from gh output
- Present options:
  - label: "Open in Browser"
    description: "Open the PR in your default browser"
  - label: "Done"
    description: "Finish the workflow"
- Done.

### 13. Fallback — Open PR Compare URL in Browser
- Detect platform from remote URL:
  - GitHub: https://github.com/OWNER/REPO/compare/BASE...HEAD?expand=1&title=ENCODED_TITLE&body=ENCODED_BODY
  - GitLab: https://gitlab.com/OWNER/REPO/-/merge_requests/new?merge_request[source_branch]=HEAD&merge_request[target_branch]=BASE&merge_request[title]=ENCODED_TITLE&merge_request[description]=ENCODED_BODY
  - Bitbucket: https://bitbucket.org/OWNER/REPO/pull-requests/new?source=HEAD&dest=BASE
- Run: open "COMPARE_URL" (macOS) or xdg-open "COMPARE_URL" (Linux)
- Show the URL to the user as well

## Error Handling

- **Nothing to commit**: Skip to Phase 2, create PR for existing pushed commits
- **Staging failed**: "Failed to stage changes. Check file permissions."
- **Commit failed**: Show hook error and suggest fixes
- **Push rejected (remote ahead)**: Suggest pull first or force push (caution)
- **Push rejected (permissions)**: "Push rejected - permission denied"
- **gh not installed**: Offer to install with brew, or fall back to browser URL
- **gh not authenticated**: Offer gh auth login, or fall back to browser URL
- **No commits to create PR**: "No commits found on this branch to create a PR from."
- **PR creation failed**: Show gh error, offer to open browser URL as fallback
- **No remote tracking**: Suggest setting upstream with git push -u origin BRANCH
- **Unknown platform**: Show the compare URL pattern and let user open manually
