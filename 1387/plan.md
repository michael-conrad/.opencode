# Implementation Plan — [#1387](https://github.com/michael-conrad/.opencode/issues/1387) — Skill card linting rules (SC-LINT-001 through 006)

- **Goal:** Add 6 structural linting rules to `validate_skill_cards.py` in the `skill-creator` skill. Each rule produces `{ rule_id, skill_name, severity, pass/fail, detail }`. Linter reports all failures, not first-failure-only.
- **Architecture:** Single phase `implement-lint-rules` with 3 sub-phases: pre-phase analysis, per-rule RED+green implementation (6 independent rules), post-phase verification. All changes in `validate_skill_cards.py`.
- **Spec:** #1387
- **Files:** `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

## Phase 1 — implement-lint-rules

**Concern:** Add 6 structural linting rules to `validate_skill_cards.py` for skill card description compliance. Each rule produces structured result `{ rule_id, skill_name, severity, pass/fail, detail }`. Linter reports all failures.

**Files:** `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8

**Dependencies:** None

**Entry conditions:** Spec approved, plan written, feature branch created

**Exit conditions:** All 6 rules implemented, behavioral tests pass, adversarial audit passes

### Sub-phase 1 — Pre-phase analysis

- [ ] 1. **Coherence gate (**clean-room**).** Verify spec coherence against codebase: read `validate_skill_cards.py` to confirm file exists and understand current structure. Note that `validate_req1` already checks `description.startswith("Use when")` — SC-LINT-001 must be extracted into its own rule with structured output. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8**
- [ ] 2. **Pre-red-baseline (**clean-room**).** Run existing tests for `validate_skill_cards.py` to establish baseline PASS. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8**

### Sub-phase 2 — Per-rule implementation (6 independent rules)

#### Item chain — SC-LINT-001 (Description starts with "Use when")

- [ ] 3. **RED (**clean-room**).** Write behavioral enforcement test for SC-LINT-001. Test sends a prompt with a skill card missing "Use when" and asserts the linter detects it. Verify test FAILS. **→ SC-1**
- [ ] 4. **Z3 check (**inline**).** `solve check` — verify RED test artifact exists and shows FAIL. **→ SC-1**
- [ ] 5. **RED doublecheck (**clean-room**).** Re-read RED test artifact to confirm it correctly targets SC-LINT-001. **→ SC-1**
- [ ] 6. **Z3 check (**inline**).** `solve check` — verify doublecheck confirms RED validity. **→ SC-1**
- [ ] 7. **Post-RED enforcement (**inline**).** Verify no GREEN work was started before RED passed. **→ SC-1**
- [ ] 8. **Z3 check (**inline**).** `solve check` — verify post-RED enforcement clean. **→ SC-1**
- [ ] 9. **GREEN (**clean-room**).** Implement SC-LINT-001 in `validate_skill_cards.py`. Extract the existing `description.startswith("Use when")` check from `validate_req1` into a standalone linting function. Add `severity` and `pass/fail` fields to the result. Produces `{ rule_id: "SC-LINT-001", skill_name, severity: "ERROR", pass/fail, detail }`. **→ SC-1, SC-7**
- [ ] 10. **Z3 check (**inline**).** `solve check` — verify GREEN implementation artifact exists. **→ SC-1**
- [ ] 11. **Post-GREEN enforcement (**inline**).** Verify GREEN implementation matches spec. **→ SC-1**
- [ ] 12. **Z3 check (**inline**).** `solve check` — verify post-GREEN enforcement clean. **→ SC-1**
- [ ] 13. **Checkpoint tag create (**inline**).** Create checkpoint tag for SC-LINT-001 completion. **→ SC-1**
- [ ] 14. **Checkpoint commit (**inline**).** Commit RED test + GREEN implementation together. **→ SC-1**

#### Item chain — SC-LINT-002 (Description contains mandatory keyword)

