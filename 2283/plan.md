---
plan_schema_version: "1.0"
issue: 2283
title: "Remove branch-finishing sub-issue creation mandate; protect PR autoclose and plan content confidentiality"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
dispatch:
  - phase: 1
    skill: test-driven-development
    task: red
  - phase: 2
    skill: test-driven-development
    task: red
  - phase: 3
    skill: test-driven-development
    task: red
---

# Implementation Plan — #2283 — Remove Branch-Finishing Sub-Issue Creation Mandate

> Issue: https://github.com/michael-conrad/.opencode/issues/2283

**Goal:** Eliminate the branch-finishing checklist's unconditional plan-phase sub-issue creation mandate, remove the sub-issue closure readiness gates, add a behavioral test proving zero sub-issue creation at finishing time, prevent PR-merge autoclose from sweeping plan-phase sub-issues, and stop posting plan phase prose to public issue bodies.

**Architecture:** Three-phase sequential change across four skill/task files and the behavioral test harness. Phase 1 (SC-1, SC-2) rewrites the Sub-Issue Linkage Verification gate in `checklist.md` into a no-create rule and removes the sub-issue closure readiness gates from `operating-protocol.md`. Phase 2 (SC-3) adds a behavioral enforcement test that proves an agent running the modified checklist on a fully-implemented multi-phase plan creates zero sub-issues — it depends on Phase 1 because it exercises the SC-1-modified checklist. Phase 3 (SC-4, SC-5) gates the PR-merge autoclose sweep in `create-pr.md` so plan-phase sub-issues are never auto-closed, and removes plan phase prose composition from `link-sub-issue.md` so plan content never reaches public issue bodies. The phase DAG (1 → 2 → 3) is acyclic and Z3-SAT validated. Each SC maps to exactly one item; no item covers multiple SCs.

**Files (sub-folder references):**
- `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`
- `.opencode/skills/finishing-a-development-branch/tasks/operating-protocol.md`
- `.opencode/tests-v2/behaviors/` (new scenario script + `session.yaml` artifacts)
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md`
- `.opencode/skills/issue-operations-sub-issues/tasks/link-sub-issue.md`

---

## Pre-Implementation Steps

These steps run once before any phase begins.

- [ ] **P1. Coherence gate (**clean-room**).** Verify the plan is coherent with the spec: every SC (SC-1, SC-2, SC-3, SC-4, SC-5) is mapped to exactly one item, no item covers multiple SCs, the phase DAG (Phase 1 → Phase 2 → Phase 3) is acyclic and Z3-SAT validated, and no superseding/stale spec exists. **→ all SCs**
- [ ] **P2. Baseline check (**sub-agent**).** Verify the working tree is at trunk tip with zero pending changes and no stale `tmp/.behavior-run.lock`. Confirm the target files exist (`finishing-a-development-branch/tasks/checklist.md`, `finishing-a-development-branch/tasks/operating-protocol.md`, `git-workflow-pr/tasks/pr-creation/create-pr.md`, `issue-operations-sub-issues/tasks/link-sub-issue.md`, `tests-v2/with-test-home`) and confirm the current defect lines: `checklist.md` Sub-Issue Linkage Verification section (link-sub-issue creation mandate), `operating-protocol.md` sub-issue closure readiness gates, `create-pr.md` `autoclose_issues` sub-issue sweep, `link-sub-issue.md` plan prose body composition. **→ all SCs**

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Branch-finishing gate removal | `test-driven-development` | `red` | `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`, `operating-protocol.md` | SC-1, SC-2 | — |
| 2 — Behavioral enforcement | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/2283-sc3-no-subissue-creation.sh` (new) | SC-3 | 1 |
| 3 — PR autoclose + plan-content protection | `test-driven-development` | `red` | `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md`, `.opencode/skills/issue-operations-sub-issues/tasks/link-sub-issue.md` | SC-4, SC-5 | 2 |

---

## Phase Details

