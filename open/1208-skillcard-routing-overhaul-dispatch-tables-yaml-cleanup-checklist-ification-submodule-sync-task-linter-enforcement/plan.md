---
number: 1208
title: "[PLAN] Skillcard routing overhaul — dispatch tables, YAML cleanup, checklist-ification, submodule-sync task, linter enforcement"
status: draft
parent_spec: 1208
created: 2026-06-14
sub_issues: [1209, 1210, 1211, 1212, 1213]
---

## Z3 Dependency Contract

```yaml
phases:
  - id: workstream-a
    label: YAML frontmatter cleanup
    depends_on: []

  - id: workstream-b
    label: Dispatch tables
    depends_on: [workstream-a]

  - id: workstream-c
    label: Checklist-ification
    depends_on: [workstream-b]

  - id: workstream-d
    label: Submodule-sync task
    depends_on: [workstream-b]

  - id: workstream-e
    label: skildeck linter
    depends_on: [workstream-b]

constraints:
  - "workstream_a_complete → workstream_b_start"
  - "workstream_b_complete → workstream_c_start"
  - "workstream_b_complete → workstream_d_start"
  - "workstream_b_complete → workstream_e_start"

verify:
  - solve check --contract --query "workstream_a < workstream_b and workstream_b < workstream_c and workstream_b < workstream_d and workstream_b < workstream_e" → SAT
```

## Phase 1: Workstream A — YAML Frontmatter Cleanup

**Sub-issue:** #1209
**Dependencies:** None
**SCs covered:** SC-A1, SC-A2

### 16-Gate Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"verify SC-A1 and SC-A2 are coherent with spec #1208 — check all 39 SKILL.md files exist, confirm YAML frontmatter structure, report any spec gaps"}` | SC-A1, SC-A2 |
| G2: pre-red-baseline | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"capture baseline: grep for 'Triggers on:' count, 'provenance:' count, 'Co-authored with AI:' count, word-count/line-count patterns across all 39 SKILL.md files; write baseline to tmp/phase1-baseline.json"}` | SC-A1, SC-A2 |
| G3: red-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"remediation":true,"task":"write RED enforcement tests: (1) grep for 'Triggers on:' in all 39 SKILL.md → expect >0 matches (baseline count), (2) grep for 'provenance:' → expect >0, (3) grep for 'Co-authored with AI:' → expect >0; tests MUST fail before cleanup"}` | SC-A1, SC-A2 |
| G4: red-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"verify RED tests actually fail: run each RED assertion, confirm non-zero exit or expected-failure output; log results to tmp/phase1-red-verified.json"}` | SC-A1, SC-A2 |
| G5: post-red-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"confirm RED phase is complete: all RED tests written, all verified failing, no GREEN work started; report BLOCKED if any RED test passes unexpectedly"}` | SC-A1, SC-A2 |
| G6: green-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"remediation":true,"task":"implement cleanup: (1) remove 'Triggers on:' keyword lists from all 39 YAML frontmatter descriptions, (2) remove 'provenance: 🤖 Co-authored with AI:' lines, (3) remove AI byline signoff lines from bodies, (4) remove word/line/stat counts, (5) rewrite descriptions to clean 'Use when...' NLU prose; write changes to all 39 files"}` | SC-A1, SC-A2 |
| G7: post-green-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"verify GREEN changes applied: grep for 'Triggers on:' → expect 0, grep for 'provenance:' → expect 0, grep for 'Co-authored with AI:' → expect 0; report any remaining matches"}` | SC-A1, SC-A2 |
| G8: checkpoint-commit | orchestrator inline | N/A | N/A | — | SC-A1, SC-A2 |
| G9: structural-checks | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"structural verification: (1) all 39 SKILL.md files still exist and are non-empty, (2) YAML frontmatter is valid in all files, (3) no files have zero-length descriptions"}` | SC-A1, SC-A2 |
| G10: green-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"independent re-verification: re-run all RED tests (now expect 0 matches), confirm all pass; cross-check against baseline from G2"}` | SC-A1, SC-A2 |
| G11: green-vbc | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"verification-before-completion: for each SC (SC-A1, SC-A2), collect evidence artifact, report PASS/FAIL per SC with tool-call evidence"}` | SC-A1, SC-A2 |
| G12: adversarial-audit | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"adversarial audit of Phase 1: audit all 39 SKILL.md for remaining YAML frontmatter issues, missed cleanup items, or description quality problems; report findings with PASS/FAIL per SC"}` | SC-A1, SC-A2 |
| G13: cross-validate | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus (PASS/FAIL/DISAGREE) per SC; escalate DISAGREE to orchestrator"}` | SC-A1, SC-A2 |
| G14: regression-check | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"regression check: verify no existing functionality broken — grep for any skill description that lost its 'Use when...' prefix, confirm all 39 files parse as valid YAML+markdown"}` | SC-A1, SC-A2 |
| G15: review-prep | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"prepare review: generate diff summary of all changes, list files modified, produce compare URL (compare/dev...feature/1209-workstream-a)"}` | SC-A1, SC-A2 |
| G16: exec-summary | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns, artifact paths"}` | SC-A1, SC-A2 |

