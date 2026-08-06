---
plan_schema_version: "1.0"
issue: 2241
title: "Authorization tracking: local issue.yaml is canonical source, not remote API labels"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 7
dispatch:
  - phase_1: test-driven-development:red
  - phase_2: test-driven-development:red
  - phase_3: test-driven-development:red
  - phase_4: test-driven-development:red
  - phase_5: test-driven-development:red
  - phase_6: test-driven-development:red
  - phase_7: test-driven-development:red
  - post: finishing-a-development-branch:checklist
  - post: audit:verification-audit
  - post: git-workflow-pr:review-prep
  - post: git-workflow-pr:create
  - post: completion-core:completion
---

# Implementation Plan — #2241 — Local issue.yaml as Canonical Authorization Source

**Issue:** https://github.com/michael-conrad/.opencode/issues/2241

**Goal:** Establish local `{issues_prefix}/{N}/issue.yaml` as the canonical source for all authorization labels, eliminate remote API label dependency and comment-scanning for authorization, and update the approval-gate guideline to document the new canonical source.

**Architecture:** All label-writing task files write authorization labels to local `issue.yaml` as primary canonical source with remote API best-effort/secondary. All label-reading task files read from local `issue.yaml` by default with remote fallback only when explicitly requested. The "No Metadata Trust" doctrine, cargo-cult remote auth references in list/search, all comment-scanning for authorization, and the dead `push-body.md` are removed. The approval-gate guideline documents local `issue.yaml` as the certifying source.

**Files:** (sub-folder references)
- `.opencode/skills/approval-gate/` — `tasks/apply-label.md`, `tasks/resolve-scope.md`, `SKILL.md`
- `.opencode/skills/issue-operations-core/tasks/` — `creation.md`, `completion.md`, `read-labels.md`, `list-issues.md`, `search-issues.md`, `read-issue.md`, `post-creation.md`
- `.opencode/skills/issue-operations/platforms/` — `gitbucket-api/SKILL.md`, `local/tasks/push-body.md` (deleted)
- `.opencode/skills/spec-creation/tasks/create.md`
- `.opencode/skills/issue-review/tasks/` — `analyze-and-spec.md`, `gather.md`
- `.opencode/skills/writing-plans/tasks/` — `handoff.md`, `create.md`
- `.opencode/skills/audit/tasks/drift-detection-investigator.md`
- `.opencode/skills/verification-before-completion/tasks/operating-protocol.md`
- `.opencode/skills/brainstorming/tasks/enforcement.md`
- `.opencode/skills/gh-cli/tasks/triage-issues.md`
- `.opencode/guidelines/` — `010-approval-gate.md`, `067-context-completeness.md`, `257-procedural-discipline-reference.md`

---

## Compliance

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

## One-Step-at-a-Time

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

## Step Status

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

## Enforcement Gate

> **Enforcement gate:** All SCs must pass before this plan is complete. Partial implementation is not permitted.

## Self-Remediation Protocol

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

---

## Blast Radius

| Zone | Impact | Files |
|------|--------|-------|
| High (medium risk) | 11 label read/write task files — canonical source switch affects authorization decisions across the pipeline | apply-label, creation, completion, spec-creation/create, analyze-and-spec, writing-plans/create, handoff, read-labels, gather, drift-detection-investigator, operating-protocol |
| Low | Cargo-cult and doctrine text removals — string-only | list-issues, search-issues, read-issue, operating-protocol |
| Low | Comment-scanning removals — eliminates fragile auth fallback | drift-detection-investigator, gather, enforcement, post-creation, resolve-scope, approval-gate/SKILL, triage-issues, 067, 257, gitbucket-api/SKILL |
| Low | Dead file deletion — no consumers | push-body.md |
| Low | Guideline update — documentation clarity only | 010-approval-gate.md |

**Unchanged downstreams:** `local-issues` tool (only calling task files change), all `*-core`/`issue-operations*`/`writing-plans`/`spec-creation`/`brainstorming`/`audit`/`verification-before-completion` SKILL.md cards, `writing-plans/tasks/analyze.md` reference pattern.

---

## Phase Table