### Phase 1 — Branch-Finishing Gate Removal

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`, `.opencode/skills/finishing-a-development-branch/tasks/operating-protocol.md` |
| SCs | SC-1, SC-2 |
| Depends On | — |

**Context:**
- files_to_modify: `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` (Sub-Issue Linkage Verification section), `.opencode/skills/finishing-a-development-branch/tasks/operating-protocol.md` (item 6 readiness gate + exit criteria)
- sc_ids: SC-1, SC-2
- behavior: branch finishing NEVER creates plan-phase sub-issues; existing sub-issues are read-only references; sub-issue closure verification is NOT a readiness gate
- constraints: other checklist gates and readiness checks (commit verification, VbC, audit) preserved

**Cost frame:** Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric. Verifying the gate removal costs one grep per file; skipping means the unconditional link-sub-issue mandate persists and the next branch-finishing run floods the public tracker with retrospective tickets.

### Phase 2 — Behavioral Enforcement

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/` (new scenario script + `session.yaml` evaluation) |
| SCs | SC-3 |
| Depends On | 1 |

**Context:**
- files_to_modify: `.opencode/tests-v2/behaviors/2283-sc3-no-subissue-creation.sh` (new artifact-only generator)
- sc_ids: SC-3
- evidence_type: behavioral
- scenario: agent running the branch-finishing checklist on a fully-implemented multi-phase plan creates zero sub-issues — clean-room `session.yaml` stderr confirms zero `link-sub-issue` / sub-issue creation calls
- harness_constraints: run via `bash .opencode/tests-v2/with-test-home opencode run '<prompt>'`; bash-tool timeout >= 600000ms (600s); `session.yaml` is PRIMARY evaluation source; no GNU timeout in scripts

**Cost frame:** Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric. Running the behavioral test costs minutes of execution time; skipping means a regression that reintroduces retrospective sub-issue creation ships undetected.

### Phase 3 — PR Autoclose + Plan-Content Protection

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md`, `.opencode/skills/issue-operations-sub-issues/tasks/link-sub-issue.md` |
| SCs | SC-4, SC-5 |
| Depends On | 2 |

**Context:**
- files_to_modify: `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` (`autoclose_issues` collection), `.opencode/skills/issue-operations-sub-issues/tasks/link-sub-issue.md` (sub-issue body composition)
- sc_ids: SC-4, SC-5
- behavior: PR-merge autoclose excludes plan-phase sub-issues (parent autoclose preserved); sub-issue bodies are metadata-only — plan phase prose (Field/Value tables, Context YAML blocks, Procedure steps) is never posted to public issue bodies
- constraints: issue-operations-sub-issues API capability and the multi-task authorization cascade model remain unchanged (out of scope)

**Cost frame:** Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric. Verifying the autoclose gate and body composition costs one grep per file; skipping means legitimate tracking sub-issues are silently closed on PR merge and plan content keeps leaking to the public tracker.

---

## Exit Criteria

- [ ] C1. The Sub-Issue Linkage Verification section in `finishing-a-development-branch/tasks/checklist.md` is removed or rewritten so it NEVER instructs creating sub-issues for plan phases at branch-finishing time (SC-1).
- [ ] C2. `finishing-a-development-branch/tasks/operating-protocol.md` no longer requires "Plan sub-issue closure verification" or "Plan sub-issues verified" as a readiness gate (SC-2).
- [ ] C3. A behavioral enforcement test verifies an agent running the branch-finishing checklist on a fully-implemented multi-phase plan creates zero sub-issues (SC-3).
- [ ] C4. `git-workflow-pr/tasks/pr-creation/create-pr.md` does not auto-close plan-phase sub-issues on PR merge; parent autoclose preserved (SC-4).
- [ ] C5. Plan content (phase tables, context YAML, procedure steps) is not posted to public issue bodies; plan files live only in the local `.issues/{N}/` spec folder (SC-5).
- [ ] C6. All five SCs map to exactly one item each; no item covers multiple SCs; the phase DAG (1 → 2 → 3) is acyclic and Z3-SAT validated.
