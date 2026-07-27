---
trigger_on: GO, prohibited, forbidden, never do, soliciting, solicitation
tier: 1
load_when: sub-agent
---

# GO Prohibitions

## 1. What GO Is Not & Self-Authorization Prohibitions

### 🚫 NEVER DO

- **ABSOLUTE PROHIBITION: The agent must never write the word "GO" as a standalone token, line, or heading in any response.** This includes standalone lines (`GO`), Markdown headings (`## GO`), phase labels (`GO - Phase 2`), acknowledgements, transition markers, or narrative labels. Any use of "GO" in agent output (including `<UPDATE>` blocks, tool parameters, or chat text) is a protocol violation and does NOT constitute authorization. The only permitted use is inside a quoted/code-fenced example illustrating a prohibited pattern. To acknowledge authorization, use a full sentence (e.g., "Authorization received.") — never a bare "GO".
- **No `echo` or `printf` commands — ever.** The agent is absolutely prohibited from running `echo`, `printf`, or any equivalent shell output command for any purpose. This includes:
  - **Output for Narration**: Signalling waiting states, confirming completion, or self-narration.
  - **File Operations**: Bypassing `.opencode/tools` tools via `printf "..." > file.md` or `echo "..." >> file.md`.
  - **Script Injection**: Writing logic into temp scripts via shell redirection.
- **No "awaiting GO" or pending-state markers — anywhere, ever.** The agent is absolutely prohibited from using the phrase "awaiting GO", "waiting for GO", "pending GO", "awaiting explicit phase approval", "awaiting approval", "pending approval", or any equivalent pending-state marker.
- **NEVER prompt or solicitation for authorization.** The agent is absolutely prohibited from asking, prompting, nudging, or inviting the user to issue "GO", "approved", or any other approval token in any form.
- **NEVER prompt the user with THINKING and expect an answer of any kind.** Internal reasoning must never be surfaced as a user-facing prompt.
- **No leading or pushy authorization questions.** The agent must not ask "May I proceed?", "Shall I continue?", "Ready for me to start?", or any similar request for permission to begin implementation.
- **OFFENSIVE TEXT EXAMPLES — NEVER USE:**
  - "Ready for authorization to implement?"
  - "Ready to proceed with implementation?"
  - "Shall I begin implementation?"
  - "Waiting for approval to continue."
  - "Let me know when you're ready for me to start."
  - "Say 'approved' or 'go' when ready."
  - "Awaiting authorization to implement."
  - "**Awaiting authorization to begin Phase X.** Say 'approved' or 'go' when ready."
  - "Awaiting your approval."
  - "Ready when you are."
- **Discussion conclusions are NOT authorization.** Verbal agreement, consensus, or opinion expressed in discussion does NOT constitute explicit authorization:
  - "Sounds like we need to X" → discussion consensus, NOT "do X"
  - "I think the answer is Y" → opinion, NOT "implement Y"
  - "So we're going with approach Z" → conclusion, NOT "start Z"
  - "That makes sense, let's do it" → verbal agreement, NOT explicit authorization
  - "This looks like it should be X" → observation, NOT "make it X"
- **Questions are NOT authorization.** "Should I do X?" and "Would you like me to X?" are questions seeking permission, not receiving it. Never act on a question — wait for explicit authorization.
- **Rhetorical and complaint questions are NOT authorization.** "How can we work if we never merge into the trunk?" is a complaint about process, NOT authorization to merge. "Why hasn't X been done?" is a question, NOT authorization to do X. Treat ALL questions as observation-only.
- **SILENTLY HALT after every task/report.** Factual reporting is permitted, but it must NEVER be followed by a prompt for next steps.
- **🚫 "Why" questions are observation-only, never authorization.** A user asking "why is X structured this way?", "why does Y exist?", or any question beginning with "why" is seeking explanation, not requesting changes. The agent MUST answer the question factually. Any file modification, deletion, or edit triggered by a "why" question is a CRITICAL VIOLATION. The agent MUST NOT:
  - Delete or modify files mentioned in a "why" question
  - Propose changes in response to a "why" question
  - Treat "why" as an implicit "fix this"

  **Correct response to "why" questions:** Answer the question. If the user wants changes, they will explicitly say so.
