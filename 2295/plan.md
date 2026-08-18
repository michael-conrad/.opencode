---
plan_schema_version: "1.0"
issue: 2295
title: "Prevent agents from storing source/tests/fixtures in .issues/ worktree"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 6
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
lifecycle_events:
  - timestamp: "2026-08-18T20:30:00Z"
    event: plan_created
    plan_path: ".opencode/.issues/2295/plan.md"
    phase_count: 6
---

# Implementation Plan — #2295 — Prevent Agents from Storing Source/Tests/Fixtures in `.issues/` Worktree

**Issue:** [https://github.com/michael-conrad/.opencode/issues/2295](https://github.com/michael-conrad/.opencode/issues/2295)

**Goal:** Establish the universal `.issues/` content-type boundary (issue metadata only, never source/test/fixture/code) in the workspace guide, remove every explicit authorization and misleading framing that routes source/test/fixture content into the non-deployable `.issues/` worktree, and add a behavioral enforcement test that verifies agents do not write test files under `.issues/`.

**Architecture:** Six-phase, one-concern-per-phase decomposition. Phase 1 (SC-1) establishes the authoritative exclusions list in `.opencode/.issues/AGENTS.md` declaring `.issues/` holds issue metadata only — this is the content-type boundary every other fix references. Phases 2–5 (SC-2/SC-3, SC-4, SC-5, SC-6) make the four text fixes to the task cards/reference docs, all editing disjoint files and depending only on Phase 1. Phase 6 (SC-7) adds the behavioral enforcement test that asserts the boundary against real agent behavior. All phases depend on Phase 1; Phases 2–6 are otherwise mutually independent (each edits a distinct file). Phase 2 applies SC-2 before SC-3 because both modify `red.md` and the `.issues/{N}/tests/` removal must precede the owning-repo directive to avoid edit conflicts. Enforcement is behavioral only for SC-7 (the enforcement test); SC-1 through SC-6 are string-verified via grep per spec.

**Files:**
- `.opencode/.issues/AGENTS.md`
- `.opencode/skills/test-driven-development/tasks/red.md`
- `.opencode/skills/writing-plans/reference/implementation-workflow.md`
- `.opencode/skills/spec-creation/tasks/create.md`
- `.opencode/skills/git-workflow-pr/tasks/review-prep.md`
- `.opencode/tests-v2/behaviors/<scenario>.sh` (new behavioral test)

**Dispatch:** `test-driven-development`, `verification-before-completion`, `audit`, `finishing-a-development-branch`, `git-workflow-pr`, `completion-core`

---

## Blast Radius

- **Phase 1 — Content-type boundary (SC-1):** Isolated to `.opencode/.issues/AGENTS.md`; adds an exclusions list declaring `.issues/` holds issue metadata only. This is the authoritative boundary all other fixes reference.
- **Phase 2 — Test-placement directive (SC-2, SC-3):** Isolated to `.opencode/skills/test-driven-development/tasks/red.md`; removes `.issues/{N}/tests/` and directs placement by the owning-repo principle.
- **Phase 3 — Artifact-retention framing (SC-4):** Isolated to `.opencode/skills/writing-plans/reference/implementation-workflow.md`; Rule 1 clarified to metadata-only.
- **Phase 4 — Artifact-copy disambiguation (SC-5):** Isolated to `.opencode/skills/spec-creation/tasks/create.md`; Step 6 copy-target disambiguated.
- **Phase 5 — PR auto-commit removal (SC-6):** Isolated to `.opencode/skills/git-workflow-pr/tasks/review-prep.md`; Step 0 unconditional `git add .issues/` auto-commit removed.
- **Phase 6 — Behavioral enforcement (SC-7):** New behavioral test at `.opencode/tests-v2/behaviors/<scenario>.sh`; artifact-only generator per canonical framework.

---

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

---

## Pre-Implementation Steps

- [ ] 1. **Coherence gate (**inline**).** Verify the spec's SCs, the structure artifact's items, and the dependency contract are mutually consistent: every SC maps to exactly one item, every item's RED/GREEN/verify/commit steps are in the same phase, and the phase DAG is acyclic (phase_1 → phase_2..phase_6, with phase_2 additionally sequenced SC-2 before SC-3 within the phase). If any inconsistency is found, HALT and report before proceeding.
- [ ] 2. **Baseline check (**inline**).** Verify the working tree is clean, the feature branch exists, and the affected files (AGENTS.md, red.md, implementation-workflow.md, create.md, review-prep.md) are present at their expected paths. Confirm the RED preconditions: AGENTS.md lacks the exclusions-list marker, `red.md` lists `.issues/{N}/tests/`, `implementation-workflow.md` Rule 1 lacks metadata-only language, `create.md` Step 6 copy-target is ambiguous, and `review-prep.md` Step 0 contains the unconditional `git add .issues/` auto-commit. If the baseline is not met, HALT and report.

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Content-type boundary | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | `.opencode/.issues/AGENTS.md` | SC-1 | — |
| 2 — Test-placement directive | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | `.opencode/skills/test-driven-development/tasks/red.md` | SC-2, SC-3 | 1 |
| 3 — Artifact-retention framing | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | `.opencode/skills/writing-plans/reference/implementation-workflow.md` | SC-4 | 1 |
| 4 — Artifact-copy disambiguation | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | `.opencode/skills/spec-creation/tasks/create.md` | SC-5 | 1 |
| 5 — PR auto-commit removal | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | `.opencode/skills/git-workflow-pr/tasks/review-prep.md` | SC-6 | 1 |
| 6 — Behavioral enforcement | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | `.opencode/tests-v2/behaviors/<scenario>.sh` | SC-7 | 1 |

---

## Phase Details

### Phase 1 — Content-type boundary

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | `.opencode/.issues/AGENTS.md` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
sc_ids: [SC-1]
exclusions_marker: "never source/test/fixture/code"
content_type_boundary: ".issues/ holds issue metadata only, never source/test/fixture/code"
```

**Procedure (SC-1 — content-type boundary exclusions list):**
- [ ] 3. **RED (**sub-agent**).** Write a failing string test asserting that `.opencode/.issues/AGENTS.md` lacks the exclusions-list marker (e.g., "never source/test/fixture/code"). **→ SC-1**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-1, AGENTS.md, exclusions marker absent
- [ ] 4. **GREEN (**sub-agent**).** Add the explicit exclusions list to `.opencode/.issues/AGENTS.md` stating `.issues/` holds issue metadata only, never source/test/fixture/code. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-1, exclusions list, content-type boundary, intent preservation
- [ ] 5. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the exclusions-list addition did not alter the workspace-guide's semantics. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-1, post-GREEN regression
- [ ] 6. **verify (**sub-agent**).** Run the string grep check asserting the exclusions-list marker is present in AGENTS.md. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-1, exclusions-list marker present
- [ ] 7. **commit-inline (**inline**).** Stage and commit the AGENTS.md exclusions-list addition. **→ SC-1**
  - Command: `git add .opencode/.issues/AGENTS.md && git commit -m "<message>"`

**Phase 1 VbC:**
- [ ] 8. **VbC (**clean-room**).** Verify SC-1 passes its string check: AGENTS.md contains the explicit exclusions list stating `.issues/` holds issue metadata only, never source/test/fixture/code. **→ SC-1**

### Phase 2 — Test-placement directive

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | `.opencode/skills/test-driven-development/tasks/red.md` |
| SCs | SC-2, SC-3 |
| Depends On | 1 |

**Context:**
```yaml
sc_ids: [SC-2, SC-3]
removed_path: ".issues/{N}/tests/"
owning_repo_principle: "resolve the repo owning the code under test, then place per that repo's conventions"
ordering: "SC-2 (remove .issues/{N}/tests/) before SC-3 (add owning-repo directive) — both edit red.md"
```

**Procedure (SC-2 — remove `.issues/{N}/tests/` as a test storage path):**
- [ ] 9. **RED (**sub-agent**).** Write a failing grep test asserting that `.opencode/skills/test-driven-development/tasks/red.md` still contains `.issues/{N}/tests/` as a valid test storage path. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-2, red.md, `.issues/{N}/tests/` present
- [ ] 10. **GREEN (**sub-agent**).** Remove `.issues/{N}/tests/` as a valid test storage path from `red.md`. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-2, remove `.issues/{N}/tests/`, intent preservation
- [ ] 11. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the test-storage-path removal did not break the RED task card's semantics. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-2, post-GREEN regression
- [ ] 12. **verify (**sub-agent**).** Run the string test grep asserting `.issues/{N}/tests/` is ABSENT from red.md. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-2, `.issues/{N}/tests/` absent
- [ ] 13. **commit-inline (**inline**).** Stage and commit the red.md test-storage-path removal. **→ SC-2**
  - Command: `git add .opencode/skills/test-driven-development/tasks/red.md && git commit -m "<message>"`

**Procedure (SC-3 — owning-repo placement directive):**
- [ ] 14. **RED (**sub-agent**).** Write a grep test asserting that `red.md` lacks the owning-repo placement reference. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-3, red.md, owning-repo reference absent
- [ ] 15. **GREEN (**sub-agent**).** Add the owning-repo principle directive to `red.md` directing test placement by resolving the repo owning the code under test, then placing per that repo's conventions. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-3, owning-repo principle, no default to `.issues/`
- [ ] 16. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the owning-repo directive is consistent with the SC-2 removal. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-3, post-GREEN regression
- [ ] 17. **verify (**sub-agent**).** Run the string test grep asserting the owning-repo reference is PRESENT in red.md. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-3, owning-repo reference present
- [ ] 18. **commit-inline (**inline**).** Stage and commit the red.md owning-repo principle addition. **→ SC-3**
  - Command: `git add .opencode/skills/test-driven-development/tasks/red.md && git commit -m "<message>"`

**Phase 2 VbC:**
- [ ] 19. **VbC (**clean-room**).** Verify SC-2 and SC-3 pass: `.issues/{N}/tests/` is absent from red.md and the owning-repo principle is present. **→ SC-2, SC-3**

### Phase 3 — Artifact-retention framing

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | `.opencode/skills/writing-plans/reference/implementation-workflow.md` |
| SCs | SC-4 |
| Depends On | 1 |

**Context:**
```yaml
sc_ids: [SC-4]
retention_rule: "Artifact Retention Rule 1"
metadata_only_language: ".issues/{N}/ holds issue metadata only, not arbitrary source/test/fixture artifacts"
```

**Procedure (SC-4 — clarify Rule 1 artifact retention):**
- [ ] 20. **RED (**sub-agent**).** Write a grep test asserting that `implementation-workflow.md` Rule 1 lacks the metadata-only clarification. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-4, implementation-workflow.md Rule 1, metadata-only language absent
- [ ] 21. **GREEN (**sub-agent**).** Reframe Rule 1 to state `.issues/{N}/` holds issue metadata only, not arbitrary source/test/fixture artifacts. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-4, metadata-only framing, intent preservation
- [ ] 22. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the Rule 1 clarification is internally consistent. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-4, post-GREEN regression
- [ ] 23. **verify (**sub-agent**).** Run the string test grep asserting the metadata-only language is PRESENT in Rule 1. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-4, metadata-only language present
- [ ] 24. **commit-inline (**inline**).** Stage and commit the implementation-workflow.md Rule 1 clarification. **→ SC-4**
  - Command: `git add .opencode/skills/writing-plans/reference/implementation-workflow.md && git commit -m "<message>"`

**Phase 3 VbC:**
- [ ] 25. **VbC (**clean-room**).** Verify SC-4 passes its string check: Rule 1 states `.issues/{N}/` holds issue metadata only, not arbitrary source/test/fixture artifacts. **→ SC-4**

### Phase 4 — Artifact-copy disambiguation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | `.opencode/skills/spec-creation/tasks/create.md` |
| SCs | SC-5 |
| Depends On | 1 |

**Context:**
```yaml
sc_ids: [SC-5]
copy_target: "Step 6 analytical-artifacts copy target"
disambiguated_scope: "only analysis artifacts (not source/test/fixture) are copied to .issues/{N}/artifacts/"
```

**Procedure (SC-5 — disambiguate Step 6 analytical-artifacts copy target):**
- [ ] 26. **RED (**sub-agent**).** Write a grep test asserting that `create.md` Step 6 lacks an unambiguous copy-target description (only analysis artifacts, not source/test/fixture). **→ SC-5**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-5, create.md Step 6, unambiguous copy-target absent
- [ ] 27. **GREEN (**sub-agent**).** Disambiguate Step 6 so only analysis artifacts (not source/test/fixture) are copied to `.issues/{N}/artifacts/`. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-5, disambiguated copy-target scope, intent preservation
- [ ] 28. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the copy-target disambiguation is consistent. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-5, post-GREEN regression
- [ ] 29. **verify (**sub-agent**).** Run the string grep asserting Step 6's copy target is disambiguated to analysis-artifacts-only. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-5, unambiguous copy-target present
- [ ] 30. **commit-inline (**inline**).** Stage and commit the create.md Step 6 disambiguation. **→ SC-5**
  - Command: `git add .opencode/skills/spec-creation/tasks/create.md && git commit -m "<message>"`

**Phase 4 VbC:**
- [ ] 31. **VbC (**clean-room**).** Verify SC-5 passes its string check: Step 6's copy-target is disambiguated to analysis artifacts only. **→ SC-5**

### Phase 5 — PR auto-commit removal

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | `.opencode/skills/git-workflow-pr/tasks/review-prep.md` |
| SCs | SC-6 |
| Depends On | 1 |

**Context:**
```yaml
sc_ids: [SC-6]
removed_commit: "unconditional `git add .issues/` auto-commit in Step 0"
removal_scope: "the unconditional auto-commit of dirty .issues/<N>/ files is removed entirely"
```

**Procedure (SC-6 — remove unconditional `.issues/` auto-commit):**
- [ ] 32. **RED (**sub-agent**).** Write a grep test asserting that `review-prep.md` Step 0 contains the unconditional `git add .issues/` auto-commit. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-6, review-prep.md Step 0, unconditional auto-commit present
- [ ] 33. **GREEN (**sub-agent**).** Remove the unconditional auto-commit of dirty `.issues/<N>/` files from `review-prep.md` Step 0 entirely. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-6, remove unconditional auto-commit, intent preservation
- [ ] 34. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the review-prep workflow semantics are preserved. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-6, post-GREEN regression
- [ ] 35. **verify (**sub-agent**).** Run the string test grep asserting the unconditional `git add .issues/` auto-commit is REMOVED from Step 0. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-6, unconditional auto-commit absent
- [ ] 36. **commit-inline (**inline**).** Stage and commit the review-prep.md Step 0 auto-commit removal. **→ SC-6**
  - Command: `git add .opencode/skills/git-workflow-pr/tasks/review-prep.md && git commit -m "<message>"`

**Phase 5 VbC:**
- [ ] 37. **VbC (**clean-room**).** Verify SC-6 passes its string check: Step 0 no longer contains the unconditional `git add .issues/` auto-commit. **→ SC-6**

### Phase 6 — Behavioral enforcement

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | `.opencode/tests-v2/behaviors/<scenario>.sh` |
| SCs | SC-7 |
| Depends On | 1 |

**Context:**
```yaml
sc_ids: [SC-7]
behavioral_test: ".opencode/tests-v2/behaviors/<scenario>.sh"
artifact_only: "artifact-only generator per canonical framework (exit 0, no self-evaluation)"
evidence: "with-test-home opencode run; stderr-based assertions for absence of .issues/ write actions; Bash tool timeout >= 600s"
```

**Procedure (SC-7 — behavioral enforcement test):**
- [ ] 38. **RED (**sub-agent**).** Write the failing behavioral scenario: before the text fixes (or while unguarded) the agent would write a test file under `.issues/`; the scenario currently lacks the `.issues/` write-prohibition assertion. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-7, behavioral scenario, no `.issues/`-write assertion
- [ ] 39. **GREEN (**sub-agent**).** Add the behavioral enforcement test at `.opencode/tests-v2/behaviors/<scenario>.sh` asserting an agent does NOT write test files under `.issues/`, per the artifact-only generator paradigm. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-7, artifact-only generator, absence-of-`.issues/`-write assertions
- [ ] 40. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the new behavioral test does not regress the enforcement suite. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-7, post-GREEN regression
- [ ] 41. **verify (**sub-agent**).** Run the behavioral test via `with-test-home opencode run`; assert stderr shows NO `.issues/` write actions; Bash tool timeout >= 600s. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-7, behavioral test PASS, stderr-based absence assertions, 600s timeout
- [ ] 42. **commit-inline (**inline**).** Stage and commit the behavioral enforcement test. **→ SC-7**
  - Command: `git add .opencode/tests-v2/behaviors/<scenario>.sh && git commit -m "<message>"`

**Phase 6 VbC:**
- [ ] 43. **VbC (**clean-room**).** Verify SC-7 passes its behavioral check: the enforcement test runs clean and asserts no `.issues/` test-file write. **→ SC-7**

**Post-Implementation Steps:**
- [ ] 44. **audit (**sub-agent**).** Run the adversarial audit of the deliverable via the DiMo 4-role chain (investigator, validator, evaluator, arbiter). **→ all SCs**
  - Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence
  - Context: all SC verdicts, evidence artifacts
- [ ] 45. **z3-check (**inline**).** Run the Z3 constraint solver verification against the dependency contract. **→ all SCs**
  - Command: `.opencode/tools/solve check --state-path ... --contract-path ...`
  - Context: dependency contract, phase DAG
- [ ] 46. **structural-checks (**sub-agent**).** Run the finishing checklist (lint, typecheck, etc.). **→ all SCs**
  - Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
  - Context: all modified files
- [ ] 47. **pre-pr-gate (**sub-agent**).** Verify all SC verdicts; BLOCK if any FAIL. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: all SC verdicts
- [ ] 48. **regression-check (**sub-agent**).** Run the final regression check before PR. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: all SCs, final regression
- [ ] 49. **review-prep (**sub-agent**).** Prepare the PR review context. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow-pr. Read `git-workflow-pr/tasks/review-prep.md` first")`
  - Context: all SCs, PR scope
- [ ] 50. **create-pr (**sub-agent**).** Create the pull request. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute create task from git-workflow-pr")`
  - Context: all SCs, PR scope
- [ ] 51. **exec-summary (**sub-agent**).** Generate the completion executive summary. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute completion task from completion-core")`
  - Context: all SCs, PR status

---

## Exit Criteria

- [ ] C1. `.opencode/.issues/AGENTS.md` contains an explicit exclusions list stating `.issues/` holds issue metadata only, never source/test/fixture/code (SC-1).
- [ ] C2. `.opencode/skills/test-driven-development/tasks/red.md` no longer lists `.issues/{N}/tests/` as a valid test storage path (SC-2).
- [ ] C3. `.opencode/skills/test-driven-development/tasks/red.md` directs test placement by the owning-repo principle (SC-3).
- [ ] C4. `.opencode/skills/writing-plans/reference/implementation-workflow.md` Rule 1 clarifies `.issues/{N}/` holds issue metadata only (SC-4).
- [ ] C5. `.opencode/skills/spec-creation/tasks/create.md` Step 6 disambiguates the analytical-artifacts copy target to analysis-artifacts-only (SC-5).
- [ ] C6. `.opencode/skills/git-workflow-pr/tasks/review-prep.md` Step 0 no longer auto-commits arbitrary dirty `.issues/<N>/` files into feature PRs (SC-6).
- [ ] C7. A behavioral enforcement test at `.opencode/tests-v2/behaviors/` asserts an agent does NOT write test files under `.issues/`, per the artifact-only generator framework (SC-7).
- [ ] C8. All SCs pass the verification gate; the plan is complete with no partial implementation.

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
