---
name: body-edit
triggers_on: body edit, edit body, edit issue body, update issue body
---

# Task: body-edit

## Purpose

Body editing IS remote synchronization. Every body edit requires verification before propagation. No valid remote state exists without a verified local source. Editing `remote.md` without structural verification propagates corruption upstream — every remote edit must pass through the fetch-transform-verify-post pipeline before reaching stakeholders.

## Entry Criteria

- Issue number identified
- Edit instruction or texted script provided
- `.issues/N/remote.md` exists (or will be created by fetch agent)
- Authorization scope permits issue body modification

## Exit Criteria

- `remote.md` structurally intact after edit (pure markdown, no frontmatter — check for corruption, not frontmatter)
- Edit applied and verified
- Sync push completed (or verified not needed for local-only platform)
- Post agent returns `{ sync_status, url }`

## Sub-Agent Dispatch Table

The orchestrator dispatches four sub-agents in strict sequence. Each sub-agent is a discrete work unit with defined input/output contracts. The orchestrator NEVER performs inline work — it routes and collects result contracts only.

| Phase | Sub-Agent | Purpose | Must Receive | Must NOT Receive | Output Contract |
|-------|-----------|---------|--------------|------------------|-----------------|
| 1 — Fetch | `fetch` | Read current `remote.md` and platform metadata | `{ issue_number }` | Edit script, transform instructions, orchestrator reasoning | `{ current_body, issue_number, platform, remote_md_path }` |
| 2 — Transform | `transform` | Apply texted script to `remote.md` | `{ remote_md_path, edit_script }` (edit_script from caller, not orchestrator preload) | Expected outcomes, pre-determined file content, orchestrator reasoning | `{ success, summary_of_changes }` |
| 3 — Verify | `verify` | Post-edit structural integrity check | `{ remote_md_path }` | Transform agent's reasoning, edit script, expected body content, orchestrator reasoning | `{ pass, issues }` |
| 4 — Post | `post` | Commit `.issues/` changes and sync push | `{ issue_number, platform, remote_md_path }` | Transform agent's summary, edit script, orchestrator reasoning | `{ sync_status, url }` |

### Critical Dispatch Rules

- **critical-rules-034**: Orchestrator is pure router — zero inline file operations
- **critical-rules-030**: Each sub-agent receives minimal context — no orchestrator preload
- **critical-rules-044**: No pre-determined file paths, line numbers, or expected outcomes in dispatch context
- **critical-rules-043**: On sub-agent failure, discard ALL work and re-task with original scoped context

## Procedure

### Phase 1: Fetch Agent

Read the current state of `.issues/N/remote.md` and platform metadata.

**Actions:**

- [ ] 1. Resolve the `.issues/` root directory:
   ```bash
   git rev-parse --show-toplevel  # find repo root
   ```
   Then locate `.issues/N/` matching the issue number.

- [ ] 2. Read `.issues/N/remote.md` via `read` tool. If the file does not exist, report `remote_md_path: null` — the transform agent will create it.

- [ ] 3. Determine platform from `github.platform` session value.

- [ ] 4. Return result contract:
   ```json
   {
     "current_body": "<content of remote.md, or null if not found>",
     "issue_number": N,
     "platform": "github|gitbucket|local",
     "remote_md_path": ".issues/{N}/remote.md"
   }
   ```

**Error handling:** If the issue directory does not exist (no `.issues/N/`), return `{ error: "issue_directory_not_found", issue_number: N }`. The orchestrator HALTs — do not create directories inline.

### Phase 2: Transform Agent

Apply the caller's texted edit script to `remote.md`.

**Input:** The `edit_script` parameter comes from the caller's original task instruction, NOT from orchestrator preload. The orchestrator passes the script to the transform sub-agent without modification or interpretation.

**Actions:**

- [ ] 1. Receive `{ remote_md_path, edit_script }` from orchestrator dispatch context.

- [ ] 2. If `remote_md_path` exists, apply the texted script:
   ```
   texted_edit_file(
     files=[remote_md_path],
     script=edit_script
   )
   ```

- [ ] 3. If `remote_md_path` is null (file does not exist), this is an error condition — `remote.md` must exist before editing or be created by a separate sync-pull operation first. Return `{ success: false, summary_of_changes: "remote.md not found — run sync pull first" }`.

- [ ] 4. Return result contract:
   ```json
   {
     "success": true|false,
     "summary_of_changes": "<human-readable summary of what changed>"
   }
   ```

**Error handling:** If `texted_edit_file` reports no match for the script's search pattern, return `{ success: false, summary_of_changes: "pattern not found in remote.md" }`. The orchestrator reports this to the caller — do not retry with modified patterns inline.

### Phase 3: Verify Agent

Post-edit structural integrity check. This agent checks STRUCTURE only — it does NOT check body length. The `remote.md` file is intentionally shorter than `spec.md` (exec summary format), so length ratio checks (critical-rules-022) do NOT apply.

**Actions:**

- [ ] 1. Read the edited `remote.md` file via `read` tool.

