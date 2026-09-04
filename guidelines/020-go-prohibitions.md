---
trigger_on: GO, prohibited, forbidden, never do, soliciting, solicitation
tier: 1
load_when: sub-agent
---

# GO Prohibitions

## 1. What GO Is Not & Self-Authorization Prohibitions

### 🚫 NEVER DO

- **ABSOLUTE PROHIBITION: The agent must never write the word "GO" as a standalone token, line, or heading in any response.** This includes standalone lines (`GO`), Markdown headings (`## GO`), phase labels (`GO - Phase 2`), acknowledgements, transition markers, or narrative labels. Any use of "GO" in agent output (including `<UPDATE>` blocks, tool parameters, or chat text) is a protocol violation and does NOT constitute authorization. The only permitted use is inside a quoted/code-fenced example illustrating a prohibited pattern. To acknowledge authorization, use a full sentence (e.g., "Authorization received.") — never a bare "GO".
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
- **🚫 Interpretive questions are explanation-only, never modification authorization.** A user asking "why is X here?", "what does Y do?", or any interpretive question MUST be answered with explanation. The agent MUST NOT:
  - Delete or untrack files mentioned in the question
  - Edit files mentioned in the question
  - Propose changes in response to the question
  
  File modification in response to an interpretive question is a CRITICAL VIOLATION. Only explicit "change this" or "fix this" language authorizes modification.
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

### Authorization Scope Parsing & Halt Rules (Tier-1)

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
- **"GO" requires unambiguous scope; clarify only when ambiguous.** If the user types "GO" (or equivalent), treat it as valid authorization ONLY when the immediate session context identifies exactly one plan/scope target.
- **Clarification gate for ambiguous "GO" only.** Ask for scope clarification only when more than one plausible plan file, phase, or implementation scope is active.
- **Pipeline-scoped "GO" phrases specify scope horizon.** "Approved #N to PR", "#N approved for plan", "approved #N through implementation" — these carry implicit scope. Read [approval-gate skill → "Authorization Scope Model"](skills/approval-gate/SKILL.md) and HALT at the specified pipeline stage.
- **Scope detection via the verb-prefix parsing table is NEVER ambiguous — the table maps every possible phrase to exactly one scope.** Do not ask the user to classify scope. "Approved #N" (no qualifier) → ALWAYS `for_analysis` scope. No clarification needed. "Approved #N to PR" → ALWAYS `for_pr` scope. The parsing table in `approval-gate` skill → Authorization Scope Model is the sole authority for scope determination.

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

**Read [approval-gate skill → "Authorization Scope Model"](skills/approval-gate/SKILL.md) for the complete verb-prefix parsing table. Read [000-critical-rules.md §Pushing Agent Intelligence Decisions](guidelines/000-critical-rules.md) for the autonomous resolution mandate. Read [000-critical-rules.md → "Structural Decision Solicitation Under for_pr Scope"](guidelines/000-critical-rules.md) for the complete enforcement, including the `question` tool prohibition under `for_pr` scope.**

### Authorization-Free Actions — No Deliberation Required

The following actions do NOT require `"approved"` or `"go"` and the agent MUST NOT deliberate over them:

- Creating GitHub Issues (specs, plans, bug reports) — Read [010-approval-gate.md §Issue Creation Is Reporting, Not Implementation](guidelines/010-approval-gate.md)
- Creating sub-issues under an approved plan — covered by plan authorization
- Posting progress comments to GitHub — permitted only through issue-operations -> comment substantive gate. Non-substantive progress (status updates, "phase complete", "implemented X") goes to chat only, never to issue comments.
- Moving issue labels — metadata operation
- Running lint/typecheck/format commands — read-only verification
- Creating feature branches — see `git-workflow` skill pre-work (requires `for_implementation` or above)
- Creating `observe/*` scratch branches — see `git-workflow --task pre-work` (permitted under `for_analysis`, MUST discard before HALT)

If the action is in this list, proceed immediately without requesting or deliberating over authorization.


---

## 1.1 Orchestrator Context Discipline (Demoted — Tier-2)

Orchestrator/sub-agent context mechanics, the three context mandates, authorization-free actions, `for_analysis` self-assignment rules, and the inline-work/dispatch-gate rules are governed in their Tier-2 home. Read [022-orchestrator-context-discipline.md](022-orchestrator-context-discipline.md) for the full rules before dispatching or routing pipeline work to sub-agents.

## 1.6 Discussion Mode Mandates (Demoted — Tier-2)

Discussion-mode rules — the `question` tool prohibition, pigeon-holing ban, single-topic discipline, brainstorming default, live-tool-call verification, and the research card catalogue procedure — are governed in their Tier-2 home. Read [025-discussion-mode.md](025-discussion-mode.md) before entering or conducting any developer discussion.

## 2. Iterative Feedback & Plan Revision

- **Discussion and analysis sessions do not grant GO.** Each session starts with zero authorization for code changes.
- **GO must be explicit and literal.** Only the exact word "GO" (or unambiguous equivalent) constitutes authorization.
- **"Revise" and "update" are plan-only directives.** Requests containing "revise" (or synonyms) refer exclusively to updating the GitHub Issue spec. They never authorize code changes. "Revise plan" means update an existing issue — never make code changes for a "revise plan" or similar.
- **Plan revision invalidates all prior approvals.** Any change to an issue invalidates all previous GOs for that plan. A new explicit GO is required.
- **Plan creation after GO invalidates authorization.** If a plan is created after receiving a GO, the prior GO is invalidated. Wait for a new GO for the documented plan.

## 4. Project-Local Tool Installation (Demoted — Tier-2)

Project-local tool installation rules are governed in their Tier-2 canonical home. Read [085-project-local-tools.md](085-project-local-tools.md) before installing any build tool under `.tools/`, `.node/`, `.uv/`, or `.jdk/`.

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

### [critical-rules-009] Silent Halt Without Prompt — no spec/plan search before stopping
Halting without first searching for existing specs and plans means leaving the user to rediscover work that may already exist. Amateurs halt blind. Professional engineers search first.

### [critical-rules-042] Gate Non-Waiver Principle — "continue" does not waive mandatory gates
Every "continue" is instruction to proceed to the next step, not to skip the step. Professional engineers know that mandatory gates are structural invariants. Amateurs treat "continue" as a shortcut past quality.
