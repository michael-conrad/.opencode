# Task: assemble-work

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Orchestrator entry point for the implementation pipeline. Called after plan approval, before any file modification. Reads the approved plan, creates feature branches and worktrees, dispatches sub-agents for each implementation item, runs verification gates, and routes to `pipeline-executor` for the internal step dispatch sequence.

This is the **mandatory entry point** — the orchestrator MUST dispatch here after plan approval. Skipping this task means skipping pre-flight verification, branch creation, sub-agent dispatch, and verification gates.

## Entry Criteria

- [ ] 1. Approved plan exists at `{N}/plan.md` (index) with phase files at `{N}/plan-{NN}-*.md` (multi-phase) or `{N}/plan.md` (single-phase)
- [ ] 2. Authorization scope covers `for_implementation` or higher (or `for_pr`/`for_pr_only`)
- [ ] 3. Authorization context available (`authorization_scope`, `halt_at`, `pr_strategy`)
- [ ] 4. Feature branch does not yet exist for this issue (or exists from pre-work)

## Exit Criteria

- [ ] 1. Feature branches and worktrees created for each implementation item
- [ ] 2. Sub-agents dispatched for each item and results collected
- [ ] 3. Post-sub-agent completion checkpoint verified (hash mismatch detection)
- [ ] 4. Work state claims verified against live state
- [ ] 5. Feature branches squash-merged into work branch
- [ ] 6. Verification gates passed (verification-before-completion, finishing-a-development-branch)
- [ ] 7. Result contract returned with status and artifact path

## Procedure

### Step 1: Read Plan and Work State

- [ ] 1. Read plan index from `{N}/plan.md` for phase table, then read current phase file from `{N}/plan-{NN}-*.md` — extract phases, items, SCs, dependencies. **→ SC-5**
- [ ] 2. Read work state file from `./tmp/{N}/work.md` — extract current progress, completed items, blocked items.
- [ ] 3. Verify pre-flight conditions:
   - Feature branch exists (MUST have been created via `git-workflow --task pre-work`)
   - Working tree is clean (`git status --porcelain` returns empty)
   - Authorization scope covers the current pipeline phase
   - Submodule state is current — resolve default branch via `git remote show origin | sed -n 's/.*HEAD branch: //p'`, then verify `git submodule status` shows submodules at that branch's tip
- [ ] 4. Create Step 1.5 entry proof marker — write `./tmp/{N}/artifacts/entry-proof-{timestamp}.yaml` with:
   ```yaml
   step: 1.5
   timestamp: "<ISO8601>"
   issuer: "<AgentName> (<ModelId>)"
    plan_path: "{N}/plan.md"
   authorization_scope: "<scope>"
   halt_at: "<halt_at>"
   pr_strategy: "<strategy>"
   ```
   **→ SC-11**

### Step 2: Create Feature Branches and Worktrees

- [ ] 1. For each implementation item in the plan, create a feature branch:
   - Single-item plan: use the existing feature branch
   - Multi-item plan: create sub-branches per item
- [ ] 2. If `WORKTREE_REQUIRED` is set, create worktrees via `using-git-worktrees` skill
- [ ] 3. Record branch/worktree state in work state file

### Step 3: Dispatch Sub-Agents

- [ ] 1. For each implementation item, dispatch a clean-room sub-agent via `task()`:
   - Context: `{issue_number, item_description, plan_path, authorization_scope, halt_at, pr_strategy, worktree.path, github.owner, github.repo}`
   - Prompt: `"execute <item> from implementation-pipeline. Read the plan at <plan_path> first"`
- [ ] 2. Collect result contracts from each sub-agent:
   - `status`: DONE | BLOCKED | OVERFLOW
   - `artifact_path`: path to full evidence on disk
   - `finding_summary`: 1-3 sentence summary
   - `blocker_reason`: if BLOCKED

### Step 4: Handle OVERFLOW Results

- [ ] 1. If a sub-agent returns `status: OVERFLOW`:
   - Record completed items in work state file
   - Apply split strategy from overflow-signal.md:
     - Per-item: one sub-agent per remaining item
     - Per-phase: split at phase boundaries
     - Chunked: 2-3 equal chunks
     - Fallback: HALT and report context overflow
   - Re-dispatch new sub-agent(s) with reduced scope
   - Continue orchestration with accumulated results
   **→ SC-12**

### Step 5: Post-Sub-Agent Completion Checkpoint

- [ ] 1. After all sub-agents return, run completion checkpoint:
   - Verify all result contracts have `status: DONE`
   - Run hash mismatch detection: compare expected file hashes against actual
   - If hash mismatch detected: flag for re-dispatch of affected items
   **→ SC-14**

### Step 6: Work State Verification

- [ ] 1. Verify every claim in work state file against live state:
   - Sub-agent completed → result contract exists with status DONE
   - Issue created → issue exists on GitHub with correct title/labels
   - Sub-issues linked → `github_issue_read(method=get_sub_issues)` returns expected
   - Branch created → `git rev-parse --verify <branch>` succeeds
   - Worktree path set → worktree directory is git repository
   - All phases complete → every phase in work state has status DONE
   **→ SC-13**
- [ ] 2. If any claim fails verification: flag as VERIFICATION-GAP, remediate before proceeding

### Step 7: Squash-Merge and Verification Gates

- [ ] 1. Squash-merge feature branches into work branch
- [ ] 2. Run `verification-before-completion --task verify` — verify all SCs
- [ ] 3. Run `finishing-a-development-branch --task checklist` — structural checks

### Step 8: Route to pipeline-executor

- [ ] 1. Route to `pipeline-executor` for the internal step dispatch sequence:
   - Call `skill({name: "implementation-pipeline"})`
   - Dispatch `pipeline-executor` with accumulated context
   **→ SC-6**

### Step 9: Return Result Contract

- [ ] 1. Return frugal result contract:
   ```yaml
   status: DONE | BLOCKED | OVERFLOW
   artifact_path: "./tmp/{N}/artifacts/assemble-work-{STATUS}-{timestamp}.yaml"
   finding_summary: "<1-3 sentence summary>"
   blocker_reason: "<if BLOCKED>"
   ```

## Context Required

- `issue_number`
- `plan_path` — path to `{N}/plan.md` (index) with phase files at `{N}/plan-{NN}-*.md`
- `authorization_scope`
- `halt_at`
- `pr_strategy`
- `worktree.path`
- `github.owner`
- `github.repo`

## Related Files

- `implementation-pipeline/tasks/pipeline-executor.md` — internal step dispatch table
- `implementation-pipeline/enforcement/overflow-signal.md` — OVERFLOW contract and re-routing
- `implementation-pipeline/enforcement/work-state-verification.md` — verification table and work state format
- `implementation-pipeline/SKILL.md` — dispatch routing table
- `git-workflow/tasks/pre-work.md` — feature branch creation
- `verification-before-completion/tasks/verify.md` — SC verification
- `finishing-a-development-branch/tasks/checklist.md` — structural checks
- `completion-core/tasks/completion.md` — exec-summary
