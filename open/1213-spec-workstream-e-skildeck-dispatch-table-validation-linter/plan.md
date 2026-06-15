---
number: 1213
title: "[PLAN] Workstream E — skildeck dispatch table validation linter"
status: draft
parent_spec: 1208
created: 2026-06-14
---

## Phase 1: Dispatch Table Validation in skildeck

**Sub-issue:** #1213
**Dependencies:** Phase 2 (Workstream B) complete
**SCs covered:** SC-E1, SC-E2

**Changes:** Add dispatch table presence check to skildeck validate, add column correctness check, add non-empty check, add behavioral enforcement test.

### 16-Gate Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"task":"verify SC-E1 and SC-E2 are coherent with spec #1208 — confirm skildeck CLI tool exists, check its validation pass structure, report any spec gaps"}` | SC-E1, SC-E2 |
| G2: pre-red-baseline | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"task":"capture baseline: run skildeck validate on a SKILL.md without dispatch table → verify it does NOT report MISSING_DISPATCH_TABLE; write baseline to tmp/phase5-baseline.json"}` | SC-E1, SC-E2 |
| G3: red-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"remediation":true,"task":"write RED enforcement tests: (1) run skildeck validate on a SKILL.md without dispatch table → expect NO MISSING_DISPATCH_TABLE error (feature doesn't exist yet), (2) grep skildeck source for 'dispatch_table' → expect 0 matches; tests MUST fail before implementation"}` | SC-E1, SC-E2 |
| G4: red-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"task":"verify RED tests actually fail: run each RED assertion, confirm expected-failure output; log results to tmp/phase5-red-verified.json"}` | SC-E1, SC-E2 |
| G5: post-red-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"task":"confirm RED phase complete: all RED tests written, all verified failing, no GREEN work started; report BLOCKED if any RED test passes unexpectedly"}` | SC-E1, SC-E2 |
| G6: green-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"remediation":true,"task":"implement skildeck validation: (1) add presence check — every SKILL.md MUST have a Trigger Dispatch Table section, (2) add column check — verify all 4 required columns exist, (3) add non-empty check — at least one data row, (4) add behavioral enforcement test that verifies agent follows dispatch table validation rules; modify skildeck source and create test file"}` | SC-E1, SC-E2 |
| G7: post-green-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"task":"verify GREEN changes applied: run skildeck validate on a SKILL.md without dispatch table → expect MISSING_DISPATCH_TABLE error; run on one with table → expect no such error"}` | SC-E1, SC-E2 |
| G8: checkpoint-commit | orchestrator inline | N/A | N/A | — | SC-E1, SC-E2 |
| G9: structural-checks | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"task":"structural verification: (1) skildeck source has dispatch table validation logic, (2) MISSING_DISPATCH_TABLE error code is defined, (3) validation runs as part of standard validate pass, (4) behavioral test file exists"}` | SC-E1, SC-E2 |
| G10: green-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"task":"independent re-verification: re-run all RED tests (now expect MISSING_DISPATCH_TABLE reported), confirm all pass; cross-check against baseline from G2"}` | SC-E1, SC-E2 |
| G11: green-vbc | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"task":"verification-before-completion: for each SC (SC-E1, SC-E2), collect evidence artifact, report PASS/FAIL with tool-call evidence"}` | SC-E1, SC-E2 |
| G12: adversarial-audit | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"task":"adversarial audit of Phase 1: audit skildeck validation logic for correctness, edge cases (empty tables, malformed tables), error message quality; report findings with PASS/FAIL per SC"}` | SC-E1, SC-E2 |
| G13: cross-validate | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus (PASS/FAIL/DISAGREE) per SC; escalate DISAGREE to orchestrator"}` | SC-E1, SC-E2 |
| G14: regression-check | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"task":"regression check: run skildeck validate on all 39 SKILL.md (now with dispatch tables) → confirm no false MISSING_DISPATCH_TABLE errors; verify existing validation rules still pass"}` | SC-E1, SC-E2 |
| G15: review-prep | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"task":"prepare review: generate diff summary, list files modified, produce compare URL (compare/dev...feature/1213-workstream-e)"}` | SC-E1, SC-E2 |
| G16: exec-summary | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":1,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns, artifact paths"}` | SC-E1, SC-E2 |

---

## SC-ID Traceability

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-E1 | skildeck validate checks dispatch table presence in SKILL.md | behavioral |
| SC-E2 | skildeck validate reports MISSING_DISPATCH_TABLE for SKILL.md without one | behavioral |

---

## Post-All-Phases Sweep

After the last phase's final gate:

- [ ] FINISHING CHECKLIST — orchestrator routes to finishing sub-agent: git status clean, lint/typecheck from scratch, coverage sweep
- [ ] PR CREATION — orchestrator routes to git-workflow pr-creation: via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — orchestrator routes to git-workflow cleanup: delete merged branches, close issues, sync dev
