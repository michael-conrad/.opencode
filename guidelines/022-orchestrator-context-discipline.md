<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
---
trigger_on: orchestrator context, context discipline, sub-agent dispatch, task(), clean-room, result contract, inline work, dispatch gate
tier: 2
load_when: sub-agent
---

# Orchestrator Context Discipline

> Demoted from [020-go-prohibitions.md §1.1](020-go-prohibitions.md) — reach this content through the one-line pointer retained in the 020 core.

## Overview

The orchestrator and sub-agents have different context management patterns. These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures.

> **Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Document size metrics (word count, line count, token count, byte-dispatch formulas) are NOT valid proxies for implementation complexity.**

## Context Flow

**Orchestrator context:** Holds routing metadata only — `worktree.path`, `github.owner`, `github.repo`, `authorization_scope`, `halt_at`, `pr_strategy`, `pipeline_phase`, `pipeline_history` (phase names only). Task file contents, analysis artifacts, and verification results go to sub-agents or disk.

**Sub-agent context:** Disposable — sub-agents read task files, source files, run analysis tools, and execute tests freely. Their context is discarded after returning a result contract.

**Result contracts:** Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence artifacts go to disk.

## The Three Mandates

The orchestrator's persistent context is a bounded, shared resource: it is carried across every step of the pipeline and every sub-agent dispatch. Each of the three mandates below is a direct consequence of protecting that context resource — the mechanisms exist because wasting orchestrator context degrades every downstream routing decision.

### 1. Orchestrator Context Lean

The orchestrator holds ONLY routing metadata:

- `worktree.path`, `github.owner`, `github.repo`, `authorization_scope`, `halt_at`, `pr_strategy`, `pipeline_phase`, `pipeline_history` (phase names only)

Everything else goes to a sub-agent:

| Does NOT belong in orchestrator | Goes to |
|-------------------------------|---------|
| Task file contents (step definitions) | Sub-agent context |
| Analysis artifacts (file paths, findings) | Sub-agent result contract → disk |
| Cached verification results | Sub-agent → disk → evidence artifacts |
| Previous sub-agent reasoning traces | Discarded with sub-agent context |
| Full file contents | Disk only |
| Pre-composed content, prose, or text intended for API posting (comments, issue bodies, PR descriptions) | Sub-agent context — sub-agent composes autonomously |

### 2. Sub-Agent Context Generosity

The sub-agent is ENCOURAGED to expand into its context:
- Read task files fully — that's what sub-agent context is for
- Read source files, run analysis tools, execute tests — burn context freely
- Write full evidence artifacts to disk

### 3. Result Contract Frugality

The sub-agent returns only:

| Field | Required | Purpose |
|-------|----------|---------|
| `status` | Yes | DONE / BLOCKED / OVERFLOW |
| `finding_summary` | Yes | 1-3 sentences of routing-significant output |
| `artifact_path` | Yes | Path to full evidence on disk |
| `blocker_reason` | If BLOCKED | Why blocked |

Everything else stays in the sub-agent's context and is discarded.

## Authorization-Free Actions — No Deliberation Required

<!-- Issue #99: Authorization-Free Actions — Signal asymmetry fix -->

The following actions do NOT require `"approved"` or `"go"` and the agent MUST NOT deliberate over them:

- Creating GitHub Issues (specs, plans, bug reports) — Read [010-approval-gate.md §Issue Creation Is Reporting, Not Implementation](010-approval-gate.md)
- Creating sub-issues under an approved plan — covered by plan authorization
- Posting progress comments to GitHub — permitted only through issue-operations -> comment substantive gate. Non-substantive progress (status updates, "phase complete", "implemented X") goes to chat only, never to issue comments.
- Moving issue labels — metadata operation
- Running lint/typecheck/format commands — read-only verification
- Creating feature branches — see `git-workflow` skill pre-work (requires `for_implementation` or above)
- Creating `observe/*` scratch branches — see `git-workflow --task pre-work` (permitted under `for_analysis`, MUST discard before HALT)