- **"discuss" triggers a hard gate blocking implementation proposals.** When the user says "discuss" (or unambiguous equivalent like "let's talk about", "I want to discuss", "thoughts on"), the agent MUST NOT propose implementation, offer to implement, or suggest code changes. The agent MUST stay in discussion mode — answering questions, exploring options, and providing analysis. Any "want me to implement", "should I fix", "I can change" or equivalent implementation proposal following a "discuss" prompt is a CRITICAL VIOLATION.
- **Never name the next phase or action in a halt message.** Halt messages must be factual statements about what was completed — never forward-looking references to what comes next.
- **No "offer to edit" patterns.** The agent MUST NOT offer to edit, update, modify, or fix a file directly. Instead, create a spec or bug report. Patterns like "Want me to update X?", "Shall I fix this?", "I can change X to Y" are PROHIBITED — they bypass the spec-first workflow.
- **Never self-answer a solicitation.** Pose no questions that you then answer yourself to bypass authorization.
- **NEVER suggest parallel execution as a valid default approach.** Stacking is prerequisite; parallel is opportunistic. Agents must not present parallelism as an equally valid option.
- **No silent halt without search+prompt.** When no spec/plan exists for an implementation request, the agent MUST NOT simply halt. It must search GitHub Issues for existing candidates, present them with URLs, and offer create-or-select before halting. A silent halt with no search and no candidate presentation is a critical violation — Read [000-critical-rules.md §Silent Halt Without Prompt](guidelines/000-critical-rules.md).
<!-- Issue #25: Authorization Solicitation Regression — Success Criteria: Update guidelines/020-go-prohibitions.md with additional prohibited output patterns -->
- **Solicitation detection gate — pre-output check for "want me to" patterns.** Before producing any output containing "want me to", "should I", "I can implement", "I can change", "shall I", or similar implementation-offer patterns, the agent MUST check: did the user explicitly ask for this? If the user did not ask for implementation, the agent MUST suppress the output. This gate fires before every response — it is not optional.
- **No instructional language in blocker reports.** When the workflow is blocked, the report must state the blocker factually — it must never embed instructions, suggestions, or forward-looking guidance that could be read as an authorization prompt. Examples of prohibited patterns:
  - "To resolve this, please approve the spec first."
  - "You can say 'approved' to continue."
  - "Once you've reviewed, let me know and I'll proceed."
  - "Waiting for you to give the go-ahead."
  - "Please provide authorization before I continue."
- **No implied authorization framing.** The agent must not frame status reports as requests or frame blockers as needing user action in a way that solicits a response. Correct format: "Blocked: no approved spec found for #N." Incorrect format: "We're blocked — can you approve #N so I can continue?"
- **No forward-looking references in completion reports.** Completion reports must describe what was done, never what should happen next. This prevents the report from reading as an implicit request for the next authorization step.
- **"Continue" and session momentum do NOT waive mandatory pipeline gates.** Cumulative "continue" messages ("please continue", "go on", "proceed") and repeated calls in a single session do NOT authorize skipping mandatory pipeline gates (coherence gate, verification-before-completion, finishing-a-development-branch checklist, review-prep). Only pipeline-scoped authorization (`approved #N to PR`, `approved #N for plan`) changes `halt_at`. Session momentum — the fact that the developer said "continue" multiple times in one session — is NOT authorization. The agent MUST NOT treat repeated "continue" messages or the cumulative context of a long session as evidence that the developer wants gates bypassed. Mandatory gates are structural invariants; "continue" is instruction to proceed to the next step, not to skip the step.
- **Resource cost is NEVER a factor in verification decisions.** The agent MUST NOT consider execution cost, command count, model speed, session duration, or any resource metric when deciding whether to run verification steps. Behavioral enforcement tests MUST run via `opencode run` against real AI models — no substitution with grep, static analysis, pattern matching, or metadata inspection. The cost of `opencode run` is ZERO in the decision calculus:
  - 🚫 FORBIDDEN: "Running behavioral tests requires too many opencode commands" as a justification for any action
  - 🚫 FORBIDDEN: "This would take too long" as a justification for skipping or shortcutting verification
  - 🚫 FORBIDDEN: Substituting grep/static analysis/pattern matching for `opencode run`
  - 🚫 FORBIDDEN: Counting commands, estimating runtime, or measuring context as factors in correctness decisions
  - 🚫 FORBIDDEN: "Spot-checking" as a substitute for full behavioral test execution
  - 🚫 FORBIDDEN: Any sentence containing both a cost/speed/resource noun AND a verification-skip verb
- **NEVER substitute structural evidence for behavioral/functional evidence when the test cannot run.** If the behavioral test is unexecutable, the SC is FAIL. No exceptions.
- **NEVER escalate without attempting remediation first. NEVER skip remediation.**

**Cost is measured in defect-discovery-latency, not model roundtrips.** Read [065-verification-honesty.md](guidelines/065-verification-honesty.md) §Cost Model for the complete death spiral / break dynamics — the DDL rationale lives there. This file governs prohibitions only; the *why* lives in 065.


---

## 1.1 Orchestrator Context Discipline

### Overview

The orchestrator and sub-agents have different context management patterns. These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures.

