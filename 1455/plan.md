# Implementation Plan — [Fix F: verification-before-completion description format (D1)](https://github.com/michael-conrad/.opencode/issues/1455) — Fix SKILL.md description to start with "Use when"

- **Goal:** Rewrite `verification-before-completion` SKILL.md `description` field to start with "Use when" per D1 compliance, preserving all dispatch conditions and mandatory language, removing the narrative-only sentence.
- **Architecture:** Single YAML frontmatter field edit in `.opencode/skills/verification-before-completion/SKILL.md`.
- **Files:** `.opencode/skills/verification-before-completion/SKILL.md`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

## Phase 1 — Description Format Fix (D1)

- **Concern:** Rewrite `.opencode/skills/verification-before-completion/SKILL.md` YAML frontmatter `description` field to start with "Use when", preserving all dispatch conditions (complete, step done, close issue), retaining mandatory language (REQUIRED, MUST), and removing the narrative-only sentence.
- **Files:** `.opencode/skills/verification-before-completion/SKILL.md`
- **SCs:** SC-1 (starts with "Use when"), SC-2 (retains dispatch conditions), SC-3 (retains mandatory language), SC-4 (narrative sentence removed), SC-5 (matches proposed text exactly)
- **Dependencies:** None
- **Entry:** Spec approved with `for_plan` scope (label: `approved-for-plan`)
- **Exit:** All 5 SCs PASS, description matches proposed text verbatim

### Pre-RED Common

- [ ] 1. **Coherence gate (**clean-room**).** Verify spec SCs are internally consistent, the proposed description complies with SKILL.md YAML frontmatter format, and no other SKILL.md fields are affected. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 2. **Pre-RED baseline (**sub-agent**).** Read `.opencode/skills/verification-before-completion/SKILL.md`, extract current `description` value. Write baseline to `./tmp/behavioral-evidence-1455/baseline.txt`. **→ SC-1, SC-4**

### Item 1: RED — Enforcement test

- [ ] 3. **RED phase (**sub-agent**).** Write content-verification test at `.opencode/tests/content-verification/d1-description-format.sh` that asserts the current description does NOT start with "Use when". Test MUST FAIL. **→ SC-1**
- [ ] 4. **Z3 check RED (**sub-agent**).** `solve check` — confirm RED test artifact exists. **→ SC-1**
- [ ] 5. **RED doublecheck (**sub-agent**).** Run the test from step 3 — confirm FAIL. **→ SC-1**
- [ ] 6. **Z3 check RED doublecheck (**sub-agent**).** `solve check` — confirm step 5 produced FAIL. **→ SC-1**
- [ ] 7. **Post-RED enforcement (**sub-agent**).** Run full content-verification suite — confirm unchanged tests still PASS. **→ SC-1**
- [ ] 8. **Z3 check POST-RED (**sub-agent**).** `solve check` — confirm step 7 produced PASS for all unchanged tests. **→ SC-1**

### Item 2: GREEN — Apply description change

- [ ] 9. **GREEN phase (**sub-agent**).** Edit `description` field in `.opencode/skills/verification-before-completion/SKILL.md` from `"Verification is REQUIRED and not optional. MUST use when claiming a task is complete, marking a step done, or closing an issue. A completion claim without verification is not a completion — it is a placeholder for undiscovered defects."` to `"Use when claiming a task is complete, marking a step done, or closing an issue. Verification is REQUIRED and not optional — MUST use before any completion claim."`. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 10. **Z3 check GREEN (**sub-agent**).** `solve check` — confirm SKILL.md description starts with "Use when". **→ SC-1**
- [ ] 11. **Post-GREEN enforcement (**sub-agent**).** Run RED test from step 3 — confirm it now PASSES. **→ SC-1**
- [ ] 12. **Z3 check POST-GREEN (**sub-agent**).** `solve check` — confirm step 11 produced PASS. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

### Item 3: REFACTOR — Verify all SCs

- [ ] 13. **Checkpoint tag create (**inline**).** `git tag opencode-config/checkpoint/1455/phase-1-opencode` and push. **→ All**
- [ ] 14. **Checkpoint commit (**inline**).** `git add .opencode/skills/verification-before-completion/SKILL.md .opencode/tests/content-verification/d1-description-format.sh && git commit -m 'checkpoint: phase 1 RED+GREEN for D1 description fix'`. **→ All**
- [ ] 15. **Structural checks (**sub-agent**).** Verify file exists at `.opencode/skills/verification-before-completion/SKILL.md`, YAML frontmatter is valid, `description` matches proposed text character-for-character. **→ SC-5**
- [ ] 16. **GREEN doublecheck (**sub-agent**).** Independent verification: read `description` field, confirm: starts with "Use when" (SC-1), contains "complete"/"step done"/"close issue" (SC-2), contains "REQUIRED"/"MUST" (SC-3), does NOT contain narrative sentence (SC-4). **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 17. **GREEN VbC (**clean-room**).** Run full SC verification against spec — all 5 SCs, each with supporting string evidence. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

### Item 4: COMMIT — Finalize

- [ ] 18. **Squash commit (**inline**).** `git reset --soft HEAD~2 && git commit -m 'fix(description): D1 compliance for verification-before-completion SKILL.md'`. **→ All**
- [ ] 19. **Post-commit verification (**clean-room**).** Verify final commit contains only `.opencode/skills/verification-before-completion/SKILL.md` and `.opencode/tests/content-verification/d1-description-format.sh`. **→ All**

### Global Post-GREEN Steps

- [ ] 20. **Collect verification artifacts (**sub-agent**).** Gather artifacts from `./tmp/1455/artifacts/` — string evidence for all 5 SCs. **→ All**
- [ ] 21. **Adversarial audit (**sub-agent**).** Dispatch `adversarial-audit --task spec-audit` — verify SC-1 through SC-5 have sufficient evidence. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 22. **Cross-validate (**sub-agent**).** Compare amended description against other SKILL.md descriptions for format consistency. **→ All**
- [ ] 23. **Regression check (**sub-agent**).** Run full content-verification test suite — confirm all PASS. **→ All**
- [ ] 24. **Review prep (**sub-agent**).** Prepare PR body with Summary, Outcome (all 5 SCs PASS), Fixes #1455, and Compare URL. **→ All**

#### Phase 1 VbC

- [ ] 25. **VbC (**clean-room**).** Verify all 5 SCs PASS against live file content after full pipeline. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 26. **Executive summary (**inline**).** Report completion: phase 1 DONE, all 5 SCs PASS, VbC confirmed PASS. **→ All**

**Concern transition:** N/A — single phase, no transition.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

### Exit Criteria

- C1. Plan file written to `.opencode/.issues/1455/plan.md`
- C2. All 5 success criteria verified PASS
- C3. Dispatch table validation PASS — all referenced skills exist
- C4. Approval cascade applied (`approved-for-plan` label present)
- C5. Cross-reference synced to spec issue #1455
- C6. All mandatory implementation-pipeline gate steps executed
- C7. RED test written and confirmed FAIL before GREEN
- C8. GREEN change matches proposed text exactly
- C9. Checkpoint tag created and pushed
- C10. Final squash commit with correct message

## Lifecycle

- **Created:** 2026-06-27T12:00:00Z
- **Pipeline:** 22/22 steps completed (research → readiness → structure → solve → write → clean-room → revisit → validate → audit-fidelity → concern-separation → completion)
- **Audit verdicts:** fidelity PASS, concern-separation PASS
- **Status:** PLAN_READY
- **Approval cascade:** `for_plan` scope → halt at `plan_created` → next: `for_implementation` authorization required for RED/GREEN
