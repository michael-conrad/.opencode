# Completion Core — Shared Completion Operations

## Entry Criteria

- verification-before-completion PASS required before any completion operation
- Workflow state is known (issue_number, branch_name, workflow_type)

## Procedure

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

Construct from session-init values with character-match verification:

1. Read `<github.owner>`, `<github.repo>`, `<github.html_url>` (or `<gitbucket.html_url>`) from session init
2. Construct: `<html_url>/<owner>/<repo>/compare/$DEFAULT_BRANCH...<branch>` using the platform's base URL from session-init
3. **Character-match verification:** Confirm `GIT_OWNER` and `GIT_REPO` in the constructed URL match session-init values exactly (character-for-character, no typos, no cached values)
4. If any mismatch: HALT and report

```bash
COMPARE_URL="${GITBUCKET_HTML_URL:-${GITHUB_HTML_URL}}/${GIT_OWNER}/${GIT_REPO}/compare/$DEFAULT_BRANCH...$(git branch --show-current)"
```

**Action URL** (for creation workflows — issue creation, approval gate):

- **Issue URL:** Extract from `issue-operations -> update-issue` API response `html_url` field — NEVER construct from template
- **PR URL:** Extract from `github_create_pull_request` API response `html_url` field — NEVER construct from template

### 3. Append Lifecycle Event

Append a completion event to the lifecycle manifest at `{project_root}/tmp/{issue-N}/lifecycle.yaml`:

```yaml
  - event: step_completed
    timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
    issuer: <AgentName> (<ModelId>)
    step: <step_label>
    status: PASS
    description: "<brief summary>"
    severity: info
```

The lifecycle manifest is append-only. Never delete or edit existing entries.

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
| Append lifecycle event | Append-only — always adds new entry | All workflows |
| Report executive summary + URL | Always run; idempotent by nature | All workflows |

## Exit Criteria

- Branch pushed (if applicable)
- URL generated and verified
- Lifecycle event appended
- Executive summary reported in chat