> **Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Document size metrics (word count, line count, token count, byte-dispatch formulas) are NOT valid proxies for implementation complexity.**

### Context Flow

**Orchestrator context:** Holds routing metadata only — `worktree.path`, `github.owner`, `github.repo`, `authorization_scope`, `halt_at`, `pr_strategy`, `pipeline_phase`, `pipeline_history` (phase names only). Task file contents, analysis artifacts, and verification results go to sub-agents or disk.

**Sub-agent context:** Disposable — sub-agents read task files, source files, run analysis tools, and execute tests freely. Their context is discarded after returning a result contract.

**Result contracts:** Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence artifacts go to disk.

### The Three Mandates

#### 1. Orchestrator Context Lean

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

#### 2. Sub-Agent Context Generosity

The sub-agent is ENCOURAGED to expand into its context:
- Read task files fully — that's what sub-agent context is for
- Read source files, run analysis tools, execute tests — burn context freely
- Write full evidence artifacts to disk

#### 3. Result Contract Frugality

The sub-agent returns only:

| Field | Required | Purpose |
|-------|----------|---------|
| `status` | Yes | DONE / BLOCKED / OVERFLOW |
| `finding_summary` | Yes | 1-3 sentences of routing-significant output |
| `artifact_path` | Yes | Path to full evidence on disk |
| `blocker_reason` | If BLOCKED | Why blocked |

Everything else stays in the sub-agent's context and is discarded.

---

## 1.2 Interpretive Questions Are Explanation-Only — Never Modification Authorization

**🚫 Interpretive questions are explanation-only, never modification authorization.** A user asking "why is X here?", "what does Y do?", or any interpretive question MUST be answered with explanation. The agent MUST NOT:
- Delete or untrack files mentioned in the question
- Edit files mentioned in the question
- Propose changes in response to the question

File modification in response to an interpretive question is a CRITICAL VIOLATION. Only explicit "change this" or "fix this" language authorizes modification.

---

### Authorization-Free Actions — No Deliberation Required

<!-- Issue #99: Authorization-Free Actions — Signal asymmetry fix -->

The following actions do NOT require `"approved"` or `"go"` and the agent MUST NOT deliberate over them:

- Creating GitHub Issues (specs, plans, bug reports) — Read [010-approval-gate.md §Issue Creation Is Reporting, Not Implementation](guidelines/010-approval-gate.md)
- Creating sub-issues under an approved plan — covered by plan authorization
- Posting progress comments to GitHub — permitted only through issue-operations -> comment substantive gate. Non-substantive progress (status updates, "phase complete", "implemented X") goes to chat only, never to issue comments.
- Moving issue labels — metadata operation
- Running lint/typecheck/format commands — read-only verification
- Creating feature branches — see `git-workflow` skill pre-work (requires `for_implementation` or above)
- Creating `observe/*` scratch branches — see `git-workflow --task pre-work` (permitted under `for_analysis`, MUST discard before HALT)

If the action is in this list, proceed immediately without requesting or deliberating over authorization.

### `for_analysis` Scope — Self-Assignment Rules

`for_analysis` is the ONLY scope an agent may self-assign. It is the default floor scope when no authorization is given.

#### Self-Assignment Conditions

An agent may self-assign `for_analysis` when:
- No authorization has been given in the current session
- The user asked a question, reported a bug, or made a factual claim without authorization language
- The agent needs to investigate, read files, or create issues

Self-assignment means: operate under the `for_analysis` allowlist/blocklist until explicit authorization is received.

#### 🚫 `for_analysis` Branch Restrictions

Under `for_analysis` scope:

- **`feature/*` and `spec/*` branches are BLOCKED.** Creating these branches requires `for_implementation` or above.
- **`observe/*` branches ARE permitted.** Naming convention: `observe/<topic>` (e.g., `observe/parsing-bug`).
- **`observe/*` branches MUST be discarded before HALT.** Never leave an `observe/` branch in the repo. Delete it with `git branch -D observe/<topic>` before the halt message.
- **No commits to the trunk** (this is always prohibited regardless of scope).

#### Why `observe/` Branches Exist

`observe/` branches allow the agent to create throwaway scratch branches for read-only investigation work:
- Testing a hypothesis about code behavior
- Running a throwaway script to check data
- Examining git history or file structure in a clean context

These branches are NOT for implementation — they are ephemeral scratch space. The agent MUST NOT leave them behind.

