# Phase 4 — Behavioral enforcement test

**Concern:** Add a behavioral enforcement test (ALREADY_GREEN case) that verifies the sub-agent returns a classified abort instead of looping, and run the artifact-only generator against a clean-room session.

**Files:**
- `.opencode/tests-v2/behaviors/2298-sc10-already-green.sh` (new)
- `.opencode/tests-v2/behaviors/` (fixture as needed)

**SCs:** SC-10

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `red.md` abort terminal state present (the ALREADY_GREEN scenario exercises red.md)
- Phase 1 VbC passed

**Exit Conditions:**
- Behavioral enforcement test exists (ALREADY_GREEN case) asserting a classified abort, not a forced/looping test
- Test passes with clean-room session.yaml evaluation

---

- [ ] 45. **RED — Create behavioral enforcement test (**sub-agent**).** Dispatch `test-driven-development --task red` to create the behavioral test at `.opencode/tests-v2/behaviors/2298-sc10-already-green.sh`. The test is an artifact-only generator using `behavior_run` from `helpers.sh`: it sends a RED-phase prompt via `opencode run` that triggers an ALREADY_GREEN-style irregular condition (a test that passes on first run before any GREEN), and produces a `session.yaml` for clean-room evaluation. RED fails because `red.md` has no abort terminal state — the sub-agent loops or forces a failing test. Context: `{issue_number: 2298, test_dir: .opencode/tests-v2/behaviors/, test_name: 2298-sc10-already-green, harness: .opencode/tests-v2/behaviors/helpers.sh}`. **SC-10**
- [ ] 46. **GREEN — Verify behavioral test exists (**clean-room**).** Dispatch a clean-room sub-agent to verify the test file exists at `.opencode/tests-v2/behaviors/2298-sc10-already-green.sh` and uses the `behavior_run` helper with the correct scenario name and prompt. Context: `{issue_number: 2298, test_file: .opencode/tests-v2/behaviors/2298-sc10-already-green.sh}`. **SC-10**
- [ ] 47. **Checkpoint commit (**inline**).** Run `git add .opencode/tests-v2/behaviors/2298-sc10-already-green.sh && git commit -m "Phase 4: add ALREADY_GREEN behavioral enforcement test"`. Context: `{issue_number: 2298}`. **SC-10**

- [ ] 48. **Run behavioral test via clean-room session (**clean-room**).** Dispatch a clean-room sub-agent to run `bash .opencode/tests-v2/behaviors/2298-sc10-already-green.sh` and evaluate the generated `session.yaml` (via `session-to-timeline`) asserting the sub-agent returns a classified `BLOCKED` abort, not a forced/looping test. Report PASS/FAIL with the session.yaml artifact. Context: `{issue_number: 2298, test_file: .opencode/tests-v2/behaviors/2298-sc10-already-green.sh}`. **SC-10**

#### Phase 4 VbC

- [ ] 49. **VbC — Verify behavioral test passes (**clean-room**).** Dispatch `verification-before-completion --task verify` to confirm SC-10 (behavioral test exists and, when run, the sub-agent returns a classified abort instead of looping). Context: `{issue_number: 2298, sc_ids: [SC-10]}`. **SC-10**

**Concern transition:** Leaving behavioral enforcement test to entering post-implementation steps.

---

## Post-Implementation Steps

- [ ] 50. **Structural checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist` to run lint, typecheck, and structural verification. Context: `{issue_number: 2298}`. **All SCs**
- [ ] 51. **Pre-PR gate (**sub-agent**).** Dispatch `verification-before-completion --task verify` to read all SC verdicts and BLOCK if any FAIL. Context: `{issue_number: 2298}`. **All SCs**
- [ ] 52. **Rationalization check (**sub-agent**).** Dispatch `verification-before-completion --task verify` with a clean-room sub-agent to evaluate whether any proposed action is a rationalization. Context: `{issue_number: 2298}`. **All SCs**
- [ ] 53. **Regression check (**sub-agent**).** Dispatch `test-driven-development --task patterns` to run regression tests. Context: `{issue_number: 2298}`. **All SCs**
- [ ] 54. **Review prep (**sub-agent**).** Dispatch `git-workflow --task review-prep` to prepare PR review context. Context: `{issue_number: 2298}`. **All SCs**
- [ ] 55. **Create PR (**sub-agent**).** Dispatch `git-workflow --task create` with `{authorization_scope: for_implementation, halt_at: pr_created}`. Context: `{issue_number: 2298}`. **All SCs**
- [ ] 56. **Exec summary (**sub-agent**).** Dispatch `completion-core --task completion` to emit lifecycle event and summary. Context: `{issue_number: 2298}`. **All SCs**
