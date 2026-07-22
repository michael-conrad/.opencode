---
trigger_on: critical, zero tolerance, violation, mandate, Tier 1
tier: 1
load_when: sub-agent
---

# CRITICAL RULES — Three-Tier Model

**Read [the authoritative list of critical rules](AGENTS.md).**
**Read [detailed rules](.opencode/guidelines/).**

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
Read [§1](guidelines/020-go-prohibitions.md). ONLY "approved"/"go" authorize action.


### [critical-rules-006] CRITICAL VIOLATION — Routing-bypass rationalization as self-authorization variant
The pattern "agent recognizes matching skill, deliberates about whether skill is needed, constructs carveout justification, executes bypass" is explicitly classified as a self-authorization variant. Any agent that matches a skill trigger but self-classifies into a "read-only" or "simple lookup" exemption and bypasses dispatch has committed a routing-bypass self-authorization violation. Read [§1](guidelines/020-go-prohibitions.md).


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
Auto-spec → auto-plan → auto-approve → auto-PR. Read [010-approval-gate.md](guidelines/010-approval-gate.md).


### [critical-rules-045] CRITICAL VIOLATION — Creating .opencode/.opencode/ Nested Directories
Breaks agent config loading. Read [§2](guidelines/060-tool-usage.md).


### [critical-rules-052] CRITICAL VIOLATION — `git rm` and file deletion require spec + authorization
`git rm` and file deletion require spec + authorization — CRITICAL VIOLATION to perform without both.

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

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Starting work from stale base | PR diff includes changes already in origin but not in local base — confusing PR diff |
| Dirty submodule state | Submodule pointer not committed — build failure on deploy |
| Skipping trunk-tip verification | Failed deploys, wasted CI cycles, manual remediation to clean stale branches |


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

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Committing without submodule pointer update | Build system resolves old pointer — build failure on deploy |
| Pushing with dirty submodule pointer | Deploy fails, requires manual remediation to create a follow-up PR |


### Tier 2 — Process-Integrity (HALT — Quality Defects)

Rules that prevent **quality defects**: skipped verification, inline work, skill bypass, monolithic implementation, verification failures, missing sub-issues. These yield to developer authorization.
### [critical-rules-007] Worktree Bypass — using stash+checkout instead of worktrees when WORKTREE_REQUIRED
Using stash+checkout means contaminating your workspace state. Professional engineers isolate work in worktrees — amateurs juggle stashes and risk losing uncommitted context.

#### 🚫 FORBIDDEN

- Using stash+checkout instead of worktrees when `WORKTREE_REQUIRED` is set

#### ✅ REQUIRED

- Always use `git worktree add` when `WORKTREE_REQUIRED` is set
- Isolate each feature branch in its own worktree to prevent workspace contamination

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Using stash+checkout when WORKTREE_REQUIRED set | Contaminates workspace state; risk of losing uncommitted context via stash juggling |


### [critical-rules-007] Relative File Paths in Worktree Context — using relative paths when worktree.path is set
Relative paths in worktree mode silently target the wrong repo. Every edit you make goes to the main repo instead of the worktree — your changes land in the wrong place. Professional agents prefix ALL paths with `worktree.path`.

#### 🚫 FORBIDDEN

- Using relative paths when `worktree.path` is set

#### ✅ REQUIRED

- Always prefix file operation paths with `worktree.path` when operating in a worktree
- Use `workdir` parameter in bash tool calls to target the worktree

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Using relative paths when worktree.path set | Edits silently target the main repo instead of the worktree |


### [critical-rules-030] Sub-Agents Ignoring Worktree Context — sub-agents modifying main repo instead of worktree
Sub-agents that modify the main repo instead of the worktree are contaminating the wrong workspace. Every file they write goes to the wrong directory. Professional orchestrators always pass `worktree.path` in task context.

#### 🚫 FORBIDDEN

- Sub-agents modifying the main repo when operating in a worktree

#### ✅ REQUIRED

- Always pass `worktree.path` in task context to sub-agents
- Sub-agents must prefix all file paths with the received `worktree.path`

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Sub-agents modifying main repo instead of worktree | Every file they write goes to the wrong directory |


### [critical-rules-008] Implementing Without Verifying Against Live Documentation
Implementing from memory means implementing from training data — always stale, always partially wrong. Professional engineers verify API signatures, env vars, and function parameters against live documentation before writing a single line of code.

#### 🚫 FORBIDDEN

- Implementing code based on memory or training data without live verification
- Claiming API parameter names, method signatures, or config field names from assumption

#### ✅ REQUIRED

- Verify API signatures against official docs or source before calling
- Check environment variable names against `.env.example` or config documentation
- Verify function signatures via `srclight_get_signature` or source code inspection

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Implementing from memory | Uses stale training data, produces incorrect API calls |
| Claiming signatures without verification | Defects discovered at runtime instead of design time |


### [critical-rules-009] Schema/API/Code Verification — claiming knowledge without verification
Claiming schema compliance or API correctness without verification means you are asserting facts you have not checked. Every unverified claim is a defect waiting for CI to discover. All code/API claims require live tool-call evidence — see `065-verification-honesty.md` → "Pre-Response Factual Claim Gate".


### [critical-rules-009] Verification Dishonesty — reporting memory as verified
Reporting memory as verification means you are presenting guesses as facts. Every claim presented without a tool call is trust you have not earned. Professional agents never report unverified information as verified — see `065-verification-honesty.md`.


### [critical-rules-009] Metadata-as-Evidence — workflow metadata is not evidence of implementation
Issue state and PR merge status are process metadata, not evidence of acceptance criteria being met. Treating labels as proof means accepting administrative artifacts as behavioral evidence. Issue state, PR merge status, and labels are NOT evidence of completion.


### [critical-rules-009] Memory/Training-Data-as-Evidence — memory and training data are always stale
Memory and training data are always stale — they represent what was true when the model was trained, not what is true now. Every factual claim must be backed by a live tool-call artifact in the current session. Agents who rely on memory produce work that cannot be trusted.


### [critical-rules-009] Skipping verification-enforcement During Content Generation
Generating content without verification means publishing unverified claims. Specs with unverified statements produce plans that implement the wrong thing. All content (specs, plans, docs, correspondence) must pass the verification gate — see `verification-enforcement` skill.


### [critical-rules-015] Plan ≠ Execution — treating documentation as evidence of completion
A plan is a map, not a destination. Treating plan completion as implementation completion means you are mistaking intent for delivery. Professional engineers verify behavior, not documentation — see `verification-enforcement` skill → "Plan ≠ Execution Evidence Rule".


### [critical-rules-009] Audience Separation — leaking internal artifacts to stakeholders
Leaking internal audit findings and raw status into stakeholder communications damages trust. Drafting tools and delivery channels are separate concerns — professional communicators maintain audience separation. Read [correspondence skill](skills/correspondence/SKILL.md) → "Audience Separation Principle".


