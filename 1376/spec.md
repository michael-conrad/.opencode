# [SPEC-FIX] implementation-pipeline SKILL.md missing orchestrator entry point — description, trigger table, and assemble-work task

## Problem

The `implementation-pipeline/SKILL.md` has three defects that prevent the orchestrator from correctly entering the pipeline:

1. **Description contains internal pipeline details** — says "17 serial dispatch steps" and "Z3-verified step transitions" which are implementation internals, not orchestrator-facing trigger information. The orchestrator needs to know *when* to use this skill, that it's mandatory, and what triggers it.

2. **Trigger Dispatch Table has no orchestrator entry point** — the table only lists step-level sub-task triggers (`sc-coherence-gate`, `red-phase`, etc.). There is no trigger for "execute plan", "implement spec", or "run pipeline" that would cause the orchestrator to dispatch here. The orchestrator must find a trigger that matches its context — "I have an approved plan and need to implement it" — and none exists.

3. **`assemble-work.md` task file does not exist** — The entry point task `assemble-work` is referenced from `executing-plans/tasks/start.md`, `executing-plans/tasks/completion.md`, `approval-gate/tasks/pre-impl/yield-to-assemble-work.md`, and `approval-gate/enforcement/auto-dispatch-table.md`, but no `tasks/assemble-work.md` file exists in the implementation-pipeline skill directory. This is a critical gap — the entry point is referenced everywhere but defined nowhere.

4. **`pipeline-executor.md` has stale step count** — Purpose section says "14-step" but the dispatch table has 17 steps. The count should not be present at all — it is an internal detail that will go stale again.

5. **SKILL.md Overview and Invocation sections contain internal pipeline details** — The orchestrator should not need to know about step counts, Z3 contracts, or sub-agent routing to decide whether to enter this skill.

## Root Cause