- [ ] 15. **RED (**clean-room**).** Write behavioral enforcement test for SC-LINT-002. Test sends a prompt with a skill card missing mandatory keyword and asserts the linter detects it. Verify test FAILS. **→ SC-2**
- [ ] 16. **Z3 check (**inline**).** `solve check` — verify RED test artifact exists and shows FAIL. **→ SC-2**
- [ ] 17. **RED doublecheck (**clean-room**).** Re-read RED test artifact to confirm it correctly targets SC-LINT-002. **→ SC-2**
- [ ] 18. **Z3 check (**inline**).** `solve check` — verify doublecheck confirms RED validity. **→ SC-2**
- [ ] 19. **Post-RED enforcement (**inline**).** Verify no GREEN work was started before RED passed. **→ SC-2**
- [ ] 20. **Z3 check (**inline**).** `solve check` — verify post-RED enforcement clean. **→ SC-2**
- [ ] 21. **GREEN (**clean-room**).** Implement SC-LINT-002 in `validate_skill_cards.py`. Rule checks description contains at least one of: `MUST`, `REQUIRED`, `always`, `not optional`, `mandatory`. Produces `{ rule_id: "SC-LINT-002", skill_name, severity: "WARNING", pass/fail, detail }`. **→ SC-2, SC-7**
- [ ] 22. **Z3 check (**inline**).** `solve check` — verify GREEN implementation artifact exists. **→ SC-2**
- [ ] 23. **Post-GREEN enforcement (**inline**).** Verify GREEN implementation matches spec. **→ SC-2**
- [ ] 24. **Z3 check (**inline**).** `solve check` — verify post-GREEN enforcement clean. **→ SC-2**
- [ ] 25. **Checkpoint tag create (**inline**).** Create checkpoint tag for SC-LINT-002 completion. **→ SC-2**
- [ ] 26. **Checkpoint commit (**inline**).** Commit RED test + GREEN implementation together. **→ SC-2**

#### Item chain — SC-LINT-003 (No standalone narrative-only sentence)

- [ ] 27. **RED (**clean-room**).** Write behavioral enforcement test for SC-LINT-003. Test sends a prompt with a skill card containing a narrative-only sentence and asserts the linter detects it. Verify test FAILS. **→ SC-3**
- [ ] 28. **Z3 check (**inline**).** `solve check` — verify RED test artifact exists and shows FAIL. **→ SC-3**
- [ ] 29. **RED doublecheck (**clean-room**).** Re-read RED test artifact to confirm it correctly targets SC-LINT-003. **→ SC-3**
- [ ] 30. **Z3 check (**inline**).** `solve check` — verify doublecheck confirms RED validity. **→ SC-3**
- [ ] 31. **Post-RED enforcement (**inline**).** Verify no GREEN work was started before RED passed. **→ SC-3**
- [ ] 32. **Z3 check (**inline**).** `solve check` — verify post-RED enforcement clean. **→ SC-3**
- [ ] 33. **GREEN (**clean-room**).** Implement SC-LINT-003 in `validate_skill_cards.py`. Rule detects narrative-only patterns: metaphors, slogans, value judgments, benefit statements. Produces `{ rule_id: "SC-LINT-003", skill_name, severity: "WARNING", pass/fail, detail }`. **→ SC-3, SC-7**
- [ ] 34. **Z3 check (**inline**).** `solve check` — verify GREEN implementation artifact exists. **→ SC-3**
- [ ] 35. **Post-GREEN enforcement (**inline**).** Verify GREEN implementation matches spec. **→ SC-3**
- [ ] 36. **Z3 check (**inline**).** `solve check` — verify post-GREEN enforcement clean. **→ SC-3**
- [ ] 37. **Checkpoint tag create (**inline**).** Create checkpoint tag for SC-LINT-003 completion. **→ SC-3**
- [ ] 38. **Checkpoint commit (**inline**).** Commit RED test + GREEN implementation together. **→ SC-3**

#### Item chain — SC-LINT-004 (Description length limit)