### [critical-rules-XXX] Posting Spec-Audit Findings as Issue Comments

**⚠️ Posting spec-audit findings as GitHub comments is FORBIDDEN.**

Audit findings from spec-auditor are internal agent guidance — equivalent to linter output. They must be posted to chat only.

- 🚫 FORBIDDEN: Posting audit findings (spec audits, plan fidelity checks, cross-validate results) as GitHub Issue comments
- 🚫 FORBIDDEN: Treating audit output as stakeholder-facing content
- ✅ REQUIRED: Audit findings go to chat only. Spec revisions (not audit results) go to issue comments when substantive.


### [critical-rules-012] Acting on Resources Without Reading All Comments
Acting on a resource after reading only the body means you are working with partial context. Every unread comment is a defect vector — authorization may live in a comment, not the body. Professional engineers read ALL comments before any action — see `067-context-completeness.md`. Amateurs act on partial context and call assumptions facts.


### [critical-rules-009] Session Trigger Echo — parroting triggers in agent output
Parroting trigger data into agent output instead of processing it internally is what amateurs do when they want their responses to read like raw log files. Professional agents process triggers internally — never echo verbatim. Read [117-session-trigger-behavior.md](guidelines/117-session-trigger-behavior.md).


### [critical-rules-016] Skipping Post-Implementation Verification Skills
Post-implementation verification skills exist to catch the defects you cannot see in your own work. Skipping them means accepting undiscovered failures into the codebase. Professional engineers always call `verification-before-completion` and `finishing-a-development-branch` after implementation — amateurs skip verification and call it done.


### [critical-rules-016] Skipping review-prep After Implementation
Review prep is the last gate before your work enters the codebase permanently. Skipping it means the first review your code receives is from a colleague, not from yourself. Professional engineers always run review-prep before submitting — amateurs let reviewers discover their mistakes. Read [git-workflow --task review-prep](skills/git-workflow/SKILL.md). Compare URL required.


### [critical-rules-016] Skipping Post-Merge Cleanup
Leaving merged branches and open issues after a merge creates a maintenance tax on every future session. Cleanup is not overhead — it is the completion ritual that keeps the repo navigable. Professional engineers clean up after every merge — amateurs leave a trail of orphaned branches and stale issues for someone else to find. Read [git-workflow --task cleanup](skills/git-workflow/SKILL.md). Deletes merged branches, closes issues, syncs trunk.


### [critical-rules-016] Wrong Chat Output at Halt Points
A halt without structured output leaves the developer guessing what happened, what was produced, and what to do next. Professional engineers always produce: Summary → Outcome → Blockers (if applicable) → URL (if applicable) → Byline. Amateurs vanish without telling anyone what they did. Read [git-workflow skill](skills/git-workflow/SKILL.md).


### [critical-rules-016] Wrong PR Body Format
A PR body without Summary/Outcome/Fixes structure buries the intent of your changes under implementation details. Reviewers need context, not code dumps. Professional engineers write PR bodies that tell the story — amateurs dump diffs and expect reviewers to reverse-engineer the intent. Read [git-workflow skill](skills/git-workflow/SKILL.md) → `pr-creation` → PR Body Requirements.


### [critical-rules-016] Wrong Compare URL Base Branch
Using the wrong base branch in a compare URL sends reviewers to the wrong diff — your changes look different against the wrong baseline. Professional engineers verify the base branch before every compare URL — amateurs send reviewers to the wrong diff and waste everyone's time. PR compare URL base: `$DEFAULT_BRANCH` (the trunk).


### [critical-rules-016] Fabricating URLs
Constructing URLs from template variables instead of extracting them from the API response is what amateurs do when they want their compare links to point to the wrong repository — and their issue URLs to break the moment they are posted. Professional engineers extract every post-creation URL from the API response `html_url` field — never from guesswork templates. Pre-creation URLs use verified session-init values with character-match verification. The detailed rules below are not suggestions — they separate reliable PRs from broken links.

#### URL Sourcing Rule 1: Post-Creation URLs — Extract from API Response (NEVER construct)

For URLs to resources that have been **created by an API call** (PR URL, Issue URL), the agent MUST extract the `html_url` field from the API response — never construct from template variables.

**Procedural enforcement in skill tasks:** The following skill task files contain mandatory URL extraction steps:
- `git-workflow/tasks/pr-creation.md` Step 7 — PR URL extraction from `github_create_pull_request`
- `git-workflow/tasks/review-prep.md` — PR URL extraction after PR creation
- `approval-gate/tasks/post-implementation.md` — PR URL extraction after PR creation
- `issue-operations/tasks/link-sub-issue.md` Step 4 — Sub-issue URL extraction from `github_issue_write`
- `issue-operations/tasks/creation.md` — Issue URL extraction from `github_issue_write`
- `issue-operations/tasks/completion.md` — Issue URL extraction from `github_issue_write`
- `verification-before-completion/tasks/completion.md` — Issue URL extraction from `github_issue_write`
- `implementation-pipeline/SKILL.md` Trigger Dispatch Table — PR URL extraction after PR creation
- `finishing-a-development-branch/tasks/checklist.md` — URL extraction checklist verification

- **PR URL:** Extract from `github_create_pull_request` response `html_url` field
- **Issue URL:** Extract from `github_issue_write` response `html_url` field
- **Template construction is FORBIDDEN** for post-creation URLs
- The API response is the single source of truth for post-creation URLs

#### URL Sourcing Rule 2: Pre-Creation URLs — Construct from Verified Session-Init Values

For URLs to resources that **haven't been created yet** (Compare URL before push), the agent MUST construct from session-init values with a mandatory character-match verification step:

1. Read `<github.owner>`, `<github.repo>`, `<gitbucket.html_url>` from session init
2. Construct the URL using those exact values
3. **Character-match verification:** Confirm the constructed URL contains the exact `<github.owner>` and `<github.repo>` strings from session init (character-for-character match, no typos, no cached values)
4. If any mismatch: HALT and report

#### Original Fabricating URLs Rule (superseded by Rule 1 and Rule 2 above)

- ✅ REQUIRED: Follow URL Sourcing Rule 1 and Rule 2 above


### [critical-rules-036] Inferring GitHub Owner from File Paths/Usernames
Guessing `github.owner` from file paths or usernames instead of reading session init means routing every GitHub API call to the wrong repository. Professional engineers use `github.owner` and `github.repo` from session init for EVERY GitHub MCP call — guessing is not engineering, it is gambling with your API routing.


### [critical-rules-036] Wrong API Routing for Submodule/Sub-folder Repos
Routing API calls for submodule repos to the parent repository means every issue operation silently targets the wrong project — and every submodule change gets lost in the wrong repo. Professional engineers resolve the correct remote via `git remote -v` before making any API call. A dry cross-reference to §9 does not route itself.


