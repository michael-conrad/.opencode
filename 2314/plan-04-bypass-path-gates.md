# Phase 4 — bypass-path-gates

**Concern:** Plan-existence gates on the bypass-path surfaces (git-workflow pre-work, TDD RED dispatch) plus behavioral block legs per surface, closing the root-cause-5 bypass path.

**Files:**
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md`
- `.opencode/skills/test-driven-development/tasks/red.md`
- `.opencode/tests-v2/behaviors/` (new bypass-path block legs)
- `.opencode/reference/skill-card-description-standards.md` (PLAN_MISSING vocabulary, already registered by Phase 1)

**SCs:** SC-14, SC-15, SC-16, SC-17

**Dependencies:** Phase 1, Phase 3

**Entry Conditions:**
- Phase 1 complete (PLAN_MISSING vocabulary registered; CRITICAL VIOLATION entry present)
- Phase 3 complete (supervision configuration in place for any behavioral leg)

**Exit Conditions:**
- `git-workflow-branch/tasks/pre-work.md` carries a plan-existence gate entry blocking with PLAN_MISSING when no approved plan.md exists at the canonical path (SC-14)
- `test-driven-development/tasks/red.md` carries the same gate entry at the RED dispatch boundary (SC-15)
- A plan-less developer-authorized dispatch entering via the pre-work path is BLOCKED with PLAN_MISSING before file modification (SC-16)
- A plan-less developer-authorized dispatch entering via the RED dispatch path is BLOCKED with PLAN_MISSING before implementation work (SC-17)

**Code Path Coverage:** The two task cards the bypass path actually traverses — pre-work (branch creation / begin work) and red (RED dispatch) — plus the enforcement-harness `opencode run` legs that exercise them.

**Cross-Cutting SCs:** None — SC-14..SC-17 are scoped to the bypass-path gate surfaces.

**Interface Boundaries:** The gate reuses the registered `PLAN_MISSING` reason code (Phase 1) and the canonical plan path `{issues_prefix}/{N}/plan.md`. The permit side remains existence-only: a present plan never blocks — staleness is the coherence gate's concern, not this gate's.

**State Transitions:** The bypass path moves from "plan-less developer-authorized dispatch implements and commits inline with zero plan check" to "mechanical PLAN_MISSING block at the first traversed surface (pre-work) and at the RED dispatch boundary".

**Cost frame:** Two task-card edits plus two behavioral legs (~minutes each, monitored). Skipping it leaves the observed inline-implement-and-commit bypass open on every pre-work/RED path.

---

## Item SC-14 — Pre-work task plan-existence gate (structural)

- [ ] 71. **Baseline (direct).** Confirm Phase 1 vocabulary/guideline surfaces are committed and pushed; confirm the effective commit is contained in a remote ref.
- [ ] 72. **RED (task-card).** Dispatch the red task from test-driven-development: structural check asserting `git-workflow-branch/tasks/pre-work.md` does NOT contain a plan.md-existence gate entry — the check FAILS the assertion — RED. **→ SC-14**
- [ ] 73. **GREEN (task-card).** Dispatch the green task from test-driven-development: add the plan-existence gate entry to the pre-work Entry Criteria/Procedure — before branch creation completes, verify an approved `plan.md` exists at the canonical path `{issues_prefix}/{N}/plan.md`; if absent, block with `PLAN_MISSING` (Tier 1 — developer authorization does not waive). **→ SC-14**
- [ ] 74. **Verify (task-card).** Dispatch the verify task from verification-before-completion: verify SC-14 with structural evidence. **→ SC-14**

## Item SC-15 — RED task plan-existence gate (structural)

- [ ] 75. **Commit (direct).** Stage the pre-work gate change and its test; commit as one atomic slice. **→ SC-14**
- [ ] 76. **RED (task-card).** Dispatch the red task from test-driven-development: structural check asserting `test-driven-development/tasks/red.md` does NOT contain a plan.md-existence gate entry — RED. **→ SC-15**
- [ ] 77. **GREEN (task-card).** Dispatch the green task from test-driven-development: add the same plan-existence gate entry to the red task Invocation/Entry — before RED work begins, verify an approved `plan.md` exists at the canonical path; if absent, block with `PLAN_MISSING`. **→ SC-15**
- [ ] 78. **Verify (task-card).** Dispatch the verify task from verification-before-completion: verify SC-15 with structural evidence. **→ SC-15**

## Item SC-16 — Bypass-path block via pre-work (behavioral)

- [ ] 79. **Commit (direct).** Stage the red-task gate change and its test; commit as one atomic slice. **→ SC-15**
- [ ] 80. **RED (task-card).** Dispatch the red task from test-driven-development: behavioral check asserting a plan-less developer-authorized dispatch entering implementation via the pre-work path is NOT blocked — the observed bypass behavior — RED. **→ SC-16**
- [ ] 81. **GREEN (task-card).** Dispatch the green task from test-driven-development: execute the monitored behavioral leg (`BEHAVIOR_SEMANTIC_MONITOR=1`) — a real `opencode run` whose prompt authorizes implementation directly with no plan present; assert stderr shows `PLAN_MISSING` blocking before any file modification. **→ SC-16**
- [ ] 82. **Verify (task-card).** Dispatch the verify task from verification-before-completion: verify SC-16 with behavioral evidence from the run's stderr. **→ SC-16**

## Item SC-17 — Bypass-path block via RED dispatch (behavioral)

- [ ] 83. **Commit (direct).** Stage the behavioral leg and its test; commit as one atomic slice. **→ SC-16**
- [ ] 84. **RED (task-card).** Dispatch the red task from test-driven-development: behavioral check asserting a plan-less developer-authorized dispatch entering via the RED dispatch path is NOT blocked — RED. **→ SC-17**
- [ ] 85. **GREEN (task-card).** Dispatch the green task from test-driven-development: execute the monitored behavioral leg (`BEHAVIOR_SEMANTIC_MONITOR=1`) — a real `opencode run` whose prompt authorizes implementation directly with no plan present; assert stderr shows `PLAN_MISSING` blocking at the RED dispatch boundary. **→ SC-17**
- [ ] 86. **Verify (task-card).** Dispatch the verify task from verification-before-completion: verify SC-17 with behavioral evidence from the run's stderr. **→ SC-17**
- [ ] 87. **Commit (direct).** Stage the behavioral leg and its test; commit as one atomic slice. **→ SC-17**
- [ ] 88. **Completion (direct).** All Phase 4 SCs PASS with evidence-type-matched artifacts; push and report.