If the action is in this list, proceed immediately without requesting or deliberating over authorization.

## `for_analysis` Scope — Self-Assignment Rules

`for_analysis` is the ONLY scope an agent may self-assign. It is the default floor scope when no authorization is given.

### Self-Assignment Conditions

An agent may self-assign `for_analysis` when:
- No authorization has been given in the current session
- The user asked a question, reported a bug, or made a factual claim without authorization language
- The agent needs to investigate, read files, or create issues

Self-assignment means: operate under the `for_analysis` allowlist/blocklist until explicit authorization is received.

### 🚫 `for_analysis` Branch Restrictions

Under `for_analysis` scope:

- **`feature/*` and `spec/*` branches are BLOCKED.** Creating these branches requires `for_implementation` or above.
- **`observe/*` branches ARE permitted.** Naming convention: `observe/<topic>` (e.g., `observe/parsing-bug`).
- **`observe/*` branches MUST be discarded before HALT.** Never leave an `observe/` branch in the repo. Delete it with `git branch -D observe/<topic>` before the halt message.
- **No commits to the trunk** (this is always prohibited regardless of scope).

### Why `observe/` Branches Exist

`observe/` branches allow the agent to create throwaway scratch branches for read-only investigation work:
- Testing a hypothesis about code behavior
- Running a throwaway script to check data
- Examining git history or file structure in a clean context

These branches are NOT for implementation — they are ephemeral scratch space. The agent MUST NOT leave them behind.

## ✅ ALWAYS DO — Orchestration Operations

- **The orchestrator allocates work by context cost.** Large or disposable work — full file reads, file edits, file writes, analysis, verification, and composition — MUST be delegated to clean-room sub-agents, whose context is disposable. Small, necessary, routing-relevant work that the orchestrator must hold — reading routing metadata, receiving result contracts, routing to the next pipeline step — is performed by the orchestrator in its own context. This is an allocation-by-context-cost model: large/disposable → sub-agent; small/necessary → orchestrator. It does not loosen the prohibition on the orchestrator doing large/disposable work inline. This context-cost dimension is distinct from the cost-blind dimension (verification/execution cost — never skip a tool call): cost-blind governs whether a sub-agent task or tool call is executed at all, while context-cost governs which of those tasks run in the orchestrator's own bounded context versus a disposable sub-agent context. Both are NON-WAIVABLE — the re-scope changes only the framing of the inline-work rule, never which tasks are delegated vs inline.

EXCEPTION — Skill routing metadata: Reading a loaded SKILL.md's Trigger Dispatch Table and Invocation section in the orchestrator's own context is the small, necessary, routing-relevant work that the allocation-by-context-cost model assigns to the orchestrator. `skill()` auto-loads the SKILL.md into the orchestrator's context — the routing metadata is already present and small; sub-agents cannot call `skill()` or load skills themselves, so the orchestrator must read these sections to determine which task card to dispatch and what canonical dispatch string to use. The orchestrator dispatches the task card (`tasks/<name>.md`), not the skill card (SKILL.md), to the sub-agent.

