---
trigger_on: critical, zero tolerance, violation, mandate, Tier 1
tier: 1
load_when: sub-agent
---

# CRITICAL RULES — Three-Tier Model

This file provides critical rules organized into three tiers. Tier 1 mandates are prescriptively enforced by `session-enforcement.ts` `buildTier1EnforcementBlock()`.

## Mandate Tiering

The reclassification organizes every symbolic rule into three tiers based on consequence severity:

| Tier | Name | Enforcement | Prose Style | Overridable |
|------|------|-------------|-------------|-------------|
| 1 | Safety-Critical | HALT + "CRITICAL VIOLATION" header | Authority frame (existing) | Never |
| 2 | Process-Integrity | HALT (no "CRITICAL VIOLATION") | Confirmshaming identity-frame | Yes — developer authorization |
| 3 | Workflow-Standard | FLAG (no halt) | Quality-signal / project standard | Flag only — no halt |

### Interaction Rule

| Scenario | Resolution | Rule |
|----------|-----------|------|
| Dev auth + Tier 2 | Dev auth wins | critical-rules-018 |
| Dev auth + Tier 1 | Safety mandate wins | critical-rules-001 |
| No dev auth + any | HALT | critical-rules-006 |

## Rules by Tier

### Tier 1 — Safety-Critical (CRITICAL VIOLATION — HALT)

Rules that prevent **irreversible harm**: data loss, security breach, production data corruption, secret exfiltration, unrecoverable repository damage. These NEVER yield to developer authorization.
### [critical-rules-006] CRITICAL VIOLATION — Question-as-Authorization — treating rhetorical/complaint questions as implementation authorization
ONLY "approved"/"go" authorize action.


### [critical-rules-006] CRITICAL VIOLATION — Routing-bypass rationalization as self-authorization variant
The pattern "agent recognizes matching skill, deliberates about whether skill is needed, constructs carveout justification, executes bypass" is explicitly classified as a self-authorization variant. Any agent that matches a skill trigger but self-classifies into a "read-only" or "simple lookup" exemption and bypasses dispatch has committed a routing-bypass self-authorization violation.


### [critical-rules-026] CRITICAL VIOLATION — Deleting Branches/Stashes Improperly
Merged: DELETE IMMEDIATELY. Unmerged: PRESERVE. Stashes: PRESERVE.


### [critical-rules-026] CRITICAL VIOLATION — Git Configuration and Destructive Command Authorization
See session-enforcement.ts config mutation watchdog + `--no-verify` detection. Authorization rules below define what requires explicit approval.

#### Operations Requiring Explicit Authorization (FORBIDDEN without "approved" or "go")

| Category | Commands |
| -- | -- |
| Remote mutations | `git remote add`, `git remote rm`, `git remote set-url` |
| Security-relevant config | `git config --local/--global/--system` for keys in Categories 1-4 below |
| Force push | `git push --force`, `git push --no-verify` |
| Bypass hooks | `git commit --no-verify` (in repos with remotes) |
| Destructive resets | `git reset --hard`, `git clean -fd`, `git checkout -- .` |
| Ref manipulation | `git update-ref`, `git symbolic-ref` |
| History rewrite | `git filter-branch`, `git filter-repo` |
| Reflog expiry | `git reflog expire` |
| Submodule mutations | `git submodule add`, `git submodule deinit` |
| Env var overrides | Setting `GIT_SSH_COMMAND`, `GIT_CONFIG_GLOBAL`, `GIT_CONFIG_SYSTEM`, `GIT_EXEC_PATH` |

#### Security-Relevant Config Key Categories

| Category | Key Patterns |
| -- | -- |
| 1. Remote/URL routing | `remote.*`, `url.*` |
| 2. Protocol/transfer | `http.*`, `https.*`, `protocol.*` |
| 3. Credential helpers | `credential.*` |
| 4. Core security | `core.sshCommand`, `core.gitProxy`, `core.hooksPath` |

#### Required Behaviors

- Verify the EXACT git command (not just its category) is authorized before running
- Check for implied unsafe operations (e.g., `rebase --strategy=ort` triggers rename detection, which is safe; `rebase --exec` runs shell commands, which is NOT)
- `git commit --no-verify` is FORBIDDEN in repos with remotes without explicit authorization
- `git push --force` always requires explicit authorization
- `git config` mutations on Categories 1-4 always require explicit authorization

#### `--no-verify` Exception for Local-Only Repos

