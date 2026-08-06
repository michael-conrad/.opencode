# Phase 4 — Remove No Metadata Trust doctrine

**Concern:** Remove the obsolete "No Metadata Trust" doctrine sections now that local `issue.yaml` is the certifying source.

**Files:**
- `.opencode/skills/issue-operations-core/tasks/read-issue.md`
- `.opencode/skills/verification-before-completion/tasks/operating-protocol.md`

**SCs:** SC-16, SC-17

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: local-first label reads established
- Phase 2 VbC passed

**Exit Conditions:**
- `read-issue.md` no longer contains the "No Metadata Trust Exceptions" section
- `operating-protocol.md` no longer contains the "No Metadata Trust Exceptions" section

---

## Code Path Coverage

| SC | Code Path |
|----|-----------|
| SC-16 | issue-operations-core → read-issue → No Metadata Trust section (removed) |
| SC-17 | verification-before-completion → operating-protocol → No Metadata Trust section (removed) |

## Cross-Cutting SCs

No cross-cutting SCs. `operating-protocol.md` is also modified by Phase 2 (SC-14) and Phase 5 (SC-15); this phase follows Phase 2 to avoid same-file edit conflict.

## Interface Boundaries

- No Metadata Trust doctrine → agent metadata verification — BACKWARD-COMPATIBLE. The doctrine was a workaround for unreliable remote labels; local `issue.yaml` is now the certifying source, so distrust of metadata is obsolete.

## State Transitions

| SC | From | To |
|----|------|----|
| SC-16 | `read-issue.md` contains "No Metadata Trust Exceptions" section | `read-issue.md` no longer contains the section |
| SC-17 | `operating-protocol.md` contains "No Metadata Trust Exceptions" section | `operating-protocol.md` no longer contains the section |

**Cost frame:** Verifying each doctrine removal costs one grep search of the task file. Skipping means the "Labels are not self-certifying" doctrine persists even though local `issue.yaml` IS the certifying source — the next agent continues to distrust local metadata.

---

- [ ] 58. **RED (**sub-agent**).** Run a grep assertion that `read-issue.md` currently contains "No Metadata Trust". The assertion SHALL match (RED state) because the doctrine section is present. **→ SC-16**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 59. **GREEN (**sub-agent**).** Remove the entire "No Metadata Trust Exceptions" section from `read-issue.md`. **→ SC-16**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 60. **Verify (**clean-room**).** Grep `read-issue.md` for "No Metadata Trust" — SHALL return no matches. **→ SC-16**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - Clean up `tmp/2241/artifacts/pipeline-verify-*` before running
- [ ] 61. **Checkpoint commit (**inline**).** Commit `read-issue.md`. **→ SC-16**

- [ ] 62. **RED (**sub-agent**).** Run a grep assertion that `operating-protocol.md` currently contains "No Metadata Trust". The assertion SHALL match (RED state) because the doctrine section is present. **→ SC-17**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 63. **GREEN (**sub-agent**).** Remove the entire "No Metadata Trust Exceptions" section from `operating-protocol.md`. **→ SC-17**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 64. **Verify (**clean-room**).** Grep `operating-protocol.md` for "No Metadata Trust" — SHALL return no matches. **→ SC-17**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 65. **Checkpoint commit (**inline**).** Commit `operating-protocol.md`. **→ SC-17**

#### Phase 4 VbC

- [ ] 66. **VbC (**clean-room**).** Verify `read-issue.md` and `operating-protocol.md` contain no "No Metadata Trust" section. **→ SC-16, SC-17**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - All SC verdicts must be PASS; any FAIL or DONE_WITH_CONCERNS coerced to FAIL blocks the phase

**Concern transition:** Leaving No Metadata Trust doctrine removal → entering comment-scanning removal. Phase 5 follows Phase 2 (and may follow Phase 4 where `operating-protocol.md` SC-17 precedes SC-15's edit on the same file).