### [critical-rules-platform-routing-bypass] CRITICAL VIOLATION — Platform Routing Bypass — direct `github_*`/`gitbucket-api` issue calls outside `issue-operations/platforms/`
All `github_*` and `gitbucket-api` issue calls MUST route through the `issue-operations` dispatcher. Making direct platform API calls outside `issue-operations/platforms/` bypasses the routing layer and creates unmaintainable, platform-locked code. Professional engineers route all calls through the dispatcher — amateurs call platform APIs directly and create vendor lock-in.


### [critical-rules-platform-api-deliberation] Platform API Deliberation Prohibited
The `issue-operations` dispatcher resolves platform selection automatically based on `github.platform`. Agents MUST NOT deliberate about which platform API to use — the dispatcher handles this. Asking "should I use GitHub or GitBucket?" or choosing a platform API manually is a routing anti-pattern. Professional engineers trust the dispatcher — amateurs second-guess platform routing.


### [critical-rules-028] Offer-to-Edit Bypass — offering to modify files without spec
Offering to "fix it quickly" instead of creating a spec is the oldest shortcut in the book — and the fastest path to unreviewed, unapproved changes polluting your codebase. Professional engineers write a spec when a fix is identified. The ONLY permitted action when a fix is found is spec creation — nothing else, no exceptions, no "just this once."


### [critical-rules-009] Enforcement Test Updates — guideline/skill changes without BEHAVIORAL enforcement tests
Adding a guideline or skill change without a BEHAVIORAL enforcement test means you are documenting, not enforcing — and documentation without enforcement is decoration. Every guideline and skill change that lacks a behavioral enforcement test is a suggestion, not a rule. Suggestions get ignored by the agents that need them most. Professional engineers ship behavioral tests with every rule change.


### [critical-rules-010] Implementation Without Spec — expanding the definition
Modifying behavior, config, or enforcement without an approved spec is what amateurs do when they want their changes to break the build and waste everyone's review time. Professional engineers produce a spec first — then implement against it. Read [010-approval-gate.md](guidelines/010-approval-gate.md).


### [critical-rules-016] Missing Progress Reports
Halting without structured output means leaving the developer guessing what happened — and that is amateur-hour behavior. Professional engineers always produce: Summary → URL → Byline. Issue comments are for substantive information only.


### [critical-rules-012] Ignoring Issue Comments
Acting on an issue without reading all its comments is the signature move of engineers who produce work that needs to be redone. Every unread comment is a defect waiting to surface. Professional engineers read every comment before touching a single line of code. Read [issue-operations skill](skills/issue-operations/SKILL.md) → `comment` task.


### [critical-rules-025] Implementation-First Gate — halting before producing deliverables
Halting with zero deliverables means you have produced nothing but chat — and chat is not implementation. Professional engineers produce at least one file modification or artifact before any halt-point output. Amateurs talk about what they will do; professionals show what they have done.


### [critical-rules-042] Single Concern Principle — every artifact addresses exactly one concern
Professional engineers ship one concern per artifact — commits, PRs, issues, specs, plans, comments, sub-agents each do exactly one thing. Amateurs mix concerns into monolithic blobs — then wonder why every change breaks something unrelated.


### [critical-rules-042] Monolithic Implementation — skipping item decomposition
Professional engineers decompose work into testable items and build one per TDD cycle (RED → GREEN → REFACTOR → COMMIT). Amateurs batch everything into single monolithic changes — then wonder why review catches half of it wrong.


### [critical-rules-042] Scope Creep — never do things outside the spec
Professional engineers implement exactly what the spec defines — nothing more, nothing less. Amateurs add features the spec never asked for — then wonder why reviewers flag every third line as scope creep.


### [critical-rules-010] Spec Without Investigation
Professional engineers inspect the codebase before writing a spec — live verification prevents assumptions. Amateurs spec from memory and training data — then wonder why the implementation doesn't fit the actual code.


### [critical-rules-010] Plan Creation Without Analytical Artifacts — bypassing the artifact gate
Professional engineers verify all 7 analytical artifacts exist before plan creation (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment). Amateurs skip artifact verification and produce plans disconnected from codebase reality — then wonder why every phase encounters a dependency or constraint the artifacts would have caught. The artifact gate is enforced at the writing-plans TDT entry, Entry Criteria, pre-plan-readiness task, and spec-to-plan handoff manifest. Skipping any of these gates means the plan was never structurally validated against the spec.

**Artifact generation:** The 7 analytical artifacts are generated by `spec-creation/tasks/analytical-artifacts.md` (dispatched from `spec-creation/tasks/create.md` Step 12.5). Artifacts are stored at `{project_root}/{path}/.issues/{N}/artifacts/{name}.yaml`. **Artifact validation:** `writing-plans/tasks/create.md` Step 4a validates artifact existence before plan creation. Missing artifacts produce BLOCKED with `MISSING_SPEC_ARTIFACT`, with auto-generation fallback via retroactive mode.


### [critical-rules-010] Implementing Stale or Superseded Specs
Professional engineers check for superseding open issues before implementing — stale specs produce wasted work. Amateurs implement whatever spec they find first — then wonder why their output is obsolete before the PR is opened.


### [critical-rules-025] Main Agent Implements Directly
Professional orchestrators route through sub-agents — amateurs inline work and produce contaminated pipelines. Read [implementation-pipeline skill](skills/implementation-pipeline/SKILL.md) Trigger Dispatch Table. Orchestrator tasks sub-agents via task() only.


### [critical-rules-016] Bypassing Mandatory Skill Calls During Implementation
Pipeline chain: pre-work → implementation-pipeline (Trigger Dispatch Table) → verification-before-completion → finishing-checklist → review-prep. Skipping any step means accepting undiscovered defects into every deliverable downstream. Each step MANDATORY.


### [critical-rules-016] Skill Bypass = Critical Violation
Every step in pipeline chain is enforceable, not advisory. Professional engineers follow the chain — amateurs take shortcuts and produce broken deliverables.


### [critical-rules-016] Auditor Skills Enforcement
Professional engineers subject every deliverable to independent audit — amateurs ship unverified work. Read [audit skill](skills/audit/SKILL.md). Binary PASS/FAIL classification (auto-fix as remediation action only).


### [critical-rules-011] Bug Reports Without Fix Spec
Reporting a bug without a fix spec means you are asking the developer to guess what happened. Professional engineers always create a fix spec with every bug report — amateurs file half-baked tickets and expect someone else to figure them out.


### [critical-rules-011] Bug Discovery Does NOT Authorize Bug Fixing
Finding a bug during implementation does NOT mean you have permission to fix it. Professional engineers stop, report the bug as a spec issue, and wait for authorization — amateurs assume discovery is a license to act.