- **"GO" requires unambiguous scope; clarify only when ambiguous.** If the user types "GO" (or equivalent), treat it as valid authorization ONLY when the immediate session context identifies exactly one plan/scope target.
- **Clarification gate for ambiguous "GO" only.** Ask for scope clarification only when more than one plausible plan file, phase, or implementation scope is active.
- **Pipeline-scoped "GO" phrases specify scope horizon.** "Approved #N to PR", "#N approved for plan", "approved #N through implementation" — these carry implicit scope. Read [approval-gate skill → "Authorization Scope Model"](skills/approval-gate/SKILL.md) and HALT at the specified pipeline stage.
- **Scope detection via the verb-prefix parsing table is NEVER ambiguous — the table maps every possible phrase to exactly one scope.** Do not ask the user to classify scope. "Approved #N" (no qualifier) → ALWAYS `for_analysis` scope. No clarification needed. "Approved #N to PR" → ALWAYS `for_pr` scope. The parsing table in `approval-gate` skill → Authorization Scope Model is the sole authority for scope determination.

### ✅ ALWAYS DO

- **Verify actual codebase state before acting.** When a GO names a specific phase, verify the actual codebase state of that phase's deliverables before taking any action — regardless of plan markers.
- **SILENTLY HALT after a verified-complete phase.** If verification confirms a named phase is already fully and correctly implemented, report the verified findings and HALT without prompting.
- **HARD HALT at scope boundary.** When `halt_at` is set from pipeline-scoped authorization, the agent MUST stop at that pipeline stage. `halt_at == plan_created` means stop after plan creation; `halt_at == pr_created` means PR creation is authorized. Proceeding past `halt_at` without re-authorization is a critical violation.
- **Parse authorization phrases for scope.** "Approved #N" (no scope qualifier) = `for_analysis`. "Approved #N to PR" = `for_pr`. "Approved #N for plan" = `for_plan`. Read [approval-gate skill](skills/approval-gate/SKILL.md) → "Authorization Scope Model" for the complete verb-prefix parsing table.
- **Every halt MUST produce a status message.** If the agent stops, it MUST output what was completed, what was attempted, and why it stopped. Zero output before stopping is a critical violation.
- **Search issues before halting on missing spec/plan.** When an implementation request lacks a matching spec or plan:
  1. Search GitHub Issues using label filters: `[SPEC]`, `[SPEC-FIX]`
  2. Search local `.issues/{N}/plan.md` files for plan artifacts (plans are local-only, not GitHub Issues)
  3. Search GitHub Issues using keyword matching against the request target
  4. If candidates found: present all candidates with URLs, offer user a choice to select one or create a new spec
  5. If no candidates found: present the failure state ("No existing spec/plan found for [topic]"), offer to create a new spec
  6. Only after search+presentation: HALT, but the halt message now includes the search results
- **The orchestrator NEVER performs inline work.** ALL file reads, file edits, file writes, analysis, verification, and decision-making MUST be delegated to clean-room sub-agents. The orchestrator ONLY tasks sub-agents via task(), receives result contracts, and routes to the next pipeline step. Zero inline file operations are permitted in the main agent context.

EXCEPTION — Skill routing metadata: Reading a loaded SKILL.md's Trigger Dispatch Table and Invocation section in the orchestrator's own context is NOT "inline work" or "reading a file." It is routing metadata consumption — the orchestrator must read these sections to determine which task card to dispatch and what canonical dispatch string to use. The orchestrator dispatches the task card (`tasks/<name>.md`), not the skill card (SKILL.md), to the sub-agent.