- [ ] 39. **RED (**clean-room**).** Write behavioral enforcement test for SC-LINT-004. Test sends a prompt with a skill card description over 300 chars and asserts the linter detects it. Verify test FAILS. **→ SC-4**
- [ ] 40. **Z3 check (**inline**).** `solve check` — verify RED test artifact exists and shows FAIL. **→ SC-4**
- [ ] 41. **RED doublecheck (**clean-room**).** Re-read RED test artifact to confirm it correctly targets SC-LINT-004. **→ SC-4**
- [ ] 42. **Z3 check (**inline**).** `solve check` — verify doublecheck confirms RED validity. **→ SC-4**
- [ ] 43. **Post-RED enforcement (**inline**).** Verify no GREEN work was started before RED passed. **→ SC-4**
- [ ] 44. **Z3 check (**inline**).** `solve check` — verify post-RED enforcement clean. **→ SC-4**
- [ ] 45. **GREEN (**clean-room**).** Implement SC-LINT-004 in `validate_skill_cards.py`. Rule checks description does not exceed 300 characters. Produces `{ rule_id: "SC-LINT-004", skill_name, severity: "WARNING", pass/fail, detail }`. **→ SC-4, SC-7**
- [ ] 46. **Z3 check (**inline**).** `solve check` — verify GREEN implementation artifact exists. **→ SC-4**
- [ ] 47. **Post-GREEN enforcement (**inline**).** Verify GREEN implementation matches spec. **→ SC-4**
- [ ] 48. **Z3 check (**inline**).** `solve check` — verify post-GREEN enforcement clean. **→ SC-4**
- [ ] 49. **Checkpoint tag create (**inline**).** Create checkpoint tag for SC-LINT-004 completion. **→ SC-4**
- [ ] 50. **Checkpoint commit (**inline**).** Commit RED test + GREEN implementation together. **→ SC-4**

#### Item chain — SC-LINT-005 (No procedure sections in SKILL.md body)

- [ ] 51. **RED (**clean-room**).** Write behavioral enforcement test for SC-LINT-005. Test sends a prompt with a SKILL.md containing a procedure section and asserts the linter detects it. Verify test FAILS. **→ SC-5**
- [ ] 52. **Z3 check (**inline**).** `solve check` — verify RED test artifact exists and shows FAIL. **→ SC-5**
- [ ] 53. **RED doublecheck (**clean-room**).** Re-read RED test artifact to confirm it correctly targets SC-LINT-005. **→ SC-5**
- [ ] 54. **Z3 check (**inline**).** `solve check` — verify doublecheck confirms RED validity. **→ SC-5**
- [ ] 55. **Post-RED enforcement (**inline**).** Verify no GREEN work was started before RED passed. **→ SC-5**
- [ ] 56. **Z3 check (**inline**).** `solve check` — verify post-RED enforcement clean. **→ SC-5**
- [ ] 57. **GREEN (**clean-room**).** Implement SC-LINT-005 in `validate_skill_cards.py`. Rule detects prohibited patterns in SKILL.md body: `"Procedure:"`, `"Operating Protocol:"`, `"Entry Criteria:"`, `"Exit Criteria:"`, numbered step lists, code blocks with bash/python/YAML. Produces `{ rule_id: "SC-LINT-005", skill_name, severity: "ERROR", pass/fail, detail }`. **→ SC-5, SC-7**
- [ ] 58. **Z3 check (**inline**).** `solve check` — verify GREEN implementation artifact exists. **→ SC-5**
- [ ] 59. **Post-GREEN enforcement (**inline**).** Verify GREEN implementation matches spec. **→ SC-5**
- [ ] 60. **Z3 check (**inline**).** `solve check` — verify post-GREEN enforcement clean. **→ SC-5**
- [ ] 61. **Checkpoint tag create (**inline**).** Create checkpoint tag for SC-LINT-005 completion. **→ SC-5**
- [ ] 62. **Checkpoint commit (**inline**).** Commit RED test + GREEN implementation together. **→ SC-5**

