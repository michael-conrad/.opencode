# Phase 3: Dead code cleanup

**Spec:** #1832
**SCs:** SC-7, SC-8, SC-9, SC-10
**Dependency:** Phase 2 complete

## Goal

Remove remaining references to `ollama-model-resolve` after the script has already been deleted from `main`. Regression guard SCs only — no code changes to `helpers.sh`.

## Steps

### Step 12 — Verify SC-7: `tools/ollama-model-resolve` already deleted

**Dispatch:** `inline`
**Chain:** `step_11`

Run `file-exists .opencode/tools/ollama-model-resolve` — assert MISSING.
Note: Already deleted from `main`. This is a regression guard.

### Step 13 — GREEN: Update `060-tool-usage.md`

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_12`

Edit `.opencode/guidelines/060-tool-usage.md`:
- Remove `ollama-model-resolve` from Tier 3 tool list

**SC-8 verification:** Grep `060-tool-usage.md` for `ollama-model-resolve` — must not appear

### Step 14 — GREEN: Update `test-enforcement.sh`

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_13`

Edit `.opencode/tests/test-enforcement.sh`:
- Remove `ollama-model-resolve` assertion from `ollama-tooling-registration` scenario
- Verify actual scenario name before removing (may have been renamed/removed)

**SC-9 verification:** Grep `test-enforcement.sh` for `ollama-model-resolve` — must not appear

### Step 15 — GREEN: Update `verify-authorization.md`

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_14`

Edit `.opencode/skills/approval-gate/tasks/verify-authorization.md`:
- Remove model resolution via `ollama-model-resolve` from Step 0.2
- Verify reference already absent before removing

**SC-10 verification:** Grep `verify-authorization.md` for `ollama-model-resolve` — must not appear

### Step 16 — VbC: Verify all Phase 3 SCs

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_15`

Run `verification-before-completion` for SC-7, SC-8, SC-9, SC-10.
All are `string` evidence type — grep/file-existence checks sufficient.

### Step 17 — Commit

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_16`

Commit Phase 3 changes with message:
```
Phase 3: Remove dead ollama-model-resolve references

- Remove ollama-model-resolve from 060-tool-usage.md Tier 3 list
- Remove ollama-model-resolve assertion from test-enforcement.sh
- Remove ollama-model-resolve from verify-authorization.md Step 0.2

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
```

## Phase Completion

- [ ] All Phase 3 SCs pass (SC-7, SC-8, SC-9, SC-10)
- [ ] Changes committed to `feature/1832-test-env-production-parity`
- [ ] Pipeline state updated to Phase 4

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
