## Phase 6: Pipeline Enforcement Gates

**Parent:** #1673

Add mandatory Z3 contract verification, clean-room plan generation enforcement, readiness gate independence, sub-agent output verification, pipeline execution discipline, sequential step ordering.

**SCs:** SC-22, SC-23, SC-24, SC-25, SC-26, SC-27, SC-28, SC-29

**Files:**
- `.opencode/skills/writing-plans/tasks/create.md` — Operating Protocol
- `.opencode/skills/writing-plans/SKILL.md` — Mandatory Task Discipline

**Changes:**
- C7: Fix Z3 contract paths in all 7 check steps
- C8: Clean-room plan generation enforcement (Step 11 mandatory gate)
- C9: Readiness gate independence (orchestrator must not self-certify)
- C10: Sub-agent output verification (file-exists check)
- C11: Pipeline execution discipline (todowrite, pipeline_phase, branch, commit, sync)
- C12: Sequential step ordering (no parallel dispatch of chain-dependent steps)

**Dependencies:** Phase 4