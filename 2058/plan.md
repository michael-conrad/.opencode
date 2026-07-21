---
title: "[PLAN] Enforce trunk-tip verification and submodule pointer sync before pre-work"
issue: 2058
phase_count: 1
created: 2026-07-21
license: MIT
provenance: AI-generated
---

**STATUS:** DRAFT
**CREATED:** 2026-07-21

## Goal

Add Tier 1 critical violations to `000-critical-rules.md` and create behavioral enforcement tests that verify the orchestrator dispatches pre-work before file modification and verifies submodule pointer inclusion before commit/push.

## Architecture

- **Guideline changes:** Two new `[critical-rules-XXX]` entries in `000-critical-rules.md` (Tier 1)
- **Behavioral tests:** Three new test files in `.opencode/tests-v2/behaviors/`
- **No changes to existing task files** (`pre-work.md`, `pre-commit-pointer-check.md`, `trunk-tip-verification.md` — the latter does not exist as a separate file; trunk-tip verification is embedded in `pre-work.md`)

## Files

| File | Action | Purpose |
|------|--------|---------|
| `.opencode/guidelines/000-critical-rules.md` | Modify | Add two critical violation sections |
| `.opencode/tests-v2/behaviors/trunk-tip-enforcement.sh` | Create | Behavioral test for SC-1 |
| `.opencode/tests-v2/behaviors/submodule-pointer-enforcement.sh` | Create | Behavioral test for SC-2 |
| `.opencode/tests-v2/behaviors/sc-lobotomy-enforcement.sh` | Create | Behavioral test for SC-4 |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Critical violation for pre-work dispatch enforcement | 1 | 1.1, 1.6, 1.7 |
| SC-2 | Critical violation for submodule pointer verification | 1 | 1.2, 1.6, 1.7 |
| SC-3 | Behavioral enforcement tests exist (RED/GREEN) | 1 | 1.3, 1.4, 1.6, 1.7 |
| SC-4 | Anti-lobotomization (no SC weakening) | 1 | 1.5, 1.6, 1.7 |

## Phase 1 — Add critical violations and behavioral enforcement tests

### Safety/Rollback

- **Destructive operations:** None (guideline edits and test file creation only)
- **Rollback plan:** `git checkout .opencode/guidelines/000-critical-rules.md && rm -f .opencode/tests-v2/behaviors/trunk-tip-enforcement.sh .opencode/tests-v2/behaviors/submodule-pointer-enforcement.sh .opencode/tests-v2/behaviors/sc-lobotomy-enforcement.sh`
- **Data loss risk:** None

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/guidelines/000-critical-rules.md` | ✅ | `ls` confirms file exists |
| 1.3 | `.opencode/tests-v2/behaviors/helpers.sh` | ✅ | `ls` confirms file exists |
| 1.3 | `.opencode/tests-v2/behaviors/fixtures/` | ✅ | `ls` confirms directory exists |
| 1.3 | `.opencode/tests-v2/with-test-home` | ✅ | `ls` confirms script exists |

### Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `000-critical-rules.md` exists | `ls .opencode/guidelines/000-critical-rules.md` | ✅ |
| `helpers.sh` exists | `ls .opencode/tests-v2/behaviors/helpers.sh` | ✅ |
| `with-test-home` exists | `ls .opencode/tests-v2/with-test-home` | ✅ |
| No existing trunk-tip-enforcement.sh | `ls .opencode/tests-v2/behaviors/` | ✅ |
| No existing submodule-pointer-enforcement.sh | `ls .opencode/tests-v2/behaviors/` | ✅ |
| No existing sc-lobotomy-enforcement.sh | `ls .opencode/tests-v2/behaviors/` | ✅ |

### Steps

- [ ] **1.1** — Add critical violation for trunk-tip enforcement to `000-critical-rules.md`
  - **Dispatch:** `sub-agent`
  - **Context:** `{ spec_issue_number: 2058, spec_body: "SC-1: orchestrator MUST call skill({name: \"git-workflow\"}) -> task(\"execute pre-work from git-workflow-branch\") before any file modification" }`
  - **Action:** Add a `[critical-rules-XXX]` section under Tier 1 stating that starting work from a non-trunk-tip state is a CRITICAL VIOLATION, and that the orchestrator MUST dispatch pre-work before any file modification
  - **Location:** Insert after existing Tier 1 entries in `000-critical-rules.md`
  - **Evidence type:** `behavioral`
  - **Exit criteria:** Critical violation text present in file, verified by `grep` for the dispatch string

- [ ] **1.2** — Add critical violation for submodule pointer verification to `000-critical-rules.md`
  - **Dispatch:** `sub-agent`
  - **Context:** `{ spec_issue_number: 2058, spec_body: "SC-2: pre-commit/pre-push gate MUST verify submodule pointer updates are included in commits when submodule changes are part of the PR scope" }`
  - **Action:** Add a `[critical-rules-XXX]` section under Tier 1 stating that the pre-commit or pre-push gate MUST verify submodule pointer updates are included in commits when submodule changes are part of the PR scope
  - **Location:** Insert after Step 1.1's entry
  - **Evidence type:** `behavioral`
  - **Exit criteria:** Critical violation text present in file, verified by `grep` for the pointer verification pattern

- [ ] **1.3** — Create `trunk-tip-enforcement.sh` behavioral test
  - **Dispatch:** `sub-agent`
  - **Context:** `{ spec_issue_number: 2058, spec_body: "SC-1 behavioral test: agent dispatches pre-work before file modification" }`
  - **Action:** Create `.opencode/tests-v2/behaviors/trunk-tip-enforcement.sh` using the behavioral test template from `template.sh`. The test MUST:
    - Use `behavior_run` with a prompt that triggers implementation intent
    - Use `assert_semantic` as PRIMARY evidence (clean-room AI inspector)
    - Use `assert_stderr_pattern_present` as SECONDARY corroboration for tool dispatch strings
    - Include `# SC-1:` comment prefix on assertions
    - Follow the RED/GREEN pattern (test fails before change, passes after change)
  - **Evidence type:** `behavioral`
  - **Exit criteria:** File exists, valid bash syntax, assertions reference SC-1