The SKILL.md was written as an internal reference document (describing how the pipeline works) rather than as an orchestrator-facing dispatch card (describing when to enter and that it's mandatory). The Trigger Dispatch Table was designed for sub-agent routing within the pipeline, not for orchestrator entry routing.

**PR #965 rename defect:** PR #965 (Phase 1: Rename divide-and-conquer → implementation-pipeline) renamed `tasks/assemble-work.md` to `tasks/pipeline-executor.md`. This was a category error — `assemble-work` is the orchestrator entry point (reads plan, creates branches, dispatches sub-agents, squash-merges, runs verification gates), while `pipeline-executor.md` is the internal step dispatch table (17-step sequence within a single item's implementation). The rename conflated two distinct concerns. The file that became `pipeline-executor.md` has completely different content (Z3 state management, checkpoint tags, remediation routing) from what `assemble-work` was supposed to contain.

## Defects

| # | Location | Defect | Severity |
|---|----------|--------|----------|
| 1 | SKILL.md description (line 3) | Contains internal pipeline details ("17 serial dispatch steps", "Z3-verified step transitions", "YAML contract artifact tracking"). Should be orchestrator-facing: when to use, mandatory signal, trigger scenarios. | CRITICAL |
| 2 | SKILL.md Trigger Dispatch Table (lines 30-51) | No orchestrator entry point trigger. Only step-level sub-task triggers. Missing: "execute plan", "implement spec", "run pipeline" → `assemble-work`. | CRITICAL |
| 3 | `tasks/assemble-work.md` | File does not exist. Referenced from 4+ files but never created. | CRITICAL |
| 4 | `tasks/pipeline-executor.md` line 7 | Says "14-step" — step count is an internal detail that should not be in the purpose statement at all. | MAJOR |
| 5 | SKILL.md Overview (lines 16-20) | Contains internal pipeline details (step count, Z3, YAML contracts). Should be orchestrator-facing. | MAJOR |
| 6 | SKILL.md Invocation (lines 94-101) | No `assemble-work` entry in the invocation table. Only lists step-level dispatch. | MAJOR |
| 7 | SKILL.md Sub-Agent Routing (line 116) | No mention of `assemble-work` as the entry point for orchestrator dispatch. | MINOR |
| 8 | `pipeline-executor.md` purpose (line 7) | Describes itself as "core dispatch routing table" — should describe itself as internal step dispatch table, not orchestrator entry point. The orchestrator entry point is `assemble-work`. | MAJOR |
| 9 | `executing-plans/tasks/start.md` | Routes to `implementation-pipeline --task assemble-work` but the task file does not exist. The routing is correct but the target is missing. | CRITICAL |
| 10 | `approval-gate/tasks/pre-impl/yield-to-assemble-work.md` | References `assemble-work` behaviors (work state file reading, feature branch creation, sub-agent dispatch, squash-merge, verification gates) but the task file that should define these behaviors does not exist. | MAJOR |

## Fix

1. **Rewrite SKILL.md description** — Remove all internal pipeline details. Use orchestrator-facing trigger description:
   - When to use: after plan approval, before any file modification
   - Mandatory signal: "MUST dispatch here"
   - Additional trigger scenarios: any implementation task with an approved plan
   - No step count, no Z3, no YAML contracts, no sub-agent routing details

2. **Add orchestrator entry point to Trigger Dispatch Table** — Add row:
   ```
   | "execute plan" / "implement spec" / "run pipeline" / "assemble work" | `assemble-work` | `orchestrator` | {issue_number, plan_path, authorization_scope, halt_at, pr_strategy} |
   ```

3. **Create `tasks/assemble-work.md`** — Entry point task file that incorporates behaviors referenced from across the codebase:
   - Reads the plan from `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md`
   - Reads work state file from `./tmp/{N}/work.md`
   - Verifies pre-flight conditions (feature branch, clean working tree, authorization scope)
   - Creates feature branches and worktrees for each implementation item
   - Creates Step 1.5 entry proof marker (per `git-workflow/tasks/cleanup/branch-cleanup.md:377`)
   - Dispatches sub-agents via `task()` for each implementation item
   - Runs post-sub-agent completion checkpoint with hash mismatch detection (per `pre-analysis/tasks/analyze.md:130`)
   - Verifies work state claims against live state before proceeding (per `implementation-pipeline/enforcement/work-state-verification.md:5`)
   - Handles OVERFLOW results from sub-agents with re-routing strategy (per `implementation-pipeline/enforcement/overflow-signal.md:18`)
   - Squash-merges feature branches into work branch
   - Runs verification gates (verification-before-completion, finishing-a-development-branch)
   - Routes to `pipeline-executor` for the internal step dispatch sequence
   - Returns result contract with status and artifact path

4. **Fix `pipeline-executor.md`** — Remove the step count from the Purpose section. Describe it as the internal step dispatch table (not the orchestrator entry point). The orchestrator entry point is `assemble-work`.

5. **Rewrite SKILL.md Overview** — Remove internal pipeline details. Replace with orchestrator-facing purpose statement.

6. **Fix SKILL.md Invocation** — Add `assemble-work` as the entry point task in the invocation table.

7. **Fix SKILL.md Sub-Agent Routing** — Add `assemble-work` as the orchestrator entry point that routes to `pipeline-executor`.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | SKILL.md description does not contain "17 serial dispatch steps", "Z3-verified", or "YAML contract" | structural | `grep` for those patterns in SKILL.md — absent |
| SC-2 | SKILL.md description contains mandatory signal ("MUST dispatch here" or equivalent) | structural | `grep` for "MUST" in SKILL.md description — present |
| SC-3 | SKILL.md Trigger Dispatch Table has orchestrator entry point for "execute plan" / "implement spec" | structural | `grep` for "execute plan" or "implement spec" in Trigger Dispatch Table — present |
| SC-4 | `tasks/assemble-work.md` exists | structural | `ls tasks/assemble-work.md` — file exists |
| SC-5 | `tasks/assemble-work.md` reads plan from `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md` | structural | `grep` for "plan.md" in assemble-work.md — present |
| SC-6 | `tasks/assemble-work.md` dispatches to pipeline-executor | structural | `grep` for "pipeline-executor" in assemble-work.md — present |
| SC-7 | `tasks/pipeline-executor.md` does not contain a step count ("N-step", "N serial", etc.) | structural | `grep` for "[0-9]+-step" in pipeline-executor.md — absent |
| SC-8 | SKILL.md Overview does not contain step count, Z3, or YAML contract details | structural | `grep` for those patterns in Overview section — absent |
| SC-9 | SKILL.md Invocation table includes `assemble-work` entry | structural | `grep` for "assemble-work" in Invocation section — present |
| SC-10 | SKILL.md Sub-Agent Routing mentions `assemble-work` as entry point | structural | `grep` for "assemble-work" in Sub-Agent Routing — present |
| SC-11 | `tasks/assemble-work.md` references Step 1.5 entry proof marker | structural | `grep` for "entry proof" or "Step 1.5" in assemble-work.md — present |
| SC-12 | `tasks/assemble-work.md` references OVERFLOW handling | structural | `grep` for "OVERFLOW" in assemble-work.md — present |
| SC-13 | `tasks/assemble-work.md` references work state verification | structural | `grep` for "work state" in assemble-work.md — present |
| SC-14 | `tasks/assemble-work.md` references post-sub-agent completion checkpoint | structural | `grep` for "completion checkpoint" or "hash mismatch" in assemble-work.md — present |
| SC-15 | `tasks/pipeline-executor.md` purpose does not describe itself as orchestrator entry point | structural | `grep` for "orchestrator entry" or "entry point" in pipeline-executor.md — absent |

## Labels

`[SPEC-FIX]`, `skill`

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