- [ ] 2. Verify structural integrity:

   | Check | Pass Condition | Failure Classification |
   |-------|---------------|----------------------|
   | No null bytes or corruption | File contains no `\x00` or binary artifacts | CORRUPTION |
   | Markdown valid | Headings, lists, links parse without syntax errors | MARKDOWN-INVALID |
   | Body content non-empty | At least one non-whitespace line | EMPTY-BODY |
   | No frontmatter present | File does NOT start with `---` (remote.md is pure markdown) | STRUCTURE-DAMAGE |

- [ ] 3. Return result contract:
   ```json
   {
     "pass": true|false,
     "issues": ["STRUCTURE-DAMAGE: frontmatter detected in remote.md", ...]
   }
   ```

**What the verify agent does NOT check:**

- Body length ratio (remote.md is intentionally shorter — critical-rules-022 does not apply)
- Content accuracy or semantic correctness
- Comparison with spec.md (different files, different purposes)

**Error handling:** If `pass` is false, the orchestrator HALTs — do not proceed to the post agent. Report the structural issues to the caller.

### Phase 4: Post Agent

Commit `.issues/` changes and sync push to remote.

**Actions:**

- [ ] 1. Stage and commit `.issues/` changes:
   ```bash
   git add .issues/
   git commit -m "body-edit: update remote.md for issue #N"
   ```

- [ ] 2. Route to `platforms/local/tasks/push-body.md` via task() to sync local changes. Pass: `{issue_number: N}`

- [ ] 3. For GitHub platform, also update the remote issue body (routed via platform sub-skill):

Route based on `github.platform`:

| `github.platform` | Route to |
|---|---|
| `github` | `platforms/github-mcp/` sub-skill |
| `gitbucket` | `platforms/gitbucket-api/` sub-skill |
| `local` | Skip remote push (local-only) |

**GitHub platform (sub-skill implementation):**
```python
# Read remote.md content (pure markdown — read verbatim, no frontmatter to strip)
github_issue_write(
    method="update",
    owner=github.owner,
    repo=github.repo,
    issue_number=N,
    body=remote_md_body_content
)
```

**GitBucket platform (sub-skill implementation):**
```bash
gb issue edit <issue-number> -R <github.owner>/<github.repo> --body "<remote_md_body_content>"
```

- [ ] 4. Return result contract:
   ```json
   {
     "sync_status": "pushed|local_only|failed",
     "url": "<html_url from API response, or null for local>"
   }
   ```

**URL extraction (MANDATORY — per critical-rules-022 §URL Sourcing):** The URL MUST be extracted from the API response `html_url` field. NEVER construct from template variables. If `html_url` is not in the response, set `url` to `null` and report the missing field.

**Error handling:** If sync push fails, return `{ sync_status: "failed", url: null }`. The orchestrator reports the failure — do not retry inline.

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task Context Rules

- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Safety Checks

Before dispatching any sub-agent, verify ALL:

- Issue number is valid (numeric, positive)
- Edit instruction or texted script is non-empty
- `github.platform` is set in session context
- `.issues/` directory exists in the repository

**If ANY check fails → HALT and report.**

## Live Verification: Body-Edit Evidence (MANDATORY)

**Each phase output MUST be verified via tool call by the next phase's sub-agent. Orchestrator assertions without phase result contracts are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| Claim | Verification Action | Tool Call | Problem Class |
|-------|-------------------|-----------|---------------|
| "remote.md exists" | Verify file is readable | `read` tool on `.issues/N/remote.md` | MISSING-ELEMENT |
| "Edit applied successfully" | Verify texted_edit_file returned success | Phase 2 result contract `success: true` | STRUCTURE-DAMAGE |
| "No frontmatter in remote.md" | Verify file does NOT start with `---` | Phase 3 result contract `pass: true` | STRUCTURE-DAMAGE |
| "No corruption" | Verify no null bytes or binary artifacts | Phase 3 result contract | CORRUPTION |
| "Sync completed" | Verify remote body matches local | `issue-operations → read-issue` → compare body | VERIFICATION-GAP |

**Evidence artifact:** Phase result contracts from all four sub-agents.

### Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| remote.md not found | MISSING-ELEMENT | flag-for-review | HALT — run sync pull first |
| Edit script pattern not found | STRUCTURE-DAMAGE | flag-for-review | HALT — report to caller |
| Frontmatter corrupted | STRUCTURE-DAMAGE | conditional | HALT — verify agent rejected edit |
| Null bytes detected | CORRUPTION | conditional | HALT — investigate source |
| Sync push failed | VERIFICATION-GAP | flag-for-review | Report failure, local commit preserved |
| Remote body mismatch | VERIFICATION-GAP | conditional | Retry sync push once, then report |

## Context Required

- Session values: `github.owner`, `github.repo`, `github.platform`
- Edit instruction: texted script string or natural language edit description
- Issue number: numeric identifier
- Related tasks: `comment` (progress comments), `close` (closure may trigger body edit)
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`
- No direct `github_*` or `gitbucket-api` calls outside `issue-operations/platforms/`
- Mirror protocol: `../platforms/github-mcp/SKILL.md` §Mirror Protocol (remote.md is the sync source)
- critical-rules-022: NOT applicable to remote.md (canonical detail lives in spec.md; remote.md is intentionally shorter)

## Pipeline Signal

```
HALT
```