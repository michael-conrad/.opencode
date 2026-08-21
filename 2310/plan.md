---
plan_schema_version: "1.0"
issue: 2310
title: "Dynamic trunk resolution in session_context_triggers.py diff stat"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 1
dispatch:
  - phase: phase_1
    skill: test-driven-development
    tasks:
      - red
      - green
      - post-regression
  - phase: phase_1
    skill: verification-before-completion
    tasks:
      - verify
  - phase: post
    skill: audit
    tasks:
      - verification-audit
  - phase: post
    skill: finishing-a-development-branch
    tasks:
      - checklist
  - phase: post
    skill: git-workflow-pr
    tasks:
      - review-prep
      - create
  - phase: post
    skill: completion-core
    tasks:
      - completion
---

# Implementation Plan — #2310 — Dynamic Trunk Resolution in session_context_triggers.py

**Goal:** Replace the hardcoded `origin/dev..HEAD` diff stat ref in `build_pair_mode_resume()` with a dynamically resolved trunk branch so pair-mode resume output works on every trunk-based repo (`master`/`main`).

**Architecture:** Add a `get_default_branch()` helper that resolves the trunk branch via `git remote show origin` (parsing the `HEAD branch:` line) with a `main` fallback when resolution fails. `build_pair_mode_resume()` uses the resolved branch to compute the diff stat. No external dependencies — PEP 723 `dependencies = []` is preserved. The `build_pair_mode_resume(branch: str) -> str` signature is unchanged (backward compatible). Local-only repos (no remote) omit the diff stat gracefully.

**Files:**
- `.opencode/scripts/session_context_triggers.py`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Dynamic trunk resolution | `test-driven-development` | `red` → `green` → `post-regression` | `session_context_triggers.py` `build_pair_mode_resume()` / `get_default_branch()` | SC-1 | — |

## Phase Details

### Phase 1 — Dynamic trunk resolution

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` → `verification-before-completion` |
| Task | `red` → `green` → `post-regression` → `verify` |
| Target | `session_context_triggers.py` `build_pair_mode_resume()` + new `get_default_branch()` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
files_to_modify:
  - .opencode/scripts/session_context_triggers.py
sc_ids: [SC-1]
evidence_type: behavioral
new_helper: get_default_branch
resolution_command: "git remote show origin" (parse "HEAD branch:" line)
fallback_branch: main
local_only_behavior: omit diff stat gracefully
signature_preserved: "build_pair_mode_resume(branch: str) -> str" unchanged
no_external_dependencies: true
```

---

## Pre-Implementation Steps (Tier 1 — once per plan)

These steps run before Phase 1 begins.

- [ ] 1. **Coherence gate (**clean-room**).** Verify the spec is coherent: all SCs traceable to requirements, all requirements traceable to SCs, no orphan requirements. Confirm SC-1's behavioral evidence type and verification method (via `with-test-home`) are consistent with the spec. **→ SC-1**
- [ ] 2. **Baseline check (**clean-room**).** Verify the codebase baseline: `.opencode/scripts/session_context_triggers.py` line 70 contains the hardcoded `origin/dev..HEAD` diff-stat ref, and the canonical trunk-resolution pattern (`git remote show origin` HEAD branch, fallback `main`) exists in the 5 reference task files. Confirm no prior changes to the target file are pending. **→ SC-1**

---

## Phase 1 — Dynamic trunk resolution

**Concern:** Resolve the trunk branch dynamically and compute the diff stat against it, replacing the hardcoded `origin/dev`.

**Files:**
- `.opencode/scripts/session_context_triggers.py`

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Pre-implementation steps (coherence gate, baseline check) passed
- Feature branch exists

**Exit Conditions:**
- `get_default_branch()` helper resolves the trunk via `git remote show origin` HEAD branch, falling back to `main`
- `build_pair_mode_resume()` computes the diff stat against the resolved trunk, never `origin/dev`
- Local-only repos omit the diff stat gracefully
- No external dependencies added; trigger structure unchanged

---

