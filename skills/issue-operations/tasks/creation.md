# Task: creation

## Purpose

Create issue with proper title format, labels, and byline after validation passes. Routes to appropriate platform sub-skill.

## Operating Protocol

1. **Run after `pre-creation` validation passes.**
2. **DO NOT skip validation.**
3. **HALT if Step 0.5 dedup gate evidence is missing.**

## Entry Criteria

- Pre-creation validation passed
- Step 0.5 dedup gate evidence available (OR Step 0.75 runtime search fallback completed)
- Single-task vs multi-task determination complete
- User has authorized creation

## Exit Criteria

- Issue created via platform sub-skill
- `needs-approval` label applied
- Creation byline included in issue body footer
- Issue number available for sub-issue linking

## Procedure

### Step 0.5: Dedup Evidence Gate

**MANDATORY before proceeding to any creation step.**

Verify that the `pre-creation` task's Step 0.5 title dedup gate was executed. This step MUST produce evidence that dedup was performed before the creation API call is allowed. **For both local and remote platforms, dedup checks MUST cover local `.issues/open/` directory AND the platform's remote issue search.**

**Required evidence (from `pre-creation` Step 0.5 output):**

```
Check: Title dedup gate for "<proposed title>"
Tool: `issue-operations → search-issues` / `platforms/gitbucket-api/` / `platforms/local/tasks/search.md`
Local: [N candidates found in .issues/open/]
Remote: [N candidates found, match levels classified]
Classification: [EXACT-DUPLICATE|NEAR-DUPLICATE|CLOSED-IN-ERROR|RELATED-BUT-DISTINCT|FALSE-POSITIVE]
Action: [auto-resolved strategy | proceed | HALT]
```

**Local dedup search (MANDATORY):**

Before or alongside the remote dedup search, search `.issues/open/` for existing local specs:

1. Route to `platforms/local/tasks/search.md` via task(). Pass: `{query: "<significant keywords>", status: "open"}`
2. For each match, compare title keywords against proposed title
3. Classify match level per `pre-creation.md` Step 0.5 Phase 2 classification table
4. If a local EXACT-DUPLICATE or NEAR-DUPLICATE exists → report it alongside any remote duplicates
5. Include local results in the dedup evidence artifact

**Gate logic:**

| Evidence Present? | Result Classified Non-Duplicate? | Action |
|-------------------|----------------------------------|--------|
| Yes | Yes | Proceed to Step 1 |
| Yes | No (EXACT-DUPLICATE / NEAR-DUPLICATE) | HALT — do not create duplicate |
| No | — | Proceed to Step 0.75 (runtime search fallback) |

**If Step 0.5 evidence is missing and runtime search fallback (Step 0.75) also fails → HALT with:**

```
Cannot create issue: Step 0.5 dedup gate evidence missing. Run pre-creation task first.
```

### Step 0.75: Runtime Search Fallback

**When Step 0.5 evidence is unavailable, perform a lightweight dedup search before allowing creation.**

This fallback catches the scenario where `pre-creation` was not run or its output is not in the current session context.

1. Extract significant keywords from the proposed title (remove stop words, prefixes like `[SPEC]`, `[SPEC-FIX]`, `[Task:]`)
2. Search `.issues/open/` for local duplicates:
    - **Local:** Route to `platforms/local/tasks/search.md` via task(). Pass: `{query: "<keywords>", status: "open"}`
    - Classify any local matches per `pre-creation.md` Step 0.5 Phase 2 classification table
3. Search for existing issues via platform API:
    - **GitHub:** `issue-operations → search-issues` with keyword query
    - **GitBucket:** `./.opencode/tools/gitbucket-api issues --state open` + `--state closed` (filter client-side by keyword match)
4. Collect candidate matches from both local and remote (issues whose titles share ≥2 significant keywords with proposed title)
5. For each candidate, classify match level per `pre-creation.md` Step 0.5 Phase 2 classification table
6. If any EXACT-DUPLICATE or NEAR-DUPLICATE found (local or remote) → HALT, report conflict
7. If all candidates are RELATED-BUT-DISTINCT or FALSE-POSITIVE → generate runtime search evidence artifact, proceed to Step 1

**Evidence artifact (MANDATORY):**

```
Check: Runtime search fallback for "<proposed title>"
Tool: `platforms/local/tasks/search.md` / `issue-operations → search-issues` / gitbucket-api issues
Local: [N candidates found in .issues/open/]
Remote: [N candidates found, match levels classified]
Classification: [EXACT-DUPLICATE|NEAR-DUPLICATE|CLOSED-IN-ERROR|RELATED-BUT-DISTINCT|FALSE-POSITIVE]
Action: [HALT | proceed with runtime evidence]
Fallthrough reason: Step 0.5 evidence unavailable
```

**If this fallback also fails (search API unavailable or returns error) → HALT with:**

```
Cannot create issue: Step 0.5 dedup gate evidence missing and runtime search fallback failed. Run pre-creation task first.
```

### Step 1: Determine Title Format