`git commit --no-verify` is permitted without authorization WHEN the repository has NO remotes configured. This exception exists because local-only repos are sandboxed environments where no external damage is possible.

**Definition:** A "local-only repo" is one where `git remote -v` returns no output. This status must be re-checked every time the exception is invoked — adding a remote retroactively removes the exception.

#### Hook Output Is Binding

Pre-commit hook output is binding. If a hook blocks a commit, fix the violation. `--no-verify` is FORBIDDEN regardless of hook output content.

#### Allowlist (No Authorization Needed)

| Operation | Rationale |
| -- | -- |
| `git config user.name` | Identity, not security |
| `git config user.email` | Identity, not security |
| `git config push.autoSetupRemote` | Convenience, safe |
| `git config pull.rebase` | Workflow preference |

#### Exempt Config Keys (Safe to Mutate Without Authorization)

| Key | Reason |
| -- | -- |
| `user.name` | Identity only, no security impact |
| `user.email` | Identity only, no security impact |
| `push.autoSetupRemote` | Convenience, no security impact |
| `pull.rebase` | Workflow preference, no security impact |

#### Enforcement Mechanisms (session-enforcement.ts)

- `session-enforcement.ts` config mutation watchdog detects `git config --global/--local/--system` for Categories 1-4 and REQUIRES authorization
- The watchdog is NOT triggered by exempt keys (user.name, user.email, push.autoSetupRemote, pull.rebase)


### Checkpoint Rollback Exception

`git reset --hard <checkpoint-tag>` is authorized automatically (no developer prompt) when ALL conditions are met:

1. A checkpoint tag exists matching `<parent>/checkpoint/<issue>/phase-<N>-<submodule>` per `git-workflow/SKILL.md` — Read [Tag Convention](skills/git-workflow/SKILL.md)
2. The current pipeline step's verification failed (VbC or dual-auditor FAIL)
3. The reset target is the checkpoint tag (not any other ref)
4. Pre-rollback diagnostics (`git status`, `git diff --stat`) reported to chat
5. The reset is followed by work-state-based re-dispatch

**First-step failure (no checkpoint):** Use `git checkout .` to clean working tree and re-dispatch.

### [critical-rules-006] CRITICAL VIOLATION — Pushing Agent Intelligence Decisions to the User
Structural decisions auto-resolved by agent. Read [brainstorming explore task](skills/brainstorming/SKILL.md).


### [critical-rules-029] CRITICAL VIOLATION — Non-Idempotent API Mutations
Check for existing resource before POST. See session-enforcement.ts.


### [critical-rules-029] CRITICAL VIOLATION — Inline Mutation Scripts
Use dedicated API client for all POST/PUT/PATCH. No `python -c '...'` mutations.


### [critical-rules-021] CRITICAL VIOLATION — Secret Exfiltration in Agent Output
Redact ALL secret values. See session-enforcement.ts `redactSecrets()`.


### [critical-rules-022] CRITICAL VIOLATION — Issue Body Erasure — replacing with shorter content
See Bug #1215. `len(new_body) >= 0.8 * len(original_body)` safeguard.


### [critical-rules-006] CRITICAL VIOLATION — for_pr Gap-Fill Halt — asking developer for structural decisions scope model resolves
Auto-spec → auto-plan → auto-approve → auto-PR.


### [critical-rules-045] CRITICAL VIOLATION — Creating .opencode/.opencode/ Nested Directories
Breaks agent config loading. Creating `.opencode/.opencode/` directories is FORBIDDEN. Any `mkdir`, `write`, or path-creating operation whose resolved path contains `.opencode/.opencode/` is a CRITICAL VIOLATION.


### [critical-rules-052] CRITICAL VIOLATION — `git rm` and file deletion require spec + authorization
`git rm` and file deletion require spec + authorization — CRITICAL VIOLATION to perform without both.


### [critical-rules-merge] CRITICAL VIOLATION — Human-Only Merge — agents MUST NOT merge PRs
Only the developer can merge PRs. The `github_merge_pull_request` tool is FORBIDDEN for agent use. Enforced at three gates:
- **PR creation gate** (`.opencode/skills/git-workflow-pr/tasks/pr-creation.md`): HALT after PR creation — do not merge
- **Completion gate** (`.opencode/skills/git-workflow-pr/tasks/completion.md`): Check that merge was not called during session
- **Authorization gate** (`.opencode/skills/approval-gate-scope/SKILL.md`): Block merge requests with HALT

