---
number: 1212
title: "[PLAN] Workstream D — New submodule-sync task for git-workflow"
status: draft
parent_spec: 1208
created: 2026-06-14
---

## Phase 1: Submodule-Sync Task + Dispatch Table Row

**Sub-issue:** #1212
**Dependencies:** Phase 2 (Workstream B) complete
**SCs covered:** SC-D1, SC-D2

**Changes:** Create `.opencode/skills/git-workflow/tasks/submodule-sync.md` task file with lightweight sync procedure, add dispatch table row in git-workflow SKILL.md for submodule sync triggers.

### 16-Gate Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"task":"verify SC-D1 and SC-D2 are coherent with spec #1208 — confirm expected task path, check git-workflow SKILL.md exists, report any spec gaps"}` | SC-D1, SC-D2 |
| G2: pre-red-baseline | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"task":"capture baseline: verify submodule-sync.md does NOT exist at expected path; grep git-workflow SKILL.md for 'submodule' or 'sync' trigger references; write baseline to tmp/phase4-baseline.json"}` | SC-D1, SC-D2 |
| G3: red-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"remediation":true,"task":"write RED enforcement tests: (1) file existence check for submodule-sync.md → expect MISSING, (2) grep git-workflow SKILL.md for 'submodule-sync' → expect 0 matches; tests MUST fail before creation"}` | SC-D1, SC-D2 |
| G4: red-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"task":"verify RED tests actually fail: run each RED assertion, confirm expected-failure output; log results to tmp/phase4-red-verified.json"}` | SC-D1, SC-D2 |
| G5: post-red-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"task":"confirm RED phase complete: all RED tests written, all verified failing, no GREEN work started; report BLOCKED if any RED test passes unexpectedly"}` | SC-D1, SC-D2 |
| G6: green-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"remediation":true,"task":"implement: (1) create .opencode/skills/git-workflow/tasks/submodule-sync.md with lightweight sync procedure, (2) add dispatch table row in git-workflow SKILL.md: 'sync submodules' / 'update submodules' → submodule-sync; write both files"}` | SC-D1, SC-D2 |
| G7: post-green-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"task":"verify GREEN changes applied: (1) submodule-sync.md exists at expected path, (2) git-workflow SKILL.md dispatch table references submodule-sync; report any missing references"}` | SC-D1, SC-D2 |
| G8: checkpoint-commit | orchestrator inline | N/A | N/A | — | SC-D1, SC-D2 |
| G9: structural-checks | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"task":"structural verification: (1) submodule-sync.md exists and is non-empty, (2) git-workflow dispatch table has correct row for submodule sync triggers, (3) task file has valid YAML frontmatter"}` | SC-D1, SC-D2 |
| G10: green-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"task":"independent re-verification: re-run all RED tests (now expect file exists + dispatch row present), confirm all pass; cross-check against baseline from G2"}` | SC-D1, SC-D2 |
| G11: green-vbc | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"task":"verification-before-completion: for each SC (SC-D1, SC-D2), collect evidence artifact, report PASS/FAIL with tool-call evidence"}` | SC-D1, SC-D2 |
| G12: adversarial-audit | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"task":"adversarial audit of Phase 1: audit submodule-sync.md for correctness, check dispatch table row format, verify task file follows skill conventions; report findings with PASS/FAIL per SC"}` | SC-D1, SC-D2 |
| G13: cross-validate | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus (PASS/FAIL/DISAGREE) per SC; escalate DISAGREE to orchestrator"}` | SC-D1, SC-D2 |
| G14: regression-check | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"task":"regression check: verify git-workflow SKILL.md still parses correctly with new dispatch row; confirm no existing dispatch rows broken"}` | SC-D1, SC-D2 |
| G15: review-prep | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"task":"prepare review: generate diff summary, list files modified, produce compare URL (compare/dev...feature/1212-workstream-d)"}` | SC-D1, SC-D2 |
| G16: exec-summary | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":1,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns, artifact paths"}` | SC-D1, SC-D2 |

---

## SC-ID Traceability

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-D1 | submodule-sync task file exists at the expected path | structural |
| SC-D2 | git-workflow dispatch table references submodule-sync for submodule sync triggers | string |

---

## Post-All-Phases Sweep

After the last phase's final gate:

- [ ] FINISHING CHECKLIST — orchestrator routes to finishing sub-agent: git status clean, lint/typecheck from scratch, coverage sweep
- [ ] PR CREATION — orchestrator routes to git-workflow pr-creation: via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — orchestrator routes to git-workflow cleanup: delete merged branches, close issues, sync dev
