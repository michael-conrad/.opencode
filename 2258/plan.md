---
plan_schema_version: "1.0"
issue: 2258
title: "Fix Gate 2 fallback SHA extraction in pre-commit hook"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 1
---

# Implementation Plan — #2258 — Fix Gate 2 fallback SHA extraction in pre-commit hook

**Goal:** Correct the fallback SHA extraction in the pre-commit hook's Gate 2 so it yields the full 40-character SHA for both clean and dirty submodules, eliminating the false BLOCK that fires on every commit.

**Architecture:** Replace the buggy fallback extraction at `.opencode/hooks/pre-commit` line 49 with a locale-independent full-SHA extraction form. The stale-pointer gate itself, the primary staged-gitlink path (line 46), and the comparison logic (lines 52-70) remain unchanged. The chosen form is the explicit awk first-char test, which strips only a status prefix (`+`, `-`, or `U`) when present and never strips a hex character.

**Files:**
- `.opencode/hooks/pre-commit` (line 49 only)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Fix Gate 2 fallback SHA extraction | `test-driven-development` | `red` | `.opencode/hooks/pre-commit` line 49 | SC-1 | — |

---

## Phase Details

### Phase 1 — Fix Gate 2 fallback SHA extraction

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/hooks/pre-commit` line 49 |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
file_to_modify: ".opencode/hooks/pre-commit"
line_to_replace: 49
current_line: "STAGED_SHA=$(git submodule status \"$sp\" 2>/dev/null | awk '{print substr($1,2)}' || true)"
replacement_form: "git submodule status \"$sp\" 2>/dev/null | awk '{s=$1; if (s ~ /^[+U-]/) s=substr(s,2); print s}'"
sc_ids: [SC-1]
evidence_type: behavioral
```

---

## Exit Criteria

- [ ] C1. The fallback SHA extraction at `.opencode/hooks/pre-commit` line 49 yields the full 40-char SHA for a clean submodule (no leading hex char stripped).
- [ ] C2. The extraction strips only a status prefix (`+`, `-`, or `U`) when present, and never strips a hex character.
- [ ] C3. The extraction is locale-independent — it does not rely on a specific `LANG`/`LC_ALL` value.
- [ ] C4. The stale-pointer gate, the primary staged-gitlink path (line 46), and the comparison logic (lines 52-70) remain unchanged.
- [ ] C5. The extraction does not emit an empty `STAGED_SHA` for a clean, current submodule.
- [ ] C6. SC-1 verification passes with behavioral evidence.

---

# Phase 1 — Fix Gate 2 fallback SHA extraction

**Concern:** Correct the fallback SHA extraction so it yields the full 40-character SHA for both clean and dirty submodules, eliminating the false BLOCK on every commit.

**Files:**
- `.opencode/hooks/pre-commit` (line 49 only)

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2258 is approved (`approved-for-for_pr` label present in local `issue.yaml`)
- Feature branch exists
- Structure artifact exists at `.opencode/.issues/2258/artifacts/structure.yaml`
- `.opencode/hooks/pre-commit` exists and line 49 contains the buggy `awk '{print substr($1,2)}'` fallback

**Exit Conditions:**
- Line 49 uses the explicit awk first-char test form
- The extraction yields the full 40-char SHA for a clean submodule
- The gate, primary path, and comparison logic are unchanged
- SC-1 verification passes with behavioral evidence

---

