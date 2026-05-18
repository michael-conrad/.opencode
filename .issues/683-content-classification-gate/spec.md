# [SPEC] Content classification gate + local-first issue architecture — unify #571, #585

**Canonical spec:** `.issues/683-content-classification-gate/spec.md`
**GitHub issue:** https://github.com/michael-conrad/.opencode/issues/683
**Prerequisite:** #523 (`.issues/` git worktree + remote.md/spec.md separation + sync push/pull)
**Supersedes:** #571, #585, #60

## Problem

AI agents post internal reasoning, design analysis, self-corrections, decision logs, audit findings, and discussion responses directly to the remote GitHub/GitBucket issue tracker as issue comments. This causes three compounding failures:

1. **Noise + clean room violations** — Internal reasoning posted as public comments contaminates audit isolation and creates churn for stakeholders
2. **Spec body staleness** — Design corrections are posted as comments rather than updating the spec body, so the authoritative body diverges from the current design
3. **Routing bypass** — ~35-40 skill task files call `github_*` / `gitbucket-api` tools directly instead of routing through the `issue-operations` dispatcher, bypassing platform routing, the substantive gate, and byline enforcement

### Evidence: Issue #682

Issue #682 received 5 comments in 28 minutes — each was internal analysis or self-correction:

| Comment | Type | Problem |
|---------|------|---------|
| "Decomposition and Chain Analysis" | Internal architecture analysis | Belongs in chat or .issues/, not GitHub |
| "Correction and Revised Decomposition" | Self-correction of approach | Internal deliberation |
| "Correction: Execution Mode Architecture" | More internal reasoning | Internal deliberation |
| "Correction: Pair Branches Eliminated" | More internal reasoning | Internal deliberation |
| "Thank you for the history" | Discussion response | Chat content posted to issue |

None of these updated the spec body, leaving the authoritative spec stale.

## Architecture

```
#523 prerequisite:
  .issues/N/spec.md     — Canonical full detail (never synced to remote)
  .issues/N/remote.md   — Exec summary (sync push reads verbatim to GitHub)
  .issues/N/state.md    — Phase tracking

#683 additions:
  ┌─ Content classification gate ─────────────────┐
  │  Before ANY comment post:                     │
  │  stakeholder → write to remote.md + sync push │
  │  internal → write to spec.md/.issues/ only    │
  └──────────────────────────────────────────────┘
  
  ┌─ Routing enforcement ─────────────────────────┐
  │  All github_* / gitbucket-api issue calls     │
  │  → route through issue-operations dispatcher  │
  └──────────────────────────────────────────────┘
  
  ┌─ Decision Log ────────────────────────────────┐
  │  assemble-work.md Step 7 → .issues/ storage   │
  │  NOT GitHub comments                          │
  └──────────────────────────────────────────────┘
```

## Solution

### Phase 1: Content classification gate (issue-operations/tasks/comment.md)

Add a mandatory classification step before every comment post. The gate determines whether content is `stakeholder` or `internal`:

| Classification | Definition | Route | Examples |
|----------------|-----------|-------|----------|
| **stakeholder** | Information a reviewer/stakeholder needs to act on | Write to `remote.md` then `local-issues sync push N` | Phase completion, scope changes, blocking conditions, milestone announcements |
| **internal** | Agent reasoning, design analysis, corrections, process metadata | `local-issues comment N --body "..."` (`.issues/` only) | Decision logs, architecture analysis, self-corrections, audit findings, discussion responses |

The gate is inserted as a new Step 1.5 in `issue-operations/tasks/comment.md`, between the existing substantiveness gate (Step 1) and the type determination (Step 2).

**Concrete classification rules:**
- Content that describes what was DONE → evaluate for `stakeholder`
- Content that describes HOW it was figured out → `internal`
- Content that revises/corrects the spec → trigger spec body update (Phase 3)
- Audit findings, verdicts, recommendations → `internal`
- Discussion responses, clarifications → `internal`
- Decision log entries → `internal`

On classification as `stakeholder`: write exec summary to `remote.md` via `texted_edit_file`, then `local-issues sync push N`. On classification as `internal`: append to `.issues/N/comments.md` via `local-issues comment N --body "..."`.

**Error handling:** If classification cannot be determined, default to `internal` (conservative — keep local rather than expose to remote).

### Phase 2: Routing enforcement (issue-operations dispatcher)

All `github_*` / `gitbucket-api` calls for issue operations MUST route through `issue-operations` tasks. Direct calls outside `issue-operations/platforms/` are a critical violation.

This absorbs the full scope of #571:

