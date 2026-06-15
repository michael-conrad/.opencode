---
number: 1223
title: "[PLAN] local-issues: no-remote push/pull guard"
status: draft
created: 2026-06-15
---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Plan: local-issues: no-remote push/pull guard

**Spec:** #1223
**Authorization scope:** `for_plan` | `halt_at: plan_created` | `pr_strategy: none`
**Type:** Separate (single-phase, single-concern bugfix)

## Summary

Add `_has_remote()` helper to `local-issues` that checks for any configured remote. Guard `_rebase_issues_branch()` and `_push_issues_branch_safe()` with early-return when no remote exists. Return `{"status": "no_remote"}` from `_sync_repo()` for no-remote repos.

**SCs covered:**
| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Repo with no remote: `_rebase_issues_branch()` returns None (skips) instead of attempting `git pull` | behavioral |
| SC-2 | Repo with no remote: `_push_issues_branch_safe()` returns None (skips) instead of attempting `git push` | behavioral |
| SC-3 | Repo with no remote: `_sync_repo()` returns `{"status": "no_remote"}` rather than `"conflict"` or `"push_failed"` | behavioral |
| SC-4 | Repo with remote: existing push/pull behavior is completely unaffected | behavioral |

**Affected file:** `.opencode/tools/local-issues`

---

## Pre-Work (before pipeline)

1. Create feature branch from dev: `feature/1223-local-issues-no-remote-guard`
2. Tag `.opencode` submodule: `.opencode/checkpoint/1223/pre`
3. Initialize pipeline state: `solve state init ./tmp/1223/state/`
4. Set initial state: `solve state update ./tmp/1223/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml --var-name previous_step --var-value init --var-name current_step --var-value sc-coherence-gate --var-name pipeline_state --var-value running`

## RED Assertions

- **SC-1 RED:** `grep -n '_rebase_issues_branch' .opencode/tools/local-issues` — verify function exists; confirm no `_has_remote` guard present in its body
- **SC-2 RED:** `grep -n '_push_issues_branch_safe' .opencode/tools/local-issues` — verify function exists; confirm no `_has_remote` guard present
- **SC-3 RED:** `grep -n 'no_remote' .opencode/tools/local-issues` — expect 0 matches (no_remote status doesn't exist yet)
- **SC-4 RED:** Verify `_has_remote` function does NOT exist: `grep -n '_has_remote' .opencode/tools/local-issues` → 0 matches

## Verification Methods

- **SC-1 (behavioral):** Create a test repo with no remote, run `_rebase_issues_branch()` → confirm returns None without attempting `git pull`
- **SC-2 (behavioral):** Same test: `_push_issues_branch_safe()` → returns None without `git push`
- **SC-3 (behavioral):** Same test: `_sync_repo()` → returns `{"status": "no_remote"}`
- **SC-4 (behavioral):** Repo with remote: existing push/pull behavior unchanged — run `_sync_repo()` → normal status, not `no_remote`

---

## Phase 1: Add _has_remote() helper and guard push/pull operations

**Concern:** Add a no-remote guard that skips push/pull operations when no remote exists (SC-1 through SC-4).

**Files:**
- `.opencode/tools/local-issues` — add `_has_remote()`, modify `_rebase_issues_branch()`, `_push_issues_branch_safe()`, `_sync_repo()`

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"task":"verify SC-1 through SC-4 are coherent with local-issues source — read the _sync_repo pipeline, confirm _rebase_issues_branch and _push_issues_branch_safe exist, report current behavior"}` | SC-1, SC-2, SC-3, SC-4 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"task":"capture baseline: run git -C <test-repo> remote -v on a repo with no remote → confirm output is empty; verify _rebase_issues_branch and _push_issues_branch_safe attempt git operations unconditionally"}` | SC-1, SC-2 |
| G3: red-phase | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"remediation":true,"task":"write RED enforcement tests: (1) grep for '_has_remote' in local-issues → expect 0 matches, (2) grep for 'no_remote' in local-issues → expect 0 matches; tests MUST fail before implementation"}` | SC-1, SC-2, SC-3 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"task":"verify RED tests actually fail: run each RED assertion, confirm expected output; log results to tmp/1223/red-verified.json"}` | SC-1, SC-2, SC-3 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"task":"confirm RED phase complete: all RED tests written, all verified failing; report BLOCKED if any RED test passes unexpectedly"}` | SC-1, SC-2, SC-3 |
| G6: green-phase | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"remediation":true,"task":"implement: (1) add _has_remote(repo_path) helper that wraps 'git -C <path> remote get-url origin', (2) guard _rebase_issues_branch with early-return None when no remote, (3) guard _push_issues_branch_safe with early-return None when no remote, (4) in _sync_repo set entry['status']='no_remote' and return before fetch/pull/push chain when no remote"}` | SC-1, SC-2, SC-3 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"task":"verify GREEN changes applied: grep for '_has_remote' in local-issues → match found; confirm _rebase_issues_branch and _push_issues_branch_safe have early-return guards"}` | SC-1, SC-2 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1, SC-2, SC-3 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"task":"structural verification: (1) _has_remote function exists, (2) _rebase_issues_branch has early-return on no-remote, (3) _push_issues_branch_safe has early-return on no-remote, (4) _sync_repo returns no_remote status"}` | SC-1, SC-2, SC-3 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"task":"independent re-verification: re-run all RED tests (now expect function present, no_remote status exists), confirm all pass"}` | SC-1, SC-2, SC-3 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"task":"verification-before-completion: for each SC (SC-1 through SC-4), collect evidence artifact, report PASS/FAIL with tool-call evidence"}` | SC-1, SC-2, SC-3, SC-4 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"task":"adversarial audit: audit guard logic for correctness: are early-return guards in right locations? do they break existing behavior? does no_remote status bubble up correctly?"}` | SC-1, SC-2, SC-3, SC-4 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"task":"cross-validate: compare G11 VbC results against G12 audit results; report consensus per SC"}` | SC-1, SC-2, SC-3, SC-4 |
| G14: regression-check | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"task":"regression check: run local-issues sync in a repo WITH a remote → confirm normal behavior, no no_remote status"}` | SC-4 |
| G15: review-prep | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"task":"prepare review: generate diff summary, list files modified, produce compare URL"}` | SC-1, SC-2, SC-3, SC-4 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"issue":1223,"phase":1,"task":"produce executive summary: what was done, SC PASS/FAIL table, any blockers or concerns"}` | SC-1, SC-2, SC-3, SC-4 |

---

## SC-ID Traceability

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `_rebase_issues_branch()` returns None when no remote | behavioral |
| SC-2 | `_push_issues_branch_safe()` returns None when no remote | behavioral |
| SC-3 | `_sync_repo()` returns `{"status": "no_remote"}` for no-remote repos | behavioral |
| SC-4 | Repo with remote: existing behavior unaffected | behavioral |

---

## Post-All-Phases Sweep

1. Tag submodule: `.opencode/checkpoint/1223/post`
2. Run enforcement tests: `bash .opencode/tests/test-enforcement.sh --changed`
3. Run finish-checklist: `skill({name: "finishing-a-development-branch"})`

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.