# Phase 5 — Doc alignment

**Concern:** Align AGENTS.md §10.7/§14/R-18/§17 with the implemented predicates (concern-map: `docs-alignment`).

**Files:**
- `.opencode/tests-v2/AGENTS.md` (§10.7, §14, R-18/§17)

**SCs:** SC-12

**Dependencies:** Phase 4 (documentation mirrors the fully implemented gate/folding/scenario predicate set; Phase 4 transitively depends on Phase 3, whose SC-8/SC-9 predicates are the primary documentation target)

**Entry Conditions:**
- Phase 4 complete and VbC passed (all monitor-path predicates implemented)
- Coherence gate + baseline check passed (plan steps 1-2)

**Exit Conditions:**
- AGENTS.md §10.7, §14, and R-18/§17 mirror the exact implemented gate predicates; advisory markdown checks clean

**Code Path Coverage:**
- AGENTS.md §10.7/§14/§17 — documentation mirrored to implemented predicates (single-definition R-10 pattern)

**Cross-Cutting SCs:** R-10 single-definition doc mirroring; `BEHAVIOR_SEMANTIC_MONITOR` opt-in unchanged.

**Interface Boundaries:**
- Documentation-only phase — no shell scripts, YAML records, or scenario code modified

**State Transitions:**
- none (documentation-only; no runtime state changes)

**Cost frame:** Advisory doc-alignment checks cost seconds. Skipping costs weeks — documentation drifts from the shipped gate, a 1000× death-spiral multiplier.

---

- [ ] 84. **pre-regression (**task-card**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-12**
- [ ] 85. **pre-regression-verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-12**
- [ ] 86. **RED — doc alignment (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — AGENTS.md §10.7/§14/R-18 do not mirror the implemented gate predicates; advisory structural check fails. **→ SC-12**
- [ ] 87. **GREEN — doc alignment (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — AGENTS.md §10.7/§14/R-18 updated to mirror the exact implemented predicates. **→ SC-12**
- [ ] 88. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-12**
- [ ] 89. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — advisory markdown checks (mdformat/pymarkdownlnt) clean; content matches implemented predicates. **→ SC-12**
- [ ] 90. **commit-inline (**direct**).** Commit the AGENTS.md sections. **→ SC-12**

#### Phase 5 VbC

- [ ] 91. **VbC (**task-card**).** Verify SC-12 (structural) verdict is PASS with matching evidence type. **→ SC-12**

**Concern transition:** Leaving Phase 5 (docs-alignment) → entering the post-implementation pipeline (audit, Z3 check, structural checks, pre-PR gate, regression check, review prep, PR creation, completion summary).
