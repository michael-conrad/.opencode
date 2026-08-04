# Phase 9 — No-Regression Default Gate (Concern C6)

**Concern:** C6 — no-regression default gate. Confirm the default path (no opt-in flags) provisions exactly one `.opencode` submodule and the `local` platform with no origin remote — byte-for-byte unchanged for the ~80 existing tests.

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (default provisioning path)
- `.opencode/tests-v2/with-test-home`

**SCs:** SC8

**Dependencies:** Phase 1, Phase 3, Phase 4, Phase 6

**Entry Conditions:**
- Phase 1 complete: allowlist extended; VbC passed.
- Phase 3 complete: multi-submodule provisioning added; VbC passed.
- Phase 4 complete: mutual-exclusion rejection added; VbC passed.
- Phase 6 complete: origin wiring added; VbC passed.

**Exit Conditions:**
- With no opt-in flags set, a representative non-opt-in behavioral test provisions exactly one `.opencode` submodule and `local` platform with no origin remote.

---

- [ ] 41. **RED (**sub-agent**).** Write a failing behavioral assertion: default provisioning (no opt-in) is unchanged — single `.opencode` submodule, `local` platform, no origin remote. **→ SC8**

- [ ] 42. **GREEN (**sub-agent**).** No implementation change is required beyond ensuring Phases 1/3/4/6 left the default path intact. Only correct a regression if one is found. **→ SC8**

- [ ] 43. **GREEN doublecheck (**clean-room**).** Run a representative non-opt-in behavioral test; clean-room evaluation of `session.yaml` confirms single-`.opencode` provisioning and no origin remote. **→ SC8**

- [ ] 44. **Checkpoint commit (**inline**).** Commit verification evidence only (no source change unless a regression was found). (No co-author trailer — added at squash time.)

#### Phase 9 VbC

- [ ] 45. **VbC (**clean-room**).** Verify SC8: clean-room `session.yaml` evaluation of a representative non-opt-in behavioral test confirms single-`.opencode` provisioning and no origin remote. **→ SC8**

**Concern transition:** Final regression gate complete → post-implementation steps.

## Post-Implementation Steps

These steps run once after the last phase completes.

- [ ] 46. **Structural checks (**sub-agent**).** Run the finishing checklist from finishing-a-development-branch (lint, typecheck, format). No behavioral/structural evidence substitution. **→ all SCs**
- [ ] 47. **Audit (**clean-room**).** Run the adversarial audit (verification-audit DiMo investigator → validator → evaluator → arbiter in sequence) on the deliverable. **→ all SCs**
- [ ] 48. **Z3 check (**inline**).** Run `.opencode/tools/solve check` with the dependency contract and state path to re-confirm the phase ordering is satisfiable. **→ all SCs**
- [ ] 49. **Pre-PR gate (**sub-agent**).** Verify all SC verdicts read PASS; any FAIL or DONE_WITH_CONCERNS coerced to FAIL blocks PR creation. **→ all SCs**
- [ ] 50. **Regression check (**sub-agent**).** Run the final regression check (TDD phase-4). **→ all SCs**
- [ ] 51. **Review-prep (**sub-agent**).** Prepare PR review context (git-workflow-pr review-prep). **→ all SCs**
- [ ] 52. **Create PR (**sub-agent**).** Create the pull request (git-workflow-pr create). **→ all SCs**
- [ ] 53. **Exec summary (**sub-agent**).** Generate the completion executive summary (completion-core). **→ all SCs**