| Artifact | File | Consumer | Content | Action |
|----------|------|----------|---------|--------|
| Skill Card | SKILL.md | Orchestrator | Routing metadata (Trigger Dispatch Table, Invocation, DISPATCH_GATE) | Load via skill(), read in own context, do NOT dispatch |
| Task Card | tasks/<name>.md | Sub-agent | Execution procedure (entry criteria, steps, exit criteria) | Dispatch via task() using canonical string from Invocation |
- **Orchestrator inline work detected → HALT.** When the orchestrator performs inline work (reading files, running analysis, making decisions instead of task()ing sub-agents), the orchestrator MUST HALT immediately. Discard pipeline execution state (work state files, cached results, sub-agent output). Published artifacts (issues, plans, specs) are edited in place — do not close and recreate. Restart from last known good commit checkpoint tag per Checkpoint Rollback Exception. Non-waivable. Read [000-critical-rules.md §Checkpoint Rollback Exception](000-critical-rules.md).
- **Discard all work on sub-agent failure before re-task.** When a sub-agent returns `status: BLOCKED` or fails, ALL work produced by that sub-agent MUST be discarded before re-task. The sub-agent's failure contaminates its output — the cause of the failure and the cause of any incorrect output are not distinguishable. Preserving partial output and re-tasking with it risks propagating contaminated state. Re-task with original scoped context only — the re-task sub-agent starts from the pre-failure branch state. This is a NON-WAIVABLE hard gate — no authorization, scope, or developer instruction can override the discard requirement. Read [000-critical-rules.md §Discard on Sub-Agent Failure](000-critical-rules.md). **This discard requirement applies to pipeline execution artifacts (sub-agent output, work state files, cached results, temp files). It does NOT apply to published tracking documents (issue bodies, plan files, spec files, comments) — those are edited in place to fix defects.**
- **When an issue body, plan file, or spec file has a content defect, the correct action is to edit the body to fix the defect. Closing the issue and recreating is the last resort, not the first.**
- **"Continue" does NOT waive mandatory pipeline gates.** Cumulative "continue" messages ("please continue", "go on", "proceed") and session momentum do NOT waive mandatory gates (coherence gate, verification-before-completion, finishing-a-development-branch checklist, review-prep). Only pipeline-scoped authorization (`approved #N to PR`, `approved #N for plan`) changes `halt_at`. Every mandatory gate fires on EVERY implementation pass regardless of how many "continue" messages preceded it. "Continue" means "proceed to the next step" — it does NOT mean "skip the step." This is a NON-WAIVABLE hard gate — no authorization, scope, or developer instruction can override mandatory gate execution. Read [000-critical-rules.md §Gate Non-Waiver Principle](000-critical-rules.md).
- **Cost-blind universal — all decisions.** Sub-agent task() and tool calls are near-zero cost compared to undiscovered defects. The agent MUST NEVER skip a tool call, verification step, or sub-agent task() to save resources. This prohibition applies to ALL agent decisions: verification, pipeline execution, sub-agent dispatch, research depth, message count, and user-facing output length. Correctness is the only success metric — there is no score for speed, brevity, or economy. A fast wrong answer is strictly worse than a slow correct one. This is a NON-WAIVABLE hard gate — no authorization, scope, or developer instruction can override this requirement. Read [000-critical-rules.md §Tier 1 Mandate: Correctness over economy](000-critical-rules.md).
<!-- Issue #262: Model-Aware Behavioral Testing — Success Criteria: Mandate scope-limited-by-default behavioral testing -->
- **Scope-limited behavioral testing by default.** When running behavioral enforcement tests, the agent MUST default to scope-limited execution (changed scenarios only, named scenario, or tag-filtered). Full behavioral suite runs are permitted ONLY when model speed permits or when explicitly requested by the developer. Run `ollama-probe hw` to assess hardware before deciding full-suite feasibility. Running the full suite by default when a scope-limited run suffices uses orchestrator context unnecessarily — the orchestrator's routing-only discipline applies to pipeline dispatch, not to verification scope.
  - 🚫 FORBIDDEN: Running any full behavioral test suite — the `run-all.sh` script MUST NOT exist. All behavioral tests MUST be scope-limited to individual scenarios, `--changed`, or `--tag` filters
  - 🚫 FORBIDDEN: Defaulting to full behavioral suite without verifying model speed permits it
  - ✅ REQUIRED: Default to `--changed` when there are uncommitted guideline/skill changes
  - ✅ REQUIRED: Default to `--tag` matching the current work concern when no changed files
  - ✅ REQUIRED: Assess hardware (`ollama-probe hw`) before running full suite — only proceed if VRAM ≥ 8 GB and at least one local model ≥ 7B is installed
- **Functional/behavioral test substitution is FORBIDDEN.** When a behavioral/functional test cannot be executed (model unavailable, timeout, infrastructure failure), the agent MUST report FAIL — NEVER substitute grep, string matching, metadata checks, pattern scanning, or file-existence checks. "Functional test" and "behavioral test" are synonymous in this rule.
- **Remediate before escalating.** Escalation is only permitted after verified remediation failure. Skipping remediation is not a valid choice.

