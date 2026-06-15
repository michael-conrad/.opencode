---
number: 1213
title: "[PLAN] Workstream E — skildeck dispatch table validation linter"
status: draft
parent_spec: 1208
created: 2026-06-15
---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Plan: Workstream E — skildeck Dispatch Table + Contract Schema Linter

**Spec:** #1213
**Authorization scope:** `for_plan` | `halt_at: plan_created` | `pr_strategy: none`
**Type:** Separate (single-phase, single concern)

## Summary

Add dispatch table validation to the skildeck `validate` command. Checks: presence of `## Trigger Dispatch Table` heading, column correctness (4 required columns), non-empty rows. Output: PASS / MISSING_DISPATCH_TABLE / INVALID_DISPATCH_TABLE_COLUMNS / EMPTY_DISPATCH_TABLE.

**SCs covered:**
| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-E1 | skildeck validate checks dispatch table presence in SKILL.md | behavioral |
| SC-E2 | skildeck validate reports MISSING_DISPATCH_TABLE for SKILL.md without a dispatch table | behavioral |
| SC-E3 | skildeck validate checks column correctness in found dispatch tables | behavioral |
| SC-E4 | skildeck validate exits non-zero when at least one SKILL.md fails validation | behavioral |

**Affected file:** `.opencode/tools/skildeck`

---

## Pre-Work (before pipeline)

1. Create feature branch from dev: `feature/1213-workstream-e-skildeck`
2. Tag `.opencode` submodule: `.opencode/checkpoint/1213/pre`
3. Initialize pipeline state: `solve state init ./tmp/1213/state/`
4. Set initial state: `solve state update ./tmp/1213/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml --var-name previous_step --var-value init --var-name current_step --var-value sc-coherence-gate --var-name pipeline_state --var-value running`

## RED Assertions

- **SC-E1 RED:** `skildeck validate .opencode/skills/approval-gate/SKILL.md` — should NOT report presence check (feature doesn't exist yet)
- **SC-E2 RED:** `skildeck validate .opencode/skills/approval-gate/SKILL.md` — should NOT report MISSING_DISPATCH_TABLE
- **SC-E3 RED:** `skildeck validate` on a SKILL.md with incomplete columns — should not detect column issues
- **SC-E4 RED:** `skildeck validate --all` — should exit 0 even with dispatch-table issues (no validation yet)

## Verification Methods

- **SC-E1 (behavioral):** `opencode-cli run` with prompt that triggers dispatch table routing → verify skildeck validates presence
- **SC-E2 (behavioral):** Run `skildeck validate` on a test SKILL.md without dispatch table → expect exit code matching error, MISSING_DISPATCH_TABLE in output
- **SC-E3 (behavioral):** Run `skildeck validate` on a test SKILL.md with incomplete columns → expect INVALID_DISPATCH_TABLE_COLUMNS in output
- **SC-E4 (behavioral):** Run `skildeck validate --all` with at least one failing SKILL.md → expect exit non-zero

---

## Phase 1: Dispatch Table Validation in skildeck

**Concern:** Add dispatch table validation logic to the skildeck CLI tool (SC-E1 through SC-E4).

**Files:**
- `.opencode/tools/skildeck` — add validation pass in validate command

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"task":"verify SC-E1 through SC-E4 are coherent with skildeck source — confirm skildeck is a Python CLI, check its validate command structure, report any spec gaps"}` | SC-E1, SC-E2, SC-E3, SC-E4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"task":"capture baseline: run skildeck validate on a test SKILL.md — verify it completes without dispatch-table errors; write baseline to tmp/1213/baseline.json"}` | SC-E1, SC-E2, SC-E3, SC-E4 |
| G3: red-phase | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"remediation":true,"task":"write RED enforcement tests: (1) skildeck validate on SKILL.md without dispatch table → should NOT report MISSING_DISPATCH_TABLE (feature doesn't exist), (2) grep skildeck for 'MISSING_DISPATCH_TABLE' → expect 0 matches; tests MUST fail before implementation"}` | SC-E1, SC-E2 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"task":"verify RED tests actually fail: run each RED assertion, confirm expected-failure output; log results to tmp/1213/red-verified.json"}` | SC-E1, SC-E2 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"task":"confirm RED phase complete: all RED tests written, all verified failing, no GREEN work started; report BLOCKED if any RED test passes unexpectedly"}` | SC-E1, SC-E2 |
| G6: green-phase | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"remediation":true,"task":"implement skildeck validation: (1) add presence check — every SKILL.md MUST have Trigger Dispatch Table heading, (2) add column check — verify 4 required columns (User says / Context, Task, Dispatch, Context passed), (3) add non-empty check — at least one data row, (4) add EMPTY_DISPATCH_TABLE and INVALID_DISPATCH_TABLE_COLUMNS result codes; modify skildeck source"}` | SC-E1, SC-E2, SC-E3 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"task":"verify GREEN changes applied: run skildeck validate on SKILL.md without dispatch table → expect MISSING_DISPATCH_TABLE; run on one with table → expect no such error"}` | SC-E1, SC-E2 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-E1, SC-E2, SC-E3 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"task":"structural verification: (1) skildeck has MISSING_DISPATCH_TABLE and INVALID_DISPATCH_TABLE_COLUMNS constants, (2) validation runs as part of validate command, (3) validation checks heading text and columns"}` | SC-E1, SC-E2, SC-E3 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"task":"independent re-verification: re-run all RED tests (now expect validation errors), confirm all pass; cross-check against baseline from G2"}` | SC-E1, SC-E2 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"task":"verification-before-completion: for each SC (SC-E1 through SC-E3), collect evidence artifact, report PASS/FAIL with tool-call evidence"}` | SC-E1, SC-E2, SC-E3 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"task":"adversarial audit of Phase 1: audit validation logic for correctness, edge cases (empty tables, malformed, missing heading), error message quality; report findings per SC"}` | SC-E1, SC-E2, SC-E3 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus (PASS/FAIL/DISAGREE) per SC"}` | SC-E1, SC-E2, SC-E3 |
| G14: regression-check | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"task":"regression check: run skildeck validate on all 39 SKILL.md files — confirm existing validation rules still pass"}` | SC-E4 |
| G15: review-prep | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"task":"prepare review: generate diff summary, list files modified, produce compare URL (compare/dev...feature/1213-workstream-e-skildeck)"}` | SC-E1, SC-E2, SC-E3, SC-E4 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"issue":1213,"phase":1,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns, artifact paths"}` | SC-E1, SC-E2, SC-E3, SC-E4 |

---

## SC-ID Traceability

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-E1 | skildeck validate checks dispatch table presence in SKILL.md | behavioral |
| SC-E2 | skildeck validate reports MISSING_DISPATCH_TABLE for SKILL.md without one | behavioral |
| SC-E3 | skildeck validate checks column correctness in found dispatch tables | behavioral |
| SC-E4 | skildeck validate exits non-zero when at least one SKILL.md fails validation | behavioral |

---

## Post-All-Phases Sweep

1. Tag submodule: `.opencode/checkpoint/1213/post`
2. Run enforcement tests: `bash .opencode/tests/test-enforcement.sh --changed`
3. Run finish-checklist: `skill({name: "finishing-a-development-branch"})`

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.