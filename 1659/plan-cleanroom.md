# Implementation Plan — #1659 — Remove worktree bootstrap from session-init

**Goal:** Remove `is_worktree_setup()` and `bootstrap_worktree_layout()` from `tools/session-init`, and remove the call to `bootstrap_worktree_layout()` in `main()`.

**Architecture:** Single file edit to `.opencode/tools/session-init`. Three removals: two function definitions and one call site.

**Files:**
- `.opencode/tools/session-init`

> **Compliance requirement:** This plan is a contract. Every step MUST be executed in order. No step may be skipped, reordered, or combined. Each step produces a specific deliverable that the next step depends on. Violating this order produces defective work that must be discarded.

> **One step at a time:** Execute exactly one step, then stop and wait for the next instruction. Do not batch steps, do not skip ahead, do not combine edits. Each step is a complete unit of work.

> **Step Status:** After each step, report the step number and status (PASS/FAIL). On FAIL, stop and report the issue.

## Phase 1 — Remove worktree bootstrap functions and call site

**Concern:** Remove `is_worktree_setup()` function definition, `bootstrap_worktree_layout()` function definition, and the call to `bootstrap_worktree_layout()` in `main()`.

**Files:** `.opencode/tools/session-init`

**SCs:** All

**Dependencies:** None

**Entry:** Plan approved

**Exit:** All three removals complete, file is syntactically valid Python

- [ ] 1. **Remove `is_worktree_setup()` function (**sub-agent**).** Delete lines 445-448 (the function definition and body). **→ SC-1**
- [ ] 2. **Remove `bootstrap_worktree_layout()` function (**sub-agent**).** Delete lines 521-588 (the function definition and body). **→ SC-2**
- [ ] 3. **Remove call to `bootstrap_worktree_layout()` in `main()` (**sub-agent**).** On line 713, delete the line `bootstrap_worktree_layout()`. **→ SC-3**
- [ ] 4. **Verify file is syntactically valid Python (**sub-agent**).** Run `uv run python -c "import ast; ast.parse(open('.opencode/tools/session-init').read())"` and confirm no syntax errors. **→ SC-4**

#### Phase 1 VbC

- [ ] 5. **VbC (**clean-room**).** Verify: `is_worktree_setup` no longer appears in file; `bootstrap_worktree_layout` no longer appears in file; `main()` contains no call to `bootstrap_worktree_layout`; file parses as valid Python. **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** N/A — single phase.

> **Compliance requirement:** This plan is a contract. Every step MUST be executed in order. No step may be skipped, reordered, or combined. Each step produces a specific deliverable that the next step depends on. Violating this order produces defective work that must be discarded.

> **Self-remediation protocol:** If a step fails, diagnose the root cause, fix it, and re-run the step. Do not skip the step or mark it as complete without verification. If the fix requires changes outside this plan's scope, stop and report.

## Exit Criteria

- C1. `is_worktree_setup()` function definition removed from `tools/session-init`
- C2. `bootstrap_worktree_layout()` function definition removed from `tools/session-init`
- C3. Call to `bootstrap_worktree_layout()` removed from `main()`
- C4. File parses as valid Python with no syntax errors