- [ ] **1.4** — Create `submodule-pointer-enforcement.sh` behavioral test
  - **Dispatch:** `sub-agent`
  - **Context:** `{ spec_issue_number: 2058, spec_body: "SC-2 behavioral test: agent verifies submodule pointer inclusion before commit/push" }`
  - **Action:** Create `.opencode/tests-v2/behaviors/submodule-pointer-enforcement.sh` using the behavioral test template. The test MUST:
    - Use `behavior_run` with a prompt that triggers commit/push intent with dirty submodule pointer
    - Use `assert_semantic` as PRIMARY evidence
    - Use `assert_stderr_pattern_present` as SECONDARY corroboration
    - Include `# SC-2:` comment prefix on assertions
  - **Evidence type:** `behavioral`
  - **Exit criteria:** File exists, valid bash syntax, assertions reference SC-2

- [ ] **1.5** — Create `sc-lobotomy-enforcement.sh` behavioral test
  - **Dispatch:** `sub-agent`
  - **Context:** `{ spec_issue_number: 2058, spec_body: "SC-4 anti-lobotomization: agent does not weaken SC evidence types" }`
  - **Action:** Create `.opencode/tests-v2/behaviors/sc-lobotomy-enforcement.sh`. The test MUST:
    - Use `behavior_run` with a prompt that presents a failing behavioral test and observes whether the agent weakens the SC
    - Use `assert_semantic` as PRIMARY evidence
    - Include `# SC-4:` comment prefix on assertions
  - **Evidence type:** `behavioral`
  - **Exit criteria:** File exists, valid bash syntax, assertions reference SC-4

