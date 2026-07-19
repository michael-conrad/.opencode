# Phase 3 — Critical violation + verification

**Concern:** Enforcement and regression prevention

**Files:**
- `.opencode/guidelines/000-critical-rules.md`

**SCs:** SC-5, SC-6

**Dependencies:** Phase 2 complete (all task cards cleaned)

**Entry conditions:** All task cards cleaned, 3 new task cards created

**Exit conditions:** Critical violation entry added, 13 clean task cards verified unmodified

**Code Path Coverage:** 000-critical-rules.md (Tier 2 section)

**Cross-Cutting SCs:** None

**Interface Boundaries:** 000-critical-rules.md is consumed by all agents — entry must use correct critical-rules-XXX format and be placed in the correct tier section

**State Transitions:** 000-critical-rules.md gains a new prohibition entry

---

- [ ] 87. **RED: Add critical violation to `000-critical-rules.md` (**sub-agent**).** **→ SC-5**
- [ ] 88. **GREEN: Add critical violation to `000-critical-rules.md` (**sub-agent**).** **→ SC-5**
- [ ] 89. **GREEN doublecheck (**inline**).** `grep -c 'task cards MUST NOT contain task()' .opencode/guidelines/000-critical-rules.md` — should be 1.
- [ ] 90. **Checkpoint commit (**inline**).** `git commit -m "1993: add critical violation for sub-agent task() calls in task cards"`

- [ ] 91. **RED: Verify 13 clean task cards unmodified (**sub-agent**).** **→ SC-6**
- [ ] 92. **GREEN: Verify 13 clean task cards unmodified (**sub-agent**).** **→ SC-6**
- [ ] 93. **GREEN doublecheck (**inline**).** `git diff -- .opencode/skills/spec-creation-requirements/tasks/requirements.md .opencode/skills/spec-creation-decomposition/tasks/decompose.md .opencode/skills/spec-creation-decomposition/tasks/blast-radius.md .opencode/skills/spec-creation-decomposition/tasks/code-path-analysis.md .opencode/skills/spec-creation-decomposition/tasks/concern-analysis.md .opencode/skills/spec-creation-decomposition/tasks/cross-cutting.md .opencode/skills/spec-creation-decomposition/tasks/state-analysis.md .opencode/skills/spec-creation-decomposition/tasks/testability-assessment.md .opencode/skills/spec-creation-decomposition/tasks/interface-compatibility.md .opencode/skills/spec-creation-validation/tasks/holistic-self-check.md .opencode/skills/spec-creation-validation/tasks/pipeline-readiness-gate.md .opencode/skills/spec-creation-validation/tasks/risk.md .opencode/skills/spec-creation-validation/tasks/traceability.md` — should show zero changes.
- [ ] 94. **Checkpoint commit (**inline**).** `git commit -m "1993: verify 13 clean task cards unmodified"` (only if changes were reverted)

#### Phase 3 VbC

- [ ] 95. **VbC (**clean-room**).**

**Concern transition:** All phases complete. Ready for post-implementation gates.
