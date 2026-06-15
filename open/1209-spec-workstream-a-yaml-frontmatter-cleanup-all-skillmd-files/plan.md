---
number: 1209
title: "[PLAN] Workstream A — YAML frontmatter cleanup (all 39 SKILL.md files)"
status: draft
parent_spec: 1208
created: 2026-06-14
---

## Phase 1: YAML Frontmatter Cleanup

**Sub-issue:** #1209
**Dependencies:** None
**SCs covered:** SC-A1, SC-A2, SC-A3, SC-A4, SC-A5

**Changes:** Remove `Triggers on:` keyword lists from YAML frontmatter descriptions, remove `provenance:` lines, remove AI byline lines from bodies, remove word/line counts, rewrite descriptions to clean "Use when..." NLU prose.

### 16-Gate Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"verify SC-A1 through SC-A5 are coherent with spec #1208 — confirm all 39 SKILL.md files exist, verify YAML frontmatter structure, report any spec gaps"}` | SC-A1, SC-A2, SC-A3, SC-A4, SC-A5 |
| G2: pre-red-baseline | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"capture baseline: grep for 'Triggers on:' count, 'provenance:' count, 'Co-authored with AI:' count, word-count/line-count patterns across all 39 SKILL.md files; write baseline to tmp/phase1-baseline.json"}` | SC-A1, SC-A2, SC-A3, SC-A4, SC-A5 |
| G3: red-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"remediation":true,"task":"write RED enforcement tests: (1) grep for 'Triggers on:' in all 39 SKILL.md → expect >0 matches (baseline count), (2) grep for 'provenance:' → expect >0, (3) grep for 'Co-authored with AI:' → expect >0, (4) grep for word/line count patterns → expect >0; tests MUST fail before cleanup"}` | SC-A1, SC-A2, SC-A3, SC-A4, SC-A5 |
| G4: red-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"verify RED tests actually fail: run each RED assertion, confirm non-zero exit or expected-failure output; log results to tmp/phase1-red-verified.json"}` | SC-A1, SC-A2, SC-A3, SC-A4, SC-A5 |
| G5: post-red-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"confirm RED phase is complete: all RED tests written, all verified failing, no GREEN work started; report BLOCKED if any RED test passes unexpectedly"}` | SC-A1, SC-A2, SC-A3, SC-A4, SC-A5 |
| G6: green-phase | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"remediation":true,"task":"implement cleanup: (1) remove 'Triggers on:' keyword lists from all 39 YAML frontmatter descriptions, (2) remove 'provenance:' lines, (3) remove AI byline signoff lines from bodies, (4) remove word/line/stat counts, (5) rewrite descriptions to clean 'Use when...' NLU prose; write changes to all 39 files"}` | SC-A1, SC-A2, SC-A3, SC-A4, SC-A5 |
| G7: post-green-enforcement | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"verify GREEN changes applied: grep for 'Triggers on:' → expect 0, grep for 'provenance:' → expect 0, grep for 'Co-authored with AI:' → expect 0, grep for word/line count patterns → expect 0; report any remaining matches"}` | SC-A1, SC-A2, SC-A3, SC-A4, SC-A5 |
| G8: checkpoint-commit | orchestrator inline | N/A | N/A | — | SC-A1, SC-A2, SC-A3, SC-A4, SC-A5 |
| G9: structural-checks | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"structural verification: (1) all 39 SKILL.md files still exist and are non-empty, (2) YAML frontmatter is valid in all files, (3) all descriptions start with 'Use when'"}` | SC-A1, SC-A5 |
| G10: green-doublecheck | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"independent re-verification: re-run all RED tests (now expect 0 matches), confirm all pass; cross-check against baseline from G2"}` | SC-A1, SC-A2, SC-A3, SC-A4, SC-A5 |
| G11: green-vbc | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"verification-before-completion: for each SC (SC-A1 through SC-A5), collect evidence artifact, report PASS/FAIL per SC with tool-call evidence"}` | SC-A1, SC-A2, SC-A3, SC-A4, SC-A5 |
| G12: adversarial-audit | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"adversarial audit of Phase 1: audit all 39 SKILL.md for remaining YAML frontmatter issues, missed cleanup items, or description quality problems; report findings with PASS/FAIL per SC"}` | SC-A1, SC-A2, SC-A3, SC-A4, SC-A5 |
| G13: cross-validate | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus (PASS/FAIL/DISAGREE) per SC; escalate DISAGREE to orchestrator"}` | SC-A1, SC-A2, SC-A3, SC-A4, SC-A5 |
| G14: regression-check | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"regression check: verify no existing functionality broken — grep for any skill description that lost its 'Use when...' prefix, confirm all 39 files parse as valid YAML+markdown"}` | SC-A1, SC-A5 |
| G15: review-prep | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"prepare review: generate diff summary of all changes, list files modified, produce compare URL (compare/dev...feature/1209-workstream-a)"}` | SC-A1, SC-A2, SC-A3, SC-A4, SC-A5 |
| G16: exec-summary | orchestrator routes to general | yes (blind) | general | `{"issue":1209,"phase":1,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns, artifact paths"}` | SC-A1, SC-A2, SC-A3, SC-A4, SC-A5 |

---

## SC-ID Traceability

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-A1 | All 39 YAML frontmatter descriptions have no `Triggers on:` keyword lists | string |
| SC-A2 | No `provenance:` lines remain in any SKILL.md YAML frontmatter | string |
| SC-A3 | No `Co-authored with AI:` byline lines remain in any SKILL.md body | string |
| SC-A4 | No word count / line count statistics remain in any SKILL.md body | string |
| SC-A5 | All 39 descriptions are clean "Use when..." NLU prose | string |

---

## Post-All-Phases Sweep

After the last phase's final gate:

- [ ] FINISHING CHECKLIST — orchestrator routes to finishing sub-agent: git status clean, lint/typecheck from scratch, coverage sweep
- [ ] PR CREATION — orchestrator routes to git-workflow pr-creation: via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — orchestrator routes to git-workflow cleanup: delete merged branches, close issues, sync dev
