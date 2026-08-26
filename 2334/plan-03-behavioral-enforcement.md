# Phase 3 — Behavioral enforcement test

**Concern:** Register a behavioral enforcement scenario that proves, via stderr assertions through the with-test-home harness, that an agent instructed to enumerate files under `.opencode/` emits a working path-parameter invocation action instead of concluding nonexistence from a silent-empty result.

**Files:**
- `.opencode/tests-v2/behaviors/<scenario>.sh` (new)
- `.opencode/tests-v2/test-enforcement.sh` (scenario registration)

**SCs:** SC-8

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: all SC-2..SC-7 remediations landed and the Phase 2 VbC passed (steps 9-39)
- The deck is fully remediated; feature branch at trunk-tip; working tree clean

**Exit Conditions:**
- A behavioral enforcement scenario is registered in `test-enforcement.sh` and runs clean under `with-test-home`
- The scenario's stderr assertions prove the agent emits a working invocation action and does not conclude nonexistence from a silent-empty result

## Code Path Coverage

(from `code-path-inventory.yaml`)

- `.opencode/tests-v2/behaviors/<scenario>.sh` + `test-enforcement.sh` — SC-8: `with-test-home opencode run '<search prompt>'` → stderr captured → `assert_stderr_pattern_*` on actions.

## Cross-Cutting SCs

(from `cross-cutting-matrix.yaml`)

- `behavioral-test-mandate` (SC-8): critical-rules-009 + tests-v2 framework discipline — with-test-home, >=600000ms timeout, no GNU timeout, stale-lock removal before reruns; scenario registered via test-enforcement.sh conventions; stderr assertions only (never prose recall).

## Interface Boundaries

(from `interface-compatibility.yaml`)

- `tests-v2 scenario registration surface` — `NEW_SCENARIO`, backward compatible, non-breaking; hosted by the existing with-test-home wrapper and test-enforcement.sh conventions.

## State Transitions

- SC-8 proves the behavioral change end-to-end: an agent instructed to enumerate files under `.opencode/` transitions from a silent-empty conclusion (pre-change) to a working path-parameter invocation action (post-change), observed via stderr actions.

## Step-by-step

- [ ] 40. **RED (**sub-agent**).** Pre-clean stale artifacts: `rm -f {project_root}/tmp/{issue-2334}/artifacts/pipeline-red-*`. Write a failing behavioral enforcement scenario (new `<scenario>.sh` + `test-enforcement.sh` registration) asserting the agent emits a working invocation action. The scenario FAILS against the pre-change deck (agent emits a naive pattern-from-root call then concludes absence). **→ SC-8**
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-8, enumeration prompt, stderr assertion helpers, with-test-home
- [ ] 41. **GREEN (**sub-agent**).** Make the scenario pass against the remediated deck: run `bash .opencode/tests-v2/with-test-home opencode run '<enumeration prompt>'` and assert stderr shows a path-parameter-form invocation action (no silent-empty nonexistence conclusion). **→ SC-8**
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-8, with-test-home run, stderr assertion helpers
- [ ] 42. **Post-regression (**sub-agent**).** Run regression patterns to confirm the new scenario does not regress the enforcement suite. **→ SC-8**
  - Clean: `rm -f {project_root}/tmp/{issue-2334}/artifacts/pipeline-post-regression-*`
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 43. **Verify (**clean-room**).** Verify SC-8 (behavioral): full `with-test-home opencode run` with stderr assertion helpers, Bash tool timeout `>= 600000ms`, no GNU timeout. BLOCK on FAIL or EVIDENCE_TYPE_MISMATCH. **→ SC-8**
  - Clean: `rm -f {project_root}/tmp/{issue-2334}/artifacts/pipeline-verify-*`
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 44. **COMMIT (**inline**).** Commit the behavioral scenario plus its test-enforcement.sh registration as one atomic slice. `git add .opencode/tests-v2/behaviors/<scenario>.sh .opencode/tests-v2/test-enforcement.sh && git commit -m "<SC-8 message>"`. **→ SC-8**

#### Phase 3 VbC

- [ ] 45. **VbC (**clean-room**).** Verify SC-8 passes its behavioral check: the scenario runs clean under the with-test-home harness with stderr assertions proving the agent emits a working invocation action instead of a false nonexistence conclusion. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-8**

**Concern transition:** Leaving the behavioral proof → entering post-implementation verification and PR delivery. All Phase 3 SCs complete; the post-implementation steps (audit, z3-check, structural checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary) follow in the plan index.
