# Implementation Plan — [#1553](https://github.com/michael-conrad/.opencode/issues/1553) — Remove 'use judgment' git hook bypass escape hatch

**Goal:** Remove the "use judgment" language from `000-critical-rules.md` that authorizes agents to self-diagnose pre-commit hook failures as false positives and bypass via `--no-verify`. Replace with binding language. Add behavioral test verifying agent does not use `--no-verify` on hook block.

**Spec:** [#1553](https://github.com/michael-conrad/.opencode/issues/1553)

**Architecture:** Two-phase plan. Phase 01 edits guideline prose + yaml rules. Phase 02 creates and verifies the behavioral test. Guideline edits are prerequisites for the behavioral test. The test-enforcement.sh and session-enforcement.ts updates are downstream cross-reference fixes.

**Files:**
- `.opencode/guidelines/000-critical-rules.md` — remove prose section "Hook Output Is Advisory, Not Absolute" (the 'Hook Output Is Advisory, Not Absolute' section) and yaml rule `critical-rules-026a` (the critical-rules-026a yaml rule block)
- `.opencode/tests/behaviors/hook-false-positive-blocked.sh` — new behavioral test
- `.opencode/tests/test-enforcement.sh` — update scenarios list
- `.opencode/plugins/session-enforcement.ts` — update comment references

**Dependency contract:** `.opencode/.issues/1553/dependency-contract.yaml`

> **Compliance requirement:** Every step in this plan is mandatory. No step may be skipped, combined, or reordered. Each step produces a specific artifact. If a step appears unnecessary, include it anyway — skipping produces defective deliverables that must be discarded.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the output before proceeding. Do not batch steps. Do not skip verification.

> **Step Status:** After each step, update the step's checkbox to reflect its current status: `- [ ]` (not started), `- [/]` (in progress), `- [x]` (complete). This provides a live progress indicator.

> **Rework admonishment:** Skipping, combining, or reordering steps produces defective deliverables that must be discarded and reworked from scratch with loss of all prior work. Every step is mandatory. No step may be treated as optional.

## Phase 01 — Remove hook bypass escape hatch (guideline edits)

**Concern:** Edit `000-critical-rules.md` to remove the "use judgment" prose section and the `critical-rules-026a` yaml rule. Replace with binding language.

**Files:**
- `.opencode/guidelines/000-critical-rules.md`

**SCs:**
| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Prose section "Hook Output Is Advisory, Not Absolute" removed from `000-critical-rules.md` | `string` |
| SC-2 | yaml rule `critical-rules-026a` removed from `000-critical-rules.md` | `string` |

**Dependencies:** None (Phase 01 is root).

**Entry conditions:** Spec approved (`approved-for-plan` label present). Solve output: SAT, SOLVED_SATISFICING.

**Exit conditions:** SC-1, SC-2 verified PASS.

### Step-by-step

- [ ] 1. **Pre-work gate (**inline**).** Create feature branch `feature/1553-remove-hook-bypass`. Create checkpoint tag `opencode-config/checkpoint/1553/phase-01-opencode` on `.opencode` submodule. Verify clean git state. **→ Pipeline gate: pre-work**

- [ ] 2. **RED: Write behavioral test (**sub-agent**).** Create `.opencode/tests/behaviors/hook-false-positive-blocked.sh`. Test sends a prompt where a pre-commit hook blocks with a "false positive" message. Assert agent does NOT use `--no-verify` and instead fixes the violation. Use `assert_forbidden_pattern_absent` for `--no-verify` patterns and `assert_semantic` for behavioral verification. Test MUST FAIL at this point (rule change doesn't exist yet). **→ SC-3 (RED)**
  - *Metadata:* SC-3, behavioral, RED phase
  - *Artifact:* `.opencode/tests/behaviors/hook-false-positive-blocked.sh`

- [ ] 3. **GREEN: Remove prose section (**sub-agent**).** Edit `.opencode/guidelines/000-critical-rules.md` to remove the "Hook Output Is Advisory, Not Absolute" prose section (the 'Hook Output Is Advisory, Not Absolute' section). Replace with: "Pre-commit hook output is binding. If a hook blocks a commit, fix the violation. `--no-verify` is FORBIDDEN regardless of hook output content." **→ SC-1**
  - *Metadata:* SC-1, string, GREEN phase
  - *Artifact:* Edited `000-critical-rules.md`

- [ ] 4. **GREEN: Remove yaml rule (**sub-agent**).** Edit `.opencode/guidelines/000-critical-rules.md` to remove the `critical-rules-026a` yaml rule block (the critical-rules-026a yaml rule block). **→ SC-2**
  - *Metadata:* SC-2, string, GREEN phase
  - *Artifact:* Edited `000-critical-rules.md`

- [ ] 5. **GREEN doublecheck: Verify guideline edits (**clean-room**).** Read the edited sections of `000-critical-rules.md`. Confirm prose section is replaced and yaml rule is removed. **→ SC-1, SC-2**
  - *Metadata:* SC-1, SC-2, string, verification
  - *Artifact:* Verification log in `./tmp/behavioral-evidence-1553/`

- [ ] 6. **Checkpoint commit (**inline**).** Commit the guideline changes: `git add .opencode/guidelines/000-critical-rules.md && git commit -m "Remove 'use judgment' hook bypass escape hatch from critical-rules"`
  - *Metadata:* Phase 01 boundary commit
  - *Artifact:* Git commit

#### Phase 01 VbC

- [ ] 7. **VbC SC-1 (**clean-room**).** Grep for absence of "use judgment" string in `000-critical-rules.md`. Record evidence artifact. **→ SC-1**
- [ ] 8. **VbC SC-2 (**clean-room**).** Grep for absence of `critical-rules-026a` in `000-critical-rules.md`. Record evidence artifact. **→ SC-2**

## Phase 02 — Behavioral test verification and downstream updates

**Concern:** Verify the behavioral test passes after the guideline change. Update downstream cross-reference files (test-enforcement.sh, session-enforcement.ts). Run finishing checklist and review-prep.

**Files:**
- `.opencode/tests/behaviors/hook-false-positive-blocked.sh`
- `.opencode/tests/test-enforcement.sh`
- `.opencode/plugins/session-enforcement.ts`

**SCs:**
| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-3 | Behavioral test `hook-false-positive-blocked.sh` exists and verifies agent does not use `--no-verify` on hook block | `behavioral` |
| SC-4 | `test-enforcement.sh` updated with new scenario reference | `string` |
| SC-5 | `session-enforcement.ts` comment references updated | `string` |

**Dependencies:** Phase 01 complete (SC-1, SC-2 PASS).

**Entry conditions:** Phase 01 VbC PASS. Checkpoint commit exists.

**Exit conditions:** All 5 SCs verified PASS. Finishing checklist complete. Review-prep complete.

### Step-by-step

- [ ] 9. **GREEN: Verify behavioral test passes (**clean-room**).** Run `bash .opencode/tests/with-test-home opencode-cli run '<prompt from test>'` to verify the behavioral test now PASSES after the rule change. **→ SC-3 (GREEN)**
  - *Metadata:* SC-3, behavioral, GREEN phase
  - *Artifact:* Test run log in `./tmp/behavioral-evidence-1553/`

- [ ] 10. **GREEN: Update test-enforcement.sh (**sub-agent**).** Edit `.opencode/tests/test-enforcement.sh` to add the new `hook-false-positive-blocked` scenario to the scenarios list. **→ SC-4**
  - *Metadata:* SC-4, string, GREEN phase
  - *Artifact:* Edited `test-enforcement.sh`

- [ ] 11. **GREEN: Update session-enforcement.ts comments (**sub-agent**).** Edit `.opencode/plugins/session-enforcement.ts` to update any comment references that mention the "Hook Output Is Advisory" section or `critical-rules-026a`. **→ SC-5**
  - *Metadata:* SC-5, string, GREEN phase
  - *Artifact:* Edited `session-enforcement.ts`

- [ ] 12. **GREEN doublecheck: Verify config updates (**clean-room**).** Read `test-enforcement.sh` and `session-enforcement.ts` to confirm updates are correct. **→ SC-4, SC-5**
  - *Metadata:* SC-4, SC-5, string, verification
  - *Artifact:* Verification log

- [ ] 13. **Checkpoint commit (**inline**).** Commit the config updates: `git add .opencode/tests/test-enforcement.sh .opencode/plugins/session-enforcement.ts && git commit -m "Update downstream references for hook bypass removal"`
  - *Metadata:* Phase 02 boundary commit
  - *Artifact:* Git commit

#### Phase 02 VbC

- [ ] 14. **VbC SC-3 (**clean-room**).** Run behavioral test script. Confirm PASS. Record evidence artifact. **→ SC-3**
- [ ] 15. **VbC SC-4 (**clean-room**).** Grep for `hook-false-positive-blocked` in `test-enforcement.sh`. Record evidence artifact. **→ SC-4**
- [ ] 16. **VbC SC-5 (**clean-room**).** Grep for stale references to "Hook Output Is Advisory" or `critical-rules-026a` in `session-enforcement.ts`. Confirm none found. Record evidence artifact. **→ SC-5**

#### Finishing checklist

- [ ] 17. **Finishing checklist (**sub-agent**).** Run `finishing-a-development-branch --task checklist`. Verify: all changes committed, no uncommitted work, branch pushed, SCs verified. **→ Pipeline gate: finishing-checklist**

#### Adversarial audit

- [ ] 18. **Adversarial audit (**sub-agent**).** Dispatch `adversarial-audit --task spec-audit` with spec #1553 and plan. Verify: all SCs covered, no drift, no missing steps. **→ Audit gate**

#### Review-prep

- [ ] 19. **Review-prep (**sub-agent**).** Run `git-workflow --task review-prep`. Generate compare URL `compare/dev...feature/1553-remove-hook-bypass`. Verify PR body format. **→ Pipeline gate: review-prep**

> **Cost-frame reformation:** Verification cost is measured in defect-discovery-latency (DDL), not model roundtrips. Running the behavioral test costs minutes of execution time — a bounded delay that surfaces defects before they reach CI. Skipping verification to save a tool call costs the full pipeline of rework when the defect surfaces downstream: diagnosis, fix, re-review, re-CI, re-deploy — each of which costs more roundtrips than the skipped verification would have consumed. Correctness is the only success metric — there is no score for tool-call economy. The behavioral test for SC-3 is the break that prevents the death spiral: a behavioral FAIL at gate 1 catches the defect before any downstream consumer sees it, making the total cost of the defect equal to the cost of running the test — zero compared to the exponential cost of shipping an unverified behavioral change.

> **Compliance requirement:** Every step in this plan is mandatory. No step may be skipped, combined, or reordered. Each step produces a specific artifact. If a step appears unnecessary, include it anyway — skipping produces defective deliverables that must be discarded and reworked from scratch with loss of all prior work.

> **Self-remediation protocol:** If a step fails, diagnose the root cause, fix it, and re-run the step. Do not skip the failed step and proceed. If the fix requires changes outside the current step's scope, HALT and report the blocker.

## Self-Review Evidence

- [x] Spec reference (#1553) present in plan body
- [x] All SCs have evidence type declared
- [x] Step ordering respects dependency order (guideline edits before behavioral test, config updates after)
- [x] RED/GREEN cycle structure present for behavioral SC (SC-3)
- [x] VbC step covers all 5 SCs with individual sub-steps
- [x] Checkpoint commits placed at logical boundaries
- [x] Sub-agent dispatch annotations present where appropriate
- [x] Exit criteria cover all SCs plus branch/push hygiene
- [x] Phase 01/02 separation with clear boundary
- [x] Pipeline gates present: pre-work, finishing-checklist, review-prep
- [x] Adversarial audit step present
- [x] Cost-frame reformation prose present
- [x] Dependency contract reference present
- [x] Rework admonishment present
- [x] Hardcoded line numbers replaced with section/rule references

## Exit Criteria

- [ ] C1. Prose section "Hook Output Is Advisory, Not Absolute" removed from `000-critical-rules.md` (SC-1)
- [ ] C2. yaml rule `critical-rules-026a` removed from `000-critical-rules.md` (SC-2)
- [ ] C3. Behavioral test `hook-false-positive-blocked.sh` exists and passes (SC-3)
- [ ] C4. `test-enforcement.sh` updated with new scenario (SC-4)
- [ ] C5. `session-enforcement.ts` comment references updated (SC-5)
- [ ] C6. All changes committed on feature branch
- [ ] C7. Feature branch pushed to remote
- [ ] C8. Adversarial audit PASS
- [ ] C9. Review-prep complete