### [critical-rules-009] Authorization-Free Actions — no deliberation required
Issue creation, sub-issues, progress comments, labels, lint/format all authorized per spec scope model. Professional engineers execute pre-authorized actions without hesitation — amateurs stop and ask for permission on every trivial step. Feature branches (`feature/*`, `spec/*`) are NOT authorization-free — they require `for_implementation` or above scope. Read [010-approval-gate.md](guidelines/010-approval-gate.md).


### [critical-rules-011] Symptom-Only Fix-Specs — patches without root cause analysis
Writing a fix spec that only addresses symptoms means you are leaving the root cause in place for the next person to find. Professional engineers always identify root cause in fix specs — amateurs patch symptoms and call it done.


### [critical-rules-009] Conflating Issue References with Authorization Cascade
Only formal `github_sub_issue_write` links trigger cascade. Professional engineers only cascade authorization through formal `github_sub_issue_write` links — amateurs read implied permission into every cross-reference.


### [critical-rules-027] Confirmation ≠ Authorization
"Yes, that's correct" ≠ authorization. Only "approved"/"go"/"#NNN approved". Amateurs treat confirmation as permission. Professionals wait for explicit authorization.


### [critical-rules-027] Feedback ≠ Authorization — treating technical input as implementation permission
User engagement is collaboration, not permission. Amateurs treat feedback as an implementation ticket. Professionals wait for explicit authorization. Read [§1](guidelines/020-go-prohibitions.md).


### [critical-rules-042] Skipping PR for Documentation/Guideline Changes
Exception: zero files modified, or already-implemented (verified by `verify-already-implemented`). Amateurs skip PRs for documentation changes. Professionals maintain review discipline for every change.


### [critical-rules-042] Blind Conflict Resolution
Resolving conflicts blindly produces broken merges. Professional engineers classify conflicts by intent before resolving — amateurs merge first and find the corruption later. Three tiers: Trivial → auto, Textual → note, Intent → HALT. Read [conflict-resolution skill](skills/conflict-resolution/SKILL.md).


### [critical-rules-042] Engineering Mindset Required
Understand → Design → Verify → Communicate. Amateurs jump from understanding to implementation. Professional engineers verify before building. Read [engineering-approach skill](skills/engineering-approach/SKILL.md).


### [critical-rules-016] Skipping Completion Guarantee on Workflow Halt
Call `--task completion` on current skill before halting. Amateurs abandon workflows mid-stream. Professionals close out every skill before halting.


### [critical-rules-009] Silent Agent Termination — producing no output before stopping
A halt without output means leaving the developer blind. Professionals produce structured output at every stop — amateurs vanish without a trace, leaving defects undiscovered. See detailed rules below.

#### Post-task() Output Guarantee

After EVERY `task(subagent_type=...)` call, the agent MUST produce output — never transition directly from task() to halt without output.

| After task() | Agent MUST |
|----------------|-----------|
| Sub-agent returned valid result | Report result or proceed to next step |
| Sub-agent returned empty result | RE-TASK clean-room sub-agent with same scoped context |
| Sub-agent returned error | RE-TASK clean-room sub-agent with same scoped context |
| Re-task also failed | Report double-failure + call `--task completion` + HALT with status message + byline |

| Violation Pattern | Classification |
|-------------------|----------------|
| Empty sub-agent result → zero output → silent halt | Critical: Silent Agent Termination |
| Empty sub-agent result → re-task attempt → status message in chat | Acceptable: self-corrected |
| Empty/error sub-agent result → inline fallback | Critical: No Inline Fallback — Universal Re-Task Mandate |

#### Post-Tool Execution Output Checkpoint

After EVERY batch of tool calls (ALL types: bash, read, write, edit, github_*, srclight_*, task, etc.), the agent MUST produce visible chat output before halting. This checkpoint applies regardless of tool success/failure, sub-agent results, or workflow end-state. The output MUST include:
1. What operation/tool was invoked
2. What the result was (success/failure/error)
3. What state this leaves the workflow in
4. What developer action (if any) is required to proceed


### [critical-rules-016] Skipping Interdependency Analysis for Batch Approvals
Approving batches without understanding interdependencies means approving work that silently conflicts with other work. Professional engineers analyze interdependencies before every batch approval — amateurs batch first and find conflicts in CI.


### [critical-rules-042] Treating Branch Stacking as Optional
Skipping branch stacking means merging chaos into your commit history. Professional engineers stack branches as prerequisite — amateurs treat stacking as optional and produce unreviewable history.


### [critical-rules-016] Leaving stale todowrite state after task completion
A stale todowrite state means the next agent picks up your abandoned context. Professional engineers complete the full todowrite lifecycle before every halt — amateurs leave their workspace dirty for others to clean.


### [critical-rules-009] Session-Verified State Trust — re-reading without state-change trigger
Re-reading a resource that was confirmed in-session is re-reading verified state — wasteful overhead. Trusting session-verified state without re-reading is professional efficiency, not laziness.


### [critical-rules-009] Verification Deduplication
Re-verifying evidence that a prior skill already collected means doubling work without doubling confidence. Professional engineers cite prior evidence artifacts — amateurs re-check what was already verified.


### [critical-rules-034] Inline Screening of Authorization Sets
Screening authorization sets inline instead of tasking a sub-agent means introducing contamination from your own reasoning. Professional engineers always task `screen-issue` sub-agents — amateurs inline and call it fast.


### [critical-rules-009] Silent Halt Without Prompt — no spec/plan search before stopping
Halting without first searching for existing specs and plans means leaving the user to rediscover work that may already exist. Amateurs halt blind. Professional engineers search first.


### [critical-rules-020] Soft-Passing Verification Mismatches
Reporting "functionally equivalent" as PASS means accepting defects into the codebase under a euphemism. Amateurs soft-pass. Professionals demand exact matches.


### [critical-rules-030] Skipping Clean-Room task() for Sub-Agents
Skipping clean-room task() means contaminating sub-agent context with orchestrator bias — every downstream result inherits that contamination. Amateurs shortcut isolation. Professionals dispatch clean.


### [critical-rules-031] Skipping Pre-Flight Checks for Sub-Agents
Dispatching a sub-agent without pre-flight checks means sending a worker into an unprepared workspace. Amateurs assume readiness. Professionals verify it.


### [critical-rules-032] Skipping Post-Flight Checks for Sub-Agents
Accepting sub-agent results without post-flight checks means trusting instead of verifying. Amateurs accept output at face value. Professionals inspect the deliverable.


### [critical-rules-033] Claiming Verification Without Tool-Call Evidence in Sub-Agent Results
Reporting verification without tool-call evidence means presenting guesses as facts. Amateurs claim. Professionals prove.