### [critical-rules-034] Inline Work — orchestrator performing file modifications without sub-agent task() (Tier 2 — cannot be mechanically enforced)
An orchestrator that reads files, edits files, or makes decisions inline has stopped being a router and started being a contaminant. Amateurs do the work themselves. Professionals route to sub-agents. Detailed rules below.

#### 🚫 FORBIDDEN
- The main orchestrator reading, editing, writing, or analyzing files in its own context
- Sub-agents combining multiple steps (analyze + write + verify) in a single task()
- The producer of a deliverable also verifying that deliverable (self-verification)
- Sub-agents receiving orchestrator reasoning, expected outcomes, or cached results
- task()ing a sub-agent without a `dispatch_context` object specifying `must_receive` and `must_not_receive`
- Any SKILL.md performing inline work (reading files, running analysis, making decisions) instead of delegating to sub-agents

#### ✅ REQUIRED
- ALL task execution uses clean-room sub-agents decomposed into discrete single-step units
- The orchestrator is a pure router — it tasks sub-agents via task() and collects result contracts, never performing work inline
- Every pipeline stage is a logged sub-agent task() in the work state file
- Every SKILL.md contains a task context audit table documenting sub-agent tasks, scope, exclusions, and inline-work status
- Verification is ALWAYS performed by a different sub-agent from the producer, with ONLY the deliverable + spec received
- Sub-agents receive minimal context (issue number + scoped instruction) — no orchestrator preload

#### Violation Patterns

| Violation Pattern | Correct Action |
| -- | -- |
| Orchestrator reads file inline to "understand context" | Task routing sub-agent instead |
| Orchestrator edits guideline text inline | Task guideline-update sub-agent |
| Orchestrator creates issue content inline ("straightforward content, I'll write it myself") | Task issue-operations skill |
| Sub-agent performs analysis + writing + verification in one task() | Decompose into 3 tasks (analyze, write, verify) |
| Verifier receives producer's reasoning or drafts | Verifier gets only deliverable + SC list |
| Orchestrator performs inline work | HALT — discard pipeline state, restart from last known good commit checkpoint tag |
| RED/GREEN sub-agent also instructed to commit and push | RED/GREEN sub-agents only execute tests — never commit, never push |
| Sub-agent detects spec/plan defect but proceeds with GREEN anyway | Sub-agent returns BLOCKED — defect must be resolved before continuing |
| User said "continue" so mandatory checks are optional | Mandatory gates are structural invariants — "continue" is NOT authorization to skip |
| Sub-agent skips defect detection in GREEN phase (code-complete without verification) | GREEN sub-agent MUST produce verification evidence before returning |
| Orchestrator treats "continue" as waiver of a failed gate checkpoint | Failed gate is absolute stop — no task() proceeds past incomplete/failed gate; contamination requires full restart |
| Orchestrator creates issue content inline (Edit on `.issues/` or direct `github_issue_write`) | Dispatch to `issue-operations --task creation`. **Fallback:** If `skill("issue-operations")` + `task()` is unavailable, use `github_issue_write` directly but MUST log tool name, version, and reason in a comment on the created issue. |

### [critical-rules-035] DISPATCH_GATE Checkpoint skipped
Reading a SKILL.md routing section and then executing the task inline means every quality gate in that skill was silently bypassed. Amateurs inline. Professionals dispatch. See DISPATCH_GATE procedure below.

#### DISPATCH_GATE Checkpoint Procedure
Every routing decision in the approval-gate pipeline chain MUST be followed by an explicit DISPATCH_GATE that forces handoff to a sub-agent:

1. **Confirm next action is task()** — verify the routing decision has been made
2. **Task sub-agent** — call `task(subagent_type="general")` with scoped context
3. **Receive result contract** — collect the structured result (never read the full task file)
4. **Log in work state file** — record which sub-agent was tasked and when
5. **Proceed based on result contract** — route to next pipeline step based on sub-agent output

