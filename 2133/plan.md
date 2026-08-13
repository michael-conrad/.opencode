---
plan_schema_version: "1.0"
issue: 2133
title: "Compact 091-incremental-build.md — remove redundant cross-refs and dead reference"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
---

# Implementation Plan — #2133 — Compact 091-incremental-build.md

**Issue URL:** https://github.com/michael-conrad/.opencode/issues/2133

**Goal:** Remove the three semantic defects from `.opencode/guidelines/091-incremental-build.md` — the duplicated `000-critical-rules.md` cross-reference on the first cross-ref line, the duplicated "tested verified correct code operations" paragraph, and the dead "Symbolic rules below" line — without restructuring, rewording, or expanding scope.

**Architecture:** Three strictly sequential phases, each removing exactly one defective line from the single target file. Each phase maps 1:1 to one SC and one item with its own RED → GREEN → verify → commit cycle. All three SCs are string evidence type, statically testable via grep. No runtime behavior changes; no interface boundary is broken. The phase DAG (1 → 2 → 3) is acyclic and Z3-SAT validated (`solve-output.yaml` — `check_status: SAT`, plan length 3).

**Files:**
- `.opencode/guidelines/091-incremental-build.md` — remove the three defective lines

**Dispatch:** `test-driven-development` (red/green per-item cycles), `verification-before-completion` (verify), `audit` (post-implementation), `finishing-a-development-branch` (structural checks), `git-workflow-pr` (review-prep, create-pr), `completion-core` (exec-summary)

---

## Blast Radius

| File | Revision | Impact Zone |
|------|----------|-------------|
| `.opencode/guidelines/091-incremental-build.md` | three lines removed | Single guideline consumed by AI agents at session load (`tier: 1`, `load_when: sub-agent`) |

No application module or executable code path is affected. The canonical copy of the "tested verified correct code operations" paragraph lives in `.opencode/guidelines/020-go-prohibitions.md` §1.1 and is untouched by this plan.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete. SC-1 through SC-3 are string checks verified by grep. A behavioral test is not applicable — the change is a static content removal with no runtime behavior.

---

## Pre-Implementation Steps

- [ ] 1. **Coherence gate (**inline**).** Verify the plan is coherent with the spec: every SC (SC-1, SC-2, SC-3) maps to exactly one item, no item covers multiple SCs, the phase DAG (Phase 1 → Phase 2 → Phase 3) is acyclic and Z3-SAT validated (`solve-output.yaml` — `check_status: SAT`, plan length 3), and no superseding/stale spec exists. If any check fails, HALT and report.
- [ ] 2. **Baseline check (**sub-agent**).** Verify the working tree is at trunk tip with zero pending changes. Confirm the target file `.opencode/guidelines/091-incremental-build.md` exists and confirm the current defect lines are present: the duplicated `000-critical-rules.md` cross-reference on the first cross-ref line, the "tested verified correct code operations" paragraph, and the "Symbolic rules below" line. If any check fails, HALT and report.

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Deduplicate first cross-ref line | `test-driven-development` | `red` | `.opencode/guidelines/091-incremental-build.md` | SC-1 | — |
| 2 — Remove paragraph after Anti-Patterns list | `test-driven-development` | `red` | `.opencode/guidelines/091-incremental-build.md` | SC-2 | 1 |
| 3 — Remove symbolic rules below line | `test-driven-development` | `red` | `.opencode/guidelines/091-incremental-build.md` | SC-3 | 2 |

---

## Phase Details

### Phase 1 — Deduplicate First Cross-Ref Line

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/guidelines/091-incremental-build.md` first cross-ref line |
| SCs | SC-1 |
| Depends On | — |

**Context:**
- files_to_modify: `.opencode/guidelines/091-incremental-build.md` (first cross-ref line in the opening paragraph)
- sc_ids: SC-1
- evidence_type: string
- behavior: the first cross-ref line contains `000-critical-rules.md` twice; remove the first instance, keep one
- constraints: no restructuring, no rewording of surrounding text; the `tests-v2/behaviors/tier1-mandate-enforcement.sh` reference on the same line is preserved

**Cost frame:** Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric. Verifying the cross-ref count costs one grep search; skipping means the duplicated cross-ref ships and the next reader follows a redundant reference.

### Phase 2 — Remove Paragraph After Anti-Patterns List

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/guidelines/091-incremental-build.md` paragraph after Anti-Patterns list |
| SCs | SC-2 |
| Depends On | 1 |

**Context:**
- files_to_modify: `.opencode/guidelines/091-incremental-build.md` (paragraph after Anti-Patterns list)
- sc_ids: SC-2
- evidence_type: string
- behavior: remove the "Implementation work is measured ONLY by whether tested verified correct code operations pass..." paragraph; the canonical copy remains in `.opencode/guidelines/020-go-prohibitions.md` §1.1
- constraints: no restructuring, no rewording of surrounding text; `020-go-prohibitions.md` is untouched

**Cost frame:** Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric. Verifying the paragraph's absence costs one grep search; skipping means the duplicated paragraph ships and the drift risk between `091-incremental-build.md` and `020-go-prohibitions.md` persists.

### Phase 3 — Remove Symbolic Rules Below Line

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/guidelines/091-incremental-build.md` symbolic rules below line |
| SCs | SC-3 |
| Depends On | 2 |

**Context:**
- files_to_modify: `.opencode/guidelines/091-incremental-build.md` (symbolic rules below line)
- sc_ids: SC-3
- evidence_type: string
- behavior: remove the "Symbolic rules below — the prose above this line replaces the previous ~200 lines of advisory text" line
- constraints: no restructuring, no rewording of surrounding text

**Cost frame:** Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric. Verifying the dead reference's absence costs one grep search; skipping means the dead reference ships and the next reader follows a stale pointer.

---

## Exit Criteria

- [ ] C1. The first cross-ref line in `.opencode/guidelines/091-incremental-build.md` contains exactly one reference to `000-critical-rules.md` (SC-1).
- [ ] C2. The paragraph beginning "Implementation work is measured ONLY by whether tested verified correct code operations pass..." is absent from `.opencode/guidelines/091-incremental-build.md` (SC-2).
- [ ] C3. The line "Symbolic rules below — the prose above this line replaces the previous ~200 lines of advisory text" is absent from `.opencode/guidelines/091-incremental-build.md` (SC-3).
- [ ] C4. All three SCs map to exactly one item each; no item covers multiple SCs; the phase DAG (1 → 2 → 3) is acyclic and Z3-SAT validated.

---

## Post-Implementation Steps

- [ ] 3. **Structural checks (**sub-agent**).** Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Run lint, typecheck, and markdown format checks on the modified file.
- [ ] 4. **Verification (**clean-room**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify all 3 SCs against their declared string evidence types. Any FAIL blocks completion.
- [ ] 5. **Audit (**clean-room**).** Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence. Adversarial audit of the deliverable.
- [ ] 6. **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` to verify phase state transitions.
- [ ] 7. **Pre-PR gate (**clean-room**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Reads all SC verdicts, BLOCKs if any FAIL.
- [ ] 8. **Regression check (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Final regression check before PR.
- [ ] 9. **Review-prep (**sub-agent**).** Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. Prepare PR review context.
- [ ] 10. **Create PR (**sub-agent**).** Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`. Create the pull request.
- [ ] 11. **Exec summary (**sub-agent**).** Dispatch `task(..., prompt: "execute completion task from completion-core")`. Generate completion executive summary.