Deleting a tracked file from the repository is a destructive operation equivalent to any code change. It requires:
1. A spec (SPEC-FIX or SPEC) describing what is being deleted and why
2. Explicit authorization ("approved" or "go")

A "why" question, a complaint about redundancy, or any interpretive inference is NEVER authorization to delete files. The agent MUST NOT run `git rm` or delete tracked files without both spec and authorization.


### [critical-rules-XXX] CRITICAL VIOLATION — Dispatching SKILL.md to sub-agents — category error

Dispatching SKILL.md content (the skill card) to a sub-agent via `task()` is a category error. The skill card contains orchestrator-level routing instructions (Trigger Dispatch Table, DISPATCH_GATE protocol, Invocation section, Orchestrator Entry Criteria) that a sub-agent cannot execute. Sub-agents cannot call `task()`, cannot follow Trigger Dispatch Tables, and cannot satisfy Orchestrator Entry Criteria.

The skill card (SKILL.md) tells the orchestrator WHAT to dispatch. The task card (tasks/<name>.md) tells the sub-agent HOW to execute. Dispatching the skill card to a sub-agent means the sub-agent receives instructions about dispatching — which it cannot do.

| Artifact | File | Consumer | Content | Action |
|----------|------|----------|---------|--------|
| Skill Card | SKILL.md | Orchestrator | Routing metadata (Trigger Dispatch Table, Invocation, DISPATCH_GATE) | Load via skill(), read in own context, do NOT dispatch |
| Task Card | tasks/<name>.md | Sub-agent | Execution procedure (entry criteria, steps, exit criteria) | Dispatch via task() using canonical string from Invocation |

The correct pattern:
1. Orchestrator calls `skill({name: "..."})` → skill card loads into orchestrator context
2. Orchestrator reads Trigger Dispatch Table and Invocation section in own context
3. Orchestrator dispatches the **task card** (`tasks/<name>.md`) to a sub-agent via `task()`
4. Sub-agent reads the task card, executes the procedure, returns a result contract

#### 🚫 FORBIDDEN
- Forwarding skill card content (Trigger Dispatch Table, DISPATCH_GATE, Invocation, Orchestrator Entry Criteria) to a sub-agent via `task()`
- Treating the `skill()` tool as a "dispatch to sub-agent" mechanism — it loads routing metadata into the orchestrator's context
- Including skill card routing sections in `task()` prompts
- Sending SKILL.md content to a sub-agent and expecting the sub-agent to "follow its instructions" — the instructions say "dispatch to sub-agents via task()" which the sub-agent cannot do

#### ✅ REQUIRED
- Call `skill({name: "..."})` to load the skill card into orchestrator context
- Read the Trigger Dispatch Table and Invocation section in the orchestrator's own context
- Dispatch the **task card** (`tasks/<name>.md`) to a sub-agent via `task()` using the canonical dispatch string
- The sub-agent receives only the task card path and routing context — never the skill card content

#### 4-Way Violation Distinction

| Violation | ID | What Happens |
|-----------|-----|-------------|
| Pre-read skill + inline execute | critical-rules-048 | Agent reads task card `.md` file, executes steps manually without calling `skill()` |
| Orchestrator inline work | critical-rules-034 | Agent performs file modifications or analysis inline without sub-agent task() |
| Tool-recipe dispatch | #329 (spec-fix) | Agent tasks sub-agent with raw API calls instead of task objectives |
| **Skill card dispatched to sub-agent** | **critical-rules-XXX** | **Agent dispatches SKILL.md content (skill card) to sub-agent via task(); sub-agent receives orchestrator-level routing instructions it cannot execute** |


### [critical-rules-XXX] CRITICAL VIOLATION — Starting work from non-trunk-tip state — orchestrator MUST dispatch pre-work before any file modification

The orchestrator MUST call `skill({name: "git-workflow"})` -> `task("execute pre-work from git-workflow-branch")` before any file modification. Starting work from a non-trunk-tip state (local `$DEFAULT_BRANCH` behind remote tracking tip, dirty submodule state, or uncommitted changes) is a CRITICAL VIOLATION. The pre-work task MUST fail BLOCKED if trunk-tip verification fails.

#### 🚫 FORBIDDEN