| Priority | Skill | Direct Calls | Migration Pattern |
|----------|-------|-------------|-------------------|
| P0 | `approval-gate` | 80+ | Replace all direct calls with `issue-operations` task dispatch |
| P1 | `git-workflow` | 15+ | Replace issue ops with dispatcher (PR ops stay direct) |
| P2 | `issue-review` | 20+ | Route through issue-operations |
| P3 | `adversarial-audit` | 12+ | Route through issue-operations |
| P4 | `writing-plans` | 6+ | Route through issue-operations |
| P5 | `spec-creation` | 5+ | Route through issue-operations |
| P6 | `brainstorming` | 3+ | Route through issue-operations |
| P7 | `pre-analysis` | 4+ | Route through issue-operations |
| P8 | `verification-before-completion` | 3+ | Route through issue-operations |
| P9 | Remaining skills (correspondence, divide-and-conquer, etc.) | 1-2 each | Route through issue-operations |

Each migrated call site gets a routing comment:
```markdown
# Routes through issue-operations per SPEC #683
```

**Critical rules** added to `000-critical-rules.md`:
- All issue operations (read, write, search, list, comment, label, sub-issue) MUST route through `issue-operations` dispatcher
- Agent MUST NOT deliberate about platform API selection — routing is the dispatcher's job
- Calling `github_issue_read/write/add_comment/search_issues/list_issues` directly (outside `issue-operations/` platform sub-skills) is a Tier 1 violation

