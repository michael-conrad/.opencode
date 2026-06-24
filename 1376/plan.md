# Implementation Plan — [#1376](https://github.com/michael-conrad/.opencode/issues/1376) — implementation-pipeline SKILL.md orchestrator entry point

**Goal:** Fix implementation-pipeline SKILL.md to provide an orchestrator-facing entry point, create the missing `assemble-work.md` task file, and fix `pipeline-executor.md` purpose statement.

**Architecture:** Single phase with three concerns in dependency order: Concern B (create `assemble-work.md`) and Concern C (fix `pipeline-executor.md`) execute in parallel, then Concern A (rewrite SKILL.md) executes last since it references both B and C by name.

**Files:**
- `.opencode/skills/implementation-pipeline/SKILL.md`
- `.opencode/skills/implementation-pipeline/tasks/assemble-work.md` (new)
- `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Phase 1 — SKILL.md rewrite, assemble-work creation, pipeline-executor fix

**Concern:** B (assemble-work.md creation) + C (pipeline-executor.md fix) in parallel, then A (SKILL.md rewrite)

**Files:** `.opencode/skills/implementation-pipeline/SKILL.md`, `.opencode/skills/implementation-pipeline/tasks/assemble-work.md`, `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`

**SCs:** SC-1 through SC-15

**Dependencies:** None

**Entry condition:** Spec approved, feature branch exists

**Exit condition:** All 15 SCs verified PASS

### Track B — Create `tasks/assemble-work.md` (SC-4, SC-5, SC-6, SC-11, SC-12, SC-13, SC-14)

1. **RED (**clean-room**).** Verify `tasks/assemble-work.md` does not exist — `ls .opencode/skills/implementation-pipeline/tasks/assemble-work.md` MUST return non-zero exit code. **→ SC-4**

2. **GREEN (**clean-room**).** Create `tasks/assemble-work.md` with:
   - Purpose: orchestrator entry point after plan approval
   - Reads plan from `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md` **→ SC-5**
   - Reads work state file from `./tmp/{N}/work.md`
   - Verifies pre-flight conditions (feature branch, clean working tree, authorization scope)
   - Creates feature branches and worktrees for each implementation item
   - Creates Step 1.5 entry proof marker **→ SC-11**
   - Dispatches sub-agents via `task()` for each implementation item
   - Runs post-sub-agent completion checkpoint with hash mismatch detection **→ SC-14**
   - Verifies work state claims against live state before proceeding **→ SC-13**
   - Handles OVERFLOW results from sub-agents with re-routing strategy **→ SC-12**
   - Squash-merges feature branches into work branch
   - Runs verification gates (verification-before-completion, finishing-a-development-branch)
   - Routes to `pipeline-executor` for internal step dispatch sequence **→ SC-6**
   - Returns result contract with status and artifact path

3. **GREEN doublecheck (**clean-room**).** Verify `tasks/assemble-work.md` exists and contains all required references. **→ SC-4, SC-5, SC-6, SC-11, SC-12, SC-13, SC-14**

4. **Checkpoint commit (**inline**).** `git add .opencode/skills/implementation-pipeline/tasks/assemble-work.md && git commit -m "feat: create tasks/assemble-work.md entry point"`

### Track C — Fix `tasks/pipeline-executor.md` purpose (SC-7, SC-15)

5. **RED (**clean-room**).** Verify `pipeline-executor.md` contains a step count pattern — `grep` for `[0-9]+-step` MUST return a match. **→ SC-7**

6. **GREEN (**clean-room**).** Edit `tasks/pipeline-executor.md`:
   - Remove step count from Purpose section (change "14-step" to no count) **→ SC-7**
   - Ensure purpose describes itself as internal step dispatch table, not orchestrator entry point **→ SC-15**

7. **GREEN doublecheck (**clean-room**).** Verify `pipeline-executor.md` does not contain `[0-9]+-step` pattern and does not describe itself as orchestrator entry point. **→ SC-7, SC-15**

8. **Checkpoint commit (**inline**).** `git add .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md && git commit -m "fix: remove stale step count from pipeline-executor.md purpose"`

### Track A — Rewrite SKILL.md (SC-1, SC-2, SC-3, SC-8, SC-9, SC-10)

9. **RED (**clean-room**).** Verify SKILL.md description contains internal pipeline details — `grep` for "17 serial dispatch steps" MUST return a match. **→ SC-1, SC-8**

10. **GREEN (**clean-room**).** Rewrite SKILL.md:
    - **Description:** Remove "17 serial dispatch steps", "Z3-verified", "YAML contract". Add orchestrator-facing trigger description with mandatory signal ("MUST dispatch here"). **→ SC-1, SC-2**
    - **Overview:** Remove step count, Z3, YAML contract details. Replace with orchestrator-facing purpose statement. **→ SC-8**
    - **Trigger Dispatch Table:** Add orchestrator entry point row for "execute plan" / "implement spec" / "run pipeline" / "assemble work" → `assemble-work`. **→ SC-3**
    - **Invocation:** Add `assemble-work` entry in the invocation table. **→ SC-9**
    - **Sub-Agent Routing:** Add `assemble-work` as the orchestrator entry point that routes to `pipeline-executor`. **→ SC-10**

11. **GREEN doublecheck (**clean-room**).** Verify:
    - No "17 serial dispatch steps", "Z3-verified", or "YAML contract" in description or Overview **→ SC-1, SC-8**
    - "MUST" present in description **→ SC-2**
    - "execute plan" or "implement spec" in Trigger Dispatch Table **→ SC-3**
    - "assemble-work" in Invocation section **→ SC-9**
    - "assemble-work" in Sub-Agent Routing **→ SC-10**

12. **Checkpoint commit (**inline**).** `git add .opencode/skills/implementation-pipeline/SKILL.md && git commit -m "fix: rewrite SKILL.md with orchestrator-facing entry point"`

### Phase 1 VbC

13. **VbC (**clean-room**).** Verify all 15 SCs PASS: SC-1 through SC-15. **→ SC-1 through SC-15**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- SC-1: SKILL.md description does not contain "17 serial dispatch steps", "Z3-verified", or "YAML contract"
- SC-2: SKILL.md description contains mandatory signal ("MUST dispatch here" or equivalent)
- SC-3: SKILL.md Trigger Dispatch Table has orchestrator entry point for "execute plan" / "implement spec"
- SC-4: `tasks/assemble-work.md` exists
- SC-5: `tasks/assemble-work.md` reads plan from `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md`
- SC-6: `tasks/assemble-work.md` dispatches to pipeline-executor
- SC-7: `tasks/pipeline-executor.md` does not contain a step count ("N-step", "N serial", etc.)
- SC-8: SKILL.md Overview does not contain step count, Z3, or YAML contract details
- SC-9: SKILL.md Invocation table includes `assemble-work` entry
- SC-10: SKILL.md Sub-Agent Routing mentions `assemble-work` as entry point
- SC-11: `tasks/assemble-work.md` references Step 1.5 entry proof marker
- SC-12: `tasks/assemble-work.md` references OVERFLOW handling
- SC-13: `tasks/assemble-work.md` references work state verification
- SC-14: `tasks/assemble-work.md` references post-sub-agent completion checkpoint
- SC-15: `tasks/pipeline-executor.md` purpose does not describe itself as orchestrator entry point