---

## Phase 2: Workstream B — Trigger Dispatch Tables

**Sub-issue:** #1210
**Dependencies:** Phase 1 complete
**SCs covered:** SC-B1, SC-B2, SC-B3, SC-B4

### 16-Gate Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"task":"verify SC-B1 through SC-B4 are coherent with spec #1208 — confirm dispatch table format spec, check all 39 SKILL.md are accessible, report any spec gaps"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G2: pre-red-baseline | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"task":"capture baseline: grep for 'Trigger Dispatch Table' across all 39 SKILL.md → expect 0 matches; list all tasks per skill from Tasks sections; write baseline to tmp/phase2-baseline.json"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G3: red-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"remediation":true,"task":"write RED enforcement tests: (1) grep for 'Trigger Dispatch Table' → expect 0 matches (no tables exist yet), (2) verify no dispatch table columns exist, (3) verify no cross-skill conflict detection exists; tests MUST fail before tables are added"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G4: red-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"task":"verify RED tests actually fail: run each RED assertion, confirm non-zero exit or expected-failure output; log results to tmp/phase2-red-verified.json"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G5: post-red-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"task":"confirm RED phase complete: all RED tests written, all verified failing, no GREEN work started; report BLOCKED if any RED test passes unexpectedly"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G6: green-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"remediation":true,"task":"implement dispatch tables: (1) add 'Trigger Dispatch Table' section to all 39 SKILL.md after Overview, (2) populate with columns: User says / Context, Task, Dispatch, Context passed, (3) run cross-skill routing audit — detect and resolve conflicting primary triggers, (4) ensure every task in Tasks section has at least one dispatch table row; write all 39 files"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G7: post-green-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"task":"verify GREEN changes applied: grep for 'Trigger Dispatch Table' → expect 39 matches; verify column headers present in all; report any skill missing the table"}` | SC-B1, SC-B2 |
| G8: checkpoint-commit | orchestrator inline | N/A | N/A | — | SC-B1, SC-B2, SC-B3, SC-B4 |
| G9: structural-checks | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"task":"structural verification: (1) all 39 SKILL.md have 'Trigger Dispatch Table' section, (2) each table has all 4 required columns, (3) each table has at least one row, (4) no orphan tasks exist"}` | SC-B1, SC-B2, SC-B4 |
| G10: green-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"task":"independent re-verification: re-run all RED tests (now expect 39 matches), confirm all pass; cross-check against baseline from G2"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G11: green-vbc | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"task":"verification-before-completion: for each SC (SC-B1 through SC-B4), collect evidence artifact, report PASS/FAIL per SC with tool-call evidence"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G12: adversarial-audit | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"task":"adversarial audit of Phase 2: audit all 39 dispatch tables for correctness, check cross-skill conflict resolution, verify no orphan tasks, check column format compliance; report findings with PASS/FAIL per SC"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G13: cross-validate | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus (PASS/FAIL/DISAGREE) per SC; escalate DISAGREE to orchestrator"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G14: regression-check | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"task":"regression check: verify no existing skill descriptions or routing logic broken by dispatch table insertion; confirm all 39 files parse as valid YAML+markdown"}` | SC-B1, SC-B2 |
| G15: review-prep | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"task":"prepare review: generate diff summary of all changes, list files modified, produce compare URL (compare/dev...feature/1210-workstream-b)"}` | SC-B1, SC-B2, SC-B3, SC-B4 |
| G16: exec-summary | orchestrator routes to general | yes (blind) | general | `{"issue":1210,"phase":2,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns, artifact paths"}` | SC-B1, SC-B2, SC-B3, SC-B4 |

---

## Phase 3: Workstream C — Procedure Checklist-ification

**Sub-issue:** #1211
**Dependencies:** Phase 2 complete
**SCs covered:** SC-C1

### 16-Gate Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"task":"verify SC-C1 is coherent with spec #1208 — confirm scope: all SKILL.md Operating Protocols + all task files with procedural steps; report any spec gaps"}` | SC-C1 |
| G2: pre-red-baseline | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"task":"capture baseline: find all prose-embedded numbered step lists across all SKILL.md Operating Protocols and task files; count prose steps vs checklist steps; write baseline to tmp/phase3-baseline.json"}` | SC-C1 |
| G3: red-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"remediation":true,"task":"write RED enforcement tests: (1) grep for prose numbered step patterns (e.g., '1. ' at line start in Operating Protocol sections) → expect >0 matches, (2) grep for '- [ ]' checklist patterns → expect fewer than prose step count; tests MUST fail before conversion"}` | SC-C1 |
| G4: red-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"task":"verify RED tests actually fail: run each RED assertion, confirm non-zero exit or expected-failure output; log results to tmp/phase3-red-verified.json"}` | SC-C1 |
| G5: post-red-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"task":"confirm RED phase complete: all RED tests written, all verified failing, no GREEN work started; report BLOCKED if any RED test passes unexpectedly"}` | SC-C1 |
| G6: green-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"remediation":true,"task":"implement checklist-ification: convert all prose-embedded numbered step descriptions to '- [ ] N. ...' checklist format across all SKILL.md Operating Protocols and task files with procedural steps; write all affected files"}` | SC-C1 |
| G7: post-green-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"task":"verify GREEN changes applied: grep for '- [ ]' checklist patterns in Operating Protocol sections → expect matches; verify prose numbered step patterns reduced to near-zero in converted sections"}` | SC-C1 |
| G8: checkpoint-commit | orchestrator inline | N/A | N/A | — | SC-C1 |
| G9: structural-checks | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"task":"structural verification: (1) all Operating Protocol sections use checklist format, (2) all task files with procedural steps use checklist format, (3) no prose-embedded numbered step lists remain in scope"}` | SC-C1 |
| G10: green-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"task":"independent re-verification: re-run all RED tests (now expect checklist format), confirm all pass; cross-check against baseline from G2"}` | SC-C1 |
| G11: green-vbc | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"task":"verification-before-completion: for SC-C1, collect evidence artifact, report PASS/FAIL with tool-call evidence"}` | SC-C1 |
| G12: adversarial-audit | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"task":"adversarial audit of Phase 3: audit all converted sections for missed prose steps, incorrect checklist formatting, or incomplete conversion; report findings with PASS/FAIL per SC"}` | SC-C1 |
| G13: cross-validate | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus (PASS/FAIL/DISAGREE) per SC; escalate DISAGREE to orchestrator"}` | SC-C1 |
| G14: regression-check | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"task":"regression check: verify no existing procedural content lost during conversion; spot-check 5 converted files for semantic preservation"}` | SC-C1 |
| G15: review-prep | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"task":"prepare review: generate diff summary of all changes, list files modified, produce compare URL (compare/dev...feature/1211-workstream-c)"}` | SC-C1 |
| G16: exec-summary | orchestrator routes to general | yes (blind) | general | `{"issue":1211,"phase":3,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns, artifact paths"}` | SC-C1 |