- [ ] 1. **Pre-implementation — coherence gate (**inline**).** Verify the spec, structure artifact, and plan are mutually consistent: SC-1 maps to Phase 1, the phase DAG has no edges, and the target is `.opencode/hooks/pre-commit` line 49. If any inconsistency is found, HALT and report.
- [ ] 2. **Pre-implementation — baseline check (**inline**).** Verify the current state: `.opencode/hooks/pre-commit` exists, line 49 contains the buggy `awk '{print substr($1,2)}'` fallback, and the working tree is on a feature branch with no uncommitted changes to the hook. Confirm the feature branch was created before any file modification.
- [ ] 3. **Pre-regression (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`. Run regression test patterns to establish the baseline before the RED phase. **→ SC-1**
- [ ] 4. **Pre-regression verify (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify the pre-regression results. **→ SC-1**
- [ ] 5. **RED (**sub-agent**).** Dispatch `task(..., prompt: "execute red task from test-driven-development")`. Write a failing enforcement test that asserts the Gate 2 fallback SHA extraction yields the full 40-char SHA for a clean submodule. The test must assert that the current buggy `awk '{print substr($1,2)}'` form produces the 39-char truncated value, and that the naive `sed 's/^[+-U]//'` form also produces the 39-char truncated value. The test FAILS because the fix does not exist yet. **→ SC-1**
- [ ] 6. **GREEN (**sub-agent**).** Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace line 49 with the explicit awk first-char test form: `STAGED_SHA=$(git submodule status "$sp" 2>/dev/null | awk '{s=$1; if (s ~ /^[+U-]/) s=substr(s,2); print s}' || true)`. Make the RED test PASS. No scope creep — only the minimum change needed. **→ SC-1**
- [ ] 7. **GREEN doublecheck (**clean-room**).** Verify the replacement form strips only a status prefix (`+`, `-`, or `U`) when present and never strips a hex character. Confirm the `sed 's/^[+-U]//'` form (dash between `+` and `U`) is NOT used, as it is locale-dependent and defective. **→ SC-1**
- [ ] 8. **Post-regression (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after the GREEN phase. **→ SC-1**
- [ ] 9. **Verify (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify the implementation against SC-1. Execute the Gate 2 fallback SHA extraction against a real clean submodule (e.g., `ArticleHtmlFix`) and assert it yields the full 40-char SHA equal to the true gitlink SHA from `git ls-tree HEAD`. Assert the naive `awk '{print substr($1,2)}'` and `sed 's/^[+-U]//'` both produce the 39-char truncated value that the fix eliminates. **→ SC-1**
- [ ] 10. **Checkpoint commit (**inline**).** Orchestrator runs `git add .opencode/hooks/pre-commit <test-file> && git commit -m "<message>"`. The test and its implementation are committed as one atomic slice. No co-author trailers during implementation commits. **→ SC-1**

#### Phase 1 VbC

- [ ] 11. **VbC (**clean-room**).** Verify the fallback SHA extraction at line 49 yields the full 40-char SHA for a clean submodule, strips only a status prefix when present, is locale-independent, does not emit an empty `STAGED_SHA`, and leaves the gate, primary path, and comparison logic unchanged. **→ SC-1**

**Concern transition:** Leaving the Gate 2 fallback SHA extraction fix → entering post-implementation. This is the only phase; no downstream phase depends on it.

---

## Post-implementation

- [ ] 12. **Audit (**sub-agent**).** Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence. Adversarial audit of the deliverable. **→ SC-1**
- [ ] 13. **Z3 check (**inline**).** Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...` directly. Run Z3 constraint solver verification. **→ SC-1**
- [ ] 14. **Structural checks (**sub-agent**).** Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Run the finishing checklist (lint, typecheck, etc.). **→ SC-1**
- [ ] 15. **Pre-PR gate (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Read all SC verdicts; BLOCK if any FAIL. **→ SC-1**
- [ ] 16. **Regression check (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Final regression check before PR. **→ SC-1**
- [ ] 17. **Review prep (**sub-agent**).** Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. Prepare PR review context. **→ SC-1**
- [ ] 18. **Create PR (**sub-agent**).** Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`. Create the pull request. **→ SC-1**
- [ ] 19. **Exec summary (**sub-agent**).** Dispatch `task(..., prompt: "execute completion task from completion-core")`. Generate the completion executive summary. **→ SC-1**

---

## Lifecycle Events

| Timestamp | Event | Plan Path | Phase Count |
|-----------|-------|-----------|-------------|
| 2026-08-08T16:19:00Z | `plan_created` | `.opencode/.issues/2258/plan.md` | 1 |
