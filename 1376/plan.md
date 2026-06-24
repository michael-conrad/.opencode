# Implementation Plan — [#1376](https://github.com/michael-conrad/.opencode/issues/1376) — implementation-pipeline SKILL.md orchestrator entry point

**Goal:** Fix implementation-pipeline SKILL.md to provide an orchestrator-facing entry point, create the missing `assemble-work.md` task file, and fix `pipeline-executor.md` purpose statement.

**Architecture:** Three concerns. Concern B (create `assemble-work.md`) and Concern C (fix `pipeline-executor.md`) execute in parallel. Concern A (rewrite SKILL.md) executes last — it references both B and C by name.

**Files:**
- `.opencode/skills/implementation-pipeline/SKILL.md`
- `.opencode/skills/implementation-pipeline/tasks/assemble-work.md` (new)
- `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Phase 1 — Create `tasks/assemble-work.md` and fix `tasks/pipeline-executor.md`

**Concern:** B (assemble-work.md creation) + C (pipeline-executor.md fix) — parallel, independent

**Files:** `.opencode/skills/implementation-pipeline/tasks/assemble-work.md`, `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`

**SCs:** SC-4, SC-5, SC-6, SC-7, SC-11, SC-12, SC-13, SC-14, SC-15

**Dependencies:** None

**Entry condition:** Feature branch exists, spec approved

**Exit condition:** Both files modified, all 9 SCs verified PASS

- [ ] 1. **Create `tasks/assemble-work.md` (**clean-room**).** Write the orchestrator entry point task file. Must include: purpose (orchestrator entry point after plan approval), plan reading from `.issues/{N}/plan.md` **→ SC-5**, work state file reading, pre-flight verification, feature branch/worktree creation, Step 1.5 entry proof marker **→ SC-11**, sub-agent dispatch, post-sub-agent completion checkpoint with hash mismatch detection **→ SC-14**, work state verification **→ SC-13**, OVERFLOW handling **→ SC-12**, squash-merge, verification gates, routing to `pipeline-executor` **→ SC-6**, result contract return. **→ SC-4, SC-5, SC-6, SC-11, SC-12, SC-13, SC-14**
- [ ] 2. **Fix `tasks/pipeline-executor.md` (**clean-room**).** Remove step count from Purpose section. Ensure purpose describes itself as internal step dispatch table, not orchestrator entry point. **→ SC-7, SC-15**

## Phase 2 — Rewrite SKILL.md

**Concern:** A (SKILL.md rewrite) — depends on Phase 1 (references `assemble-work.md` by name)

**Files:** `.opencode/skills/implementation-pipeline/SKILL.md`

**SCs:** SC-1, SC-2, SC-3, SC-8, SC-9, SC-10

**Dependencies:** Phase 1 complete

**Entry condition:** `tasks/assemble-work.md` exists

**Exit condition:** SKILL.md rewritten, all 6 SCs verified PASS

- [ ] 3. **Rewrite description (**clean-room**).** Remove "17 serial dispatch steps", "Z3-verified", "YAML contract". Add orchestrator-facing trigger description with mandatory signal ("MUST dispatch here"). **→ SC-1, SC-2**
- [ ] 4. **Rewrite Overview (**clean-room**).** Remove step count, Z3, YAML contract details. Replace with orchestrator-facing purpose statement. **→ SC-8**
- [ ] 5. **Add orchestrator entry point to Trigger Dispatch Table (**clean-room**).** Add row: `"execute plan" / "implement spec" / "run pipeline" / "assemble work"` → `assemble-work`. **→ SC-3**
- [ ] 6. **Fix Invocation table (**clean-room**).** Add `assemble-work` as the entry point task. **→ SC-9**
- [ ] 7. **Fix Sub-Agent Routing (**clean-room**).** Add `assemble-work` as the orchestrator entry point that routes to `pipeline-executor`. **→ SC-10**

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
