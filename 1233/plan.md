# Plan — [SPEC-FIX] check-pr task card: replace defective prose with validated 6-phase checklist

**Issue:** [michael-conrad/.opencode#1233](https://github.com/michael-conrad/.opencode/issues/1233)
**Goal:** Replace the defective `tasks/check-pr.md` task card (prose + Python pseudocode) with a validated 6-phase serial chain checklist using `- [ ]` items throughout.
**Architecture:** Single-file replacement of `.opencode/skills/git-workflow/tasks/check-pr.md`. No other files modified.
**Tech Stack:** Markdown task card (opencode skill task file). No code changes.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Phase 1: Replace check-pr.md with Validated 6-Phase Checklist

**Concern:** Content replacement — write new task card with deterministic `- [ ]` checklist items across 6 serial phases.
**Files:** `.opencode/skills/git-workflow/tasks/check-pr.md`
**SCs covered:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "Verify spec coherence for #1233: single-file replacement of check-pr.md with 6-phase checklist", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-11 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "Read current check-pr.md at .opencode/skills/git-workflow/tasks/check-pr.md and document its defects (prose steps, no checklists, underspecified decision logic, no submodule awareness)", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-1 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "Write a content-verification test that asserts the current check-pr.md contains prose numbered sections (defect pattern). Test must FAIL on current content.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-1 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "Verify the RED test from G3 fails against current check-pr.md content. Report PASS if test fails, FAIL if test passes.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-1 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "Verify no implementation code has been written yet (git diff --name-only -- src/ shows 0 lines). Report structural gate result.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | — |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "Write the new check-pr.md at .opencode/skills/git-workflow/tasks/check-pr.md with the validated 6-phase serial chain structure. Each phase must use - [ ] checklist items. No prose numbered sections. No Python pseudocode blocks. The 6 phases are: Phase 1: Scan for Merged PRs (ls -d .git/ */.git/ */.git/ glob), Phase 2: Verify Each Merge (confirm merged_at is set), Phase 3: Clean Up Branches (delete local+remote, preserve hash-permanence tags, delete checkpoint tags), Phase 4: Close Linked Issues (active investigation, depth-first: sub-repos first, children before parents, no comment churn), Phase 5: Submodule Reconciliation (clean up submodule feature branches, restore to dev tip), Phase 6: Final State (branch-aware parking per current branch type, leave submodule pointers dirty). Include enforcement gate header from existing card. Include entry/exit criteria per phase.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "Verify the new check-pr.md file exists and has - [ ] checklist items (grep for '- [ ]' returns >0 lines). Report structural gate result.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-1 |
| G8: checkpoint-commit | inline | N/A | N/A | — | — |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "Run structural verification on the new check-pr.md: (1) grep for '- [ ]' — must have items, (2) grep for '```python' — must be absent, (3) grep for 'Step 1' / 'Step 2' / 'Step 3' as numbered prose headings — must be absent, (4) verify Phase 1 has 'ls -d .git/' glob, (5) verify Phase 3 mentions hash-permanence tags, (6) verify Phase 4 mentions depth-first closure, (7) verify Phase 6 mentions branch-aware parking. Report PASS/FAIL per check.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "Verify the new check-pr.md content matches the spec's 6-phase structure. Read the file and confirm: Phase 1 scans repos, Phase 2 verifies merge state, Phase 3 deletes branches preserving tags, Phase 4 closes issues depth-first, Phase 5 reconciles submodules, Phase 6 parks branches. Report PASS/FAIL per phase.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-1 through SC-10 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "Run verification-before-completion for #1233. Verify all 10 string-type SCs (SC-1 through SC-10) against the new check-pr.md file content. Produce evidence artifacts at ./tmp/1233/artifacts/.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-1 through SC-10 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "Run adversarial audit on the new check-pr.md content. Verify: (1) no prose numbered sections, (2) all 6 phases present in correct order, (3) each phase has actionable - [ ] items, (4) no Python pseudocode, (5) submodule-aware decision paths present, (6) branch existence verification mechanism specified, (7) exit criteria complete. Report PASS/FAIL per finding.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-1 through SC-10 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "Cross-validate the adversarial audit findings against the spec SCs. Verify no EVIDENCE_TYPE_MISMATCH (string SCs verified with string evidence). Report consensus PASS/FAIL.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-1 through SC-10 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "Run content-verification enforcement tests: bash .opencode/tests/test-enforcement.sh --tag check-pr. Verify existing tests still pass after the replacement.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | — |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "Prepare review for #1233: verify git status clean, verify new check-pr.md is the only changed file, generate compare URL.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | — |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "Generate completion summary for #1233: report what was replaced, which SCs are verified, and the PR URL.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | — |

### Inter-Phase Handoff

N/A — single phase plan. No inter-phase handoff needed.

---

## Phase 2: Behavioral Verification (SC-11, SC-12)

**Concern:** Behavioral evidence — verify the sub-agent executing the new card produces correct cleanup behavior.
**Files:** `.opencode/skills/git-workflow/tasks/check-pr.md` (read-only verification)
**SCs covered:** SC-11, SC-12

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "Verify behavioral SCs (SC-11, SC-12) require behavioral evidence. Confirm SC-11 (serial phase ordering) and SC-12 (correct cleanup) need opencode-cli run with clean-room semantic inspection.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-11, SC-12 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "Document the current behavioral test baseline for check-pr. Check if any behavioral tests exist at .opencode/tests/behaviors/ for check-pr or cleanup scenarios.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-11, SC-12 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "Write a behavioral test script at .opencode/tests/behaviors/check-pr-6-phase.sh that: (1) sets up a test repo with a merged PR and uncleaned branch, (2) runs opencode-cli run 'check prs' with the new check-pr.md, (3) asserts the agent follows the 6-phase serial chain (SC-11) and produces correct cleanup (SC-12). Test must FAIL on old card content.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-11, SC-12 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "Run the behavioral test from G3 against the current (old) check-pr.md. Verify it FAILS. Report PASS if test fails, FAIL if test passes.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-11, SC-12 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "Verify no implementation changes have been made to check-pr.md beyond what Phase 1 produced. git diff --name-only -- .opencode/skills/git-workflow/tasks/check-pr.md should show the Phase 1 replacement only.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | — |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "The check-pr.md has already been replaced in Phase 1. Verify the behavioral test from G3 now PASSES against the new content. Run the test and report result.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-11, SC-12 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "Verify the behavioral test PASSES. If FAIL, report blocker. If PASS, confirm SC-11 and SC-12 are verified.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-11, SC-12 |
| G8: checkpoint-commit | inline | N/A | N/A | — | — |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "Verify the behavioral test script exists at .opencode/tests/behaviors/check-pr-6-phase.sh and is syntactically valid (bash -n check).", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-11, SC-12 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "Re-run the behavioral test from G3 one more time to confirm non-flaky PASS. Report result.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-11, SC-12 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "Run verification-before-completion for SC-11 and SC-12. Verify behavioral evidence artifacts exist at ./tmp/1233/artifacts/. Report PASS/FAIL.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-11, SC-12 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "Run adversarial audit on behavioral evidence for SC-11 and SC-12. Verify: (1) SC-11 evidence proves serial phase ordering, (2) SC-12 evidence proves correct cleanup behavior, (3) no EVIDENCE_TYPE_MISMATCH (behavioral SCs verified with behavioral evidence). Report PASS/FAIL.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-11, SC-12 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "Cross-validate behavioral audit findings. Verify consensus between auditors. Report PASS/FAIL.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-11, SC-12 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "Run all enforcement tests: bash .opencode/tests/test-enforcement.sh. Verify no regressions from the check-pr.md replacement.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | — |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "Final review prep for #1233: verify all 12 SCs have evidence artifacts, verify git status clean, generate compare URL.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-1 through SC-12 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "Generate final completion summary for #1233. Report all 12 SCs with evidence types and verification status. Include PR URL.", "issue_number": 1233, "owner": "michael-conrad", "repo": ".opencode"}` | SC-1 through SC-12 |

### Inter-Phase Handoff

N/A — final phase. Proceed to Post-All-Phases Sweep.

---

## Post-All-Phases Sweep

- [ ] FINISHING CHECKLIST — orchestrator routes to finishing sub-agent: git status clean, lint/typecheck from scratch, coverage sweep
- [ ] PR CREATION — orchestrator routes to git-workflow pr-creation: via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — orchestrator routes to git-workflow cleanup: delete merged branches, close issues, sync dev

---

## SC Coverage Summary

| SC | Evidence Type | Phase | Verification Method |
|----|--------------|-------|---------------------|
| SC-1 | string | Phase 1 | grep for `- [ ]` checklist format, no prose numbered sections |
| SC-2 | string | Phase 1 | grep for `ls -d .git/` glob pattern |
| SC-3 | string | Phase 1 | grep for `merged_at` or merge state check |
| SC-4 | string | Phase 1 | grep for branch deletion (local + remote) |
| SC-5 | string | Phase 1 | grep for hash-permanence tag preservation |
| SC-6 | string | Phase 1 | grep for active issue investigation (not regex body text) |
| SC-7 | string | Phase 1 | grep for depth-first closure (sub-repos first) |
| SC-8 | string | Phase 1 | grep for no-comment-churn or silent closure |
| SC-9 | string | Phase 1 | grep for submodule feature branch cleanup |
| SC-10 | string | Phase 1 | grep for branch-aware parking rules |
| SC-11 | behavioral | Phase 2 | opencode-cli run → assert_semantic (serial phase ordering) |
| SC-12 | behavioral | Phase 2 | opencode-cli run → assert_semantic (correct cleanup behavior) |

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 OpenCode (deepseek-v4-flash)
