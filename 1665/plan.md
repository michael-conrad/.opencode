# Implementation Plan — [#1665](https://github.com/michael-conrad/.opencode/issues/1665) — Fix pre-commit Gate 2a work state file creation deadlock

**Goal:** Create work state file automatically before Gate 2a fires, preventing the deadlock where Gate 2a blocks commits when no work state file exists.

**Spec:** [#1665](https://github.com/michael-conrad/.opencode/issues/1665)

**Architecture:** Add work state file creation to the approval-gate auto-dispatch step (primary path) and pre-work (alternative path), fix Gate 2a error message to remove `divide-and-conquer` reference.

**Files:**
- `.opencode/skills/approval-gate/tasks/verify-authorization/auto-dispatch.md` — add work state file creation step
- `.opencode/skills/git-workflow/tasks/pre-work.md` — add work state file creation step (alternative)
- `.opencode/hooks/pre-commit` — fix Gate 2a error message, remove `divide-and-conquer` reference

> **Compliance requirement:** All steps in this plan are mandatory. No step may be skipped, combined, or optimized out. Each step must be executed in order. Skipping any step produces defective deliverables that must be discarded.
>
> **Cost-frame reformation:** Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Document size metrics (word count, line count, token count, byte-dispatch formulas) are NOT valid proxies for implementation complexity. Orchestrator context discipline (lean routing metadata only) is an operational bookkeeping concern — it describes how the orchestrator routes work to sub-agents, not how much work there is to do.
>
> **⚠️ Rework admonishment:** Skipping, combining, or reordering steps in this plan WILL produce defective deliverables. Defective deliverables MUST be discarded and reworked from scratch — no patching, no salvaging, no "close enough." All prior work on the affected phase is lost. The cost of rework from scratch far exceeds the cost of following the plan correctly the first time. Do not learn this the hard way.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the output before proceeding. Do not batch steps. Do not proceed to step N+1 until step N is verified complete.

> **Step Status:** Before each step, update the step status in the work state file. After each step, mark it complete. This ensures traceability and enables checkpoint rollback.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range |
|-------|------|---------|-----|--------------|------------|
| 1 | Fix Gate 2a Deadlock | Work state file creation + error message fix | SC-1, SC-2, SC-3, SC-4 | None | 1-12 |

## Phase 1 — Fix Gate 2a Deadlock

**Concern:** Work state file creation + error message fix

**Files:**
- `.opencode/skills/approval-gate/tasks/verify-authorization/auto-dispatch.md`
- `.opencode/skills/git-workflow/tasks/pre-work.md`
- `.opencode/hooks/pre-commit`

**SCs:** SC-1, SC-2, SC-3, SC-4

**Dependencies:** None

**Entry conditions:** Spec approved, solve output SAT

**Exit conditions:** Work state file created on authorization, Gate 2a does not block first commit, error message fixed

- [ ] 1. **RED (**sub-agent**).** Write behavioral enforcement test for SC-1: send approval-gate prompt, verify `tmp/work-*.md` exists with correct frontmatter. Test MUST FAIL (no work state file creation exists yet). **→ SC-1**
- [ ] 2. **RED (**sub-agent**).** Write behavioral enforcement test for SC-2: create feature branch, make change, commit — verify no Gate 2a block. Test MUST FAIL. **→ SC-2**
- [ ] 3. **RED (**sub-agent**).** Write content-verification test for SC-3: grep pre-commit hook for `divide-and-conquer` — assert absent. Test MUST FAIL (string still present). **→ SC-3**
- [ ] 4. **RED (**sub-agent**).** Write content-verification test for SC-4: read created `tmp/work-*.md` — verify frontmatter fields present. Test MUST FAIL. **→ SC-4**
- [ ] 5. **GREEN (**sub-agent**).** Add work state file creation to `auto-dispatch.md`. Insert step after authorization scope is set: create `tmp/work-<branch>.md` with frontmatter containing `authorization_scope` and `halt_at`. **→ SC-1, SC-4**
- [ ] 6. **GREEN (**sub-agent**).** Add work state file creation to `pre-work.md`. Insert step after branch creation: create `tmp/work-<branch>.md` with frontmatter. **→ SC-1, SC-4 (alternative path)**
- [ ] 7. **GREEN (**sub-agent**).** Fix Gate 2a error message in `pre-commit` hook. Replace `divide-and-conquer` reference with correct skill name or remove it. **→ SC-3**
- [ ] 8. **GREEN doublecheck (**clean-room**).** Run behavioral test from step 1 — verify PASS. **→ SC-1**
- [ ] 9. **GREEN doublecheck (**clean-room**).** Run behavioral test from step 2 — verify PASS. **→ SC-2**
- [ ] 10. **GREEN doublecheck (**clean-room**).** Run content-verification test from step 3 — verify PASS. **→ SC-3**
- [ ] 11. **GREEN doublecheck (**clean-room**).** Run content-verification test from step 4 — verify PASS. **→ SC-4**
- [ ] 12. **Checkpoint commit (**inline**).** Commit all changes together: `git add -A && git commit -m "fix(#1665): create work state file before Gate 2a, fix error message"`

#### Phase 1 VbC

- [ ] 13. **VbC (**clean-room**).** Verify all 4 SCs: SC-1 (work state file created on authorization), SC-2 (first commit not blocked), SC-3 (no divide-and-conquer reference), SC-4 (frontmatter has authorization_scope and halt_at). **→ SC-1, SC-2, SC-3, SC-4**

> **Self-remediation protocol:** If any step fails, do not proceed. Diagnose the root cause, fix it, re-verify, and only then continue. If a checkpoint tag exists, rollback to the last PASS state before re-dispatching.

## Exit Criteria

- [ ] C1. Work state file (`tmp/work-*.md`) is created automatically when authorization scope is set via `approval-gate`
- [ ] C2. Gate 2a does not block the first commit on a feature branch
- [ ] C3. Error message in Gate 2a no longer references `divide-and-conquer` skill
- [ ] C4. Work state file frontmatter contains `authorization_scope` and `halt_at` fields
