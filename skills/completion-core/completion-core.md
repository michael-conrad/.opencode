# Completion Core — Shared Completion Operations

## Default Branch Resolution

```bash
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
if [ -z "$DEFAULT_BRANCH" ]; then DEFAULT_BRANCH="main"; fi
```

Reference this file from per-skill `tasks/completion.md` files for common completion operations.

## Common Completion Operations

### 1. Push Branch (Idempotent)

Check whether the branch has unpushed commits before pushing:

```bash
UNPUSHED=$(git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null)
if [ -n "$UNPUSHED" ]; then
    git push -u origin $(git branch --show-current)
else
    echo "Branch already up to date with remote. No push needed."
fi
```

If no remote tracking branch exists yet, `git push -u origin <branch>` creates it.

### 2. Generate URL

Two URL patterns depending on workflow type:

**Compare URL** (for git push workflows — implementation, git-workflow, finishing):

Extract owner/repo from the remote URL:

```bash
REMOTE_URL=$(git remote get-url origin)
if echo "$REMOTE_URL" | grep -q "github.com"; then
  HTML_URL="https://github.com"
  OWNER=$(echo "$REMOTE_URL" | sed -n 's/.*github.com[:\/]\([^/]*\)\/.*/\1/p')
  REPO=$(echo "$REMOTE_URL" | sed -n 's/.*github.com[:\/][^/]*\/\(.*\)\.git/\1/p')
else
  HTML_URL=""
  OWNER=$(echo "$REMOTE_URL" | sed -n 's/.*[:\/]\([^/]*\)\/\([^/]*\)\.git/\1/p')
  REPO=$(echo "$REMOTE_URL" | sed -n 's/.*[:\/]\([^/]*\)\/\([^/]*\)\.git/\2/p')
fi
COMPARE_URL="${HTML_URL}/${OWNER}/${REPO}/compare/$DEFAULT_BRANCH...$(git branch --show-current)"
```

**Action URL** (for creation workflows — issue creation, approval gate):

- **Issue URL:** Extract from `issue-operations -> update-issue` API response `html_url` field — NEVER construct from template <!-- Routes through issue-operations per SPEC #683 -->
- **PR URL:** Extract from `github_create_pull_request` API response `html_url` field — NEVER construct from template

### 3. Route Status Comment Through Substantive Gate — route through `issue-operations -> comment` substantive gate. Gate decides whether to post.

### 4. Report Executive Summary in Chat (Always Runs)

Chat output is idempotent by nature. Always produce:

```
**Summary:**

<1-2 sentences describing the impact and stakeholder value.>

**Outcome:** <What changed for stakeholders>

<URL if applicable, ALWAYS LAST>
```

**URL is ALWAYS last** per `000-critical-rules.md`.

## Idempotency Summary

| Operation | Idempotency Mechanism | Applies To |
| -- | -- | -- |
| Push branch | Check `git log origin/..HEAD` before pushing | Git workflows only |
| Generate URL | Check if URL already generated; compare URL for pushes, action URL for creation workflows | All workflows |
| Post status comment | Substantiveness gate (per `issue-operations` skill `comment` task) | Workflows with issue context |
| Report executive summary + URL | Always run; idempotent by nature | All workflows |
