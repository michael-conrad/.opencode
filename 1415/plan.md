# Implementation Plan — [#1415](https://github.com/michael-conrad/.opencode/issues/1415) — verify-already-implemented gate in for_pr auto-dispatch before gap-fill

- **Goal:** Add a `verify-already-implemented` dispatch to the `for_pr` auto-dispatch row in `auto-dispatch-table.md` so that already-implemented specs are autoclosed before gap-fill creates unnecessary artifacts.
- **Architecture:** Single-file edit to `approval-gate/enforcement/auto-dispatch-table.md` (p1) + two behavioral enforcement test scripts (p2). No new tasks or gates — the existing `verify-already-implemented.md` task handles autoclose correctly. The change is purely in the routing table.
- **Files:**
  - `.opencode/skills/approval-gate/enforcement/auto-dispatch-table.md` — add `verify-already-implemented` dispatch before gap-fill in `for_pr` row
  - `.opencode/tests/behaviors/1415-sc2-autoclose-already-implemented.sh` — behavioral test for SC-2
  - `.opencode/tests/behaviors/1415-sc3-gap-fill-unimplemented.sh` — behavioral test for SC-3

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

## Phase 1 — File Change: Update for_pr row in auto-dispatch-table.md

- **Concern:** Add `verify-already-implemented` dispatch to the `for_pr` scope row in `auto-dispatch-table.md`, inserted before the gap-fill dispatch. Single file, single edit.
- **Files:** `.opencode/skills/approval-gate/enforcement/auto-dispatch-table.md`
- **SCs:** SC-1
- **Dependencies:** None
- **Entry:** Spec approved, plan authorization confirmed, feature branch created
- **Exit:** `for_pr` row in `auto-dispatch-table.md` includes `verify-already-implemented` dispatch before gap-fill; RED test fails, GREEN test passes

- [ ] 1. **Pre-flight handoff (**clean-room**).** Execute `implementation-pipeline --task pre-flight-handoff` — validates RED checkpoints, SC-ID traceability, approval cascade state, verification gate preservation, and manifest writes at `./tmp/{issue-1415}/artifacts/plan-to-pipeline-handoff-*.yaml`. **→ SC-1**
- [ ] 2. **Handoff-consistency check (**inline**).** Read both `spec-to-plan-handoff-*.yaml` and `plan-to-pipeline-handoff-*.yaml` manifests and compare shared variables (SC coverage total, decomposition classification, phase count). BLOCK on mismatch. **→ SC-1**
- [ ] 3. **Coherence gate (**clean-room**).** Execute `adversarial-audit --task coherence-extraction` — evidence-type uplift + substrate classification for SC-1. Verify the plan-to-file mapping is coherent: the `for_pr` row in `auto-dispatch-table.md` is the correct target for the change. **→ SC-1**
- [ ] 4. **Pre-RED baseline (**clean-room**).** Execute `implementation-pipeline --task pre-red-baseline` — doc-source-currency check on `auto-dispatch-table.md` + SC-ID cross-ref traceability. Produce solution state file + source currency report. **→ SC-1**
- [ ] 5. **RED phase (**sub-agent**).** Execute `test-driven-development --task red` — write a content-verification test (string evidence) that greps for `verify-already-implemented` in the `for_pr` row of `auto-dispatch-table.md`. The test MUST FAIL because the dispatch entry does not exist yet. Write test to `./tmp/issue-1415/artifacts/`. **→ SC-1**
- [ ] 6. **Z3 check RED (**inline**).** Execute `solve check` against red-phase output contract (`contracts/red-phase-output-template.yaml`). **→ SC-1**
- [ ] 7. **RED doublecheck (**clean-room**).** Execute `verification-before-completion --task verify` — verify the RED test artifact exists and the grep assertion fails against the current file content. **→ SC-1**
- [ ] 8. **Z3 check RED doublecheck (**inline**).** Execute `solve check` against red-doublecheck output contract (`contracts/red-doublecheck-output-template.yaml`). **→ SC-1**
- [ ] 9. **Post-RED enforcement (**clean-room**).** Execute `implementation-pipeline --task post-red-enforcement` — `git diff --name-only -- src/ | wc -l` must be 0 (no source changes in RED phase). **→ SC-1**
- [ ] 10. **Z3 check post-RED (**inline**).** Execute `solve check` against post-red-enforcement output contract (`contracts/post-red-enforcement-output-template.yaml`). **→ SC-1**
- [ ] 11. **GREEN phase (**sub-agent**).** Execute `test-driven-development --task green` — edit `auto-dispatch-table.md` to add `verify-already-implemented` dispatch before gap-fill in the `for_pr` row. The `for_pr` row currently reads:
      ```
      | `for_pr` | Auto-create spec+plan (gap-fill), auto-approve, proceed through PR creation, stacked PR |
      ```
      Change to:
      ```
      | `for_pr` | Verify already-implemented, auto-create spec+plan (gap-fill), auto-approve, proceed through PR creation, stacked PR |
      ```
      Re-run the RED test — it MUST PASS now. **→ SC-1**