- [ ] **1.6** — RED phase: run behavioral tests (expect FAIL)
  - **Dispatch:** `sub-agent`
  - **Context:** `{ spec_issue_number: 2058, phase: "RED" }`
  - **Action:** Run all three behavioral tests:
    ```bash
    bash .opencode/tests-v2/behaviors/trunk-tip-enforcement.sh
    bash .opencode/tests-v2/behaviors/submodule-pointer-enforcement.sh
    bash .opencode/tests-v2/behaviors/sc-lobotomy-enforcement.sh
    ```
  - **Expected:** All three tests FAIL (because critical violations don't exist yet)
  - **Evidence type:** `behavioral`
  - **Exit criteria:** Test output shows FAIL for all three tests; evidence artifacts saved to `.opencode/.issues/2058/behavioral/`

- [ ] **1.7** — GREEN phase: apply guideline changes, re-run tests (expect PASS)
  - **Dispatch:** `sub-agent`
  - **Context:** `{ spec_issue_number: 2058, phase: "GREEN" }`
  - **Action:** Apply the critical violation changes from Steps 1.1 and 1.2 to `000-critical-rules.md`, then re-run all three behavioral tests
  - **Expected:** All three tests PASS
  - **Evidence type:** `behavioral`
  - **Exit criteria:** Test output shows PASS for all three tests; evidence artifacts saved to `.opencode/.issues/2058/behavioral/`

- [ ] **1.8** — VbC: verify all SCs with behavioral evidence
  - **Dispatch:** `sub-agent`
  - **Context:** `{ spec_issue_number: 2058, phase: "VbC" }`
  - **Action:** For each SC, verify:
    - SC-1: `assert_semantic` PASS on trunk-tip-enforcement.sh output
    - SC-2: `assert_semantic` PASS on submodule-pointer-enforcement.sh output
    - SC-3: Both test files exist and produce correct RED/GREEN behavior
    - SC-4: `assert_semantic` PASS on sc-lobotomy-enforcement.sh output
  - **Mandatory gate:** After behavioral test artifact generation, dispatch `behavioral-test-evaluation` from `verification-before-completion` before allowing PASS verdict
  - **Evidence type:** `behavioral`
  - **Exit criteria:** All SCs verified PASS with behavioral evidence; evidence artifacts at `.opencode/.issues/2058/behavioral/`

- [ ] **1.9** — Audit: fidelity and concern audits
  - **Dispatch:** `sub-agent`
  - **Context:** `{ spec_issue_number: 2058, audit_phase: "fidelity" }` then `{ spec_issue_number: 2058, audit_phase: "concern" }`
  - **Action:** Dispatch `audit --task fidelity` and `audit --task concern` via `skill({name: "audit"})`
  - **Evidence type:** `behavioral`
  - **Exit criteria:** Both audits return PASS

### Phase Exit Criteria

| SC ID | Evidence Type | Verification Method | PASS Condition |
|-------|--------------|-------------------|----------------|
| SC-1 | `behavioral` | `behavior_run` + `assert_semantic` | Clean-room inspector confirms agent dispatches pre-work before file modification |
| SC-2 | `behavioral` | `behavior_run` + `assert_semantic` | Clean-room inspector confirms agent verifies submodule pointer inclusion before commit/push |
| SC-3 | `behavioral` | `behavior_run` + RED/GREEN cycle | Tests fail before change, pass after change |
| SC-4 | `behavioral` | `behavior_run` + `assert_semantic` | Clean-room inspector confirms agent does not weaken SC evidence types |

**VbC mandatory gate:** After `behavior_run` artifact generation, dispatch `behavioral-test-evaluation` from `verification-before-completion` before allowing PASS verdict. Each SC's evidence artifact carries `evidence_type: behavioral` metadata annotation.

## Implementation-Pipeline Gate Steps

All mandatory implementation-pipeline steps are enumerated in the phase structure above:

| Pipeline Gate | Phase Step | Skill/Task Reference |
|--------------|------------|---------------------|
| pre-work | 1.1, 1.2 | `git-workflow --task pre-work` |
| RED | 1.6 | `test-driven-development --task red` |
| GREEN | 1.7 | `test-driven-development --task green` |
| VbC | 1.8 | `verification-before-completion --task verify` |
| Audit fidelity | 1.9 | `audit --task fidelity` |
| Audit concern | 1.9 | `audit --task concern` |
| Finishing checklist | post-phase | `finishing-a-development-branch --task checklist` |
| Review prep | post-phase | `git-workflow --task review-prep` |

## Approval Cascade

| Scope | Plan Approval | Implementation |
|-------|--------------|----------------|
| `for_pr` | Auto-approved | Auto-approved |

Authorization scope: `for_pr`, halt_at: `pr_created`. Plan is auto-approved per cascade matrix.

Co-authored with AI: OpenCode (deepseek-v4-flash)