- [ ] 3. **RED (**sub-agent**).** Write a failing behavioral enforcement test asserting the script resolves the trunk dynamically (no hardcoded `origin/dev`) and computes the diff stat against the resolved trunk. Run it via `with-test-home`; assert stderr shows the hardcoded `origin/dev` is still present (RED — test FAILs). **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Implement the `get_default_branch()` helper (parse `git remote show origin` HEAD branch; fallback `main`) and update `build_pair_mode_resume()` to use the resolved branch for the diff stat. No scope creep — minimum change only. **→ SC-1**
- [ ] 5. **GREEN doublecheck (**clean-room**).** Verify the implementation matches the canonical trunk-resolution pattern in the 5 reference task files and preserves the `build_pair_mode_resume(branch: str) -> str` signature. **→ SC-1**
- [ ] 6. **Post-regression (**sub-agent**).** Run regression test patterns after the GREEN change; confirm no existing behavior regressed (trigger structure, exit codes, feedback boundary, nested-opencode detection). **→ SC-1**
- [ ] 7. **Verify (**clean-room**).** Run the behavioral test via `with-test-home`: send a real-domain prompt in a pair-mode branch context; assert stderr shows the script resolves the trunk dynamically (no `origin/dev`) and computes the diff stat against the resolved trunk. **→ SC-1**
- [ ] 8. **Commit (**inline**).** Stage and commit the test + implementation together as one atomic slice: `git add .opencode/scripts/session_context_triggers.py <test files> && git commit -m "<message>"`. **→ SC-1**

#### Phase 1 VbC

- [ ] 9. **VbC (**clean-room**).** Verify SC-1: `build_pair_mode_resume()` computes the diff stat against the dynamically resolved trunk branch (e.g., `origin/master..HEAD` or `origin/main..HEAD`), never `origin/dev`, and falls back to `main` when the remote HEAD branch cannot be resolved. **→ SC-1**

**Concern transition:** Phase 1 is the only phase (SC-1). No downstream phase depends on it.

---

## Post-Implementation Steps (Tier 1 — once per plan)

These steps run after Phase 1 completes.

- [ ] 10. **Audit (**sub-agent**).** Dispatch adversarial audit of the deliverable via `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence. **→ SC-1**
- [ ] 11. **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` to verify workflow state transitions satisfy the contracts. **→ SC-1**
- [ ] 12. **Structural checks (**sub-agent**).** Run the finishing checklist (`task(..., prompt: "execute checklist task from finishing-a-development-branch")`): lint, typecheck, and structural validation. **→ SC-1**
- [ ] 13. **Pre-PR gate (**clean-room**).** Verify all SC verdicts before PR creation via `task(..., prompt: "execute verify task from verification-before-completion")`; BLOCK if any SC verdict is FAIL (including DONE_WITH_CONCERNS and EVIDENCE_TYPE_MISMATCH coerced to FAIL). **→ SC-1**
- [ ] 14. **Regression check (**sub-agent**).** Run the final regression check before PR via `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-1**
- [ ] 15. **Review prep (**sub-agent**).** Prepare PR review context via `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. **→ SC-1**
- [ ] 16. **Create PR (**sub-agent**).** Create the pull request via `task(..., prompt: "execute create task from git-workflow-pr")`. **→ SC-1**
- [ ] 17. **Exec summary (**sub-agent**).** Generate the completion executive summary via `task(..., prompt: "execute completion task from completion-core")`. **→ SC-1**

---

## Exit Criteria

- [ ] C1. `get_default_branch()` resolves the trunk via `git remote show origin` HEAD branch with `main` fallback.
- [ ] C2. `build_pair_mode_resume()` computes the diff stat against the resolved trunk, never `origin/dev`.
- [ ] C3. SC-1 behavioral evidence (via `with-test-home`) passes: stderr shows dynamic trunk resolution.
- [ ] C4. No external dependencies added; `build_pair_mode_resume(branch: str) -> str` signature preserved.
- [ ] C5. Local-only repos omit the diff stat gracefully without crashing.
- [ ] C6. Trigger structure unchanged (only `pair_mode_resume` and `nested_opencode_fatal` remain).
- [ ] C7. All post-implementation gates (audit, z3-check, structural-checks, pre-pr-gate, regression-check) pass.

---

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **Phase 1:** Running the behavioral test via `with-test-home` costs minutes of execution time — a bounded delay that surfaces the dynamic-resolution defect before it ships. Skipping it means the hardcoded `origin/dev` defect ships to every trunk-based repo, silently omitting pair-mode diff stats, and costs 1000× more to diagnose and fix in production.

---

## Lifecycle Events

| Timestamp | Event | Detail |
|-----------|-------|--------|
| 2026-08-21T05:26:47Z | `plan_created` | Plan file: `.opencode/.issues/2310/plan.md`; phase count: 1 |

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