- 🚫 FORBIDDEN: Loading a SKILL.md routing section and then performing the described task inline
- 🚫 FORBIDDEN: Reading full SKILL.md content (beyond the routing section) in the orchestrator context
- ✅ REQUIRED: After reading routing metadata, immediately task a sub-agent for execution
- ✅ REQUIRED: The orchestrator NEVER loads task file content — it only receives result contracts

### [critical-rules-034] Orchestrator Inline Work = pipeline contamination (Tier 2 — cannot be mechanically enforced)
Orchestrator inline work detected → HALT. Discard pipeline execution state (work state files, cached results, sub-agent output). Published artifacts (issues, plans, specs) are edited in place — do not close and recreate. Restart from last known good commit checkpoint tag per Checkpoint Rollback Exception. Non-waivable. Read [000-critical-rules.md §Checkpoint Rollback Exception](000-critical-rules.md).

- 🚫 FORBIDDEN: Continuing the pipeline after detecting orchestrator inline work; attempting to "clean up" or "patch" after orchestrator inline work; preserving any cached state, work state files, or verification results produced during the inline work session
- ✅ REQUIRED: On detection of orchestrator inline work: HALT immediately; discard ALL work state files, cached results, and in-progress artifacts; restart from last known good commit checkpoint tag; log the detection event in the new work state file

### [critical-rules-042] Discard on Sub-Agent Failure
Preserving output from a BLOCKED sub-agent means propagating contaminated state into the next attempt. Amateurs salvage. Professionals discard and re-task with original context.

### [critical-rules-034] Tool-Recipe Task() — sub-agents as API proxies (Tier 2 — cannot be mechanically enforced)
Tasking a sub-agent with `github_create_pull_request` instead of "create a PR" means you are using the agent as an API proxy, not an engineer. Professional agents task objectives. Amateurs task tool recipes. Every tool-recipe dispatch is a decision you made for the sub-agent, not a problem you gave it to solve.

### [critical-rules-048] Skill Pre-Read + Inline Execution — reading skill task files and executing steps manually

Reading a skill's task files and then inlining the steps means you are bypassing the quality gates designed to catch your mistakes. Professional agents load skills. Amateurs inline. Every skill you pre-read and execute manually is a defect you accepted before writing a single line of code.

**3-Way Violation Distinction:**

| Violation | ID | What Happens |
|----------|-----|-------------|
| Pre-read skill + inline execute | critical-rules-048 | Agent reads `.md` task file, executes steps manually without calling `skill()` |
| Orchestrator inline work | critical-rules-034 | Agent performs file modifications or analysis inline without sub-agent task() |
| Tool-recipe dispatch | #329 (spec-fix) | Agent tasks sub-agent with raw API calls instead of task objectives |

### [critical-rules-044] Preloading Sub-Agent Context — task()ing with pre-determined file paths/line numbers/outcomes
Handing a sub-agent pre-determined file paths, line numbers, and expected outcomes means you are not asking the sub-agent to do the work — you are asking it to execute your guesses. Professional engineers gate every execution behind a pre-analysis sub-agent that discovers the scope independently. Amateurs preload their assumptions.

### [critical-rules-043] Universal Re-Task Mandate — no inline fallback on sub-agent failure
When a sub-agent fails, inline fallback means the failure contaminates your pipeline — you inherit the same context that caused the error. Professional engineers always re-task clean-room with the same scoped context. Amateurs patch in place and compound their problems.