| Issue Type | Title Format | Example |
|------------|--------------|---------|
| Primary spec | `[SPEC] <Feature Name>` | `[SPEC] PubMed API Rate Limiting` |
| Bug fix | `[SPEC-FIX] <Bug Description>` | `[SPEC-FIX] Token Refresh Failure` |
| Enhancement | `[SPEC-ENHANCEMENT] <Enhancement>` | `[SPEC-ENHANCEMENT] Add Rate Limiting` |
| Task | `[Task: #<parent>] <Task Description>` | `[Task: #100] Create user tables` |

### Step 2: Create Issue (Platform-Aware Ordering)

#### Step 2.0: Platform Check

Determine creation order based on `github.platform`:

| `github.platform` | Creation Order |
|---|---|
| `github` | Remote first → local |
| `gitbucket` | Remote first → local |
| `local` | Local first (existing behavior) |

**For `github` and `gitbucket` platforms** proceed to Step 2.1 (Remote-First).
**For `local` platform** proceed to Step 2.2 (Local-First).

#### Step 2.1: Remote-First Flow (when `github.platform != local`)

1. Promote to remote platform FIRST. Route based on `github.platform`:

   **GitHub:**
   Route to `platforms/github-mcp/` sub-skill via task(). Pass issue parameters (title, body, labels). The platform sub-skill handles the `github_issue_write` call.

   **GitBucket:**
   Route to `platforms/gitbucket-api/` sub-skill via task(). Pass issue parameters (title, body, labels). The platform sub-skill handles the `gitbucket-api` call.

   **Note (GitBucket):** Labels can ONLY be set during creation. Post-creation label changes do not work.

2. **Extract remote issue number** from API response `number` field
3. **Create local `.issues/open/<remote-number>-<slug>/`** — the remote number IS the local directory name (no local counter needed)
4. Write spec body to `.issues/open/<remote-number>-<slug>/spec.md` (preserving YAML frontmatter)
5. Record remote metadata in YAML frontmatter:

   ```yaml
   remote_issue: <remote-number>
   remote_url: <html_url-from-api-response>
   promoted_at: <timestamp>
   ```

6. **Counter advancement:** Read `.counter`. If `counter <= remote_number`, write `remote_number + 1` to `.counter` to prevent future local-first issues from colliding with this remote number.

**Local copy retains full-fidelity detail** — extra metadata, reasoning, and agent notes that stakeholders don't need.

#### Step 2.2: Local-First Flow (when `github.platform == local`)

**Use counter-based numbering. Create local first, no remote promotion:**

Route to `platforms/local/tasks/creation.md` via task(). Pass: `{title: "<title>", labels: ["needs-approval"]}`

Then write the spec body to `.issues/open/NNN-slug/spec.md` (preserving YAML frontmatter).

**Local copy retains full-fidelity detail** — extra metadata, reasoning, and agent notes that stakeholders don't need.

**No remote promotion possible.** Issue exists only in `.issues/open/`.

**Response includes:**
- Local issue number (counter-based)
- Local path: `.issues/open/NNN-slug/spec.md`

**Post-Creation URL Extraction (MANDATORY — per `000-critical-rules.md` §URL Sourcing):**

The Issue URL MUST be extracted from the API response `html_url` field — NEVER constructed from template variables:

1. After the creation API call, extract the `html_url` field from the response
2. Use this exact value as the Issue URL for all subsequent references (chat output, cross-references, sub-issue linking reports)
3. **Template construction is FORBIDDEN for post-creation URLs** — do NOT assemble from `<gitbucket.html_url>`, `<github.owner>`, `<github.repo>`, or issue number
4. If `html_url` is not available in the API response: HALT and report

### Step 3: Verify Byline in Issue Body

**The issue body must already include a byline footer** (added during spec drafting):

```
🤖 <AgentName> (<ModelId>) created
```

**No separate comment needed.** The byline is part of the issue body content, not a standalone comment.

### Step 4: Report Issue Created

Report based on creation flow:

**Remote-first flow (GitHub/GitBucket):**

```
Created remote issue #MMM at <html_url>
Local mirror: .issues/open/MMM-slug/spec.md
```

**Local-first flow (local platform only):**

```
Created local issue #NNN at `.issues/open/NNN-slug/spec.md`
```

### Step 4.5: Developer Review Signal

When an issue is created (local or promoted), remind the developer how to review:

**Local platform (local-first):**
```
Local issue #NNN created. Review with:
  platforms/local/tasks/read.md via task()
```

**Remote platform (remote-first):**
```
Issue #MMM created on GitHub. Review:
  Remote: <html_url>
  Local mirror: platforms/local/tasks/read.md via task()
```

### Step 5: Enforce Exec Summary Body Format

**The created issue body MUST include the exec summary body format below.** If the body was constructed without these sections, update it immediately via the platform sub-skill (`issue-operations → update-issue`) before proceeding to Step 4.

The body must contain the following 6 sections in order:

1. **Spec Reference Blockquote** (mandatory — top of body, before all other content):
   ```
   > Full spec and plan artifacts: {{REMOTE_BROWSER_URL}}/{{OWNER}}/{{REPO}}/tree/issues-data/.issues/N/
   ```
   - `{{REMOTE_BROWSER_URL}}` from session-init (platform-agnostic — use `github.html_url` or `gitbucket.html_url` as appropriate)
   - `{{OWNER}}` / `{{REPO}}` from session-init, verified against target issue's repository
   - `{{SPEC_BRANCH}}` always `issues-data`
   - `{{SPEC_PATH}}` always `.issues/N/` (where N is the created issue number)
   - **Repo-awareness guard:** Confirm owner/repo from session-init matches the target issue's repository. If the issue resides in a submodule/sub-folder repo (different owner/repo from root), use that repo's owner/repo. Do NOT route a cross-repo URL with the wrong owner/repo pair.
   - All links MUST be full resolved URLs — no platform shortcuts (`#NNN`, relative paths)

2. **Problem** (mandatory) — What problem this solves, why now, BLUF (Bottom Line Up Front) format. 1-3 sentences.

3. **Scope** (mandatory) — 3-5 bullets describing what is in-scope, followed by an explicit `**Out of scope:**` list describing what is NOT covered.

4. **Approach** (mandatory) — High-level solution description, 3-5 sentences. Focus on architectural choices and rationale, not implementation details.

5. **Impact** (mandatory) — Top 3 risks with one-line mitigation each, key dependencies, and a call to action.

6. **AI Agent Instructions** (mandatory):
   ```
   ## AI Agent Instructions

   This issue is an executive summary for human stakeholders.
   The authoritative spec and plan artifacts are at .issues/N/.
   AI agents MUST read the local spec/plan files for implementation
   and MUST NOT base implementation on this summary.
   ```

**Post-creation enforcement:** Run this check after Step 2 (issue created) and before Step 4 (report). If any section is missing, call `issue-operations → update-issue` to amend the body with the missing section(s). Do NOT proceed to report until all 6 sections are verified present.

## Multi-Task Spec Handling

**If spec has multiple phases:**

1. After creating parent issue
2. Invoke `issue-operations --task link-sub-issue`
3. Create phase-level sub-issues
4. Link each via platform sub-skill (GitHub: `github_sub_issue_write(method="add")`; GitBucket: comment-based linking)

**Single-task exemption:**
- If spec has ONE task, skip sub-issue creation
- Apply `needs-approval` label
- Proceed to `post-creation` task

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task Context Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Safety Checks

Before proceeding, verify ALL:

- Step 0.5 dedup evidence present OR Step 0.75 runtime search fallback completed
- Pre-creation validation passed
- Title follows proper format
- `needs-approval` label applied
- Creation byline in body footer

**If ANY check fails → HALT and report.**

## Context Required

- Related tasks: `pre-creation` (runs first), `post-creation` (runs next), `link-sub-issue` (sub-issue creation)
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`
- No direct `github_*` or `gitbucket-api` calls outside `issue-operations/platforms/`
- Label state machine: `141-planning-status-tracking.md §10` (add `needs-approval` on creation; GitHub `labels` parameter replaces all labels)

## Live Verification: Creation Evidence (MANDATORY)

**Each creation precondition MUST be verified via tool call. Assertions without tool-call artifacts are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| Claim | Verification Action | Tool Call | Problem Class |
|-------|-------------------|-----------|---------------|
| "Title dedup gate performed" | Verify dedup was run before creation | Check pre-creation output for Step 0.5 evidence; if missing, run Step 0.75 runtime search fallback | MISSING-ELEMENT → HALT |
| "Pre-creation validation passed" | Verify validation result exists | Check pre-creation output in session | MISSING-ELEMENT |
| "No conflicting spec exists" | Search for overlapping issues | `issue-operations → search-issues` → verify | CONFLICTING |
| "Title follows format" | Verify title prefix | Check `[SPEC]`, `[SPEC-FIX]`, `[SPEC-ENHANCEMENT]`, `[Task:` prefix | STRUCTURE-VIOLATION |
| "Issue was created" | Verify API response | Check `number` field in creation response | MISSING-ELEMENT |
| "`needs-approval` label applied" | Verify label on created issue | `issue-operations → read-labels` → verify label | MISSING-ELEMENT |
| "Byline in body" | Verify byline present | Check issue body for `🤖` marker | STRUCTURE-VIOLATION |

**Evidence artifact:** Pre-creation result, creation API response, post-creation label check.

### Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| Step 0.5 dedup evidence missing | MISSING-ELEMENT | HALT | HALT — "Cannot create issue: Step 0.5 dedup gate evidence missing. Run pre-creation task first." |
| Step 0.75 runtime search found duplicate | CONFLICTING | HALT | HALT — report duplicate, do not create |
| Pre-creation not run | MISSING-ELEMENT | flag-for-review | HALT — run pre-creation first |
| Conflicting spec found | CONFLICTING | flag-for-review | HALT — report conflict |
| Wrong title format | STRUCTURE-VIOLATION | auto-fix | Correct title before creation |
| Creation API failed | MISSING-ELEMENT | flag-for-review | HALT — retry or report error |
| Label missing post-creation | MISSING-ELEMENT | auto-fix | Add label immediately |
| Byline missing | STRUCTURE-VIOLATION | auto-fix | Add byline to body |