---
plan_schema_version: "1.0"
issue: 2257
title: "Fix GitBucket label operation documentation via local test instance validation"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
---

# Implementation Plan — #2257 — Fix GitBucket Label Operation Documentation

**Goal:** Empirically determine the actual GitBucket label-operation workflow against a live local instance, then correct the four `gitbucket-api` skill-card files to the verified truth.

**Architecture:** Two-phase, dependency-sequenced plan. Phase 1 establishes empirical ground truth via the sanctioned GitBucket harness (`__ensure_gitbucket`) — behavioral probes of issue-level label mutation and repo-level label CRUD, synthesized into a capability split (SC-1..4). Phase 2 propagates that verified truth into the four documentation files (`label-operations.md`, `SKILL.md` manifest, `issue-operations.md`, `mcp-operations.md`) with deterministic grep assertions (SC-5..7). Phase 2 strictly follows Phase 1 because its grep assertions depend on the verified capability split.

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (harness reuse — read only)
- `.opencode/tests-v2/behaviors/<new behavioral test script>` (new probe script)
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/label-operations.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/issue-operations.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/mcp-operations.md`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — empirical probes | `test-driven-development` | `red` / `green` | `.opencode/tests-v2/behaviors/<probe script>` + helpers.sh | SC-1, SC-2, SC-3, SC-4 | — |
| 2 — documentation edits | `test-driven-development` | `red` / `green` | `label-operations.md`, `SKILL.md`, `issue-operations.md`, `mcp-operations.md` | SC-5, SC-6, SC-7 | 1 |

---

## Phase Details

### Phase 1 — Empirical Probes

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` / `green` / `verify` |
| Target | `.opencode/tests-v2/behaviors/<new behavioral test script>` (uses `__ensure_gitbucket`) |
| SCs | SC-1, SC-2, SC-3, SC-4 |
| Depends On | — |

**Context:**
```yaml
harness: ".opencode/tests-v2/behaviors/helpers.sh"
harness_function: "__ensure_gitbucket"
harness_flag: "BEHAVIOR_NEEDS_REMOTE=1"
gb_cli_version: "v0.6.1"
behavioral_runner: "bash .opencode/tests-v2/with-test-home opencode run ..."
bash_timeout_ms: 600000
issue_level_endpoint: "/repos/{owner}/{repo}/issues/{number}/labels"
repo_level_commands:
  - "gb label list"
  - "gb label create"
  - "gb label view"
  - "gb label edit"
  - "gb label delete"
sc_ids: [SC-1, SC-2, SC-3, SC-4]
```

### Phase 2 — Documentation Edits

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` / `green` / `verify` |
| Target | `label-operations.md`, `SKILL.md`, `issue-operations.md`, `mcp-operations.md` |
| SCs | SC-5, SC-6, SC-7 |
| Depends On | 1 |

**Context:**
```yaml
files_to_modify:
  - ".opencode/skills/issue-operations/platforms/gitbucket-api/tasks/label-operations.md"
  - ".opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md"
  - ".opencode/skills/issue-operations/platforms/gitbucket-api/tasks/issue-operations.md"
  - ".opencode/skills/issue-operations/platforms/gitbucket-api/tasks/mcp-operations.md"
verified_truth_source: "Phase 1 SC-4 capability split"
sc_ids: [SC-5, SC-6, SC-7]
```

---

## Pre-Implementation (Global — once)

- [ ] 1. **Coherence gate (**clean-room**).** Confirm all 7 SCs from the spec are mapped to exactly one phase, the phase DAG has no cycles, and Phase 2 depends only on Phase 1.
- [ ] 2. **Baseline check (**inline**).** Verify the current working state: `gb` CLI v0.6.1 present, the four target skill-card files exist with the documented-BROKEN status, and `.opencode` submodule is on trunk.

---

## Phase Files

Detailed step-by-step execution for each phase is in the split phase files:

- [`plan-01-empirical-probes.md`](plan-01-empirical-probes.md) — Phase 1, SC-1..4
- [`plan-02-documentation-edits.md`](plan-02-documentation-edits.md) — Phase 2, SC-5..7

---

## Exit Criteria

- [ ] C1. SC-1: `__ensure_gitbucket` provisions a reachable, authenticated GitBucket instance with a test repository (behavioral PASS)
- [ ] C2. SC-2: Issue-level label mutation empirically determined WORKING or BROKEN with `get_issue` readback evidence (behavioral PASS)
- [ ] C3. SC-3: Repo-level label CRUD confirmed WORKING against the instance (behavioral PASS)
- [ ] C4. SC-4: Correct issue-level vs repo-level capability split synthesized from SC-2 + SC-3 (structural PASS)
- [ ] C5. SC-5: `label-operations.md` updated to verified workflow, false BROKEN claims removed (string PASS)
- [ ] C6. SC-6: `SKILL.md` capability manifest "Post-creation labels" row corrected to verified workflow (string PASS)
- [ ] C7. SC-7: Downstream references in `issue-operations.md` and `mcp-operations.md` corrected (string PASS)
- [ ] C8. All 7 SCs PASS before PR creation; any single FAIL blocks advancement (SC Enforcement Gate)

---

## Post-Implementation (Global — once)

- [ ] **Structural checks (**sub-agent**).** Run `execute checklist task from finishing-a-development-branch` (lint/typecheck/format on any changed files).
- [ ] **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` against `dependency-contract.yaml` to confirm Phase 2 only activates when Phase 1 is complete.
- [ ] **Pre-PR gate (**sub-agent**).** Run `execute verify task from verification-before-completion` reading all 7 SC verdicts; BLOCK if any FAIL.
- [ ] **Regression check (**sub-agent**).** Run `execute phase-4 task from test-driven-development` final regression before PR.
- [ ] **Audit (**sub-agent**).** Run `execute verification-audit DiMo investigator from audit` (then validator, evaluator, arbiter) for adversarial audit of the deliverable.
- [ ] **Review-prep (**sub-agent**).** Run `execute review-prep from git-workflow-pr`.
- [ ] **Create PR (**sub-agent**).** Run `execute create task from git-workflow-pr`; include the `.opencode` submodule pointer update alongside the change.
- [ ] **Exec summary (**sub-agent**).** Run `execute completion task from completion-core`.

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-08T16:19:43Z | `plan_created` | Plan file: `.opencode/.issues/2257/plan.md`; phase count: 2
