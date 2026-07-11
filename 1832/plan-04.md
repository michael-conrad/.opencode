# Phase 4: Documentation

**Spec:** #1832
**SCs:** SC-11, SC-12
**Dependency:** Phase 3 complete

## Goal

Add Session Failure Diagnosis section to `tests/AGENTS.md` and cross-reference in `.opencode/AGENTS.md`.

## Steps

### Step 18 — GREEN: Add §Session Failure Diagnosis to `tests/AGENTS.md`

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_17`

Edit `.opencode/tests/AGENTS.md`:
- Add §Session Failure Diagnosis section with:
  - Diagnostic checklist table (6 checks)
  - 5 common root causes
  - Clarification that `node_modules/` under `~/.config/opencode/` is irrelevant to test isolation

**SC-11 verification:** Grep for `Session Failure Diagnosis` heading

### Step 19 — GREEN: Add cross-reference to `.opencode/AGENTS.md`

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_18`

Edit `.opencode/AGENTS.md`:
- Update the "Isolated test environment" paragraph with session failure diagnosis summary
- Add cross-reference to the full checklist in `tests/AGENTS.md`

**SC-12 verification:** Grep for `Session failure diagnosis` in `.opencode/AGENTS.md`

### Step 20 — VbC: Verify all Phase 4 SCs

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_19`

Run `verification-before-completion` for SC-11, SC-12.
Both are `string` evidence type — grep checks sufficient.

### Step 21 — Commit

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_20`

Commit Phase 4 changes with message:
```
Phase 4: Add session failure diagnosis documentation

- Add §Session Failure Diagnosis to tests/AGENTS.md
- Add cross-reference in .opencode/AGENTS.md

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
```

## Phase Completion

- [ ] All Phase 4 SCs pass (SC-11, SC-12)
- [ ] Changes committed to `feature/1832-test-env-production-parity`
- [ ] Pipeline state updated to Phase 5

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
