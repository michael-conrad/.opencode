# Task: comment

## Purpose

Post comments to issues/PRs following the substantive comment gate and byline format. Routes posting via platform sub-skill. Absorbs `github-comments` skill functionality.

## Entry Criteria

- Comment content is substantive (conveys information stakeholders need to understand what changed or why)
- Comment type specified (completion, update, rejection)
- Issue/PR number identified

## Exit Criteria

- If substantive: comment posted with correct byline format
- If not substantive: comment skipped (no posting)

## Procedure

### Step 0: Caller Guidance — Evaluate Gate Before Committing

**This substantiveness gate MUST be evaluated by callers BEFORE the caller commits to posting.**
Callers must not assume posting is the default outcome. The gate determines whether posting is warranted:

- [ ] 1. Caller routes comment content through this gate first (before any posting action)
- [ ] 2. Gate evaluates: Is this substantive? If yes → post. If no → output to chat only
- [ ] 3. Caller respects the gate's decision — never post content the gate classified as non-substantive

Non-substantive progress (status updates, "phase complete", "implemented X") goes to chat only, never to issue comments.

### Step 1: Substantiveness Gate

Before posting, evaluate: Does this comment convey information a stakeholder needs to understand what changed or why?

| If | Action |
|----|--------|
| Comment explains substantive change stakeholders need to know | **Post with byline** |
| Comment is merely "Task complete" or status update | **SKIP — do not post** |
| Comment explains what changed during closure (beyond status) | **Post with byline** |

### Step 1.5: Content Classification Gate

After substantiveness, classify comment content before determining type. Classification determines routing — where the comment lands and whether it reaches stakeholders.

| Classification | Definition | Route |
|---|---|---|
| **stakeholder** | Information a reviewer/stakeholder needs to act on | Write to `remote.md` → route to `platforms/local/tasks/push-body.md` via task() |
| **internal** | Agent reasoning, design analysis, corrections, process metadata | `.issues/N/comments.md` only |

**Concrete classification rules:**

| Content Type | Classification | Rationale |
|---|---|---|
| What was DONE | Evaluate for stakeholder | May affect stakeholder understanding or require action |
| HOW it was figured out | **internal** | Process detail, not actionable |
| Revising/correcting spec | **internal** | Correction updates the issue body, not a comment |
| Audit findings, verdicts | **internal** | Process metadata, not stakeholder-facing |
| Discussion responses | **internal** | Agent-to-agent reasoning |
| Decision log entries | **internal** | Process metadata |

**Error handling:** Default to `internal` (conservative) when classification is uncertain. Stakeholder-visible content is additive — it can always be promoted later. Internal content posted publicly cannot be retracted.

### Step 1.5b: Routing Gate for Spec/Plan Corrections

When content is classified as "Revising/correcting spec" or "Revising/correcting plan", do NOT post a comment. Route to the correct pipeline:

| Content Type | Route To |
|---|---|
| Revising/correcting spec | `spec-creation --task change-control` |
| Revising/correcting plan | `task("execute revise from writing-plans")` |

The comment task's only job is posting comments — not revising bodies, not updating specs, not modifying plans.

### Step 2: Determine Comment Type

| Type | Purpose | Status Text | Icon |
|------|---------|-------------|------|
| Completion | Task finished | completed | ✅ |
| Update | Modified existing content | updated | 📝 |
| Rejection | Cannot proceed | rejected | ❌ |
| Copy Editor | Posting on behalf of user | `🤖 ✎📝 on behalf of <AgentName>` | ✎ |

### Step 3: Apply Format Template

**Invariant byline format (all types):**
```
🤖 <AgentName> (<ModelId>) <status-icon> <status>
```

**Completion Template:**
```markdown
**Summary:**

<1-2 sentences describing impact and stakeholder value>

**Outcome:** <What changed for stakeholders>

All tasks complete from this specification.

---
🤖 <AgentName> (<ModelId>) ✅ completed
```