| Artifact | File | Consumer | Content | Action |
|----------|------|----------|---------|--------|
| Skill Card | SKILL.md | Orchestrator | Routing metadata (Trigger Dispatch Table, Invocation, DISPATCH_GATE) | Load via skill(), read in own context, do NOT dispatch |
| Task Card | tasks/<name>.md | Sub-agent | Execution procedure (entry criteria, steps, exit criteria) | Dispatch via task() using canonical string from Invocation |
- **Orchestrator inline work irreversibly poisons the pipeline — full restart required.** When the orchestrator performs inline work (reading files, running analysis, making decisions instead of task()ing sub-agents), the entire pipeline is irreversibly poisoned. The orchestrator MUST restart from `verify-authorization` with ALL state discarded — no caching, no carryover, no partial recovery. A poisoned pipeline produces contaminated deliverables that inherit the orchestrator's preloaded bias through every downstream sub-agent. This is a NON-WAIVABLE hard gate — no authorization, scope, or developer instruction can override the restart requirement. Read [000-critical-rules.md §Orchestrator Inline Work = Poisoned Pipeline](guidelines/000-critical-rules.md). **The pipeline restart applies to pipeline state (work state files, cached results, sub-agent output). It does NOT apply to published artifacts (issues, plans, specs) — those are edited in place.**
- **Discard all work on sub-agent failure before re-task.** When a sub-agent returns `status: BLOCKED` or fails, ALL work produced by that sub-agent MUST be discarded before re-task. The sub-agent's failure contaminates its output — the cause of the failure and the cause of any incorrect output are not distinguishable. Preserving partial output and re-tasking with it risks propagating contaminated state. Re-task with original scoped context only — the re-task sub-agent starts from the pre-failure branch state. This is a NON-WAIVABLE hard gate — no authorization, scope, or developer instruction can override the discard requirement. Read [000-critical-rules.md §Discard on Sub-Agent Failure](guidelines/000-critical-rules.md). **This discard requirement applies to pipeline execution artifacts (sub-agent output, work state files, cached results, temp files). It does NOT apply to published tracking documents (issue bodies, plan files, spec files, comments) — those are edited in place to fix defects.**
- **When an issue body, plan file, or spec file has a content defect, the correct action is to edit the body to fix the defect. Closing the issue and recreating is the last resort, not the first.**
- **"Continue" does NOT waive mandatory pipeline gates.** Cumulative "continue" messages ("please continue", "go on", "proceed") and session momentum do NOT waive mandatory gates (coherence gate, verification-before-completion, finishing-a-development-branch checklist, review-prep). Only pipeline-scoped authorization (`approved #N to PR`, `approved #N for plan`) changes `halt_at`. Every mandatory gate fires on EVERY implementation pass regardless of how many "continue" messages preceded it. "Continue" means "proceed to the next step" — it does NOT mean "skip the step." This is a NON-WAIVABLE hard gate — no authorization, scope, or developer instruction can override mandatory gate execution. Read [000-critical-rules.md §Gate Non-Waiver Principle](guidelines/000-critical-rules.md).
- **Cost-blind universal — all decisions.** Sub-agent task() and tool calls are near-zero cost compared to undiscovered defects. The agent MUST NEVER skip a tool call, verification step, or sub-agent task() to save resources. This prohibition applies to ALL agent decisions: verification, pipeline execution, sub-agent dispatch, research depth, message count, and user-facing output length. Correctness is the only success metric — there is no score for speed, brevity, or economy. A fast wrong answer is strictly worse than a slow correct one. This is a NON-WAIVABLE hard gate — no authorization, scope, or developer instruction can override this requirement. Read [000-critical-rules.md §Tier 1 Mandate: Correctness over economy](guidelines/000-critical-rules.md).
<!-- Issue #262: Model-Aware Behavioral Testing — Success Criteria: Mandate scope-limited-by-default behavioral testing -->
- **Scope-limited behavioral testing by default.** When running behavioral enforcement tests, the agent MUST default to scope-limited execution (changed scenarios only, named scenario, or tag-filtered). Full behavioral suite runs are permitted ONLY when model speed permits or when explicitly requested by the developer. Run `ollama-probe hw` to assess hardware before deciding full-suite feasibility. Running the full suite by default when a scope-limited run suffices uses orchestrator context unnecessarily — the orchestrator's routing-only discipline applies to pipeline dispatch, not to verification scope.
  - 🚫 FORBIDDEN: Running any full behavioral test suite — the `run-all.sh` script MUST NOT exist. All behavioral tests MUST be scope-limited to individual scenarios, `--changed`, or `--tag` filters
  - 🚫 FORBIDDEN: Defaulting to full behavioral suite without verifying model speed permits it
  - ✅ REQUIRED: Default to `--changed` when there are uncommitted guideline/skill changes
  - ✅ REQUIRED: Default to `--tag` matching the current work concern when no changed files
  - ✅ REQUIRED: Assess hardware (`ollama-probe hw`) before running full suite — only proceed if VRAM ≥ 8 GB and at least one local model ≥ 7B is installed
- **Functional/behavioral test substitution is FORBIDDEN.** When a behavioral/functional test cannot be executed (model unavailable, timeout, infrastructure failure), the agent MUST report FAIL — NEVER substitute grep, string matching, metadata checks, pattern scanning, or file-existence checks. "Functional test" and "behavioral test" are synonymous in this rule.
- **Remediate before escalating.** Escalation is only permitted after verified remediation failure. Skipping remediation is not a valid choice.
<!-- #862,#863,#864: Critical-rules-049 standalone submodule-only PR prohibition — CRITICAL VIOLATION -->
- **NEVER create a submodule-only PR in ANY context, for ANY reason (Tier 1 — CRITICAL VIOLATION).** When the parent repo has dirty submodule pointer(s) (`git status` shows modified submodules), the agent MUST NOT create a feature branch + PR solely to update those pointers. This applies during cleanup, implementation, PR creation, or any other workflow stage. **NO trunk commits either** — the dirty pointer(s) are left dirty, period. Submodule pointers are restored to trunk tip during the next pre-work cycle via the tag-based hash permanence system. Read [git-workflow cleanup task](skills/git-workflow/SKILL.md) Step 1.7 for the complete prohibition.
  - 🚫 FORBIDDEN: `git checkout -b feature/submodule-pointer-*` and opening a PR
  - 🚫 FORBIDDEN: Any PR whose only changed files are submodule pointer updates (regardless of submodule count)
  - 🚫 FORBIDDEN: Committing dirty pointer(s) to the trunk
  - 🚫 FORBIDDEN: Rationalizing "this is just a pointer update, not real code"
  - 🚫 FORBIDDEN: Using critical-rules-049 (submodule-only-PR prohibition) as a rationalization to skip `git-workflow --task cleanup` dispatch on "pr merged" triggers. The prohibition applies to PR creation only — it does NOT exempt cleanup dispatch.
  - ✅ CORRECT: Leave dirty pointer(s) untouched — they resolve on next pre-work cycle