| Phase | Name | Skill | Task | Target | SCs | Depends On | Step Range |
|-------|------|-------|------|--------|-----|-----------|------------|
| 1 | Local-first label writes | `test-driven-development` | `red` | 6 label-write task files | SC-2, SC-3, SC-4, SC-6, SC-7, SC-8 | — | 3–27 |
| 2 | Local-first label reads | `test-driven-development` | `red` | 5 label-read task files | SC-1, SC-9, SC-12, SC-13, SC-14 | 1 | 28–48 |
| 3 | Remove cargo-cult remote auth | `test-driven-development` | `red` | `list-issues.md`, `search-issues.md` | SC-10, SC-11 | — | 49–57 |
| 4 | Remove No Metadata Trust doctrine | `test-driven-development` | `red` | `read-issue.md`, `operating-protocol.md` | SC-16, SC-17 | 2 | 58–66 |
| 5 | Remove comment-scanning for authorization | `test-driven-development` | `red` | 10 files (SC-15…SC-26) | SC-15, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26 | 2 | 67–107 |
| 6 | Delete dead `push-body.md` | `test-driven-development` | `red` | `push-body.md` (deleted) | SC-27 | — | 108–112 |
| 7 | Update approval-gate guideline | `test-driven-development` | `red` | `010-approval-gate.md` | SC-5 | 1, 2 | 113–117 |

---

## Phase Details

### Phase 1 — Local-first label writes

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | apply-label.md, creation.md, completion.md, spec-creation/create.md, analyze-and-spec.md, writing-plans/create.md |
| SCs | SC-2, SC-3, SC-4, SC-6, SC-7, SC-8 |
| Depends On | — |

**Context:** All six label-writing task files switch their primary write target from remote API to local `{issues_prefix}/{N}/issue.yaml` via the `local-issues update --labels` subcommand. Remote writes become best-effort/secondary and never block the pipeline. Reference pattern for local write: `local-issues update --number {N} --labels`.

### Phase 2 — Local-first label reads

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | handoff.md, read-labels.md, gather.md, drift-detection-investigator.md, operating-protocol.md |
| SCs | SC-1, SC-9, SC-12, SC-13, SC-14 |
| Depends On | 1 |

**Context:** All five label-reading task files switch their default read source from remote API to local `{issues_prefix}/{N}/issue.yaml` via the `local-issues read-labels` subcommand. Remote reads only occur as fallback or when explicitly requested. Reference pattern for local read: `writing-plans/tasks/analyze.md` (reads auth from local issue.yaml labels field).

### Phase 3 — Remove cargo-cult remote auth from list/search

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | list-issues.md, search-issues.md |
| SCs | SC-10, SC-11 |
| Depends On | — |

**Context:** Remove the "Authorization scope label verification" use case from `list-issues.md` and the "Authorization scope label search" use case from `search-issues.md`.

### Phase 4 — Remove No Metadata Trust doctrine

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | read-issue.md, operating-protocol.md |
| SCs | SC-16, SC-17 |
| Depends On | 2 |

**Context:** Remove the entire "No Metadata Trust Exceptions" section from `read-issue.md` and `operating-protocol.md`. The doctrine was a workaround for unreliable remote labels; local issue.yaml is now the certifying source.

### Phase 5 — Remove comment-scanning for authorization

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | drift-detection-investigator.md, gather.md, enforcement.md, post-creation.md, resolve-scope.md, approval-gate/SKILL.md, triage-issues.md, 067-context-completeness.md, 257-procedural-discipline-reference.md, gitbucket-api/SKILL.md |
| SCs | SC-15, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26 |
| Depends On | 2 |

**Context:** Eliminate all scanning of issue comments for authorization tokens across the listed task files, skill cards, and guidelines. Authorization is parsed from chat messages only (verb-prefix table), never from comments. Shared-file sequencing: gather.md (SC-12/SC-18), drift-detection-investigator.md (SC-13/SC-15), operating-protocol.md (SC-14/SC-17) were edited in Phase 2; this phase's edits follow to avoid same-file edit conflicts.

### Phase 6 — Delete dead `push-body.md`

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `issue-operations/platforms/local/tasks/push-body.md` (deleted) |
| SCs | SC-27 |
| Depends On | — |

**Context:** Delete `.opencode/skills/issue-operations/platforms/local/tasks/push-body.md` — a dead file describing a non-existent sync operation. No consumers.

### Phase 7 — Update approval-gate guideline

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `guidelines/010-approval-gate.md` |
| SCs | SC-5 |
| Depends On | 1, 2 |