**Update Template:**
```markdown
**Summary:**

<1-2 sentences describing what changed and why stakeholders need to know>

**Outcome:** <What changed for stakeholders>

---
🤖 <AgentName> (<ModelId>) 📝 updated
```

### Prose-Driven Comment Bodies (CRITICAL)

**Comment bodies MUST be prose-driven — natural paragraphs that explain what changed and why.**

Stakeholders need understanding, not commit logs. GitHub diffs already show what changed; comments explain WHY.

### Step 3.5: Byline Verification (MANDATORY)

Before posting any AI-authored comment, verify the byline is present:

| If | Action |
|----|--------|
| Body ends with `🤖 Co-authored with AI: <AgentName> (<ModelId>)` | ✅ Proceed to Step 5 |
| Body contains byline elsewhere | ✅ Proceed to Step 5 |
| Body has no byline | **Append byline as last line before posting** |
| Comment is not AI-authored (copy-pasted or human-authored) | ✅ Skip — no byline needed |

**This check applies regardless of target repository** (home repo or external). External posts have higher attribution priority, not lower.

**Standalone byline correction comments are ABSOLUTELY FORBIDDEN.** If a byline was missing from a previously posted comment:

| Option | When | Action |
|--------|------|--------|
| Edit the comment | Platform supports edit + agent has edit permission | Edit original, append byline as last line |
| Delete + repost | Agent has delete permission | Delete original, repost with byline |
| Accept the omission | No edit/delete permission | Leave it — never add a separate byline comment |

### Step 5: Validate Format

**CRITICAL: Emoji must be PLAIN TEXT (not inside italic/bold formatting)**

- Emoji is outside markdown formatting
- Byline follows invariant format
- Summary is 1-2 sentences max
- Outcome states what changed
- Horizontal rule separates summary from byline
- Body is prose-driven, not rigid bullet lists

### Step 6: Post Comment (Platform Routing)

Route based on `github.platform`:

| `github.platform` | Route to |
|---|---|
| `github` | `platforms/github-mcp/` sub-skill |
| `gitbucket` | `platforms/gitbucket-api/` sub-skill |
| `local` | `platforms/local/` sub-skill |

**GitHub platform (sub-skill implementation):**
```python
github_add_issue_comment(
    owner=<github.owner>,
    repo=<github.repo>,
    issue_number=N,
    body=formatted_comment
)
```

**GitBucket platform (sub-skill implementation):**
```bash
gb issue comment <issue-number> -b "<formatted_comment>" -R <github.owner>/<github.repo>
```

**Local platform (sub-skill implementation):**
Route to `platforms/local/tasks/comment.md` via task(). Pass: `{issue_number: N, body: "<formatted_comment>", action: "post"}`.

## Live Verification: Comment Claims (MANDATORY)

**When this task prepares a comment, any claims about issue/PR state MUST be verified against live state.**

| Comment Claim | Verification Action | Tool Call (routed) |
|--------------|-------------------|-----------|
| "Spec revised" in revision comment | Verify spec body actually changed | `issue-operations → read-issue` then compare body |
| "Implementation complete" in closure comment | Verify PR merged via platform API | `github_pull_request_read(method=get)` → check `merged` field *(PR ops — not routed through issue-operations)* |
| "Fixes #N" in PR comment | Verify issue #N exists | `issue-operations → read-issue` then verify existence |

## Common Issues

| Issue | Resolution |
|-------|------------|
| Non-substantive content | Skip posting entirely — progress goes to chat only |
| Emoji inside bold/italic | Move emoji outside formatting |
| Missing outcome | Add what changed for stakeholders |
| Summary too long | Reduce to 1-2 sentences |

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

## Context Required

- Session values: github.owner, github.repo, github.platform
- Related tasks: `close` (uses comment for closure), `link-sub-issue` (uses comment for fallback)
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`
- Byline verification (Step 3.5) applies to ALL repositories — external posts have higher attribution priority
- No direct `github_*` or `gitbucket-api` calls outside `issue-operations/platforms/`