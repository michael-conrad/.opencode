# Phase 6 — Delete dead `push-body.md`

**Concern:** Delete the dead `push-body.md` file describing a non-existent sync operation.

**Files:**
- `.opencode/skills/issue-operations/platforms/local/tasks/push-body.md` (deleted)

**SCs:** SC-27

**Dependencies:** None (independent phase)

**Entry Conditions:**
- Spec #2241 approved
- Feature branch exists on `$DEFAULT_BRANCH` in the `.opencode` submodule
- Pre-implementation steps (coherence gate, baseline check) complete and PASS

**Exit Conditions:**
- `push-body.md` no longer exists at `.opencode/skills/issue-operations/platforms/local/tasks/push-body.md`

---

## Code Path Coverage

| SC | Code Path |
|----|-----------|
| SC-27 | issue-operations → local platform → push-body.md (dead file removed) |

## Cross-Cutting SCs

No cross-cutting SCs. The file has no consumers — it describes a non-existent sync operation.

## Interface Boundaries

No interface changes. The `local-issues` tool and `issue-operations` platform SKILL cards are unchanged.

## State Transitions

| SC | From | To |
|----|------|----|
| SC-27 | `push-body.md` exists at `issue-operations/platforms/local/tasks/` | `push-body.md` no longer exists |

**Cost frame:** Verifying the dead-file deletion costs one file-existence check. Skipping means a dead file describing a non-existent operation remains in the codebase, confusing future agents and reviewers.

---

- [ ] 108. **RED (**sub-agent**).** Assert that `push-body.md` exists at `.opencode/skills/issue-operations/platforms/local/tasks/push-body.md`. The assertion SHALL pass (RED state) because the file is present. **→ SC-27**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 109. **GREEN (**sub-agent**).** Delete `push-body.md` via `git rm` from `.opencode/skills/issue-operations/platforms/local/tasks/`. **→ SC-27**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 110. **Verify (**clean-room**).** Assert that the file no longer exists at `.opencode/skills/issue-operations/platforms/local/tasks/push-body.md` — SHALL NOT exist. **→ SC-27**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - Clean up `tmp/2241/artifacts/pipeline-verify-*` before running
- [ ] 111. **Checkpoint commit (**inline**).** Commit the `push-body.md` deletion. **→ SC-27**

#### Phase 6 VbC

- [ ] 112. **VbC (**clean-room**).** Verify the file does not exist at `.opencode/skills/issue-operations/platforms/local/tasks/push-body.md`. **→ SC-27**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - All SC verdicts must be PASS; any FAIL or DONE_WITH_CONCERNS coerced to FAIL blocks the phase

**Concern transition:** Leaving dead-file deletion → entering approval-gate guideline update. Phase 6 is independent; no phase depends on it.