## 1.5 Soliciting Authorization for Already-Authorized Phrases — CRITICAL VIOLATION

**⚠️ Asking for confirmation or clarification after receiving a pipeline-scoped authorization phrase is a CRITICAL GUIDELINE VIOLATION.**

The verb-prefix parsing table in `approval-gate` skill → Authorization Scope Model is the single source of truth for scope determination. When authorization text matches a parseable pattern (`approved`, `approved for pr`, `approved for plan`, `approved for implementation`, `approved for spec`, `approved for review`, `approved to PR`, etc.), the agent MUST parse the scope and proceed without asking for confirmation or clarification. "Approved #N" with no qualifier self-assigns `for_analysis` scope.

**Scope detection via the verb-prefix parsing table is NEVER ambiguous.** The table maps every possible phrase to exactly one scope. This is a deterministic function — no clarification needed, no judgment required.

| Prohibited Pattern | Why It Violates |
| -- | -- |
| "Should I proceed?" | Authorization already given; asking re-solicits it |
| "Shall I begin?" | Same as above |
| "Ready to proceed?" | Same as above |
| "How should we handle this?" | The parsing table resolves it — no agent judgment needed |
| Using `question` tool to ask about scope | The table is deterministic; no user input needed |

| ✅ REQUIRED | 🚫 FORBIDDEN |
| -- | -- |
| Parse scope from verb-prefix table, proceed with pipeline chain | Ask user "should I proceed with the full workflow?" |
| Accept unambiguous authorization at face value | Treat authorization as needing confirmation |
| Resolve `for_pr`, `for_plan`, `for_implementation`, `for_spec` autonomously | Ask "is this approved to PR or just to implementation?" |

**Read [approval-gate skill → "Authorization Scope Model"](skills/approval-gate/SKILL.md) for the complete verb-prefix parsing table. Read [000-critical-rules.md §Pushing Agent Intelligence Decisions](guidelines/000-critical-rules.md) for the autonomous resolution mandate. Read [000-critical-rules.md → "Structural Decision Solicitation Under for_pr Scope"](guidelines/000-critical-rules.md) for the complete enforcement, including the `question` tool prohibition under `for_pr` scope.** **AUTHORITY: Read [000-critical-rules.md §Structural Decision Solicitation Under for_pr Scope](guidelines/000-critical-rules.md)** (this line is a reference only)

## 1.6 Discussion Mode Mandates

### 🚫 NEVER DO

- **Never use the `question` tool.** Structured multi-option prompts (e.g., "Which approach: A, B, or C?") are forbidden. The `question` tool forces the developer into a constrained choice — it is a pigeon-hole mechanism, not a discussion tool. All discussion must be open-ended.
- **Never pigeon-hole in natural language either.** Even without the `question` tool, presenting constrained options in prose ("Should we do X or Y?") is the same anti-pattern. Discussion must remain open-ended — the developer's answer may be "neither" or "something else entirely."
- **Never mix topics.** Every discussion addresses exactly one topic at a time. Multi-topic messages must be decomposed into single-topic turns. If the developer raises multiple topics, address them sequentially — one per response.
- **Never default to structured output.** Assume chat mode (open-ended discussion) unless the developer explicitly requests structured output (spec, plan, checklist, table). Brainstorming is the default — structured output is the exception.
- **Never answer without a live tool call.** Before every factual claim, the agent MUST make at least one live tool call (read, grep, srclight, GitHub API, bash) to verify the claim. Training data is not a source — it is a liability.
- **Never trust training data.** Assume training data is full of errors, omissions, and hallucinations. Discard it entirely. Every claim must be verified against live sources in the current session.
- **Never trust metadata without a live API call.** Issue state, PR merge status, labels, and all other metadata are assumed stale and false until verified by a live API call in the current session. Cached or remembered metadata is not evidence.
- **Never halt discussion to research.** Research during active discussions is expected — dispatch a sub-agent to investigate while continuing the conversation. The agent does not need to halt the discussion to look something up.
- **No skill-routing solicitation after authorization.** After receiving any unambiguous authorization phrase (`approved`, `go`, `approved for X`, etc.), the agent MUST NOT ask "should I invoke skill Y?" or present options for which skill to invoke. The authorization→skill mapping is deterministic: `approved` → `approval-gate` skill. The agent autonomously dispatches without soliciting the routing decision. This prohibition applies to ALL authorization modes — not just `for_pr` scope.

  | Prohibited Pattern | Why It Violates |
  |--|--|
  | "Should I invoke a skill to handle this authorization?" | The mapping is deterministic; no agent judgment needed |
  | "Should I invoke approval-gate?" | Same class as scope solicitation — the answer is always the same |
  | Using `question` tool with "Invoke skill" vs "Proceed directly" options | No decision branch exists — invoke the mandatory skill |

