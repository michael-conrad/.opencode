# Phase 7 — functional end-to-end verification

**Concern:** Shared test home with test project + test gitbucket instance; run spec-creation pipeline and audit DiMo chain end-to-end against fixture; incremental sequencing.

**Files:**
- `.opencode/tests-v2/with-test-home`
- `.opencode/tests-v2/behaviors/helpers.sh`
- New behavioral test scripts + fixtures

**SCs:** SC-32, SC-33, SC-34

**Dependencies:** Phase 1, Phase 2, Phase 3, Phase 4, Phase 5, Phase 6

**Entry Conditions:**
- All six prior phases complete and VbC passed
- The remediated spec-creation and audit skills are well-formed on disk
- `with-test-home` and `__ensure_gitbucket` infrastructure available

**Exit Conditions:**
- Full spec-creation pipeline (analyze → create → validate) runs end-to-end against a fixture in the shared test home and produces a valid spec with no mis-routing, no missing task cards, no broken cross-references, no deprecated dispatch strings
- Audit DiMo 4-role chain (investigator → validator → evaluator → arbiter) runs end-to-end against a fixture spec and produces a valid verdict with each role dispatching to the correct split task card with a complete dispatch contract
- Spec-creation and audit behavioral tests share a common test home with a test project and test gitbucket instance, sequenced incrementally

---

## Code Path Coverage

- Path 8 (functional behavioral test harness): `.opencode/tests-v2/with-test-home`, `.opencode/tests-v2/behaviors/helpers.sh`, behavioral test scripts + fixtures — shared test home with test project + test gitbucket instance; incremental sequencing

## Cross-Cutting SCs

- Functional verification (SC-32, SC-33, SC-34) — verifies the remediated spec-creation pipeline and audit DiMo chain work end-to-end, not just well-formed
- Shared test home + gitbucket (SC-34) — prerequisite for SC-32 and SC-33

## Interface Boundaries

- spec-creation pipeline (analyze → create → validate) → spec-creation sub-agents (verified end-to-end)
- audit DiMo 4-role chain (investigator → validator → evaluator → arbiter) → audit role sub-agents (verified end-to-end)
- with-test-home + __ensure_gitbucket → behavioral test harness (shared, isolated environment)

## State Transitions

- functional verification: CURRENT (skills well-formed but not proven to work end-to-end) → VERIFIED (spec-creation pipeline and audit DiMo chain run end-to-end against fixture in shared test home with gitbucket)

---

## Step-by-step

- [ ] 182. **RED (**sub-agent**).** Write failing behavioral test dispatching the full spec-creation pipeline (analyze → create → validate) end-to-end against a fixture problem in the shared test home and asserting correct output (a valid spec with no mis-routing, no missing task cards, no broken cross-references, no deprecated dispatch strings). **→ SC-32**
- [ ] 183. **GREEN (**sub-agent**).** Ensure the remediated spec-creation pipeline dispatches end-to-end against the test gitbucket instance and produces a valid spec with no mis-routing, no missing task cards, no broken cross-references, and no deprecated dispatch strings. **→ SC-32**
- [ ] 184. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-32**
- [ ] 185. **verify (**clean-room**).** Verify SC-32: opencode run (with-test-home) dispatches the remediated spec-creation pipeline end-to-end against the test gitbucket instance and asserts correct output. **→ SC-32**
- [ ] 186. **commit-inline (**inline**).** Stage and commit spec-creation/SKILL.md, spec-creation/tasks, and the behavioral test script with the SC-32 test and change together.

- [ ] 187. **RED (**sub-agent**).** Write failing behavioral test dispatching the audit DiMo 4-role chain (investigator → validator → evaluator → arbiter) end-to-end against a fixture spec in the shared test home and asserting a valid verdict with each role dispatching to the correct split task card with a complete dispatch contract. **→ SC-33**
- [ ] 188. **GREEN (**sub-agent**).** Ensure the remediated audit chain dispatches end-to-end and produces a valid verdict, with each role dispatching to the correct split task card with a complete dispatch contract. **→ SC-33**
- [ ] 189. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-33**
- [ ] 190. **verify (**clean-room**).** Verify SC-33: opencode run (with-test-home) dispatches the remediated audit chain end-to-end and asserts correct output. **→ SC-33**
- [ ] 191. **commit-inline (**inline**).** Stage and commit audit/SKILL.md, audit/tasks, and the behavioral test script with the SC-33 test and change together.

- [ ] 192. **RED (**sub-agent**).** Write failing behavioral test verifying the spec-creation and audit behavioral test setup uses the shared with-test-home infrastructure with the gitbucket instance, sequenced incrementally. **→ SC-34**
- [ ] 193. **GREEN (**sub-agent**).** Ensure the spec-creation and audit behavioral tests share a common test home with a test project and test gitbucket instance, sequenced so later tests build upon the state created by earlier tests in an incremental fashion. **→ SC-34**
- [ ] 194. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-34**
- [ ] 195. **verify (**clean-room**).** Verify SC-34: verify the behavioral test setup uses the shared with-test-home infrastructure with the gitbucket instance. **→ SC-34**
- [ ] 196. **commit-inline (**inline**).** Stage and commit the behavioral test scripts and fixtures with the SC-34 test and change together.

#### Phase 7 VbC

- [ ] 197. **VbC (**clean-room**).** Verify all Phase 7 SCs (SC-32, SC-33, SC-34) pass their verification methods. **→ SC-32, SC-33, SC-34**

**Cost frame:** Running each functional end-to-end behavioral test costs minutes of execution time. Skipping means the remediated spec-creation pipeline and audit DiMo chain are never proven to work end-to-end — a mis-routing, a missing task card, a broken cross-reference, or a deprecated dispatch string ships undetected and every spec created or audited through the pipeline inherits the defect.

**Concern transition:** Leaving functional end-to-end verification → plan completion. This is the terminal phase; all 38 SCs must pass before the plan is complete.

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
