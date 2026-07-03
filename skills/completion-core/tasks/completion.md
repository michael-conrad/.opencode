<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: completion

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Push changes, generate issue/PR URLs, append lifecycle event, and produce executive summary output for the orchestrator pipeline.

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
```

### Task Context Rules
- Missing `authorization_scope` in task context -> return `status: BLOCKED`
- Instructed to exceed `halt_at` -> return `status: BLOCKED`

## Entry Criteria

- Feature branch exists with committed changes
- Authorization scope covers current `halt_at` boundary
- git remote verified (if pushing is expected)

## Exit Criteria

- Changes pushed to remote (if `halt_at >= pr_created`)
- Compare URL generated with correct base branch
- Lifecycle event appended to `./tmp/{issue-N}/lifecycle.yaml`
- Executive summary output produced
- Byline verified in all posted content

## Procedure

### Step 1: Push Changes

Check whether the branch has unpushed commits before pushing:

```bash
UNPUSHED=$(git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null)
if [ -n "$UNPUSHED" ]; then
    git push -u origin $(git branch --show-current)
else
    echo "Branch already up to date with remote. No push needed."
fi
```

- Use `git push -u origin <branch>` if branch not yet tracking remote
- Use `git push` if branch already tracking remote

### Step 2: Generate Compare URL

Construct from session-init values with character-match verification:

- [ ] 1. Read `<github.owner>`, `<github.repo>`, `<github.html_url>` (or `<gitbucket.html_url>`) from session context
- [ ] 2. Construct: `<html_url>/<owner>/<repo>/compare/dev...<branch>` using the platform's base URL from session-init
- [ ] 3. **Character-match verification:** Confirm `<github.owner>` and `<github.repo>` in the constructed URL match session-init values exactly (character-for-character, no typos, no cached values)
- [ ] 4. If any mismatch: HALT and report

```bash
COMPARE_URL="${GITBUCKET_HTML_URL:-${GITHUB_HTML_URL}}/${GIT_OWNER}/${GIT_REPO}/compare/dev...$(git branch --show-current)"
```

### Step 3: Append Lifecycle Event

Append a completion event to the lifecycle manifest at `./tmp/{issue-N}/lifecycle.yaml`:

```yaml
  - event: step_completed
    timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
    issuer: <AgentName> (<ModelId>)
    step: exec-summary
    status: PASS
    description: "<brief summary of what was completed>"
    severity: info
```

The lifecycle manifest is append-only. Never delete or edit existing entries.

### Step 4: Executive Summary Output

Produce structured output in chat:

```
**Summary:** <what was completed>

**Branch:** <branch_name>

**Compare URL:** <url> (if pushed)

**Status:** <halt_at boundary reached>

**Next:** <what authorization is needed to proceed>
```

URL is ALWAYS last per `000-critical-rules.md`.

### Step 5: Z3 State Update

Record completion position in the pipeline state machine:

```bash
solve state update ./tmp/{issue-N}/state/ \
    --var-name pipeline_state \
    --var-value complete \
    --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
```

## Idempotency Summary

| Operation | Idempotency Mechanism |
|-----------|----------------------|
| Push branch | Check `git log origin/..HEAD` before pushing |
| Generate URL | Construct from session-init values — deterministic |
| Append lifecycle event | Append-only — always adds new entry |
| Report executive summary | Always run; idempotent by nature |
| Z3 state update | `--var-value complete` is idempotent |

## Error Handling

| Error | Action |
|-------|--------|
| Push fails (no remote) | Skip push, report local-only |
| Push fails (auth error) | Report auth failure, ask developer |
| No changes to push | Skip push step |
| URL generation fails | Report manually |
| Lifecycle event append fails | Report failure, include summary in chat only |

## Result Contract

```yaml
status: DONE | BLOCKED
pushed: true | false
compare_url: "<url>" | null
lifecycle_event_appended: true | false
summary: "<1-3 sentence summary>"
```

## Artifact Output

Write the result contract to:
```
./tmp/{issue-N}/artifacts/pipeline-exec-summary-{STATUS}-{timestamp}.yaml
```

Following the #932 naming convention per `implementation-pipeline` pipeline-executor dispatch table.

## Live Verification: Completion Evidence (MANDATORY)

| Claim | Verification Action | Tool Call |
|-------|-------------------|-----------|
| "Changes pushed" | Verify remote tracking branch exists | `git status` / `git log origin/HEAD..HEAD` |
| "Compare URL valid" | Verify owner and repo character-match | Compare against session-init values |
| "Comment routed" | Verify lifecycle event appended | `grep -c "event:" ./tmp/{issue-N}/lifecycle.yaml` |
| "Byline present" | Verify byline is last substantive line | Read posted comment text |

## Cross-References

- `git-workflow --task review-prep`
- `git-workflow --task pr-creation`
- `implementation-pipeline/tasks/pipeline-executor.md` — Step 14 dispatch table
- `000-critical-rules.md` — URL ALWAYS last requirement
- `080-code-standards.md` — AI Co-Authored Attribution
