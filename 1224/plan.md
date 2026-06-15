---
number: 1224
title: "[PLAN] Replace .gitmodules-based repo discovery with filesystem glob scan"
status: draft
created: 2026-06-15
---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Plan: Replace .gitmodules-based repo discovery with filesystem glob scan

**Spec:** #1224
**Authorization scope:** `for_plan` | `halt_at: plan_created` | `pr_strategy: none`
**Type:** Separate (single-phase, single-concern refactor)

## Summary

Replace three `.gitmodules`-dependent and parent-missing discovery functions (`_discover_submodules()`, `_discover_subrepos()`, `_discover_repos()`) with a single `_discover_all_repos()` using filesystem glob. Parent repo always first entry. Remove all `repos.insert(0, current)` workarounds. Remove `.gitmodules` parsing entirely.

**SCs covered:**
| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `_discover_submodules()` function removed | string |
| SC-2 | `_discover_subrepos()` function removed | string |
| SC-3 | `_discover_repos()` replaced by `_discover_all_repos()` inclusive of parent repo | string |
| SC-4 | All `repos.insert(0, current)` workarounds removed | string |
| SC-5 | No `.gitmodules` references remain in tools/ | string |
| SC-6 | `_discover_all_repos()` scans all three glob patterns (`.git/`, `*/.git/`, `*/.git`) | structural |

**Affected file:** `.opencode/tools/local-issues`

---

## Pre-Work (before pipeline)

1. Create feature branch from dev: `feature/1224-local-issues-fs-repo-discovery`
2. Tag `.opencode` submodule: `.opencode/checkpoint/1224/pre`
3. Initialize pipeline state: `solve state init ./tmp/1224/state/`
4. Set initial state: `solve state update ./tmp/1224/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml --var-name previous_step --var-value init --var-name current_step --var-value sc-coherence-gate --var-name pipeline_state --var-value running`

## RED Assertions

- **SC-1 RED:** `grep -n '_discover_submodules' .opencode/tools/local-issues` — expect matches (function exists)
- **SC-2 RED:** `grep -n '_discover_subrepos' .opencode/tools/local-issues` — expect matches (function exists)
- **SC-3 RED:** `grep -n '_discover_repos' .opencode/tools/local-issues` — expect matches (old function exists, new `_discover_all_repos` does not)
- **SC-4 RED:** `grep -rn 'insert(0, current)' .opencode/tools/local-issues` — expect matches (workarounds exist)
- **SC-5 RED:** `grep -n 'gitmodules\|\.gitmodules' .opencode/tools/local-issues` — expect matches (gitmodules references exist)
- **SC-6 RED:** `grep -n '_discover_all_repos' .opencode/tools/local-issues` — expect 0 matches (function does not exist yet)

## Verification Methods

- **SC-1 (string):** `grep -n '_discover_submodules' .opencode/tools/local-issues` → 0 matches
- **SC-2 (string):** `grep -n '_discover_subrepos' .opencode/tools/local-issues` → 0 matches
- **SC-3 (string):** `grep -n '_discover_all_repos' .opencode/tools/local-issues` → matches found; no `_discover_repos` definition remains
- **SC-4 (string):** `grep -rn 'insert(0, current)' .opencode/tools/local-issues` → 0 matches
- **SC-5 (string):** `grep -n 'gitmodules' .opencode/tools/local-issues` → 0 matches
- **SC-6 (structural):** Read `_discover_all_repos()` source → confirm it scans `.git/`, `*/.git/`, `*/.git` patterns

---

## Phase 1: Replace repo discovery with clean filesystem glob

**Concern:** Replace three functions with one clean `_discover_all_repos()` and remove `.gitmodules` parsing and `insert(0, current)` workarounds (SC-1 through SC-6).