- Starting any file modification without first dispatching `git-workflow --task pre-work`
- Working from a stale base branch (local `$DEFAULT_BRANCH` behind `origin/$DEFAULT_BRANCH`)
- Starting work with dirty submodule state or uncommitted changes
- Skipping trunk-tip verification (6-step gate: parent repo trunk tip, zero pending changes, remote tracking match, submodule trunk tip, submodule zero pending, submodule remote tracking match, submodule pointer match)

#### ✅ REQUIRED

- Call `skill({name: "git-workflow"})` -> `task("execute pre-work from git-workflow-branch")` before any file modification
- The pre-work task MUST fail BLOCKED if trunk-tip verification fails
- Verify parent repo is on `$DEFAULT_BRANCH`, zero pending changes, at remote tracking tip
- Verify each submodule is on `$DEFAULT_BRANCH`, zero pending changes, at remote tracking tip
- Verify submodule pointer matches committed SHA (no `+` prefix in `git submodule status`)


### [critical-rules-XXX] CRITICAL VIOLATION — Pre-commit/pre-push submodule pointer verification — MUST verify submodule pointer updates are included in commits

The pre-commit or pre-push gate MUST verify that if a submodule pointer is dirty AND the submodule has changes that are part of the PR scope, the pointer update is included in the commit. Failing to commit a submodule pointer update causes build failures on deploy because the build system resolves the old pointer which does not have the required changes.

#### 🚫 FORBIDDEN

- Committing non-submodule changes while leaving dirty submodule pointers uncommitted
- Pushing a branch where submodule pointer changes are part of the PR scope but not included in the commit
- Skipping the `pre-commit-pointer-check` task dispatch

#### ✅ REQUIRED

- Before every commit, dispatch `skill({name: "git-workflow"})` -> `task("execute pre-commit-pointer-check from git-workflow-branch")`
- Verify that if `git submodule status` shows a `+` prefix (dirty pointer), the pointer update is staged alongside non-submodule changes
- If the submodule pointer is dirty AND the submodule has changes that are part of the PR scope, the pointer update MUST be included in the commit


### [critical-rules-XXX] CRITICAL VIOLATION — Direct `github_issue_write` for spec content bypassing spec-creation pipeline

Using `github_issue_write` to create or update spec issue content (issue body, title, or description for a [SPEC] or [SPEC-FIX] issue) instead of dispatching through the `spec-creation` pipeline is a CRITICAL VIOLATION. All spec content MUST be created and revised through `skill({name: "spec-creation"})` → `task(..., prompt: "execute create from spec-creation-validation")` or the equivalent revision task. Direct `github_issue_write` calls for spec content bypass the spec-creation pipeline's quality gates (brainstorming, decomposition, analytical artifacts, holistic self-check, spec-auditor).

**Exception:** Non-substantive metadata updates (labels, assignees, status markers) via `github_issue_write` are permitted. Spec body content (problem statement, success criteria, approach, affected files) MUST go through the spec-creation pipeline.

**🚫 FORBIDDEN:**
- `github_issue_write(method=create, title="[SPEC] ...", body="...")` — creating a spec issue directly
- `github_issue_write(method=update, body="...")` — updating spec body content directly
- Any direct mutation of spec issue body content outside the spec-creation pipeline

**✅ REQUIRED:**
- `skill({name: "spec-creation"})` → `task(..., prompt: "execute create from spec-creation-validation")` for new specs
- `skill({name: "spec-creation"})` → `task(..., prompt: "execute revise from spec-creation-validation")` for spec revisions
- `github_issue_write` for labels, assignees, comments, and status markers only


### [critical-rules-stop] CRITICAL VIOLATION — "stop" command triggers terminal halt — zero output, zero tool calls, zero proposals
When the user says "stop" (or unambiguous equivalent), the agent MUST immediately cease all operations: no further output, no tool calls, no proposals, no follow-up questions. "stop" is a hard state transition — there is no recovery from "stop" within the same session. The user must explicitly restart with a new message. This is a Tier 1 safety-critical rule — it NEVER yields to developer authorization.

#### 🚫 FORBIDDEN
- Producing any output after "stop" (including "okay, stopping now", "understood", or any acknowledgment)
- Making any tool call after "stop" (including cleanup, save, or status checks)
- Proposing alternatives, asking for clarification, or suggesting next steps
- Treating "stop" as "stop and try something else" — it is terminal, not conditional
- Any form of acknowledgment, confirmation, or farewell

