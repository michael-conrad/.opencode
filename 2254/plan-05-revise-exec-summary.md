# Phase 5 — revise exec-summary regeneration

**Concern:** Revise task regenerates exec-summary remote issue body on revision.

**Files:**
- `.opencode/skills/spec-creation/tasks/revise.md`

**SCs:** SC-22

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: canonical exec-summary body format established by the create task
- Phase 1 VbC passed

**Exit Conditions:**
- spec-creation/tasks/revise.md regenerates the exec-summary remote issue body when the spec is revised

---

## Code Path Coverage

- Path 2 (spec-creation task cards): `.opencode/skills/spec-creation/tasks/revise.md` — regenerate exec-summary remote issue body on revision

## Cross-Cutting SCs

- Revise exec-summary regeneration (SC-22) — reuses the canonical exec-summary body format established by the create task in Phase 1 (SC-19)

## Interface Boundaries

- spec-creation/tasks/revise.md → spec-creation sub-agent (same revision flow, regenerated body)

## State Transitions

- create task exec-summary body: CANONICAL (from Phase 1) → REGENERATED (revise refreshes the remote exec-summary body to match the authoritative local spec)

---

## Step-by-step

- [ ] 115. **RED (**sub-agent**).** Write failing enforcement test asserting spec-creation/tasks/revise.md regenerates the exec-summary remote issue body when the spec is revised. **→ SC-22**
- [ ] 116. **GREEN (**sub-agent**).** Make revise.md regenerate the exec-summary remote issue body on revision. **→ SC-22**
- [ ] 117. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN change. **→ SC-22**
- [ ] 118. **verify (**clean-room**).** Verify SC-22: grep spec-creation/tasks/revise.md for exec-summary body regeneration on revision. **→ SC-22**
- [ ] 119. **commit-inline (**inline**).** Stage and commit spec-creation/tasks/revise.md with the SC-22 test and change together.

#### Phase 5 VbC

- [ ] 120. **VbC (**clean-room**).** Verify Phase 5 SC-22 passes its verification method. **→ SC-22**

**Cost frame:** Verifying the revise exec-summary regeneration fix costs one grep search. Skipping means a revised spec ships a stale remote exec-summary body that contradicts the authoritative local spec.

**Concern transition:** Leaving revise exec-summary regeneration → entering format conformance + linter + links. Phase 7 depends on Phase 5's revise exec-summary regeneration.

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
