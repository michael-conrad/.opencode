# Implementation Plan — [.opencode#1439](https://github.com/michael-conrad/.opencode/issues/1439) — Fix wrong spec_path in local-issues list/search

- **Goal:** Fix `local-issues list` and `local-issues search` to print `spec_path=.issues/N` per issue instead of the incorrect `spec_path=.issues`.
- **Architecture:** Single-file change to `.opencode/tools/local-issues`. Move `spec_path` computation inside the per-issue loop in two functions, reusing the existing `_find_issue_dir_in_repo()` helper.
- **Files:**
  - `.opencode/tools/local-issues` — `_search_in_repo()` (line ~1319) and `_list_issues_in_repo()` (line ~1392)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

## Phase 1 — Fix spec_path in _search_in_repo and _list_issues_in_repo

- **Concern:** Correct per-issue `spec_path` output in `list` and `search` commands
- **Files:** `.opencode/tools/local-issues`
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** None
- **Entry:** Feature branch created, spec approved
- **Exit:** Both functions compute `spec_path` per-issue, all SCs verified PASS

- [ ] 1. **Coherence gate (**clean-room**).** Verify the spec's root cause analysis matches the actual code: `_search_in_repo()` computes `spec_path` once at line 1320 outside the loop; `_list_issues_in_repo()` computes `spec_path` once at line 1393 outside the loop. Confirm `_find_issue_dir_in_repo()` exists at line 66 and accepts `(number, repo_path)` signature. **→ SC-1, SC-2**

- [ ] 2. **Pre-RED baseline (**inline**).** Run `local-issues list` and `local-issues search` to capture current (broken) output. Save to `./tmp/pre-fix-baseline.log`. Confirm `spec_path=.issues` appears (not `.issues/N`).

- [ ] 3. **RED phase — behavioral test (**sub-agent**).** Write a behavioral enforcement test that runs `local-issues list` and `local-issues search` and asserts `spec_path=.issues/N` (not `.issues`). The test MUST FAIL at this point because the fix hasn't been applied. **→ SC-1, SC-2**

- [ ] 4. **Z3 check — RED (**inline**).** Run `solve check` to verify RED test artifact exists and shows FAIL status.

- [ ] 5. **RED doublecheck (**inline**).** Re-read the RED test output to confirm it fails with the expected pattern (`spec_path=.issues` present, `spec_path=.issues/N` absent).

- [ ] 6. **Z3 check — RED doublecheck (**inline**).** Run `solve check` to verify RED doublecheck artifact confirms expected failure.

- [ ] 7. **Post-RED enforcement (**inline**).** Confirm no GREEN implementation has started — only the RED test exists.

- [ ] 8. **Z3 check — post-RED (**inline**).** Run `solve check` to verify post-RED enforcement status is PASS.

- [ ] 9. **GREEN phase — fix `_search_in_repo()` (**sub-agent**).** In `_search_in_repo()`, move `spec_path` computation inside the per-issue loop. Replace the single `spec_path` at line 1320 with a per-issue call: `spec_path = _spec_path_for_issue(num, repo_path)` inside the loop body (after `seen.add(num)`). The `_spec_path_for_issue()` function already calls `_find_issue_dir_in_repo()` and returns the correct relative path. **→ SC-1**

- [ ] 10. **GREEN phase — fix `_list_issues_in_repo()` (**sub-agent**).** In `_list_issues_in_repo()`, move `spec_path` computation inside the per-issue loop. Replace the single `spec_path` at line 1393 with a per-issue call: `spec_path = _spec_path_for_issue(num, repo_path)` inside the loop body (after `seen.add(num)`). **→ SC-2**

- [ ] 11. **Z3 check — GREEN (**inline**).** Run `solve check` to verify both GREEN changes are applied and the RED test now passes.

- [ ] 12. **Post-GREEN enforcement (**inline**).** Confirm the RED test passes with the fix applied. Run `local-issues list` and `local-issues search` to verify `spec_path=.issues/N` appears.

- [ ] 13. **Z3 check — post-GREEN (**inline**).** Run `solve check` to verify post-GREEN enforcement status is PASS.

- [ ] 14. **Checkpoint tag create (**inline**).** Create checkpoint tag: `opencode-config/checkpoint/1439/phase-1-opencode`.

- [ ] 15. **Checkpoint commit (**inline**).** Commit the fix with message: `fix: per-issue spec_path in _search_in_repo and _list_issues_in_repo (#1439)`.

- [ ] 16. **Structural checks (**inline**).** Run `ruff check .opencode/tools/local-issues` and `pyright .opencode/tools/` to confirm no lint or type errors.

- [ ] 17. **GREEN doublecheck (**inline**).** Re-run the behavioral test to confirm PASS. Run `local-issues list` and `local-issues search` manually and inspect output for `spec_path=.issues/N`. **→ SC-1, SC-2**

- [ ] 18. **GREEN VbC (**clean-room**).** Verify all SCs:
  - SC-1: `local-issues list` output shows `spec_path=.issues/N` for each issue
  - SC-2: `local-issues search` output shows `spec_path=.issues/N` for each result
  - SC-3: `local-issues read N` still shows correct `spec_path=.issues/N` (no regression)
  - SC-4: grep for all callers of `_spec_path_for_issue()` and `_find_issue_dir_in_repo()` — confirm no other callers need updating

- [ ] 19. **Adversarial audit — spec-fidelity (**sub-agent**).** Dispatch adversarial auditor to verify the fix matches the spec's root cause analysis and success criteria. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 20. **Adversarial audit — concern-separation (**sub-agent**).** Dispatch adversarial auditor to verify the fix is scoped to the single concern (spec_path in list/search) and does not introduce unrelated changes.

- [ ] 21. **Cross-validate (**sub-agent**).** Dispatch cross-validation sub-agent to verify all SC evidence artifacts exist and are consistent.

- [ ] 22. **Regression check (**inline**).** Run `local-issues read` on a known issue to confirm no regression. Run `local-issues list` and `local-issues search` to confirm all three commands produce correct `spec_path=.issues/N`.

- [ ] 23. **Review prep (**sub-agent**).** Dispatch review-prep to prepare the branch for PR: squash commits, write PR body, generate compare URL.

- [ ] 24. **Executive summary (**inline**).** Report: fix applied to `_search_in_repo()` and `_list_issues_in_repo()`, both now compute `spec_path` per-issue via `_spec_path_for_issue()`. All SCs verified PASS.

#### Phase 1 VbC

- [ ] 25. **VbC (**clean-room**).** Verify all SCs: SC-1 (list output), SC-2 (search output), SC-3 (read no regression), SC-4 (no other callers affected). **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving spec_path fix in list/search commands. No further phases — single-phase plan.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- C1: `_search_in_repo()` computes `spec_path` per-issue inside the loop using `_spec_path_for_issue()`
- C2: `_list_issues_in_repo()` computes `spec_path` per-issue inside the loop using `_spec_path_for_issue()`
- C3: `local-issues list` prints `spec_path=.issues/N` for each issue
- C4: `local-issues search` prints `spec_path=.issues/N` for each result
- C5: `local-issues read` continues to print correct `spec_path=.issues/N` (no regression)
- C6: No other callers of `_spec_path_for_issue()` or `_find_issue_dir_in_repo()` are affected
- C7: All lint and type checks pass
- C8: Behavioral test passes with the fix applied