**New issue-operations tasks** (from #571 Phase 2):
- `read-issue`, `read-comments`, `read-labels`, `read-sub-issues`, `list-issues`, `search-issues`, `update-issue`

### Phase 3: Spec body staleness fix

When a comment contains content that revises, corrects, or supersedes the spec body, the agent MUST update the spec body — not leave it stale and add another comment.

**Trigger:** After content classified as `stakeholder` (Phase 1), check: "Does this revise, correct, or supersede the spec body?"

**If yes:**
1. Update `.issues/N/spec.md` (canonical spec detail)
2. Update `.issues/N/remote.md` (exec summary)
3. `local-issues sync push N` (push to GitHub)
4. Post the explanatory comment as audit trail (contains "Spec body updated per #683 Phase 3 — see comment for details")

**If no:** Proceed with normal comment routing per Phase 1.

### Phase 4: Decision Log → .issues/ storage

**File:** `divide-and-conquer/tasks/assemble-work.md` Step 7

**Current behavior:** Posts `decision_log_entry` as a GitHub Issue comment on the Plan issue — this is the highest-risk pattern for internal reasoning leakage.

**New behavior:** Write `decision_log_entry` to `.issues/` local storage using `local-issues comment N --body "..."`. Do NOT post to GitHub.

The Decision Log is internal reasoning — it should never be on the remote tracker. Stakeholders get the exec summary from the deliverable artifact, not the reasoning trace.

### Phase 5: Skill card bypass sweep

Remediate the ~35-40 skill task files identified with direct `github_*` / `gitbucket-api` calls. Each file gets updated to route through `issue-operations` dispatcher per Phase 2 migration table.

Detailed file list per category:

**Comment posting (8 files)** — route through `issue-operations --task comment`:
- `completion-core/SKILL.md` (direct github_add_issue_comment)
- `completion-core/completion-core.md`
- `writing-plans/tasks/create/create-and-validate.md`
- `approval-gate/tasks/verify-authorization/spec-to-plan-cascade.md`
- `approval-gate/tasks/verify-already-implemented.md`
- `approval-gate/tasks/reconcile-issue-graph.md`
- `git-workflow/tasks/cleanup/issue-closure.md`
- `issue-review/tasks/analyze-and-spec.md`

**Issue creation (5 files)** — route through `issue-operations --task creation`:
- `sync-guidelines/tasks/sync-push.md`
- `sync-guidelines/tasks/sync-pull.md`
- `conflict-resolution/tasks/classify-and-resolve.md`
- `issue-review/tasks/analyze-and-spec.md`
- `approval-gate/tasks/verify-sub-issues.md`

**Body updates (2 files)** — route through `issue-operations body-edit` task (from #523):
- `sre-runbook/tasks/track.md`
- `verification-before-completion/tasks/completion.md`

**Sub-issue linking (2 files)** — route through `issue-operations --task link-sub-issue`:
- `issue-review/tasks/analyze-and-spec.md`
- `approval-gate/tasks/verify-sub-issues.md`

### Phase 6: Enforcement tests

| SC | Phase | Criterion | Verification |
|----|-------|-----------|-------------|
| SC-1 | 1 | comment.md has classification gate Step 1.5 (stakeholder vs internal) | Read file, verify Step 1.5 exists |
| SC-2 | 1 | stakeholder content routes to remote.md + sync push; internal routes to .issues/comments.md | grep for stakeholder route and internal route in comment.md |
| SC-3 | 1 | Default classification is `internal` when uncertain | grep for "default to internal" in comment.md |
| SC-4 | 2 | 000-critical-rules.md has Platform Routing Bypass critical violation section | grep for "Platform Routing Bypass" |
| SC-5 | 2 | 000-critical-rules.md has Platform API Deliberation Prohibited section | grep for "Platform API Deliberation Prohibited" |
| SC-6 | 2 | issue-operations tasks table includes 7 new read/query tasks | grep for all 7 task names in SKILL.md |
| SC-7 | 2 | All direct github_* calls outside issue-operations/ eliminated | grep -rn for direct calls outside issue-operations/ returns 0 |
| SC-8 | 3 | Spec body updated when comment revises spec | Behavioral test: post correction comment → verify spec.md and remote.md updated |
| SC-9 | 4 | Decision Log written to .issues/ not GitHub | grep assemble-work.md Step 7 — no github_add_issue_comment for decision log |
| SC-10 | 5 | All 35-40 identified files route through issue-operations | Per-file verification against Phase 5 list |
| SC-11 | 6 | Behavioral tests exist for classification gate, routing enforcement, decision log | ls *.sh in tests/behaviors/ |

## Superseded Issues

| Issue | Action | Rationale |
|-------|--------|-----------|
| **#571** | Close as superseded | Routing enforcement absorbed into Phase 2 |
| **#585** | Close as superseded | Phase tracking local-first + promotion gate absorbed into Phases 1 and `.issues/` mandate |
| **#60** | Close as not_planned | Track branch model superseded by #523 worktree approach |

## Dependencies

| Issue | Relationship | Status |
|-------|-------------|--------|
| **#523** | Strict prerequisite — `.issues/` worktree + remote.md/spec.md + sync push/pull | OPEN, needs-approval |
| **#586** | Transitive dependency — local-issues tool defects (#523 depends on #586) | Need to check status |

Phases are sequential: Phase 1 → 2 → 3 → 4 → 5 → 6.

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Classification gate slows down comment posting | Medium | Low | Classification is agent reasoning step — negligible latency |
| Agent incorrectly classifies internal as stakeholder | Medium | High | Conservative default (internal when uncertain); audit trail for misclassifications |
| #523 not yet implemented when this spec is approved | High | Critical | Strict prerequisite — do not implement until #523 lands |
| Migration of 35-40 files creates merge conflicts | Medium | Medium | Phase 5 is last; submodule branching strategy isolates changes |
| Existing remote comments create permanent split (pre-fix vs post-fix) | Certain | Low | Forward-only change. Old comments remain; new comments follow routing rules |

## Non-Requirements

- No changes to PR operations (PR creation/read/merge stay in git-workflow)
- No changes to `session-enforcement.ts` or git hooks
- No changes to `local-issues` tool infrastructure (that's #523's scope)
- No data migration of existing comments
- No changes to `.gitignore` or repository structure

## Out of Scope

- `.issues/` worktree setup and git isolation mechanism (spec #523)
- `local-issues` tool development and defect fixes (spec #586, needed by #523)
- Existing `.issues/` data migration (handled by #523 Item 6)
- PR platform routing (PRs remain in git-workflow per #571 N-04)
- Dark prose weaving into comment templates (separate concern per #635)

## Files Changed

| File | Phase | Action |
|------|-------|--------|
| `skills/issue-operations/tasks/comment.md` | 1 | Add classification gate Step 1.5 |
| `guidelines/000-critical-rules.md` | 2 | Add Platform Routing Bypass + Platform API Deliberation sections |
| `guidelines/060-tool-usage.md` | 2 | Add Platform Routing Mandate subsection |
| `skills/issue-operations/SKILL.md` | 2 | Add 7 new read/query tasks to task table |
| `skills/issue-operations/tasks/read-issue.md` | 2 | New task file |
| `skills/issue-operations/tasks/read-comments.md` | 2 | New task file |
| `skills/issue-operations/tasks/read-labels.md` | 2 | New task file |
| `skills/issue-operations/tasks/read-sub-issues.md` | 2 | New task file |
| `skills/issue-operations/tasks/list-issues.md` | 2 | New task file |
| `skills/issue-operations/tasks/search-issues.md` | 2 | New task file |
| `skills/issue-operations/tasks/update-issue.md` | 2 | New task file |
| `skills/divide-and-conquer/tasks/assemble-work.md` | 4 | Replace Step 7 GitHub comment with .issues/ storage |
| ~35-40 individual skill task files | 5 | Replace direct github_* calls with issue-operations dispatch |
| `tests/behaviors/content-classification-gate.sh` | 6 | New behavioral test |
| `tests/behaviors/platform-routing-enforcement.sh` | 6 | New behavioral test |
| `tests/behaviors/decision-log-local-first.sh` | 6 | New behavioral test |
| `tests/behaviors/spec-body-staleness-fix.sh` | 6 | New behavioral test |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