### [critical-rules-034] Inline Work — orchestrator performing file modifications without sub-agent task()
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
| Orchestrator performs inline work | Pipeline is poisoned — restart from `verify-authorization` with zero state retained |
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


### [critical-rules-034] Orchestrator Inline Work = Poisoned Pipeline
An orchestrator that performs inline work has contaminated every artifact produced during that session — the pipeline is poisoned, not fixable. Amateurs patch. Professionals restart from zero. Non-waivable.

- 🚫 FORBIDDEN: Continuing the pipeline after detecting orchestrator inline work; attempting to "clean up" or "patch" a poisoned pipeline; preserving any cached state, work state files, or verification results produced during a poisoned pipeline
- ✅ REQUIRED: On detection of orchestrator inline work: HALT immediately; discard ALL work state files, cached results, and in-progress artifacts; restart from `verify-authorization` with zero state retained; log the poison-detection event in the new work state file


### [critical-rules-042] Discard on Sub-Agent Failure
Preserving output from a BLOCKED sub-agent means propagating contaminated state into the next attempt. Amateurs salvage. Professionals discard and re-task with original context.


### [critical-rules-034] Tool-Recipe Task() — sub-agents as API proxies
Tasking a sub-agent with `github_create_pull_request` instead of "create a PR" means you are using the agent as an API proxy, not an engineer. Professional agents task objectives. Amateurs task tool recipes. Every tool-recipe dispatch is a decision you made for the sub-agent, not a problem you gave it to solve.


### [critical-rules-042] Skipping Spec/Plan Coherence Gate (Pre-RED)
Dispatching RED sub-agents without a coherence gate means your implementation plan has never been checked against the codebase. Professional engineers verify coherence before writing a single line of code. Amateurs find out at review time.


### [critical-rules-042] Skipping Execution-Time Coherence Detection (RED + GREEN)
A RED sub-agent that detects a spec/codebase contradiction but proceeds anyway is producing code that cannot work. Professional sub-agents return BLOCKED. Amateurs return broken code that CI will discover later.


### [critical-rules-042] Gate Non-Waiver Principle — "continue" does not waive mandatory gates
Every "continue" is instruction to proceed to the next step, not to skip the step. Professional engineers know that mandatory gates are structural invariants. Amateurs treat "continue" as a shortcut past quality.


### [critical-rules-046] Mechanical-Only Audit Without Semantic and Conflict Exploration
Running an audit that only checks mechanical patterns means you are looking for typos when the building is on fire. Professional auditors probe semantic completeness and inter-rule conflicts. Amateurs count violations without understanding them.


### [critical-rules-047] VbC Fabricated PASS — reporting file existence as verified behavioral evidence
Reporting that a file exists as evidence that behavior is correct is what amateurs do when they want their verification to pass without doing the work. Professional engineers verify behavioral outcomes, not structural presence. File existence proves nothing about correctness.


### [critical-rules-048] Skill Pre-Read + Inline Execution — reading skill task files and executing steps manually

Reading a skill's task files and then inlining the steps means you are bypassing the quality gates designed to catch your mistakes. Professional agents load skills. Amateurs inline. Every skill you pre-read and execute manually is a defect you accepted before writing a single line of code.

**3-Way Violation Distinction:**

| Violation | ID | What Happens |
|----------|-----|-------------|
| Pre-read skill + inline execute | critical-rules-048 | Agent reads `.md` task file, executes steps manually without calling `skill()` |
| Orchestrator inline work | critical-rules-034 | Agent performs file modifications or analysis inline without sub-agent task() |
| Tool-recipe dispatch | #329 (spec-fix) | Agent tasks sub-agent with raw API calls instead of task objectives |


### [critical-rules-038] Implementing Before PR Merge Boundary
Implementing a dependent phase before its PR boundary has merged means you are building on a foundation that does not exist yet. Professional engineers respect PR merge boundaries. Amateurs stack work on unreviewed code.


### [critical-rules-042] Content Verification Before Branch Deletion
Deleting a branch without verifying its content against the target branch means you are destroying code whose status you have not confirmed. Professional engineers diff first. Amateurs delete blind and lose work.


### [critical-rules-042] Model-Aware Clean-Room task() for Behavioral Testing
Running behavioral tests through grep and static analysis instead of `opencode run` means you are testing the wrong thing — text patterns, not agent behavior. Professional engineers test against real AI models in clean-room isolation. Amateurs grep for keywords and call it verified.


### [critical-rules-pipeline-reprime] Pipeline re-priming — enforcement blocks at each skill boundary
Pipeline stage transitions require re-encountering an enforcement block restating procedural discipline identity. Professional engineers re-prime at every boundary. Amateurs let context degrade between gates.


### [critical-rules-044] Preloading Sub-Agent Context — task()ing with pre-determined file paths/line numbers/outcomes
Handing a sub-agent pre-determined file paths, line numbers, and expected outcomes means you are not asking the sub-agent to do the work — you are asking it to execute your guesses. Professional engineers gate every execution behind a pre-analysis sub-agent that discovers the scope independently. Amateurs preload their assumptions.


### [critical-rules-043] Universal Re-Task Mandate — no inline fallback on sub-agent failure
When a sub-agent fails, inline fallback means the failure contaminates your pipeline — you inherit the same context that caused the error. Professional engineers always re-task clean-room with the same scoped context. Amateurs patch in place and compound their problems.


### [critical-rules-051] Skipping mandatory submodule tagging at pre-work
Skipping submodule tagging means the starting SHA becomes unreachable after squash merge and branch deletion — the work still exists but nobody can find it. Professional engineers tag every submodule at pre-work. Amateurs lose history that their future selves need.


### [critical-rules-018] Pipeline-Scoped Authorization with Hard HALT at Scope Boundary
Read [approval-gate skill](skills/approval-gate/SKILL.md) → Authorization Scope Model.


### [critical-rules-hard-fail] Hard Failure Discipline — FAIL is a hard gate, never reclassifiable

A FAIL signal at any pipeline stage (auditor verdict, sub-agent result, cleanup gate, SC-verification gate, phase-completion gate) is a **hard gate** — it must be remediated, not sidestepped. `DONE_WITH_CONCERNS` is coerced to FAIL — caveats are defects, not completions. The bright-line coercion rule in `implementation-pipeline/SKILL.md` Trigger Dispatch Table governs this coercion.

