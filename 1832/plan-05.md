# Phase 5: Full suite verification

**Spec:** #1832
**SCs:** SC-18
**Dependency:** Phase 4 complete

## Goal

Run the full behavioral test suite to verify all changes pass with 0 failures.

## Steps

### Step 22 — Run full suite

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_21`

Run `bash .opencode/tests/test-enforcement.sh --changed`

**SC-18 verification:** All tests pass with 0 failures.

### Step 23 — Remediation (if needed)

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_22`

If any test fails:
1. Diagnose root cause
2. Remediate
3. Re-run `test-enforcement.sh --changed`
4. Repeat until 0 failures

### Step 24 — Review-prep

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_23`

Run `git-workflow --task review-prep`:
- Verify all commits are on the feature branch
- Verify diff against `main`
- Generate compare URL
- Prepare PR body

### Step 25 — PR creation

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_24`

Create PR from `feature/1832-test-env-production-parity` → `main` with:
- Summary of all 5 phases
- SC table with PASS status
- Compare URL

## Phase Completion

- [ ] SC-18 passes (full suite 0 failures)
- [ ] Review-prep complete
- [ ] PR created
- [ ] All 18 SCs pass with 100% clean PASS

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