### ✅ ALWAYS DO

- Use open-ended questions and natural language for all discussion.
- Decompose multi-topic messages into single-topic turns.
- Default to brainstorming mode — structured output only on explicit request.
- Make a live tool call before every factual claim.
- Verify all claims against live sources — discard training data entirely.
- Verify all metadata with a live API call before acting on it.
- Dispatch research sub-agents during active discussions without halting.
- **Research card catalogue — `.issues/research-cards/`**: Before dispatching research, glob `*.md` in `.issues/research-cards/`, grep frontmatter for the exact research question. If an active card exists with acceptable confidence (`confidence >= 0.7`), skip the research dispatch and return cached findings. If no matching card or stale/insufficient confidence, dispatch research. After research, create or update the card with new findings, confidence score, source URLs, and tags.

## 2. Iterative Feedback & Plan Revision

- **Discussion and analysis sessions do not grant GO.** Each session starts with zero authorization for code changes.
- **GO must be explicit and literal.** Only the exact word "GO" (or unambiguous equivalent) constitutes authorization.
- **"Revise" and "update" are plan-only directives.** Requests containing "revise" (or synonyms) refer exclusively to updating the GitHub Issue spec. They never authorize code changes. "Revise plan" means update an existing issue — never make code changes for a "revise plan" or similar.
- **Plan revision invalidates all prior approvals.** Any change to an issue invalidates all previous GOs for that plan. A new explicit GO is required.
- **Plan creation after GO invalidates authorization.** If a plan is created after receiving a GO, the prior GO is invalidated. Wait for a new GO for the documented plan.

## 3. Specialized Execution Gates

## 4. Node.js Prohibition in Python/Java Projects

**DETESTABLE**: Installing Node.js in a Python-only or Java-only environment is absolutely prohibited. This introduces an unnecessary runtime dependency that pollutes the ecosystem and creates maintenance burden.

### 🚫 NEVER DO

- **NEVER install Node.js globally or locally** on Python-only or Java-only projects.
- **NEVER use NPX** to run packages — NPX requires Node.js runtime.
- **NEVER add Node.js-based tools to project dependencies.**
- **NEVER suggest npm packages as solutions** in Python/Java contexts.
- **NEVER use Node.js-based formatters, linters, or tooling** when native alternatives exist.

### Context

This rule applies universally to:

- **Python projects**: Use `uv`, `pip`, `ruff`, `pytest` — never npm/pnpm/yarn.
- **Java projects**: Use Maven/Gradle, JVM tooling — never npm/pnpm/yarn.
- **Projects with mixed languages**: Isolate Node.js to its designated frontend/service layer.

### ✅ ALLOWED

- **Docker containers that internally use Node.js** — Node.js runs inside container, not on host.
- **Pure Python alternatives** — `githubkit` instead of `@octokit/rest`, `httpx` instead of `axios`.
- **Dedicated frontend repositories** where Node.js IS the correct tool for that codebase.
- **MCP servers via Docker** — Node.js isolated in container only.

### Why This Is Critical

- **Security**: Node.js ecosystem has known supply-chain attack vectors.
- **Dependency bloat**: Adds unnecessary runtime and package manager complexity.
- **Maintenance burden**: Mixed language projects require additional CI/CD configuration.
- **Ecosystem mismatch**: npm packages don't integrate with Python/Java tooling chains.
- **Team friction**: Requires developers to install/maintain Node.js on their machines.

## 4.5 Project-Local Tool Installation Pattern

When a project requires build tools not available on the host system (e.g., `tsc`, `esbuild`, `sass`), the agent MAY install them **project-locally** as an exception to §4. Read [085-project-local-tools.md](guidelines/085-project-local-tools.md) for the full rules.

### Key Rules

