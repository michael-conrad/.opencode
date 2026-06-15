---
number: 1210
title: "[PLAN] Workstream B — Trigger dispatch tables (all 39 SKILL.md files)"
status: draft
parent_spec: 1208
created: 2026-06-14
---

## Phase 1: Trigger Dispatch Tables

**Sub-issue:** #1210
**Dependencies:** Phase 1 (Workstream A) complete
**SCs covered:** SC-B1, SC-B2, SC-B3, SC-B4

**Changes:** Add `## Trigger Dispatch Table` section to all 39 SKILL.md files after Overview, populate with 4 columns (User says / Context, Task, Dispatch, Context passed), run cross-skill routing audit, ensure every task has at least one dispatch table row.

### 16-Gate Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"task":"verify SC-B1 through SC-B4 are coherent with spec #1208 — confirm dispatch table format spec, check all 39 SKILL.md are accessible, report any spec gaps"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G2: pre-red-baseline | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"task":"capture baseline: grep for 'Trigger Dispatch Table' across all 39 SKILL.md → expect 0 matches; list all tasks per skill from Tasks sections; write baseline to tmp/phase2-baseline.json"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G3: red-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"remediation":true,"task":"write RED enforcement tests: (1) grep for 'Trigger Dispatch Table' → expect 0 matches (no tables exist yet), (2) verify no dispatch table columns exist, (3) verify no cross-skill conflict detection exists; tests MUST fail before tables are added"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G4: red-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"task":"verify RED tests actually fail: run each RED assertion, confirm non-zero exit or expected-failure output; log results to tmp/phase2-red-verified.json"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G5: post-red-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"task":"confirm RED phase complete: all RED tests written, all verified failing, no GREEN work started; report BLOCKED if any RED test passes unexpectedly"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G6: green-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"remediation":true,"task":"implement dispatch tables: (1) add 'Trigger Dispatch Table' section to all 39 SKILL.md after Overview, (2) populate with columns: User says / Context, Task, Dispatch, Context passed, (3) run cross-skill routing audit — detect and resolve conflicting primary triggers, (4) ensure every task in Tasks section has at least one dispatch table row; write all 39 files"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G7: post-green-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"task":"verify GREEN changes applied: grep for 'Trigger Dispatch Table' → expect 39 matches; verify column headers present in all; report any skill missing the table"}` | SC-B1, SC-B2 |
| G8: checkpoint-commit | orchestrator inline | N/A | N/A | — | SC-B1, SC-B2, SC-B3, SC-B4 |
| G9: structural-checks | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"task":"structural verification: (1) all 39 SKILL.md have 'Trigger Dispatch Table' section, (2) each table has all 4 required columns, (3) each table has at least one row, (4) no orphan tasks exist"}` | SC-B1, SC-B2, SC-B4 |
| G10: green-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"task":"independent re-verification: re-run all RED tests (now expect 39 matches), confirm all pass; cross-check against baseline from G2"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G11: green-vbc | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"task":"verification-before-completion: for each SC (SC-B1 through SC-B4), collect evidence artifact, report PASS/FAIL per SC with tool-call evidence"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G12: adversarial-audit | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"task":"adversarial audit of Phase 1: audit all 39 dispatch tables for correctness, check cross-skill conflict resolution, verify no orphan tasks, check column format compliance; report findings with PASS/FAIL per SC"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G13: cross-validate | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus (PASS/FAIL/DISAGREE) per SC; escalate DISAGREE to orchestrator"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G14: regression-check | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"task":"regression check: verify no existing skill descriptions or routing logic broken by dispatch table insertion; confirm all 39 files parse as valid YAML+markdown"}` | SC-B1, SC-B2 |
| G15: review-prep | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"task":"prepare review: generate diff summary of all changes, list files modified, produce compare URL (compare/dev...feature/1210-workstream-b)"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G16: exec-summary | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":1,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns, artifact paths"}` | SC-B1, SC-B2, SC-B3, SC-B4 |

---

## SC-ID Traceability

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-B1 | All 39 SKILL.md have a Trigger Dispatch Table section | string |
| SC-B2 | Every dispatch table has at minimum: User says / Context column, Task column, Dispatch column, Context passed column | string |
| SC-B3 | No conflicting primary triggers exist between any two dispatch tables | behavioral (cross-skill audit) |
| SC-B4 | Every task listed in a skill's Tasks section has at least one dispatch table row | string |

---

## Post-All-Phases Sweep

After the last phase's final gate:

- [ ] FINISHING CHECKLIST — orchestrator routes to finishing sub-agent: git status clean, lint/typecheck from scratch, coverage sweep
- [ ] PR CREATION — orchestrator routes to git-workflow pr-creation: via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — orchestrator routes to git-workflow cleanup: delete merged branches, close issues, sync dev
