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
2. The current pipeline step's verification failed (VbC or DiMo 4-role chain FAIL)
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
- **Authorization gate** (`.opencode/skills/approval-gate/SKILL.md`): Block merge requests with HALT

Deleting a tracked file from the repository is a destructive operation equivalent to any code change. It requires:
1. A spec (SPEC-FIX or SPEC) describing what is being deleted and why
2. Explicit authorization ("approved" or "go")

A "why" question, a complaint about redundancy, or any interpretive inference is NEVER authorization to delete files. The agent MUST NOT run `git rm` or delete tracked files without both spec and authorization.


### [critical-rules-PR-ORG] CRITICAL VIOLATION — Stacked PR Is the Only Valid Organization
Creating N branches for N issues under any authorization scope is a critical violation. All issues within an authorization scope share one feature branch with one commit per issue. The only valid PR strategy is `stacked` — one branch, N commits, one PR. The `individual` strategy (N branches, N PRs) does not exist.

An authorization scope that halts before PR creation declares `pr_strategy: none`. An authorization scope that creates PRs declares `pr_strategy: stacked`. There is no third option.

Bright-line companion:

PR organization IS branch organization. Stacked PR IS the only valid organization.
Every authorization scope declares exactly one strategy: stacked or none.
Creating N branches for N issues IS a critical violation — Period.


### [critical-rules-XXX] CRITICAL VIOLATION — Dispatching SKILL.md to sub-agents — category error

Dispatching SKILL.md content (the skill card) to a sub-agent via `task()` is a category error. The skill card contains orchestrator-level routing instructions (Trigger Dispatch Table, DISPATCH_GATE protocol, Invocation section, Orchestrator Entry Criteria) that a sub-agent cannot execute. Sub-agents cannot call `task()`, cannot follow Trigger Dispatch Tables, and cannot satisfy Orchestrator Entry Criteria. This rule is a direct consequence of the allocation-by-context-cost model: the skill card is small, necessary, routing-relevant metadata that the orchestrator must hold in its own context, while the task card is the execution procedure that the sub-agent's disposable context consumes. Sending the skill card to a sub-agent wastes sub-agent context on routing metadata the sub-agent cannot act on — the opposite of allocation-by-context-cost.

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

| **Skill card dispatched to sub-agent** | **critical-rules-XXX** | **Agent dispatches SKILL.md content (skill card) to sub-agent via task(); sub-agent receives orchestrator-level routing instructions it cannot execute** |


### [critical-rules-XXX] CRITICAL VIOLATION — Starting work from non-trunk-tip state — orchestrator MUST dispatch pre-work before any file modification

The orchestrator MUST call `skill({name: "git-workflow"})` -> `task("execute pre-work from git-workflow-branch")` before any file modification. Starting work from a non-trunk-tip state (local `$DEFAULT_BRANCH` behind remote tracking tip, dirty submodule state, or uncommitted changes) is a CRITICAL VIOLATION. The pre-work task MUST fail BLOCKED if trunk-tip verification fails.

#### 🚫 FORBIDDEN

- Starting any file modification without first dispatching `git-workflow --task pre-work`
- Working from a stale base branch (local `$DEFAULT_BRANCH` behind `origin/$DEFAULT_BRANCH`)
- Starting work with dirty submodule state or uncommitted changes
- Skipping trunk-tip verification (6-step gate: parent repo remote trunk tip, zero pending changes, remote tracking match, submodule remote trunk tip, submodule zero pending, submodule remote tracking match, submodule pointer match)

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

### [critical-rules-074] CRITICAL VIOLATION — Missing SKILL.md or task cards — investigation report + fatal HALT with escalation

Missing skill deck files (SKILL.md or task cards) indicate a broken skill directory structure that prevents agent routing and task execution. The agent MUST NOT attempt to infer, fabricate, or proceed without the missing files.

| Condition | Required Action |
|-----------|----------------|
| Missing `SKILL.md` in a skill directory (`skills/<name>/`) | Investigation report + fatal HALT |
| Missing task card referenced by the skill's Trigger Dispatch Table | Investigation report + fatal HALT |
| Missing `SKILL.md` in a `tasks/` subdirectory | Investigation report + fatal HALT |

**Investigation report** MUST include: the specific file paths that are missing, the skill name, the TDT entry (if applicable), and the directory listing showing the gap.

**Escalation path:** Report findings to the developer with specific file paths. Do NOT create placeholder files, do NOT infer content, do NOT proceed without the missing files. The developer must create or restore the missing files.

#### 🚫 FORBIDDEN
- Creating placeholder SKILL.md or task card files to "fix" the gap
- Inferring or fabricating skill content from the skill name alone
- Proceeding with implementation while skill deck files are missing
- Silently skipping a skill whose deck is incomplete

#### ✅ REQUIRED
- On detecting a missing SKILL.md or task card: produce an investigation report with specific file paths
- HALT with fatal escalation — report to developer
- Wait for developer to create or restore the missing files before proceeding

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














