---

## Phase 4: Workstream D — New submodule-sync Task

**Sub-issue:** #1212
**Dependencies:** Phase 2 complete
**SCs covered:** SC-D1, SC-D2

### 16-Gate Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"task":"verify SC-D1 and SC-D2 are coherent with spec #1208 — confirm expected task path, check git-workflow SKILL.md exists, report any spec gaps"}` | SC-D1, SC-D2 |
| G2: pre-red-baseline | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"task":"capture baseline: verify submodule-sync.md does NOT exist at expected path; grep git-workflow SKILL.md for 'submodule' or 'sync' trigger references; write baseline to tmp/phase4-baseline.json"}` | SC-D1, SC-D2 |
| G3: red-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"remediation":true,"task":"write RED enforcement tests: (1) file existence check for submodule-sync.md → expect MISSING, (2) grep git-workflow SKILL.md for 'submodule-sync' → expect 0 matches; tests MUST fail before creation"}` | SC-D1, SC-D2 |
| G4: red-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"task":"verify RED tests actually fail: run each RED assertion, confirm expected-failure output; log results to tmp/phase4-red-verified.json"}` | SC-D1, SC-D2 |
| G5: post-red-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"task":"confirm RED phase complete: all RED tests written, all verified failing, no GREEN work started; report BLOCKED if any RED test passes unexpectedly"}` | SC-D1, SC-D2 |
| G6: green-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"remediation":true,"task":"implement: (1) create .opencode/skills/git-workflow/tasks/submodule-sync.md with lightweight sync procedure, (2) add dispatch table row in git-workflow SKILL.md: 'sync submodules' / 'update submodules' → submodule-sync; write both files"}` | SC-D1, SC-D2 |
| G7: post-green-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"task":"verify GREEN changes applied: (1) submodule-sync.md exists at expected path, (2) git-workflow SKILL.md dispatch table references submodule-sync; report any missing references"}` | SC-D1, SC-D2 |
| G8: checkpoint-commit | orchestrator inline | N/A | N/A | — | SC-D1, SC-D2 |
| G9: structural-checks | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"task":"structural verification: (1) submodule-sync.md exists and is non-empty, (2) git-workflow dispatch table has correct row for submodule sync triggers, (3) task file has valid YAML frontmatter"}` | SC-D1, SC-D2 |
| G10: green-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"task":"independent re-verification: re-run all RED tests (now expect file exists + dispatch row present), confirm all pass; cross-check against baseline from G2"}` | SC-D1, SC-D2 |
| G11: green-vbc | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"task":"verification-before-completion: for each SC (SC-D1, SC-D2), collect evidence artifact, report PASS/FAIL with tool-call evidence"}` | SC-D1, SC-D2 |
| G12: adversarial-audit | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"task":"adversarial audit of Phase 4: audit submodule-sync.md for correctness, check dispatch table row format, verify task file follows skill conventions; report findings with PASS/FAIL per SC"}` | SC-D1, SC-D2 |
| G13: cross-validate | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus (PASS/FAIL/DISAGREE) per SC; escalate DISAGREE to orchestrator"}` | SC-D1, SC-D2 |
| G14: regression-check | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"task":"regression check: verify git-workflow SKILL.md still parses correctly with new dispatch row; confirm no existing dispatch rows broken"}` | SC-D1, SC-D2 |
| G15: review-prep | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"task":"prepare review: generate diff summary, list files modified, produce compare URL (compare/dev...feature/1212-workstream-d)"}` | SC-D1, SC-D2 |
| G16: exec-summary | orchestrator routes to general | yes (blind) | general | `{"issue":1212,"phase":4,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns, artifact paths"}` | SC-D1, SC-D2 |