**Remediation-first sequence (mandated by #763):**
1. **Remediate** the root cause — diagnose what produced the FAIL
2. **Re-verify** — When the original FAIL came from an audit, "re-verify" means dispatching a clean-room re-audit via `skill({name: "audit"})` + `task()`. A self-check, inline re-read, or orchestrator-level re-verification is NOT sufficient — the re-audit must be independent of the remediator's context. For non-audit FAILs, repeat the verification command/assertion that produced the FAIL.
3. **Proceed** only on confirmed PASS from re-verification
4. **HALT only on double-failure** — if re-verification also fails, report blocker with both failure artifacts

**Prohibited patterns:**
- **Reclassification** — turning a FAIL into "PASS with caveats" or "functionally equivalent" is soft-passing by another name (Read [critical-rules-020](guidelines/000-critical-rules.md))
- **INCONCLUSIVE** — a verdict of INCONCLUSIVE for a gate that produces deterministic PASS/FAIL is a reclassification, not a finding. INCONCLUSIVE is prohibited as a gate verdict at all pipeline stages. The auditor files have been updated to remove INCONCLUSIVE — see `audit` task files
- **HALT without remediation attempt** — a FAIL that halts the pipeline without any remediation attempt is abandoning the root cause instead of fixing it. Professional engineers always attempt remediation before escalation. See `763-remediation-first`

Professional engineers remediate then re-verify — amateurs reclassify, soft-pass, or INCONCLUSIVE to avoid doing the work. Read [065-verification-honesty.md](guidelines/065-verification-honesty.md) → "Hard Failure Discipline".

### [critical-rules-test-integrity] Test Integrity Mandate — No Lobotomizing Tests

Removing or weakening a behavioral (semantic, functional) test assertion to work around a timeout, failure, or infrastructure issue is the most expensive defect you can introduce. A lobotomized test passes by removing the signal it was designed to produce — producing a false PASS that masks a real defect.

**Read [080-code-standards.md §Test Integrity Mandate](guidelines/080-code-standards.md). Key provisions:**

- **Rule 1**: Removing or weakening behavioral assertions is a CRITICAL VIOLATION — equivalent to soft-passing a verification mismatch
- **Rule 2**: Timeout is always diagnosable — never assume model unavailability without tool-call evidence
- **Rule 3**: Research sub-agents for test infrastructure problems — mandatory after 2+ remediation failures
- **Rule 4**: FAIL is a hard gate — never proceed past FAIL. Only valid outcomes: PASS, FAIL (remediate and re-run), or INCONCLUSIVE after exhaustive remediation (escalate only)


### [critical-rules-sc-lobotomy] CRITICAL VIOLATION — SC Lobotomy Prohibition — removing, weakening, deferring, skipping, or blocking success criteria

Removing or weakening a success criterion from a spec to evade implementation is a CRITICAL VIOLATION. An agent MUST NOT:
- Remove an SC from a spec's SC table to make it "closable"
- Weaken an SC's evidence type (e.g., `behavioral` to `string`) to make it easier to verify
- Replace an SC with a weaker version (changing what success means)
- Mark an SC as "blocked" or "deferred" in the spec body to evade implementation
- Skip an SC entirely — claiming it is "not applicable", "out of scope for this change", "too complex for this change", "will be handled separately", or any equivalent rationalization
- Add a `depends-on` or cross-reference solely to push SC verification out of the current spec
- Claim an SC is "not achievable" and modify the spec rather than implementing it

Required behavior: If an SC is structurally valid and the agent cannot implement it, report BLOCKED with root cause and HALT. The agent must NOT modify the spec, remove the SC, add a new change to "fix" the SC by changing what it tests, or create a dependent spec to offload the SC. The remediation-first protocol applies: attempt to implement before concluding impossibility.


### [critical-rules-BEH-EV] Runtime-Behavioral Evidence Classification Gate — structural evidence for behavioral changes is EVIDENCE_TYPE_MISMATCH

The question "does this change affect runtime behavior?" is substrate-determined — the change either alters runtime behavior or it does not. Intent, author assertion, and hope are irrelevant. When the answer is YES, submitting structural or string evidence is EVIDENCE_TYPE_MISMATCH, not a soft downgrade. The verdict is FAIL. No advisory, no "PASS with structural caveat," no INCONCLUSIVE. The classification gate enforces what the evidence type taxonomy already requires: behavioral changes demand behavioral evidence.

Runtime behavior includes: agent dispatch decisions, enforcement gate outcomes, tool selection, pipeline routing, conditional branching, test execution results, and any observable system output. A change that modifies WHAT a system DOES at runtime — as opposed to what it CONTAINS statically — is a runtime-behavioral change.

The uplift is automatic. Declaring an SC as `structural` or `string` does not exempt it from behavioral evidence requirements when the underlying change affects runtime behavior. Evidence type is determined by what the change DOES, not by what the author declares. A `string` SC that tests a runtime-behavioral change is automatically uplifted to `behavioral` — the declared type is overridden by the substrate classification.

🚫 FORBIDDEN:
- Submitting structural or string evidence for a runtime-behavioral change and reporting PASS
- Declaring an SC as `structural` to avoid behavioral testing when the change affects runtime behavior
- Classifying the evidence type question as intent-determined ("what did the author mean?") instead of substrate-determined ("does this change affect runtime behavior?")
- Producing an advisory or INCONCLUSIVE verdict when EVIDENCE_TYPE_MISMATCH is detected

✅ REQUIRED:
- Classify the change question as substrate-determined: "Does this change affect runtime behavior? YES/NO"
- When YES: automatically uplift declared evidence type to `behavioral` regardless of author declaration
- When the declared type is `structural` or `string` but the change is runtime-behavioral: report EVIDENCE_TYPE_MISMATCH with a FAIL verdict
- Apply the same remediation-first protocol as all hard failures: diagnose, remediate, re-verify

Authority sources: Read [080-code-standards.md §Evidence Type Taxonomy](guidelines/080-code-standards.md), Read [080-code-standards.md §Test Integrity Mandate](guidelines/080-code-standards.md), Read [020-go-prohibitions.md §1 ALWAYS DO — Cost-blind verification](guidelines/020-go-prohibitions.md). Read [065-verification-honesty.md](guidelines/065-verification-honesty.md) §Cost Model for the death-spiral cost rationale underlying this classification gate — automatic uplift from structural→behavioral prevents the death spiral at the earliest possible gate.


### [critical-rules-linters-advisory] All linters are advisory only — no auto-modify

All linters (current and future) MUST run in read-only/report-only mode. No linter may auto-modify files. A linter that modifies files is not advisory — it is destructive.

| Linter | Forbidden | Required |
|--------|-----------|----------|
| `ruff check` | `ruff check --fix` (auto-fixes) | `ruff check` (report only) |
| `ruff format` | `ruff format` (auto-formats) | `ruff format --check` (report what would change) |
| `mdformat` | `mdformat` (without `--check`) | `mdformat --check` (report what would change) |
| Any future linter | Auto-modify mode | Read-only/report-only mode |

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

This rule is the orchestrator-side counterpart to the Sub-Agent Entry Criteria already defined in every SKILL.md's DISPATCH_GATE section. The sub-agent rejects preloaded context with `PRELOADED_CONTEXT_REJECTED` — but the orchestrator must never send it in the first place.

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

- Revise the existing deliverable via the appropriate pipeline (spec-creation --task revise, writing-plans --task update)
- If revision is structurally impossible, document the rationale in an issue comment before creating a replacement

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Creating replacement artifact instead of revising | Orphans original issue, breaks cross-references, wastes issue numbers |
| Inline-fixing defective deliverable | Bypasses pipeline quality gates, produces defective output |


### [critical-rules-072] No-Inline-Fix — orchestrator MUST NOT inline-fix defective sub-agent output
When a sub-agent returns a defective deliverable, the orchestrator MUST NOT attempt to fix the defective artifact directly via `github_issue_write`, file edit, or any other direct mutation. The orchestrator MUST dispatch a revision task to the appropriate pipeline (spec-creation --task revise for specs, writing-plans --task update for plans).

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


### [critical-rules-XXX] Derivation Provenance — every element must have a consumer or first-principles justification

Adding a parameter, field, method, class, configuration key, contract entry, routing scope variable, or code block whose sole justification is "it exists in another location" is a process-integrity failure. Every element must trace to:

1. A specific consumer (task file, function call, code path) that reads or branches on it, OR
2. A first-principles derivation from the problem statement, spec SC, or requirements

"Because it's there in the other file/service/spec/plan" is NOT a valid justification.

#### Applies to ALL agent output

| Artifact Type | Examples of Cargo Cult | Correct Pattern |
|---------------|----------------------|-----------------|
| Code (Java, Python, etc.) | Copying method params, imports, class structure from another file | Derive from consumer callsites or API contract |
| Specs | Adding contract fields without identifying consuming task file | Each field must name at least one consumer |
| Plans | Applying three-tier phase structure without evaluating fit | Derive phase structure from spec SCs |
| Contracts | Propagating fields through dispatch pipelines with no reader | Field without consumer = dead weight |
| Routing tables | Adding scope variables no sub-agent branches on | Each scope variable must be read by ≥1 task file |
| Config files | Copying keys from another environment without verifying consumer | Each key must be read by at least one code path |

#### Remediation

When a derivation-provenance violation is detected (by the agent during self-review, or by an auditor):
- Remove the unjustified element
- If the element is needed, identify the consumer or first-principles derivation
- Do NOT add a placeholder consumer to satisfy the rule — the consumer must be real

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Adding contract field without consumer | Dead weight in every dispatch — context overhead with zero behavioral effect |
| Copying method params from reference class | Wrong parameter set for the new domain — produces incorrect API |
| Propagating routing scope variable no task reads | Every sub-agent receives unused context — routing complexity with no benefit |
| Applying template structure without evaluation | Every artifact looks the same regardless of problem shape — misses domain-specific concerns |

Rules that prevent **inconsistency or tech debt**: naming conventions, numbering, comment style, tool selection. Violations are flagged but do not halt.
### Tier 3 — Workflow-Standard (FLAG — Convention/Consistency)

### [critical-rules-005] Direct-Branch Default — feature branch without worktree is the norm
Default: `git checkout -b feature/X` in main repo. Worktree opt-in when `WORKTREE_REQUIRED` set. Read [git-workflow --task pre-work](skills/git-workflow/SKILL.md).


### [critical-rules-005] Skipping Git Pre-Check — working without feature branch
Must verify git state and create feature branch before any file modification. Creating `feature/*` or `spec/*` branches additionally requires `for_implementation` or above authorization scope.

#### 🚫 FORBIDDEN

- Working without a feature branch
- Creating `feature/*` or `spec/*` branches without `for_implementation` or above authorization scope

#### ✅ REQUIRED

- Verify git state before any file modification
- Create feature branch before starting work
- Ensure `for_implementation` or above scope before creating `feature/*` or `spec/*` branches

#### Why This Matters

| Violation Pattern | Consequence |
|-------------------|-------------|
| Working without feature branch | Changes land directly on trunk branches, breaking branch discipline |
| Creating branches without authorization | Feature/spec branches created without proper scope approval |


### [critical-rules-024] Uncommitted/Unpushed Changes After Implementation
Read [finishing-a-development-branch --task checklist](skills/finishing-a-development-branch/SKILL.md).


### [critical-rules-023] Missing AI Co-Authored Attribution
Format: `Co-authored with AI: <AgentName> (<ModelId>)`. Read [080-code-standards.md](guidelines/080-code-standards.md).


### [critical-rules-023] Hardcoded Identity Values in Skills and Guidelines
Use `<AgentName>`, `<ModelId>`, `<github.owner>` placeholders. Read [080-code-standards.md](guidelines/080-code-standards.md).


### [critical-rules-018] Sub-issue Structure Bypass — multi-task plans
Phases require sub-issue linkage. Read [issue-operations skill](skills/issue-operations/SKILL.md) → `link-sub-issue` task.


### [critical-rules-018] Stopping After Single Phase in Multi-Task Plan
Complete ALL phases, report ONCE, HALT ONCE. Read [approval-gate skill](skills/approval-gate/SKILL.md).


### [critical-rules-013] Sub-issue Closure Timing
Read [git-workflow --task cleanup](skills/git-workflow/SKILL.md).


### [critical-rules-013] Assuming Closed Issues Are Verified
Read [approval-gate --task verify-closed-issue](skills/approval-gate/SKILL.md) and [--task reconcile-issue-graph](skills/approval-gate/SKILL.md).


### [critical-rules-041] Listing Merged PRs Without Calling Cleanup
"check prs" = cleanup trigger → `git-workflow --task check-pr`.


### [critical-rules-019] Creating PRs Without Explicit Instruction
Exception: `for_pr` scope authorizes PR creation.


### [critical-rules-018] Ignoring Spec-to-Plan Approval Cascade
Spec approved + faithful plan exists = plan auto-approved.


### [critical-rules-013] Closing Issues Before PR Merge
Read [git-workflow --task cleanup](skills/git-workflow/SKILL.md) for post-merge closure.


### [critical-rules-013] Parent/Child Issue Closure
Close children first, then parent. Read [git-workflow --task cleanup](skills/git-workflow/SKILL.md).


### [critical-rules-039] Parent Issue Left Open After All Children Closed
Must close parent plan when all children verified complete.



### [critical-rules-039] Process Gaps Are Bugs — completed issues not auto-closed
Read [verify-already-implemented skill](skills/verification-before-completion/SKILL.md) → Auto-Close Procedure.


### [critical-rules-070] Issue Closure Outside Cleanup Workflow — agent MUST NOT close GitHub Issues through direct API calls
The agent MUST NOT call `github_issue_write(method=update, state=closed)` or equivalent on any GitHub Issue outside the `git-workflow --task cleanup` workflow. The cleanup workflow is the sole authorized closure path, and it enforces PR merge verification, body-preservation safeguards, and parent/child ordering before closure. Issues created by the agent in a session MUST survive at least one session boundary before closure. Read [git-workflow --task cleanup](skills/git-workflow/SKILL.md) for the authorized closure path. Read [issue-operations/tasks/close.md](skills/issue-operations/SKILL.md) for the structured close workflow (only callable from within cleanup).


### [critical-rules-018] Sub-issue Linkage Verification — phase count mismatch
Read [approval-gate --task verify-authorization](skills/approval-gate/SKILL.md) Step 5.


### [critical-rules-023] Posting AI-Authored Content Without Byline Verification
Verify byline presence before ANY API call posting AI-authored content.


### [critical-rules-037] Structural Decision Solicitation Under for_pr Scope
No `question` tool for structural decisions when `halt_at >= pr_created`.


### [critical-rules-049] Standalone Submodule-Only PR Creation During Cleanup

Creating a PR whose sole purpose is to update a submodule pointer during the cleanup pipeline stage. Read [git-workflow cleanup task](skills/git-workflow/SKILL.md) Step 1.7 for the complete prohibition and correct behavior (leave dirty pointer untouched).

**Scope clarification:** This prohibition applies to PR creation only. It does NOT exempt the agent from dispatching `git-workflow --task cleanup` on "pr merged" triggers. The cleanup sub-agent independently determines which cleanup actions apply — including whether to leave the submodule pointer dirty. Using this prohibition as a rationalization to skip the entire cleanup workflow is a routing-bypass self-authorization violation (critical-rules-006).


### [critical-rules-039] Parent Issue Left Open After All Children Closed
See verify-already-implemented Step 6, cleanup Step 2.8.


### [critical-rules-040] Un-Squashed PR — creating single-issue PR with multiple commits
Single-issue: exactly 1 commit. Work branch: N commits = N items.


### [critical-rules-041] Listing Merged PRs Without Calling Cleanup
"check prs" = cleanup trigger.


### [critical-rules-060] Functional/Behavioral Test Substitution Prohibition — substituting structural/grep/metadata checks when behavioral tests cannot execute

"Functional test" and "behavioral test" are synonymous — both verify actual agent behavior by executing code and observing output. When a behavioral/functional test CANNOT be executed (model unavailable, timeout, infrastructure failure, `opencode` not installed), the ONLY valid outcome is FAIL. The agent MUST NEVER substitute grep, string matching, metadata checks, pattern scanning, or file-existence checks for behavioral/functional test execution.

#### Authority Sources

- Read [080-code-standards.md §Terminology Note](guidelines/080-code-standards.md) — functional test and behavioral test are synonymous
- Read [080-code-standards.md §Behavioral RED/GREEN as Primary Enforcement Gate](guidelines/080-code-standards.md) — behavioral evidence is PRIMARY
- Read [020-go-prohibitions.md §1 ALWAYS DO — Cost-blind verification](guidelines/020-go-prohibitions.md): substitution is forbidden
- Read [skills/verification-before-completion/tasks/verify.md §"When Behavioral/Functional Tests Cannot Execute"](skills/verification-before-completion/tasks/verify.md) — FAIL is the only valid outcome when the test cannot run

#### Forbidden Substitutions
- Grep/string matching/pattern scanning as behavioral evidence
- Metadata checks (file existence, label state, PR merge status) as behavioral evidence
- File-existence checks as behavioral evidence
- "Spot-checking" as behavioral test substitute
- Any structural check reported as PASS for a behavioral SC

#### Required Actions
1. When a behavioral/functional test cannot execute: report FAIL with explanation
2. Attempt remediation (alternative model selection, infrastructure check)
3. Exhaustive remediation before escalation: only after ALL available model selection, infrastructure check, and alternative model paths have been verified as failed may the agent HALT with escalation
4. There is NO valid path from "test cannot run" to "PASS" or "UNVERIFIED with structural substitute"


### [critical-rules-PR-ORG] Stacked PR Is the Only Valid Organization

Creating N branches for N issues under any authorization scope is a critical violation. All issues within an authorization scope share one feature branch with one commit per issue. The only valid PR strategy is `stacked` — one branch, N commits, one PR. The `individual` strategy (N branches, N PRs) does not exist.

An authorization scope that halts before PR creation declares `pr_strategy: none`. An authorization scope that creates PRs declares `pr_strategy: stacked`. There is no third option.

Bright-line companion:

PR organization IS branch organization. Stacked PR IS the only valid organization.
Every authorization scope declares exactly one strategy: stacked or none.
Creating N branches for N issues IS a critical violation — Period.


### [critical-rules-accountability-ownership] Accountability/Remediation Ownership Model

ALL failures are agent-owned. Remediation is the default action. Escalation is only permitted after verified remediation failure. The following 8 principles govern agent accountability:

1. **Audit fail is a fail** — no exceptions, no reclassification, no soft-passing
2. **Bad prompt is on the agent** — the agent owns prompt quality; a poorly specified prompt is the agent's defect to remediate
3. **Defective spec/plan is on the agent** — the agent produces correct artifacts or remediates them; defective upstream artifacts are not an excuse for downstream failures
4. **Bad/incomplete implementation is on the agent** — the agent owns implementation quality; incomplete or incorrect output must be remediated, not flagged for someone else
5. **Missing text artifacts is a fail** — the agent produces complete deliverables; absent preamble, missing documentation, or incomplete issue bodies are agent-owned defects
6. **Skipped functional/behavioral testing is a fail** — no exceptions, no excuses; the agent runs and passes behavioral tests before claiming completion
7. **Remediate autonomously, never escalate** — escalation is only for dire circumstances (infrastructure failure, model crash, credentials missing); skipping remediation is not a valid choice
8. **No "pre-existing failure" rationalization** — test infrastructure is part of the ship condition. An agent MUST NOT use "pre-existing failure", "already broken before my change", "baseline failure", or any equivalent rationalization to justify proceeding past a test failure, verification mismatch, or pipeline gate FAIL. The agent owns the pipeline state at entry; any failure present at entry must be remediated before proceeding.

All failures are agent-owned. Remediation is the default action. Escalation is only permitted after verified remediation failure — never as a first response, never as a shortcut.


### [critical-rules-066] Terminology Standardization — all context references must use standardized vocabulary
All references to "context budget", "context cost", and "context awareness" must use the standardized vocabulary: "orchestrator context", "sub-agent context", and "orchestrator context discipline". These terms describe operational bookkeeping for context management — they are NOT implementation complexity measures. Read [§1.1 Terminology Standardization](guidelines/020-go-prohibitions.md). CHANGELOG entries and historical references are exempt.


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

---