**Files:**
- `.opencode/tools/local-issues` — replace functions, remove workarounds, remove gitmodules references

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"task":"verify SC-1 through SC-6 are coherent with local-issues source — read lines 265-330 to confirm _discover_submodules (265-298), _discover_subrepos (301-319), _discover_repos (322-329) exist; confirm all callers with insert(0, current) patterns"}` | SC-1, SC-2, SC-3, SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"task":"capture baseline: count all references to _discover_submodules, _discover_subrepos, _discover_repos in tools/local-issues; count all insert(0, current) occurrences; count all gitmodules references; write to tmp/1224/baseline.json"}` | SC-1, SC-2, SC-3, SC-4, SC-5 |
| G3: red-phase | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"remediation":true,"task":"write RED enforcement tests: (1) grep for _discover_submodules → expect matches (function exists), (2) grep for _discover_subrepos → expect matches, (3) grep for _discover_repos → expect matches (no _discover_all_repos yet), (4) grep for insert(0, current) → expect matches, (5) grep for gitmodules → expect matches; tests MUST fail before implementation"}` | SC-1, SC-2, SC-3, SC-4, SC-5 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"task":"verify RED tests actually fail: run each RED assertion, confirm expected output; log results to tmp/1224/red-verified.json"}` | SC-1, SC-2, SC-3, SC-4, SC-5 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"task":"confirm RED phase complete: all RED tests written, all verified failing; report BLOCKED if any RED test passes unexpectedly"}` | SC-1, SC-2, SC-3, SC-4, SC-5 |
| G6: green-phase | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"remediation":true,"task":"implement: (1) write _discover_all_repos() — scans three glob patterns (.git/, */.git/, */.git), parent repo always first, excludes bare repos via rev-parse --is-bare-repository, no recursion, no .gitmodules, (2) remove _discover_submodules() (lines 265-298), (3) remove _discover_subrepos() (lines 301-319), (4) replace _discover_repos() with _discover_all_repos(), (5) update all callers — remove every repos.insert(0, current) workaround, (6) grep for any remaining .gitmodules references and replace with glob-based approach"}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"task":"verify GREEN changes applied: grep for _discover_all_repos → matches found; grep for _discover_submodules and _discover_subrepos → no matches; grep for insert(0, current) → no matches; grep for gitmodules references → no matches in tools/"}` | SC-1, SC-2, SC-3, SC-4, SC-5 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"task":"structural verification: (1) _discover_all_repos() exists, (2) no _discover_submodules override, (3) no _discover_subrepos, (4) no _discover_repos, (5) no insert(0, current) patterns, (6) no gitmodules references, (7) _discover_all_repos references root .git/ and iterates child dirs for .git existence"}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"task":"independent re-verification: re-run all RED tests (now expect no matches for old functions, matches for new), confirm all pass"}` | SC-1, SC-2, SC-3, SC-4, SC-5 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"task":"verification-before-completion: for each SC (SC-1 through SC-6), collect evidence artifact (grep or source read), report PASS/FAIL with tool-call evidence"}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"task":"adversarial audit: audit _discover_all_repos for correctness: does it handle edge cases? root-only repos? repos with git worktrees? repos with .git as file (submodule gitlink)? does it exclude bare repos correctly? verify all old callers use the new function"}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus per SC"}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 |
| G14: regression-check | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"task":"regression check: run local-issues list in a typical project with submodules → confirm parent + children are all listed; run in a project without submodules → confirm at least parent repo listed"}` | SC-3 |
| G15: review-prep | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"task":"prepare review: generate diff summary, list files modified, produce compare URL"}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"issue":1224,"phase":1,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns"}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 |

---

## SC-ID Traceability

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `_discover_submodules()` function removed | string |
| SC-2 | `_discover_subrepos()` function removed | string |
| SC-3 | `_discover_repos()` replaced by `_discover_all_repos()` inclusive of parent repo | string |
| SC-4 | All `repos.insert(0, current)` workarounds removed | string |
| SC-5 | No `.gitmodules` references remain in tools/ | string |
| SC-6 | `_discover_all_repos()` scans all three glob patterns (`.git/`, `*/.git/`, `*/.git`) | structural |

---

## Post-All-Phases Sweep

1. Tag submodule: `.opencode/checkpoint/1224/post`
2. Run enforcement tests: `bash .opencode/tests/test-enforcement.sh --changed`
3. Run finish-checklist: `skill({name: "finishing-a-development-branch"})`

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.