---

## Phase 5: Workstream E — skildeck Dispatch Table Validation

**Sub-issue:** #1213
**Dependencies:** Phase 2 complete
**SCs covered:** SC-E1, SC-E2

### 16-Gate Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"task":"verify SC-E1 and SC-E2 are coherent with spec #1208 — confirm skildeck CLI tool exists, check its validation pass structure, report any spec gaps"}` | SC-E1, SC-E2 |
| G2: pre-red-baseline | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"task":"capture baseline: run skildeck validate on a SKILL.md without dispatch table → verify it does NOT report MISSING_DISPATCH_TABLE; write baseline to tmp/phase5-baseline.json"}` | SC-E1, SC-E2 |
| G3: red-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"remediation":true,"task":"write RED enforcement tests: (1) run skildeck validate on a SKILL.md without dispatch table → expect NO MISSING_DISPATCH_TABLE error (feature doesn't exist yet), (2) grep skildeck source for 'dispatch_table' → expect 0 matches; tests MUST fail before implementation"}` | SC-E1, SC-E2 |
| G4: red-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"task":"verify RED tests actually fail: run each RED assertion, confirm expected-failure output; log results to tmp/phase5-red-verified.json"}` | SC-E1, SC-E2 |
| G5: post-red-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"task":"confirm RED phase complete: all RED tests written, all verified failing, no GREEN work started; report BLOCKED if any RED test passes unexpectedly"}` | SC-E1, SC-E2 |
| G6: green-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"remediation":true,"task":"implement skildeck validation: (1) add validation rule checking every SKILL.md MUST have a Trigger Dispatch Table section, (2) format check: correct columns + at least one row per task, (3) report MISSING_DISPATCH_TABLE error code for SKILL.md without one; modify skildeck source"}` | SC-E1, SC-E2 |
| G7: post-green-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"task":"verify GREEN changes applied: run skildeck validate on a SKILL.md without dispatch table → expect MISSING_DISPATCH_TABLE error; run on one with table → expect no such error"}` | SC-E1, SC-E2 |
| G8: checkpoint-commit | orchestrator inline | N/A | N/A | — | SC-E1, SC-E2 |
| G9: structural-checks | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"task":"structural verification: (1) skildeck source has dispatch table validation logic, (2) MISSING_DISPATCH_TABLE error code is defined, (3) validation runs as part of standard validate pass"}` | SC-E1, SC-E2 |
| G10: green-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"task":"independent re-verification: re-run all RED tests (now expect MISSING_DISPATCH_TABLE reported), confirm all pass; cross-check against baseline from G2"}` | SC-E1, SC-E2 |
| G11: green-vbc | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"task":"verification-before-completion: for each SC (SC-E1, SC-E2), collect evidence artifact, report PASS/FAIL with tool-call evidence"}` | SC-E1, SC-E2 |
| G12: adversarial-audit | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"task":"adversarial audit of Phase 5: audit skildeck validation logic for correctness, edge cases (empty tables, malformed tables), error message quality; report findings with PASS/FAIL per SC"}` | SC-E1, SC-E2 |
| G13: cross-validate | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus (PASS/FAIL/DISAGREE) per SC; escalate DISAGREE to orchestrator"}` | SC-E1, SC-E2 |
| G14: regression-check | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"task":"regression check: run skildeck validate on all 39 SKILL.md (now with dispatch tables) → confirm no false MISSING_DISPATCH_TABLE errors; verify existing validation rules still pass"}` | SC-E1, SC-E2 |
| G15: review-prep | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"task":"prepare review: generate diff summary, list files modified, produce compare URL (compare/dev...feature/1213-workstream-e)"}` | SC-E1, SC-E2 |
| G16: exec-summary | orchestrator routes to general | yes (blind) | general | `{"issue":1213,"phase":5,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns, artifact paths"}` | SC-E1, SC-E2 |

---

## SC-ID Traceability

| SC | Workstream | Criterion | Evidence Type |
|----|-----------|-----------|---------------|
| SC-A1 | A | All 39 YAML frontmatters have clean "Use when..." descriptions with no Triggers on: keywords | string |
| SC-A2 | A | No AI byline lines remain in any SKILL.md body | string |
| SC-B1 | B | All 39 SKILL.md have a Trigger Dispatch Table section | string |
| SC-B2 | B | Every dispatch table has at minimum: User says / Context column, Task column, Dispatch column, Context passed column | string |
| SC-B3 | B | No conflicting primary triggers exist between any two dispatch tables | behavioral (cross-skill audit) |
| SC-B4 | B | Every task listed in a skill's Tasks section has at least one dispatch table row | string |
| SC-C1 | C | All Operating Protocol sequential procedures use - [ ] N. checklist format | string |
| SC-D1 | D | submodule-sync task file exists at the expected path | structural |
| SC-D2 | D | git-workflow dispatch table references submodule-sync for submodule sync triggers | string |
| SC-E1 | E | skildeck validate command checks dispatch table presence in SKILL.md | behavioral |
| SC-E2 | E | skildeck validate reports MISSING_DISPATCH_TABLE for SKILL.md without one | behavioral |