**Context:** Update `guidelines/010-approval-gate.md` to clarify that canonical authorization state is in local `{issues_prefix}/{N}/issue.yaml`; remote labels are advisory/display only. Sequenced after the local-first write (Phase 1) and read (Phase 2) primaries are established.

---

## Pre-Implementation (Tier 1 Global)

- [ ] 1. **Coherence gate (**clean-room**).** Verify the spec and plan are coherent and the phase DAG is acyclic before any implementation begins. **→ All SCs**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - Confirm the 7 analytical artifacts exist and match the current spec body
- [ ] 2. **Baseline check (**clean-room**).** Verify the feature branch is at `$DEFAULT_BRANCH` tip, zero pending changes, and the `.opencode` submodule pointer is clean. **→ All SCs**
  - Dispatch via `skill({name: "git-workflow"})` → `task("execute pre-work from git-workflow-branch")`

## Post-Implementation (Tier 1 Global)

- [ ] 118. **Structural checks (**sub-agent**).** Run the finishing checklist (lint, typecheck, format) across all modified files. **→ All SCs**
  - Dispatch via `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
- [ ] 119. **Regression check (**sub-agent**).** Run final regression tests after all phases complete. **→ All SCs**
  - Dispatch via `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-regression-check-*` before running
- [ ] 120. **Audit (**clean-room**).** Adversarial audit of the complete deliverable against all 27 SCs. **→ All SCs**
  - Dispatch via `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` followed by validator, evaluator, arbiter in sequence
  - Clean up `tmp/2241/artifacts/pipeline-audit-*` before running
- [ ] 121. **Z3 check (**inline**).** Run the Z3 constraint solver to verify the completed phase state satisfies the dependency contract. **→ All SCs**
  - Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path .opencode/.issues/2241/dependency-contract.yaml` directly
  - Clean up `tmp/2241/artifacts/pipeline-z3-check-*` before running
- [ ] 122. **Pre-PR gate (**clean-room**).** Read all SC verdicts; BLOCK if any verdict is FAIL or coerced to FAIL. **→ All SCs**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - Clean up `tmp/2241/artifacts/pipeline-pre-pr-gate-*` before running
- [ ] 123. **Review prep (**sub-agent**).** Prepare the PR review context with a summary of all changes and SC evidence. **→ All SCs**
  - Dispatch via `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
- [ ] 124. **Create PR (**sub-agent**).** Create the pull request for the `.opencode` submodule branch. **→ All SCs**
  - Dispatch via `task(..., prompt: "execute create task from git-workflow-pr")`
  - HALT after PR creation — the developer merges; do not merge
- [ ] 125. **Executive summary (**sub-agent**).** Generate the completion executive summary and append the lifecycle event. **→ All SCs**
  - Dispatch via `task(..., prompt: "execute completion task from completion-core")`

## Exit Criteria

- [ ] C1. All label-writing task files (apply-label, creation, spec-creation/create, analyze-and-spec, writing-plans/create) write to local `issue.yaml` as primary canonical source with remote best-effort/secondary. **SC-2, SC-3, SC-6, SC-7, SC-8**
- [ ] C2. `completion.md` reads `needs-approval` from local `issue.yaml`; remote write best-effort. **SC-4**
- [ ] C3. All label-reading task files (handoff, read-labels, gather, drift-detection-investigator, operating-protocol) read from local `issue.yaml` by default with remote fallback only. **SC-1, SC-9, SC-12, SC-13, SC-14**
- [ ] C4. `list-issues.md` and `search-issues.md` contain no "Authorization scope label" use case. **SC-10, SC-11**
- [ ] C5. `read-issue.md` and `operating-protocol.md` contain no "No Metadata Trust" section. **SC-16, SC-17**
- [ ] C6. No task file, skill card, or guideline scans comments for "approved"/"go" or notes authorization in comments. **SC-15, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26**
- [ ] C7. `push-body.md` no longer exists at `issue-operations/platforms/local/tasks/`. **SC-27**
- [ ] C8. `010-approval-gate.md` clarifies canonical auth is local `issue.yaml`; remote labels advisory. **SC-5**
- [ ] C9. All SCs verified; no verification FAIL; phase DAG acyclic; Z3 SAT. **All SCs**
