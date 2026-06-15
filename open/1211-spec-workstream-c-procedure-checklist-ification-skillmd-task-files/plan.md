---
number: 1211
title: "[PLAN] Workstream C — Procedure checklist-ification (SKILL.md + task files)"
status: draft
parent_spec: 1208
created: 2026-06-14
---

## Phase 1: Procedure Checklist-ification

**Sub-issue:** #1211
**Dependencies:** Phase 2 (Workstream B) complete
**SCs covered:** SC-C1

**Changes:** Convert all prose-embedded numbered step descriptions to `- [ ] N.` checklist format across all SKILL.md Operating Protocol sections and task files with procedural steps.

### 16-Gate Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"task":"verify SC-C1 is coherent with spec #1208 — confirm scope: all SKILL.md Operating Protocols + all task files with procedural steps; report any spec gaps"}` | SC-C1 |
| G2: pre-red-baseline | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"task":"capture baseline: find all prose-embedded numbered step lists across all SKILL.md Operating Protocols and task files; count prose steps vs checklist steps; write baseline to tmp/phase3-baseline.json"}` | SC-C1 |
| G3: red-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"remediation":true,"task":"write RED enforcement tests: (1) grep for prose numbered step patterns (e.g., '1. ' at line start in Operating Protocol sections) → expect >0 matches, (2) grep for '- [ ]' checklist patterns → expect fewer than prose step count; tests MUST fail before conversion"}` | SC-C1 |
| G4: red-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"task":"verify RED tests actually fail: run each RED assertion, confirm non-zero exit or expected-failure output; log results to tmp/phase3-red-verified.json"}` | SC-C1 |
| G5: post-red-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"task":"confirm RED phase complete: all RED tests written, all verified failing, no GREEN work started; report BLOCKED if any RED test passes unexpectedly"}` | SC-C1 |
| G6: green-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"remediation":true,"task":"implement checklist-ification: convert all prose-embedded numbered step descriptions to '- [ ] N. ...' checklist format across all SKILL.md Operating Protocols and task files with procedural steps; write all affected files"}` | SC-C1 |
| G7: post-green-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"task":"verify GREEN changes applied: grep for '- [ ]' checklist patterns in Operating Protocol sections → expect matches; verify prose numbered step patterns reduced to near-zero in converted sections"}` | SC-C1 |
| G8: checkpoint-commit | orchestrator inline | N/A | N/A | — | SC-C1 |
| G9: structural-checks | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"task":"structural verification: (1) all Operating Protocol sections use checklist format, (2) all task files with procedural steps use checklist format, (3) no prose-embedded numbered step lists remain in scope"}` | SC-C1 |
| G10: green-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"task":"independent re-verification: re-run all RED tests (now expect checklist format), confirm all pass; cross-check against baseline from G2"}` | SC-C1 |
| G11: green-vbc | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"task":"verification-before-completion: for SC-C1, collect evidence artifact, report PASS/FAIL with tool-call evidence"}` | SC-C1 |
| G12: adversarial-audit | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"task":"adversarial audit of Phase 1: audit all converted sections for missed prose steps, incorrect checklist formatting, or incomplete conversion; report findings with PASS/FAIL per SC"}` | SC-C1 |
| G13: cross-validate | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus (PASS/FAIL/DISAGREE) per SC; escalate DISAGREE to orchestrator"}` | SC-C1 |
| G14: regression-check | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"task":"regression check: verify no existing procedural content lost during conversion; spot-check 5 converted files for semantic preservation"}` | SC-C1 |
| G15: review-prep | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"task":"prepare review: generate diff summary of all changes, list files modified, produce compare URL (compare/dev...feature/1211-workstream-c)"}` | SC-C1 |
| G16: exec-summary | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":1,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns, artifact paths"}` | SC-C1 |

---

## SC-ID Traceability

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-C1 | All Operating Protocol sequential procedures and task file numbered steps use `- [ ] N.` checklist format | string |

---

## Post-All-Phases Sweep

After the last phase's final gate:

- [ ] FINISHING CHECKLIST — orchestrator routes to finishing sub-agent: git status clean, lint/typecheck from scratch, coverage sweep
- [ ] PR CREATION — orchestrator routes to git-workflow pr-creation: via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — orchestrator routes to git-workflow cleanup: delete merged branches, close issues, sync dev
