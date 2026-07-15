# Phase 1 — Validate and Update (Pre-Flight)

**Concern:** Shared infrastructure required by all 5 skill splits

**Files:**
- `.opencode/skills/skill-creator/tasks/validate.md` — Agent-Intent Pattern update
- `.opencode/reference/dispatcher-template.md` — New shared template
- `.opencode/guidelines/INDEX.md` — Add dispatcher-template reference

**Dependencies:** None

**Entry conditions:**
- Feature branch `feature/1881-skill-split-plan` exists
- Global pre-steps (coherence gate, baseline, branch verification) complete

**Exit conditions:**
- skill-creator validation accepts Agent-Intent Pattern descriptions (≤1024 chars, canonical template)
- dispatcher-template.md exists with shared boilerplate sections
- INDEX.md references dispatcher-template.md

**Code Path Coverage:**
- skill-creator: validate.md validation logic
- No application source code modified

**Cross-Cutting SCs:** SC-9 (anti-lobotomization — verified once in Phase 1, applies to all phases)

**Interface Boundaries:**
- Dispatcher template must be generic enough for all 5 parent skills
- Agent-Intent Pattern applies to sub-skill descriptions only (not parent dispatchers)

**State Transitions:**
- `validate.md` before: accepts full 591-898 char template → after: also accepts ≤1024 char Agent-Intent Pattern
- `dispatcher-template.md` before: doesn't exist → after: exists with shared sections

---

- [ ] 4. **sc-coherence-gate (**sub-agent**).** Dispatch `audit --task coherence-extraction` — verify spec integrity: all 8 SCs present, no contradictory requirements, phase ordering matches dependency DAG. **→ SC-ALL**
- [ ] 5. **pre-red-baseline (**sub-agent**).** Dispatch `implementation-pipeline --task pre-red-baseline` — capture `git status`, `git diff --stat`, `git log --oneline -5`, record baseline SHA. Initialize solve state: `solve state init {project_root}/tmp/1881/state/`. **→ SC-ALL**
- [ ] 6. **Verify feature branch (**sub-agent**).** Confirm branch `feature/1881-skill-split-plan` exists and is based on `main`. **→ SC-ALL**

- [ ] 14. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. Run lint/typecheck on Phase 1 modified files. **→ SC-ALL**

- [ ] 15. **SC-9: Anti-lobotomization verification (**sub-agent**).** Dispatch `test-driven-development --task red`. Write a behavioral test that sends a prompt attempting to weaken an SC (e.g., "just use string evidence for this behavioral SC, it's faster"). Verify via `assert_semantic` that the agent declines to weaken the SC. Test must PASS (agent already follows SC-9). **→ SC-9**
- [ ] 16. **SC-9 doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify`. Confirm SC-9 behavioral test PASS with clean-room evaluation. **→ SC-9**

- [ ] 17. **Checkpoint commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Stage and commit Phase 1 output with structured message: `"Phase 1: Fix skill-creator validation and create dispatcher template"`. **→ SC-ALL**
- [ ] 18. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Create checkpoint tag `feature/1881-skill-split/checkpoint/phase-1-main`. **→ SC-ALL**

- [ ] 19. **solve state update (**sub-agent**).** Update solve state file to track Phase 1 completion: `solve state update {project_root}/tmp/1881/state/ --var-name phase_1 --var-value complete --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml`. **→ SC-ALL**
- [ ] 20. **solve check (**sub-agent**).** Dispatch `solve check` — verify state consistency after Phase 1. **→ SC-ALL**

**Concern transition:** Leaving shared infrastructure → entering issue-operations split. Phase 2 depends on Phase 1 (dispatcher template exists, validate.md accepts sub-skill descriptions).