#### ✅ REQUIRED
- On detecting "stop": immediately cease all operations
- Zero output, zero tool calls, zero proposals
- The user must explicitly restart with a new message to resume interaction
- "stop" is a hard state transition — no recovery within the same session

### [critical-rules-073] CRITICAL VIOLATION — Reading source files with intent to modify without `for_implementation`+ scope

Reading source files with the intent to modify them constitutes implicit self-authorization. An agent that reads a source file and then modifies it without `for_implementation` or higher scope has bypassed the approval gate. This applies to ALL file types: source code, configuration, guidelines, skills, and task files.

#### 🚫 FORBIDDEN
- Reading a source file and then modifying it without `for_implementation`+ scope
- Using "I was just reading" as a defense after modifying a file
- Reading files to "understand the codebase" and then making changes without authorization

#### ✅ REQUIRED
- Before reading any source file with potential intent to modify, verify authorization scope
- If scope is `for_analysis` or lower, read-only mode is enforced — no modifications permitted
- If scope is `for_implementation` or higher, proceed with reading and modification
- When in doubt about intent, treat as read-only until scope is confirmed

### Tier 2 — Process-Integrity (HALT — Quality Defects)

Rules that prevent **quality defects**: skipped verification, inline work, skill bypass, monolithic implementation, verification failures, missing sub-issues. These yield to developer authorization.

### Channel-Routing Table — Issue Comments vs. Chat Output

**Progress executive summaries go to chat ONLY, not GitHub Issue comments.**

| Action | Channel |
|--------|---------|
| Progress executive summaries | Chat only |
| Review-prep / verification status | Chat only |
| Substantive spec revision | Chat + Issue comment |
| PR created | Chat only |
| Issue blocked | Issue comment |
| Bug discovered during implementation | Issue comment |
| User question response | Issue comment |
| Issue closure | Issue comment |
| Agent completes implementation task | Chat only |
| Spec-audit findings | Internal only |


### [critical-rules-009] Silent Halt Without Prompt — no spec/plan search before stopping
Halting without first searching for existing specs and plans means leaving the user to rediscover work that may already exist. Amateurs halt blind. Professional engineers search first.


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
Orchestrator inline work detected → HALT. Discard pipeline execution state (work state files, cached results, sub-agent output). Published artifacts (issues, plans, specs) are edited in place — do not close and recreate. Restart from last known good commit checkpoint tag per Checkpoint Rollback Exception. Non-waivable. Read [000-critical-rules.md §Checkpoint Rollback Exception](guidelines/000-critical-rules.md).

- 🚫 FORBIDDEN: Continuing the pipeline after detecting orchestrator inline work; attempting to "clean up" or "patch" after orchestrator inline work; preserving any cached state, work state files, or verification results produced during the inline work session
- ✅ REQUIRED: On detection of orchestrator inline work: HALT immediately; discard ALL work state files, cached results, and in-progress artifacts; restart from last known good commit checkpoint tag; log the detection event in the new work state file


### [critical-rules-042] Discard on Sub-Agent Failure
Preserving output from a BLOCKED sub-agent means propagating contaminated state into the next attempt. Amateurs salvage. Professionals discard and re-task with original context.


### [critical-rules-034] Tool-Recipe Task() — sub-agents as API proxies (Tier 2 — cannot be mechanically enforced)
Tasking a sub-agent with `github_create_pull_request` instead of "create a PR" means you are using the agent as an API proxy, not an engineer. Professional agents task objectives. Amateurs task tool recipes. Every tool-recipe dispatch is a decision you made for the sub-agent, not a problem you gave it to solve.


### [critical-rules-042] Gate Non-Waiver Principle — "continue" does not waive mandatory gates
Every "continue" is instruction to proceed to the next step, not to skip the step. Professional engineers know that mandatory gates are structural invariants. Amateurs treat "continue" as a shortcut past quality.


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
The orchestrator holds routing metadata only (worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase, pipeline_history). Task file contents, analysis artifacts, and verification results go to sub-agents or disk. Read [§1.1](guidelines/020-go-prohibitions.md).

> **Note:** These are operational bookkeeping guidelines for context management. They describe how the orchestrator routes work to sub-agents — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.

### [critical-rules-065] Result Contract Frugality — result contracts limited to routing-significant data
Result contracts carry only routing-significant data (status, finding_summary, artifact_path, blocker_reason). Full evidence artifacts go to disk. Read [§1.1](guidelines/020-go-prohibitions.md).

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