### [critical-rules-063] Orchestrator Context Lean — orchestrator holds routing metadata only
The orchestrator holds routing metadata only (worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase, pipeline_history). Task file contents, analysis artifacts, and verification results go to sub-agents or disk. Read [Orchestrator Context Lean](#1-orchestrator-context-lean).

> **Note:** These are operational bookkeeping guidelines for context management. They describe how the orchestrator routes work to sub-agents — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.

### [critical-rules-065] Result Contract Frugality — result contracts limited to routing-significant data
Result contracts carry only routing-significant data (status, finding_summary, artifact_path, blocker_reason). Full evidence artifacts go to disk. Read [Result Contract Frugality](#3-result-contract-frugality).

### [critical-rules-dispatch-gate-canonical] Canonical Dispatch String Violation — orchestrator uses custom prompt after reading canonical dispatch string

**After loading a skill and reading its Trigger Dispatch Table, the orchestrator MUST use the canonical dispatch string verbatim from the skill's Invocation section. Writing a custom prompt with preloaded context — file paths, step sequences, expected outcomes, or orchestrator reasoning — is a DISPATCH_GATE violation.**

The pattern to enforce:
1. Load skill → read dispatch table + Invocation section → see canonical string
2. Use that exact string as the `prompt` parameter
3. Do NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
4. If canonical dispatch produces empty result: re-task clean-room (max 2 retries)

This rule is the orchestrator-facing side of the DISPATCH_GATE protocol: the orchestrator must never send preloaded context in the first place.

#### 🚫 FORBIDDEN

- Writing a custom `task()` prompt with preloaded file paths, step sequences, expected outcomes, or orchestrator reasoning after reading the canonical dispatch string
- Treating the dispatch table as "reference material" rather than a binding protocol
- Inlining orchestrator reasoning into the prompt

#### ✅ REQUIRED

- Use the exact canonical dispatch string verbatim from the skill's Trigger Dispatch Table
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)
- All 37 skill SKILL.md files with DISPATCH_GATE sections contain an Orchestrator Entry Criteria block documenting this rule. 1 platform sub-skill (issue-operations/platforms/local/SKILL.md) also has a DISPATCH_GATE section with Orchestrator Entry Criteria.

### [critical-rules-071] Revision-Not-Replacement — defective sub-agent deliverables MUST be revised, not replaced
When a sub-agent returns a defective deliverable (spec, plan, or other artifact), the orchestrator MUST revise the existing deliverable via the appropriate pipeline (spec-creation for specs, writing-plans for plans). The orchestrator MUST NOT create a replacement artifact (new issue, new file) unless revision is structurally impossible (e.g., the original issue was deleted).

#### 🚫 FORBIDDEN

- Creating a new issue/file to replace a defective sub-agent deliverable when revision is possible
- Orphaning the original issue number by creating a replacement

#### ✅ REQUIRED

- Revise the existing deliverable via the appropriate pipeline (spec-creation --task revise, writing-plans --task revise)
- If revision is structurally impossible, document the rationale in an issue comment before creating a replacement

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Creating replacement artifact instead of revising | Orphans original issue, breaks cross-references, wastes issue numbers |
| Inline-fixing defective deliverable | Bypasses pipeline quality gates, produces defective output |

### [critical-rules-072] No-Inline-Fix — orchestrator MUST NOT inline-fix defective sub-agent output
When a sub-agent returns a defective deliverable, the orchestrator MUST NOT attempt to fix the defective artifact directly via `github_issue_write`, file edit, or any other direct mutation. The orchestrator MUST dispatch a revision task to the appropriate pipeline (spec-creation --task revise for specs, writing-plans --task revise for plans).

#### 🚫 FORBIDDEN

- Using `github_issue_write` to directly edit a defective spec/plan body
- Using file edit tools to directly modify a defective deliverable file
- Any direct mutation that bypasses the revision pipeline

#### ✅ REQUIRED

- Dispatch a revision task to the appropriate pipeline
- Let the pipeline sub-agent handle the revision with full context and discipline

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Inline-fixing defective deliverable | Bypasses pipeline quality gates, produces defective output |
| Direct mutation of issue body | Lacks spec-creation context, produces inconsistent results |

### [critical-rules-066] Terminology Standardization — all context references must use standardized vocabulary
All references to "context budget", "context cost", and "context awareness" must use the standardized vocabulary: "orchestrator context", "sub-agent context", and "orchestrator context discipline". These terms describe operational bookkeeping for context management — they are NOT implementation complexity measures. Read [Overview](#overview). CHANGELOG entries and historical references are exempt.
