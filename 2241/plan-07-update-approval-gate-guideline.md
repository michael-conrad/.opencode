# Phase 7 — Update approval-gate guideline

**Concern:** Document that canonical authorization state is in local `issue.yaml`; remote labels are advisory/display only.

**Files:**
- `.opencode/guidelines/010-approval-gate.md`

**SCs:** SC-5

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 1 complete: local-first label writes established
- Phase 2 complete: local-first label reads established
- Phase 1 and Phase 2 VbC passed

**Exit Conditions:**
- `010-approval-gate.md` clarifies canonical auth state is local `issue.yaml`; remote labels advisory

---

## Code Path Coverage

| SC | Code Path |
|----|-----------|
| SC-5 | guideline → agent reads canonical auth source → local issue.yaml |

## Cross-Cutting SCs

No cross-cutting SCs. Documentation-only update confined to the `CONCERN_GUIDELINE` concern.

## Interface Boundaries

No interface changes. This is a documentation clarity update; no behavioral logic changes.

## State Transitions

| SC | From | To |
|----|------|----|
| SC-5 | `010-approval-gate.md` does not state the canonical auth source | `010-approval-gate.md` clarifies canonical auth state is local `issue.yaml`; remote labels advisory |

**Cost frame:** Verifying the guideline update costs one grep search of `010-approval-gate.md`. Skipping means the next agent reads the old guideline and continues using remote labels as authoritative — the documented canonical-source switch is never communicated.

---

- [ ] 113. **RED (**sub-agent**).** Run a grep assertion that `010-approval-gate.md` currently does NOT contain "canonical" or "local issue.yaml" in reference to authorization state. The assertion SHALL match the absence (RED state) because the canonical-source language is not present. **→ SC-5**
  - Dispatch via `task(..., prompt: "execute red task from test-driven-development")`
  - Clean up `tmp/2241/artifacts/pipeline-red-*` before running
- [ ] 114. **GREEN (**sub-agent**).** Update `010-approval-gate.md` to clarify that canonical authorization state is in local `{issues_prefix}/{N}/issue.yaml`; remote labels are advisory/display only. **→ SC-5**
  - Dispatch via `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 115. **Verify (**clean-room**).** Grep `010-approval-gate.md` for "canonical" or "local issue.yaml" — SHALL return matches. **→ SC-5**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - Clean up `tmp/2241/artifacts/pipeline-verify-*` before running
- [ ] 116. **Checkpoint commit (**inline**).** Commit `010-approval-gate.md`. **→ SC-5**

#### Phase 7 VbC

- [ ] 117. **VbC (**clean-room**).** Verify `010-approval-gate.md` clarifies canonical auth is local `issue.yaml`; remote labels advisory. **→ SC-5**
  - Dispatch via `task(..., prompt: "execute verify task from verification-before-completion")`
  - All SC verdicts must be PASS; any FAIL or DONE_WITH_CONCERNS coerced to FAIL blocks the phase

**Concern transition:** Leaving approval-gate guideline update → entering post-implementation steps (structural checks, verification, audit, regression check, review-prep, PR creation, completion). This is the final phase.