- [ ] 12. **Z3 check GREEN (**inline**).** Execute `solve check` against green-phase output contract (`contracts/green-phase-output-template.yaml`). **→ SC-1**
- [ ] 13. **Post-GREEN enforcement (**clean-room**).** Execute `implementation-pipeline --task post-green-enforcement` — `git diff --name-only -- test/ | wc -l` must be 0 (no test changes in GREEN phase). **→ SC-1**
- [ ] 14. **Z3 check post-GREEN (**inline**).** Execute `solve check` against post-green-enforcement output contract (`contracts/post-green-enforcement-output-template.yaml`). **→ SC-1**
- [ ] 15. **Checkpoint tag create (**clean-room**).** Execute `implementation-pipeline --task checkpoint-tag-create` — create git tag `opencode-config/checkpoint/1415/phase-1-.opencode`. **→ SC-1**
- [ ] 16. **Checkpoint commit (**inline**).** Execute `git-workflow --task commit-prep` — commit the RED test artifact and the GREEN file edit together as one working slice. **→ SC-1**
- [ ] 17. **Structural checks (**clean-room**).** Execute `finishing-a-development-branch --task checklist` — run lint/typecheck/format on changed files. **→ SC-1**
- [ ] 18. **GREEN doublecheck (**clean-room**).** Execute `verification-before-completion --task verify` — semantic-intent verification: confirm the `for_pr` row now routes to `verify-already-implemented` before gap-fill. **→ SC-1**
- [ ] 19. **GREEN VbC (**clean-room**).** Execute `verification-before-completion --task completion` — produce VbC completion artifact for SC-1. **→ SC-1**
- [ ] 20. **Completeness gate (**clean-room**).** Execute `completeness-gate --task check` — non-adversarial completeness check on the deliverable before routing to adversarial audit. **→ SC-1**
- [ ] 21. **Resolve models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors. **→ SC-1**
- [ ] 22. **Adversarial audit — auditor 1 (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `subagent_type` from auditor_1. If non-clean-pass (FAIL): remediate root cause, re-run resolve-models, restart from step 21. `DONE_WITH_CONCERNS` coerced to FAIL. **→ SC-1**
- [ ] 23. **Adversarial audit — auditor 2 (**sub-agent**).** Dispatch same audit task with `subagent_type` from auditor_2. If non-clean-pass: remediate root cause, re-run resolve-models, restart from step 21. **→ SC-1**
- [ ] 24. **Cross-validate (**clean-room**).** Execute `adversarial-audit --task cross-validate` — receives `auditor_artifact_paths` from steps 22-23. Produce cross-validate findings YAML. **→ SC-1**
- [ ] 25. **Regression check (**clean-room**).** Execute `test-driven-development --task patterns` (regression) — verify no other scope rows in `auto-dispatch-table.md` were affected. **→ SC-1**
- [ ] 26. **Review prep (**clean-room**).** Execute `git-workflow --task review-prep` — push, compare URL. **→ SC-1**
- [ ] 27. **Exec summary (**clean-room**).** Execute `completion-core --task completion` — append lifecycle event + chat exec summary. **→ SC-1**

#### Phase 1 VbC

- [ ] 28. **VbC (**clean-room**).** Verify SC-1: `grep -n 'verify-already-implemented' .opencode/skills/approval-gate/enforcement/auto-dispatch-table.md` returns a match in the `for_pr` row. **→ SC-1**

**Concern transition:** Leaving file-change (auto-dispatch-table.md edit) → entering behavioral-test creation (SC-2 and SC-3 enforcement tests). Phase 2 depends on Phase 1's deliverable (the `for_pr` row must already contain the `verify-already-implemented` dispatch so that behavioral tests can exercise the new routing).

## Phase 2 — Behavioral Tests: Create enforcement tests for SC-2 and SC-3

- **Concern:** Create two behavioral enforcement test scripts that verify the agent's actual behavior when `for_pr` authorization is given: (a) autoclose on already-implemented spec, (b) gap-fill + PR creation on unimplemented spec.
- **Files:**
  - `.opencode/tests/behaviors/1415-sc2-autoclose-already-implemented.sh`
  - `.opencode/tests/behaviors/1415-sc3-gap-fill-unimplemented.sh`
- **SCs:** SC-2, SC-3
- **Dependencies:** Phase 1 (the `for_pr` row must already route to `verify-already-implemented` before gap-fill)
- **Entry:** Phase 1 complete — `auto-dispatch-table.md` has `verify-already-implemented` in `for_pr` row
- **Exit:** Both behavioral test scripts exist, RED tests fail (no agent behavior change yet), GREEN tests pass after agent behavior is verified

- [ ] 29. **Pre-flight handoff (**clean-room**).** Execute `implementation-pipeline --task pre-flight-handoff` — validates RED checkpoints, SC-ID traceability, approval cascade state, verification gate preservation, and manifest writes at `./tmp/{issue-1415}/artifacts/plan-to-pipeline-handoff-*.yaml`. **→ SC-2, SC-3**
- [ ] 30. **Handoff-consistency check (**inline**).** Read both `spec-to-plan-handoff-*.yaml` and `plan-to-pipeline-handoff-*.yaml` manifests and compare shared variables. BLOCK on mismatch. **→ SC-2, SC-3**
- [ ] 31. **Coherence gate (**clean-room**).** Execute `adversarial-audit --task coherence-extraction` — verify the behavioral test approach is coherent with SC-2 and SC-3 evidence types (both `behavioral`). **→ SC-2, SC-3**
- [ ] 32. **Pre-RED baseline (**clean-room**).** Execute `implementation-pipeline --task pre-red-baseline` — doc-source-currency check on existing behavioral test patterns in `.opencode/tests/behaviors/` + SC-ID cross-ref traceability. **→ SC-2, SC-3**
- [ ] 33. **RED — SC-2 test (**sub-agent**).** Execute `test-driven-development --task red` — write behavioral test `1415-sc2-autoclose-already-implemented.sh` that:
      - Sets up a spec that is already implemented and merged
      - Sends `for_pr` authorization prompt via `opencode-cli run`
      - Asserts the issue is closed with `state_reason: completed` (via `assert_semantic` clean-room inspector)
      - Asserts NO PR is created (via `assert_semantic`)
      The test MUST FAIL because the agent does not yet route to `verify-already-implemented` before gap-fill (the behavioral test exercises the full agent, not just the file content). **→ SC-2**
- [ ] 34. **Z3 check RED (**inline**).** Execute `solve check` against red-phase output contract. **→ SC-2**
- [ ] 35. **RED doublecheck (**clean-room**).** Execute `verification-before-completion --task verify` — verify the SC-2 RED test artifact exists and fails when run. **→ SC-2**
- [ ] 36. **Z3 check RED doublecheck (**inline**).** Execute `solve check` against red-doublecheck output contract. **→ SC-2**
- [ ] 37. **Post-RED enforcement (**clean-room**).** Execute `implementation-pipeline --task post-red-enforcement` — `git diff --name-only -- src/ | wc -l` must be 0. **→ SC-2**
- [ ] 38. **Z3 check post-RED (**inline**).** Execute `solve check` against post-red-enforcement output contract. **→ SC-2**
- [ ] 39. **RED — SC-3 test (**sub-agent**).** Execute `test-driven-development --task red` — write behavioral test `1415-sc3-gap-fill-unimplemented.sh` that:
      - Sets up a spec that is NOT yet implemented
      - Sends `for_pr` authorization prompt via `opencode-cli run`
      - Asserts a PR IS created (via `assert_semantic` clean-room inspector)
      - Asserts the issue remains open (via `assert_semantic`)
      The test MUST FAIL because the agent does not yet route correctly. **→ SC-3**
- [ ] 40. **Z3 check RED (**inline**).** Execute `solve check` against red-phase output contract. **→ SC-3**
- [ ] 41. **RED doublecheck (**clean-room**).** Execute `verification-before-completion --task verify` — verify the SC-3 RED test artifact exists and fails when run. **→ SC-3**
- [ ] 42. **Z3 check RED doublecheck (**inline**).** Execute `solve check` against red-doublecheck output contract. **→ SC-3**
- [ ] 43. **Post-RED enforcement (**clean-room**).** Execute `implementation-pipeline --task post-red-enforcement` — `git diff --name-only -- src/ | wc -l` must be 0. **→ SC-2, SC-3**
- [ ] 44. **Z3 check post-RED (**inline**).** Execute `solve check` against post-red-enforcement output contract. **→ SC-2, SC-3**
- [ ] 45. **GREEN — SC-2 test (**sub-agent**).** Execute `test-driven-development --task green` — the SC-2 behavioral test was already written in step 33. The GREEN phase for SC-2 is verifying that the test passes when run against the agent with the Phase 1 change in place. Re-run `1415-sc2-autoclose-already-implemented.sh` — it MUST PASS now because the agent routes to `verify-already-implemented` before gap-fill. **→ SC-2**
- [ ] 46. **Z3 check GREEN (**inline**).** Execute `solve check` against green-phase output contract. **→ SC-2**
- [ ] 47. **Post-GREEN enforcement (**clean-room**).** Execute `implementation-pipeline --task post-green-enforcement` — `git diff --name-only -- test/ | wc -l` must be 0 (no test changes in GREEN phase). **→ SC-2**
- [ ] 48. **Z3 check post-GREEN (**inline**).** Execute `solve check` against post-green-enforcement output contract. **→ SC-2**
- [ ] 49. **GREEN — SC-3 test (**sub-agent**).** Execute `test-driven-development --task green` — re-run `1415-sc3-gap-fill-unimplemented.sh` — it MUST PASS now because the agent routes to `verify-already-implemented`, determines the spec is NOT already implemented, and proceeds with gap-fill + PR creation. **→ SC-3**
- [ ] 50. **Z3 check GREEN (**inline**).** Execute `solve check` against green-phase output contract. **→ SC-3**
- [ ] 51. **Post-GREEN enforcement (**clean-room**).** Execute `implementation-pipeline --task post-green-enforcement` — `git diff --name-only -- test/ | wc -l` must be 0. **→ SC-3**
- [ ] 52. **Z3 check post-GREEN (**inline**).** Execute `solve check` against post-green-enforcement output contract. **→ SC-3**
- [ ] 53. **Checkpoint tag create (**clean-room**).** Execute `implementation-pipeline --task checkpoint-tag-create` — create git tag `opencode-config/checkpoint/1415/phase-2-.opencode`. **→ SC-2, SC-3**
- [ ] 54. **Checkpoint commit (**inline**).** Execute `git-workflow --task commit-prep` — commit both behavioral test files together as one working slice. **→ SC-2, SC-3**
- [ ] 55. **Structural checks (**clean-room**).** Execute `finishing-a-development-branch --task checklist` — run lint/typecheck/format on changed files. **→ SC-2, SC-3**
- [ ] 56. **GREEN doublecheck (**clean-room**).** Execute `verification-before-completion --task verify` — semantic-intent verification: confirm both behavioral tests pass and exercise the correct agent behavior paths. **→ SC-2, SC-3**
- [ ] 57. **GREEN VbC (**clean-room**).** Execute `verification-before-completion --task completion` — produce VbC completion artifact for SC-2 and SC-3. **→ SC-2, SC-3**
- [ ] 58. **Completeness gate (**clean-room**).** Execute `completeness-gate --task check` — non-adversarial completeness check on both behavioral test deliverables before routing to adversarial audit. **→ SC-2, SC-3**
- [ ] 59. **Resolve models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors. **→ SC-2, SC-3**
- [ ] 60. **Adversarial audit — auditor 1 (**sub-agent**).** Dispatch `adversarial-audit --task verification-audit` with `subagent_type` from auditor_1. If non-clean-pass: remediate, re-run resolve-models, restart from step 59. **→ SC-2, SC-3**
- [ ] 61. **Adversarial audit — auditor 2 (**sub-agent**).** Dispatch same audit task with `subagent_type` from auditor_2. If non-clean-pass: remediate, re-run resolve-models, restart from step 59. **→ SC-2, SC-3**
- [ ] 62. **Cross-validate (**clean-room**).** Execute `adversarial-audit --task cross-validate` — receives `auditor_artifact_paths` from steps 60-61. **→ SC-2, SC-3**
- [ ] 63. **Regression check (**clean-room**).** Execute `test-driven-development --task patterns` (regression) — verify existing behavioral tests in `.opencode/tests/behaviors/` are not broken by the new tests. **→ SC-2, SC-3**
- [ ] 64. **Review prep (**clean-room**).** Execute `git-workflow --task review-prep` — push, compare URL. **→ SC-2, SC-3**
- [ ] 65. **Exec summary (**clean-room**).** Execute `completion-core --task completion` — append lifecycle event + chat exec summary. **→ SC-2, SC-3**

#### Phase 2 VbC

- [ ] 66. **VbC (**clean-room**).** Verify SC-2: Run `1415-sc2-autoclose-already-implemented.sh` — test passes with `assert_semantic` confirming issue closed and no PR created. **→ SC-2**
- [ ] 67. **VbC (**clean-room**).** Verify SC-3: Run `1415-sc3-gap-fill-unimplemented.sh` — test passes with `assert_semantic` confirming PR created. **→ SC-3**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- **C1.** `for_pr` row in `auto-dispatch-table.md` includes `verify-already-implemented` dispatch before gap-fill (SC-1 — string evidence via grep)
- **C2.** Behavioral test `1415-sc2-autoclose-already-implemented.sh` exists and passes — verifies agent autocloses already-implemented spec with no PR created (SC-2 — behavioral evidence via `assert_semantic`)
- **C3.** Behavioral test `1415-sc3-gap-fill-unimplemented.sh` exists and passes — verifies agent proceeds with gap-fill and PR creation for unimplemented spec (SC-3 — behavioral evidence via `assert_semantic`)
- **C4.** All implementation-pipeline gates executed in order per plan steps 1-67 — no steps skipped, combined, or reordered
- **C5.** Adversarial audit passed with dual cross-family auditor consensus — both auditors returned clean PASS
- **C6.** Cross-validate findings YAML produced with no unresolved findings
- **C7.** Regression check passed — existing behavioral tests in `.opencode/tests/behaviors/` are not broken
- **C8.** Review prep completed — branch pushed, compare URL produced
- **C9.** Lifecycle manifest at `./tmp/{issue-1415}/lifecycle.yaml` has monotonically increasing event count