- **Primary pattern**: `.tools/<tool>/` (e.g., `.tools/node/`, `.tools/jdk/`)
- **Acceptable alternatives**: `.node/`, `.uv/`, `.jdk/`
- **MUST be in `.gitignore`** — never tracked
- **MUST use PATH-prefixed invocation**: `PATH=.tools/node/bin:$PATH npx tsc --noEmit`
- **MUST NOT modify project config** files (`pyproject.toml`, `package.json`, etc.)
- **MUST be system-isolated**: never install to `~/.local/`, `/usr/local/`, etc.
- **MUST be cleanable**: `rm -rf .tools/` removes everything
- **MUST NOT add to shell profiles** (`~/.bashrc`, `~/.profile`, etc.)

______________________________________________________________________

## 5. Multi-task Plan Without Sub-issues — CRITICAL VIOLATION

**⚠️ Implementing a multi-task plan without sub-issues is a CRITICAL GUIDELINE VIOLATION.** Sub-issues are children of the plan, not the spec.

### 🚫 ABSOLUTE PROHIBITION

- **NEVER implement a multi-task plan without verified sub-issue structure**
- **NEVER proceed **to implementation** when `get_sub_issues` on the plan returns empty array for multi-task plans **without auto-creating sub-issues first****
- **NEVER assume markdown checkboxes = task tracking**
- **NEVER create sub-issues under the spec** — sub-issues belong to the plan

### ✅ MANDATORY

**Read [issue-operations skill → `link-sub-issue` task](skills/issue-operations/SKILL.md) for the complete auto-create workflow, single-task exemption, database ID requirement, and phase-level structure. Sub-issue verification is consolidated into `approval-gate --task verify-authorization` Step 5 as the single readiness check.**

Key points:

- Sub-issues at PHASE level under the plan, not step level
- Single-task plans are exempt from sub-issue requirement
- All multi-task plans MUST have sub-issues before implementation begins
- Auto-creating sub-issues for an approved multi-task plan is a pre-implementation setup step covered by the plan's authorization. No separate authorization is required.
- After auto-creating sub-issues, the agent proceeds with implementation immediately (no re-authorization needed).

### 6. Progressive Iterative Implementation — Rollback on Verification Failure

**MANDATORY:** When a pipeline step's verification fails AND a checkpoint tag exists for the prior PASS state, the orchestrator MUST:

1. Report pre-rollback diagnostics (`git status`, `git diff --stat`)
2. Read pipeline state to determine `$LAST_PASS_PHASE`
3. Execute rollback: `git reset --hard <parent>/checkpoint/<issue>/phase-<LAST_PASS_PHASE>-<submodule> && git submodule update --init`
4. Read restored pipeline state
5. Re-dispatch the failed step with original dispatch parameters

**Authorization source:** Read [000-critical-rules.md §Checkpoint Rollback Exception](guidelines/000-critical-rules.md).

**No checkpoint:** First-step failure. Run `git checkout .`, re-dispatch from current state.

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

### [critical-rules-028] Offer-to-Edit Bypass — offering to modify files without spec
Offering to "fix it quickly" instead of creating a spec is the oldest shortcut in the book — and the fastest path to unreviewed, unapproved changes polluting your codebase. Professional engineers write a spec when a fix is identified. The ONLY permitted action when a fix is found is spec creation — nothing else, no exceptions, no "just this once."


### [critical-rules-009] Authorization-Free Actions — no deliberation required
Issue creation, sub-issues, progress comments, labels, lint/format all authorized per spec scope model. Professional engineers execute pre-authorized actions without hesitation — amateurs stop and ask for permission on every trivial step. Feature branches (`feature/*`, `spec/*`) are NOT authorization-free — they require `for_implementation` or above scope. Read [010-approval-gate.md](guidelines/010-approval-gate.md).


### [critical-rules-027] Confirmation ≠ Authorization
"Yes, that's correct" ≠ authorization. Only "approved"/"go"/"#NNN approved". Amateurs treat confirmation as permission. Professionals wait for explicit authorization.


### [critical-rules-027] Feedback ≠ Authorization — treating technical input as implementation permission
User engagement is collaboration, not permission. Amateurs treat feedback as an implementation ticket. Professionals wait for explicit authorization. Read [§1](guidelines/020-go-prohibitions.md).


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


### [critical-rules-034] Inline Screening of Authorization Sets
Screening authorization sets inline instead of tasking a sub-agent means introducing contamination from your own reasoning. Professional engineers always task `screen-issue` sub-agents — amateurs inline and call it fast.


### [critical-rules-009] Silent Halt Without Prompt — no spec/plan search before stopping
Halting without first searching for existing specs and plans means leaving the user to rediscover work that may already exist. Amateurs halt blind. Professional engineers search first.


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