#### Item chain — SC-LINT-006 (Dispatch table sub-item type correctness)

- [ ] 63. **RED (**clean-room**).** Write behavioral enforcement test for SC-LINT-006. Test sends a prompt with a dispatch table containing wrong sub-item types and asserts the linter detects it. Verify test FAILS. **→ SC-6**
- [ ] 64. **Z3 check (**inline**).** `solve check` — verify RED test artifact exists and shows FAIL. **→ SC-6**
- [ ] 65. **RED doublecheck (**clean-room**).** Re-read RED test artifact to confirm it correctly targets SC-LINT-006. **→ SC-6**
- [ ] 66. **Z3 check (**inline**).** `solve check` — verify doublecheck confirms RED validity. **→ SC-6**
- [ ] 67. **Post-RED enforcement (**inline**).** Verify no GREEN work was started before RED passed. **→ SC-6**
- [ ] 68. **Z3 check (**inline**).** `solve check` — verify post-RED enforcement clean. **→ SC-6**
- [ ] 69. **GREEN (**clean-room**).** Implement SC-LINT-006 in `validate_skill_cards.py`. Rule checks sub-bullets (`-`) for parameter metadata, sub-checkboxes (`- [ ]`) for actionable sub-steps. Produces `{ rule_id: "SC-LINT-006", skill_name, severity: "WARNING", pass/fail, detail }`. **→ SC-6, SC-7**
- [ ] 70. **Z3 check (**inline**).** `solve check` — verify GREEN implementation artifact exists. **→ SC-6**
- [ ] 71. **Post-GREEN enforcement (**inline**).** Verify GREEN implementation matches spec. **→ SC-6**
- [ ] 72. **Z3 check (**inline**).** `solve check` — verify post-GREEN enforcement clean. **→ SC-6**
- [ ] 73. **Checkpoint tag create (**inline**).** Create checkpoint tag for SC-LINT-006 completion. **→ SC-6**
- [ ] 74. **Checkpoint commit (**inline**).** Commit RED test + GREEN implementation together. **→ SC-6**

### Sub-phase 3 — Post-phase verification

- [ ] 75. **Structural checks (**clean-room**).** Verify all 6 rules produce structured results with `rule_id`, `severity`, `pass/fail` fields. **→ SC-7**
- [ ] 76. **Green doublecheck (**clean-room**).** Re-run all 6 RED tests to confirm they now PASS. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 77. **Green VbC (**clean-room**).** Verify linter reports all failures (not first-failure-only) by running against a skill card with multiple violations. **→ SC-8**
- [ ] 78. **Adversarial audit (**clean-room**).** Dispatch adversarial auditor to audit all 6 rule implementations against spec. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8**
- [ ] 79. **Cross-validate (**clean-room**).** Dispatch cross-validate auditor to verify audit consensus. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8**
- [ ] 80. **Regression check (**clean-room**).** Run full test suite to verify no regressions. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8**
- [ ] 81. **Review-prep (**clean-room**).** Prepare branch for PR: squash commits, write PR body, generate compare URL. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8**
- [ ] 82. **Exec summary (**inline**).** Report completion: summary, outcome, blockers, URL, byline. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8**

#### Phase 1 VbC

- [ ] 83. **VbC (**clean-room**).** Verify all 6 rules implemented, all behavioral tests pass, linter reports all failures, adversarial audit passes. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8**

**Concern transition:** Leaving `implement-lint-rules` → entering PR creation. No further phases.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- C1. All 6 linting rules (SC-LINT-001 through 006) implemented in `validate_skill_cards.py`
- C2. Each rule produces structured result `{ rule_id, skill_name, severity, pass/fail, detail }`
- C3. Linter reports all failures, not first-failure-only
- C4. Behavioral enforcement tests exist for all 6 rules and pass
- C5. Adversarial audit passes with consensus
- C6. No regressions in existing test suite
- C7. Branch ready for PR with review-prep completed
