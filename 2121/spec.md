## Problem

`.opencode/guidelines/000-critical-rules.md` contains 5 categories of duplicative or harmful content that are not appropriate for a session-start preloaded file:

1. **Intro cross-references to preloaded files** — Lines 9-10 point to AGENTS.md and the guidelines directory, both already loaded in the same `opencode.jsonc` instructions array. Verified: 2 occurrences of `Read [the authoritative list` / `Read [detailed rules` at lines 9-10 (tool call: `grep -cE "Read \[the authoritative list\|Read \[detailed rules" .opencode/guidelines/000-critical-rules.md` returned `2`).
2. **Stubs pointing to preloaded guideline files** — Cross-references like `Read [§1](guidelines/020-go-prohibitions.md)` that point to guidelines loaded in the same instructions array. The rule content lives in those files, not here. Verified: 18 of the 48 `Read [` cross-references in the file point to preloaded guidelines (010, 020, 060, 065, 067, 075, 080, 090, 091, 117, 130) — tool call: `grep -cE "Read \[.*guidelines/0(10\|20\|60\|65\|67\|75\|80\|90\|91\|117\|130)" .opencode/guidelines/000-critical-rules.md` returned `18`.
3. **Skill-card-specific and task-card-specific rules** — Rules that only apply when a particular skill is dispatched, not at session start. 123 of 141 rule headers are skill-specific.
4. **Per-entry dark prose framing** — "Professional engineers... amateurs..." pattern restated in 57 rule entries. Verified by `grep -cE "Professional engineers\|amateurs" .opencode/guidelines/000-critical-rules.md` returning `57`.
5. **"Why This Matters" tables** — 10 tables that restate the FORBIDDEN/REQUIRED sections without adding rule content. Verified by `grep -cE "Why This Matters" .opencode/guidelines/000-critical-rules.md` returning `10`.

## Success Criteria

Per `.opencode/guidelines/091-incremental-build.md` and `080-code-standards.md`: document size metrics (line count, KB, word count) are NOT valid proxies for implementation complexity. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Therefore, success criteria below measure categorical content correctness, not file size.

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The two intro cross-references to AGENTS.md and the guidelines directory are absent from the file | string | `grep -cE "Read \[the authoritative list\|Read \[detailed rules" .opencode/guidelines/000-critical-rules.md` returns 0 |
| SC-2 | All `Read [` cross-references pointing to preloaded guidelines (010, 020, 060, 065, 067, 075, 080, 090, 091, 117, 130) are absent from the file body. Phase 1 covers this SC indirectly. Phase 2 covers it directly. | string | `grep -cE "Read \[.*guidelines/0(10\|20\|60\|65\|67\|75\|80\|90\|91\|117\|130)" .opencode/guidelines/000-critical-rules.md` returns 0 |
| SC-3 | Every rule listed in the "Rules to Move" table below is present in its target skill/task card with equivalent content. The "Key phrase" column shows a distinctive phrase (1-10 words) that MUST appear in the target file. Phrases come from either the rule's body (first descriptive sentence) or, for cross-reference-only rules, the rule title. Phase 1 covers this SC. | behavioral | For each (source rule, target file, key phrase) triple, run `grep -F "<key phrase>" <target file>` and confirm at least one match. The `grep -F` flag does fixed-string matching, not regex, so phrases with special characters work correctly. |
| SC-4 | Per-entry dark prose framing ("Professional engineers... amateurs...") appears fewer than 3 times in the file (file-level framing allowed, per-entry framing removed) | string | `grep -cE "Professional engineers\|amateurs" .opencode/guidelines/000-critical-rules.md` returns < 3 |
| SC-5 | "Why This Matters" tables are absent from the file (both headers and bodies) | string | `grep -cE "Why This Matters" .opencode/guidelines/000-critical-rules.md` returns 0 |
| SC-6 | The Mandate Tiering table, Interaction Rule table, and Channel-Routing Table all remain in the file. Mandate Tiering is a level-2 heading (`^##`); Interaction Rule and Channel-Routing Table are level-3 headings (`^###`) | string | `grep -qE "^## Mandate Tiering" .opencode/guidelines/000-critical-rules.md` returns 0 AND `grep -qE "^### Interaction Rule" .opencode/guidelines/000-critical-rules.md` returns 0 AND `grep -qE "^### Channel-Routing Table" .opencode/guidelines/000-critical-rules.md` returns 0 |
| SC-7 | Every rule listed in the "Universal Rules to Keep" enumeration below is present in the file with its full `### [critical-rules-NNN] <description>` header intact | string | For each of the 18 universal rule headers (full text), `grep -qF "<full header text>" .opencode/guidelines/000-critical-rules.md` returns 0. Full header text includes the bracket ID, em-dash, and description. |
| SC-8 | No rule body contains a paragraph whose tokens are a strict superset of the rule's title tokens. A "title-restating" paragraph is one where ≥80% of the title's non-stopword tokens appear in the paragraph AND the paragraph adds no new non-stopword tokens beyond the title's. Stopword list: `the, a, an, is, are, was, were, be, been, being, of, in, on, to, for, with, by, at, from, and, or, but, not, no`. | behavioral | For each remaining `### [critical-rules-NNN]` rule, extract the title text after the bracket ID, tokenize on whitespace, lowercase, strip punctuation, remove stopwords. Diff each paragraph's token set against the title's token set. If a paragraph's token set is a subset of the title's token set AND the title's set is ≥80% covered by the paragraph, the paragraph is a restatement and must be removed. |
| SC-9 | No remaining `### [critical-rules-NNN]` rule is duplicated (same full header text appears more than once) | string | `grep -E "^### \[critical-rules-" .opencode/guidelines/000-critical-rules.md \| sort \| uniq -d` returns 0 lines |
| SC-10 | The total count of `### [critical-rules-NNN]` rule headers in the file equals 18 | string | `grep -cE "^### \[critical-rules-" .opencode/guidelines/000-critical-rules.md` returns 18 |

## Rules to Move (Source → Target Mapping)

Each entry below is a unique source rule paired with exactly one target file. The "Key phrase" column provides a distinctive phrase (1-10 words) that MUST appear in the target file after the move (verified by SC-3 using `grep -F`). Phrases come from the rule's first descriptive body sentence, or — for the 7 rules whose body contains only cross-references — from the rule title. All 123 entries have a non-empty, non-placeholder phrase.

| Source rule header | Target file | Key phrase |
|---|---|---|
| `[critical-rules-007] Worktree Bypass — using stash+checkout instead of worktrees when WORKTREE_REQUIRED` | `.opencode/skills/using-git-worktrees/SKILL.md` | `Using stash+checkout means contaminating your workspace state. Professional engineers isolate` |
| `[critical-rules-007] Relative File Paths in Worktree Context — using relative paths when worktree.path is set` | `.opencode/skills/using-git-worktrees/SKILL.md` | `Relative paths in worktree mode silently target the wrong repo.` |
| `[critical-rules-030] Sub-Agents Ignoring Worktree Context — sub-agents modifying main repo instead of worktree` | `.opencode/skills/using-git-worktrees/SKILL.md` | `Sub-agents that modify the main repo instead of the worktree` |
| `[critical-rules-008] Implementing Without Verifying Against Live Documentation` | `.opencode/guidelines/075-docs-verification.md` | `Implementing from memory means implementing from training data — always` |
| `[critical-rules-009] Schema/API/Code Verification — claiming knowledge without verification` | `.opencode/guidelines/065-verification-honesty.md` | `Claiming schema compliance or API correctness without verification means you` |
| `[critical-rules-009] Verification Dishonesty — reporting memory as verified` | `.opencode/guidelines/065-verification-honesty.md` | `Reporting memory as verification means you are presenting guesses as` |
| `[critical-rules-009] Metadata-as-Evidence — workflow metadata is not evidence of implementation` | `.opencode/guidelines/065-verification-honesty.md` | `Issue state and PR merge status are process metadata, not` |
| `[critical-rules-009] Memory/Training-Data-as-Evidence — memory and training data are always stale` | `.opencode/guidelines/065-verification-honesty.md` | `Memory and training data are always stale — they represent` |
| `[critical-rules-009] Skipping verification-enforcement During Content Generation` | `.opencode/guidelines/065-verification-honesty.md` | `Generating content without verification means publishing unverified claims. Specs with` |
| `[critical-rules-015] Plan ≠ Execution — treating documentation as evidence of completion` | `.opencode/guidelines/065-verification-honesty.md` | `A plan is a map, not a destination. Treating plan` |
| `[critical-rules-009] Audience Separation — leaking internal artifacts to stakeholders` | `.opencode/skills/correspondence/SKILL.md` | `Leaking internal audit findings and raw status into stakeholder communications` |
| `[critical-rules-XXX] Posting Spec-Audit Findings as Issue Comments` | `.opencode/skills/audit/SKILL.md` | `Audit findings from spec-auditor are internal agent guidance — equivalent` |
| `[critical-rules-012] Acting on Resources Without Reading All Comments` | `.opencode/guidelines/067-context-completeness.md` | `Acting on a resource after reading only the body means` |
| `[critical-rules-009] Session Trigger Echo — parroting triggers in agent output` | `.opencode/guidelines/117-session-trigger-behavior.md` | `Parroting trigger data into agent output instead of processing it` |
| `[critical-rules-016] Skipping Post-Implementation Verification Skills` | `.opencode/skills/verification-before-completion/SKILL.md` | `Post-implementation verification skills exist to catch the defects you cannot` |
| `[critical-rules-016] Skipping review-prep After Implementation` | `.opencode/skills/git-workflow-pr/tasks/review-prep.md` | `Review prep is the last gate before your work enters` |
| `[critical-rules-016] Skipping Post-Merge Cleanup` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | `Leaving merged branches and open issues after a merge creates` |
| `[critical-rules-016] Wrong Chat Output at Halt Points` | `.opencode/skills/git-workflow/SKILL.md` | `A halt without structured output leaves the developer guessing what` |
| `[critical-rules-016] Wrong PR Body Format` | `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` | `A PR body without Summary/Outcome/Fixes structure buries the intent of` |
| `[critical-rules-016] Wrong Compare URL Base Branch` | `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` | `Using the wrong base branch in a compare URL sends` |
| `[critical-rules-016] Fabricating URLs` | `.opencode/guidelines/065-verification-honesty.md` | `Constructing URLs from template variables instead of extracting them from` |
| `[critical-rules-036] Inferring GitHub Owner from File Paths/Usernames` | `.opencode/skills/issue-operations/SKILL.md` | `Guessing `github.owner` from file paths or usernames instead of reading` |
| `[critical-rules-036] Wrong API Routing for Submodule/Sub-folder Repos` | `.opencode/skills/issue-operations/SKILL.md` | `Routing API calls for submodule repos to the parent repository` |
| `[critical-rules-platform-routing-bypass] CRITICAL VIOLATION — Platform Routing Bypass — direct `github_*`/`gitbucket-api` issue calls outside `issue-operations/platforms/`` | `.opencode/skills/issue-operations/SKILL.md` | `All `github_*` and `gitbucket-api` issue calls MUST route through the` |
| `[critical-rules-platform-api-deliberation] Platform API Deliberation Prohibited` | `.opencode/skills/issue-operations/SKILL.md` | `The `issue-operations` dispatcher resolves platform selection automatically based on `github.platform`.` |
| `[critical-rules-028] Offer-to-Edit Bypass — offering to modify files without spec` | `.opencode/guidelines/020-go-prohibitions.md` | `Offering to "fix it quickly" instead of creating a spec` |
| `[critical-rules-009] Enforcement Test Updates — guideline/skill changes without BEHAVIORAL enforcement tests` | `.opencode/guidelines/080-code-standards.md` | `Adding a guideline or skill change without a BEHAVIORAL enforcement` |
| `[critical-rules-010] Implementation Without Spec — expanding the definition` | `.opencode/guidelines/010-approval-gate.md` | `Modifying behavior, config, or enforcement without an approved spec is` |
| `[critical-rules-016] Missing Progress Reports` | `.opencode/skills/git-workflow/SKILL.md` | `Halting without structured output means leaving the developer guessing what` |
| `[critical-rules-012] Ignoring Issue Comments` | `.opencode/guidelines/067-context-completeness.md` | `Acting on an issue without reading all its comments is` |
| `[critical-rules-025] Implementation-First Gate — halting before producing deliverables` | `.opencode/skills/executing-plans/SKILL.md` | `Halting with zero deliverables means you have produced nothing but` |
| `[critical-rules-042] Single Concern Principle — every artifact addresses exactly one concern` | `.opencode/skills/programming-principles/SKILL.md` | `Professional engineers ship one concern per artifact — commits, PRs,` |
| `[critical-rules-042] Monolithic Implementation — skipping item decomposition` | `.opencode/guidelines/091-incremental-build.md` | `Professional engineers decompose work into testable items and build one` |
| `[critical-rules-042] Scope Creep — never do things outside the spec` | `.opencode/skills/programming-principles/SKILL.md` | `Professional engineers implement exactly what the spec defines — nothing` |
| `[critical-rules-010] Spec Without Investigation` | `.opencode/guidelines/010-approval-gate.md` | `Professional engineers inspect the codebase before writing a spec —` |
| `[critical-rules-010] Plan Creation Without Analytical Artifacts — bypassing the artifact gate` | `.opencode/guidelines/010-approval-gate.md` | `Professional engineers verify all 7 analytical artifacts exist before plan` |
| `[critical-rules-010] Implementing Stale or Superseded Specs` | `.opencode/guidelines/130-authority-source.md` | `Professional engineers check for superseding open issues before implementing —` |
| `[critical-rules-025] Main Agent Implements Directly` | `.opencode/skills/implementation-pipeline/SKILL.md` | `Professional orchestrators route through sub-agents — amateurs inline work and` |
| `[critical-rules-016] Bypassing Mandatory Skill Calls During Implementation` | `.opencode/skills/implementation-pipeline/SKILL.md` | `Pipeline chain: pre-work → implementation-pipeline (Trigger Dispatch Table) → verification-before-completion` |
| `[critical-rules-016] Skill Bypass = Critical Violation` | `.opencode/skills/implementation-pipeline/SKILL.md` | `Every step in pipeline chain is enforceable, not advisory. Professional` |
| `[critical-rules-016] Auditor Skills Enforcement` | `.opencode/skills/audit/SKILL.md` | `Professional engineers subject every deliverable to independent audit — amateurs` |
| `[critical-rules-011] Bug Reports Without Fix Spec` | `.opencode/skills/issue-operations/SKILL.md` | `Reporting a bug without a fix spec means you are` |
| `[critical-rules-011] Bug Discovery Does NOT Authorize Bug Fixing` | `.opencode/guidelines/010-approval-gate.md` | `Finding a bug during implementation does NOT mean you have` |
| `[critical-rules-009] Authorization-Free Actions — no deliberation required` | `.opencode/guidelines/020-go-prohibitions.md` | `Issue creation, sub-issues, progress comments, labels, lint/format all authorized per` |
| `[critical-rules-011] Symptom-Only Fix-Specs — patches without root cause analysis` | `.opencode/guidelines/010-approval-gate.md` | `Writing a fix spec that only addresses symptoms means you` |
| `[critical-rules-009] Conflating Issue References with Authorization Cascade` | `.opencode/guidelines/010-approval-gate.md` | `Only formal `github_sub_issue_write` links trigger cascade. Professional engineers only cascade` |
| `[critical-rules-027] Confirmation ≠ Authorization` | `.opencode/guidelines/020-go-prohibitions.md` | `"Yes, that's correct" ≠ authorization. Only "approved"/"go"/"#NNN approved". Amateurs treat` |
| `[critical-rules-027] Feedback ≠ Authorization — treating technical input as implementation permission` | `.opencode/guidelines/020-go-prohibitions.md` | `User engagement is collaboration, not permission. Amateurs treat feedback as` |
| `[critical-rules-042] Skipping PR for Documentation/Guideline Changes` | `.opencode/skills/git-workflow-pr/SKILL.md` | `Exception: zero files modified, or already-implemented (verified by `verify-already-implemented`). Amateurs` |
| `[critical-rules-042] Blind Conflict Resolution` | `.opencode/skills/conflict-resolution/SKILL.md` | `Resolving conflicts blindly produces broken merges. Professional engineers classify conflicts` |
| `[critical-rules-042] Engineering Mindset Required` | `.opencode/skills/engineering-approach/SKILL.md` | `Understand → Design → Verify → Communicate. Amateurs jump from` |
| `[critical-rules-016] Skipping Completion Guarantee on Workflow Halt` | `.opencode/skills/completion-core/SKILL.md` | `Call `--task completion` on current skill before halting. Amateurs abandon` |
| `[critical-rules-009] Silent Agent Termination — producing no output before stopping` | `.opencode/guidelines/020-go-prohibitions.md` | `A halt without output means leaving the developer blind. Professionals` |
| `[critical-rules-016] Skipping Interdependency Analysis for Batch Approvals` | `.opencode/guidelines/010-approval-gate.md` | `Approving batches without understanding interdependencies means approving work that silently` |
| `[critical-rules-042] Treating Branch Stacking as Optional` | `.opencode/skills/git-workflow-branch/SKILL.md` | `Skipping branch stacking means merging chaos into your commit history.` |
| `[critical-rules-016] Leaving stale todowrite state after task completion` | `.opencode/guidelines/060-tool-usage.md` | `A stale todowrite state means the next agent picks up` |
| `[critical-rules-009] Session-Verified State Trust — re-reading without state-change trigger` | `.opencode/guidelines/065-verification-honesty.md` | `Re-reading a resource that was confirmed in-session is re-reading verified` |
| `[critical-rules-009] Verification Deduplication` | `.opencode/guidelines/065-verification-honesty.md` | `Re-verifying evidence that a prior skill already collected means doubling` |
| `[critical-rules-034] Inline Screening of Authorization Sets` | `.opencode/guidelines/020-go-prohibitions.md` | `Screening authorization sets inline instead of tasking a sub-agent means` |
| `[critical-rules-009] Silent Halt Without Prompt — no spec/plan search before stopping` | `.opencode/guidelines/020-go-prohibitions.md` | `Halting without first searching for existing specs and plans means` |
| `[critical-rules-020] Soft-Passing Verification Mismatches` | `.opencode/guidelines/065-verification-honesty.md` | `Reporting "functionally equivalent" as PASS means accepting defects into the` |
| `[critical-rules-030] Skipping Clean-Room task() for Sub-Agents` | `.opencode/guidelines/060-tool-usage.md` | `Skipping clean-room task() means contaminating sub-agent context with orchestrator bias` |
| `[critical-rules-031] Skipping Pre-Flight Checks for Sub-Agents` | `.opencode/guidelines/060-tool-usage.md` | `Dispatching a sub-agent without pre-flight checks means sending a worker` |
| `[critical-rules-032] Skipping Post-Flight Checks for Sub-Agents` | `.opencode/guidelines/060-tool-usage.md` | `Accepting sub-agent results without post-flight checks means trusting instead of` |
| `[critical-rules-033] Claiming Verification Without Tool-Call Evidence in Sub-Agent Results` | `.opencode/guidelines/065-verification-honesty.md` | `Reporting verification without tool-call evidence means presenting guesses as facts.` |
| `[critical-rules-034] Inline Work — orchestrator performing file modifications without sub-agent task()` | `.opencode/guidelines/020-go-prohibitions.md` | `An orchestrator that reads files, edits files, or makes decisions` |
| `[critical-rules-035] DISPATCH_GATE Checkpoint skipped` | `.opencode/guidelines/020-go-prohibitions.md` | `Reading a SKILL.md routing section and then executing the task` |
| `[critical-rules-034] Orchestrator Inline Work = Poisoned Pipeline` | `.opencode/guidelines/020-go-prohibitions.md` | `An orchestrator that performs inline work has contaminated every artifact` |
| `[critical-rules-042] Discard on Sub-Agent Failure` | `.opencode/guidelines/020-go-prohibitions.md` | `Preserving output from a BLOCKED sub-agent means propagating contaminated state` |
| `[critical-rules-034] Tool-Recipe Task() — sub-agents as API proxies` | `.opencode/guidelines/020-go-prohibitions.md` | `Tasking a sub-agent with `github_create_pull_request` instead of "create a PR"` |
| `[critical-rules-042] Skipping Spec/Plan Coherence Gate (Pre-RED)` | `.opencode/skills/spec-creation/SKILL.md` | `Dispatching RED sub-agents without a coherence gate means your implementation` |
| `[critical-rules-042] Skipping Execution-Time Coherence Detection (RED + GREEN)` | `.opencode/skills/spec-creation/SKILL.md` | `A RED sub-agent that detects a spec/codebase contradiction but proceeds` |
| `[critical-rules-042] Gate Non-Waiver Principle — "continue" does not waive mandatory gates` | `.opencode/guidelines/020-go-prohibitions.md` | `Every "continue" is instruction to proceed to the next step,` |
| `[critical-rules-046] Mechanical-Only Audit Without Semantic and Conflict Exploration` | `.opencode/skills/audit/SKILL.md` | `Running an audit that only checks mechanical patterns means you` |
| `[critical-rules-047] VbC Fabricated PASS — reporting file existence as verified behavioral evidence` | `.opencode/skills/verification-before-completion/SKILL.md` | `Reporting that a file exists as evidence that behavior is` |
| `[critical-rules-048] Skill Pre-Read + Inline Execution — reading skill task files and executing steps manually` | `.opencode/guidelines/020-go-prohibitions.md` | `Reading a skill's task files and then inlining the steps` |
| `[critical-rules-038] Implementing Before PR Merge Boundary` | `.opencode/skills/git-workflow-pr/SKILL.md` | `Implementing a dependent phase before its PR boundary has merged` |
| `[critical-rules-042] Content Verification Before Branch Deletion` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | `Deleting a branch without verifying its content against the target` |
| `[critical-rules-042] Model-Aware Clean-Room task() for Behavioral Testing` | `.opencode/guidelines/080-code-standards.md` | `Running behavioral tests through grep and static analysis instead of` |
| `[critical-rules-pipeline-reprime] Pipeline re-priming — enforcement blocks at each skill boundary` | `.opencode/skills/implementation-pipeline/SKILL.md` | `Pipeline stage transitions require re-encountering an enforcement block restating procedural` |
| `[critical-rules-044] Preloading Sub-Agent Context — task()ing with pre-determined file paths/line numbers/outcomes` | `.opencode/guidelines/020-go-prohibitions.md` | `Handing a sub-agent pre-determined file paths, line numbers, and expected` |
| `[critical-rules-043] Universal Re-Task Mandate — no inline fallback on sub-agent failure` | `.opencode/guidelines/020-go-prohibitions.md` | `When a sub-agent fails, inline fallback means the failure contaminates` |
| `[critical-rules-051] Skipping mandatory submodule tagging at pre-work` | `.opencode/skills/git-workflow-branch/SKILL.md` | `Skipping submodule tagging means the starting SHA becomes unreachable after` |
| `[critical-rules-018] Pipeline-Scoped Authorization with Hard HALT at Scope Boundary` | `.opencode/guidelines/010-approval-gate.md` | `Pipeline-Scoped Authorization with Hard HALT at Scope Boundary` |
| `[critical-rules-hard-fail] Hard Failure Discipline — FAIL is a hard gate, never reclassifiable` | `.opencode/guidelines/065-verification-honesty.md` | `A FAIL signal at any pipeline stage (auditor verdict, sub-agent` |
| `[critical-rules-test-integrity] Test Integrity Mandate — No Lobotomizing Tests` | `.opencode/guidelines/080-code-standards.md` | `Removing or weakening a behavioral (semantic, functional) test assertion to` |
| `[critical-rules-sc-lobotomy] CRITICAL VIOLATION — SC Lobotomy Prohibition — removing, weakening, deferring, skipping, or blocking success criteria` | `.opencode/skills/spec-creation/SKILL.md` | `Removing or weakening a success criterion from a spec to` |
| `[critical-rules-BEH-EV] Runtime-Behavioral Evidence Classification Gate — structural evidence for behavioral changes is EVIDENCE_TYPE_MISMATCH` | `.opencode/guidelines/080-code-standards.md` | `The question "does this change affect runtime behavior?" is substrate-determined` |
| `[critical-rules-linters-advisory] All linters are advisory only — no auto-modify` | `.opencode/guidelines/060-tool-usage.md` | `All linters (current and future) MUST run in read-only/report-only mode.` |
| `[critical-rules-063] Orchestrator Context Lean — orchestrator holds routing metadata only` | `.opencode/guidelines/020-go-prohibitions.md` | `The orchestrator holds routing metadata only (worktree.path, github.owner, github.repo, authorization_scope,` |
| `[critical-rules-065] Result Contract Frugality — result contracts limited to routing-significant data` | `.opencode/guidelines/020-go-prohibitions.md` | `Result contracts carry only routing-significant data (status, finding_summary, artifact_path, blocker_reason).` |
| `[critical-rules-dispatch-gate-canonical] Canonical Dispatch String Violation — orchestrator uses custom prompt after reading canonical dispatch string` | `.opencode/guidelines/020-go-prohibitions.md` | `After loading a skill and reading its Trigger Dispatch Table,` |
| `[critical-rules-071] Revision-Not-Replacement — defective sub-agent deliverables MUST be revised, not replaced` | `.opencode/guidelines/020-go-prohibitions.md` | `When a sub-agent returns a defective deliverable (spec, plan, or` |
| `[critical-rules-072] No-Inline-Fix — orchestrator MUST NOT inline-fix defective sub-agent output` | `.opencode/guidelines/020-go-prohibitions.md` | `When a sub-agent returns a defective deliverable, the orchestrator MUST` |
| `[critical-rules-XXX] Derivation Provenance — every element must have a consumer or first-principles justification` | `.opencode/guidelines/080-code-standards.md` | `Adding a parameter, field, method, class, configuration key, contract entry,` |
| `[critical-rules-005] Direct-Branch Default — feature branch without worktree is the norm` | `.opencode/skills/git-workflow-branch/SKILL.md` | `Default: `git checkout -b feature/X` in main repo. Worktree opt-in` |
| `[critical-rules-005] Skipping Git Pre-Check — working without feature branch` | `.opencode/skills/git-workflow-branch/SKILL.md` | `Must verify git state and create feature branch before any` |
| `[critical-rules-024] Uncommitted/Unpushed Changes After Implementation` | `.opencode/skills/finishing-a-development-branch/SKILL.md` | `Uncommitted/Unpushed Changes After Implementation` |
| `[critical-rules-023] Missing AI Co-Authored Attribution` | `.opencode/guidelines/080-code-standards.md` | `Format: `Co-authored with AI: <AgentName> (<ModelId>)`. Read [080-code-standards.md](guidelines/080-code-standards.md).` |
| `[critical-rules-023] Hardcoded Identity Values in Skills and Guidelines` | `.opencode/guidelines/080-code-standards.md` | `Use `<AgentName>`, `<ModelId>`, `<github.owner>` placeholders. Read [080-code-standards.md](guidelines/080-code-standards.md).` |
| `[critical-rules-018] Sub-issue Structure Bypass — multi-task plans` | `.opencode/skills/issue-operations-sub-issues/SKILL.md` | `Phases require sub-issue linkage. Read [issue-operations skill](skills/issue-operations/SKILL.md) → `link-sub-issue` task.` |
| `[critical-rules-018] Stopping After Single Phase in Multi-Task Plan` | `.opencode/guidelines/010-approval-gate.md` | `Complete ALL phases, report ONCE, HALT ONCE. Read [approval-gate skill](skills/approval-gate/SKILL.md).` |
| `[critical-rules-013] Sub-issue Closure Timing` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | `Sub-issue Closure Timing` |
| `[critical-rules-013] Assuming Closed Issues Are Verified` | `.opencode/guidelines/010-approval-gate.md` | `Assuming Closed Issues Are Verified` |
| `[critical-rules-041] Listing Merged PRs Without Calling Cleanup` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | `"check prs" = cleanup trigger → `git-workflow --task check-pr`.` |
| `[critical-rules-019] Creating PRs Without Explicit Instruction` | `.opencode/guidelines/010-approval-gate.md` | `Exception: `for_pr` scope authorizes PR creation.` |
| `[critical-rules-018] Ignoring Spec-to-Plan Approval Cascade` | `.opencode/guidelines/010-approval-gate.md` | `Spec approved + faithful plan exists = plan auto-approved.` |
| `[critical-rules-013] Closing Issues Before PR Merge` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | `Closing Issues Before PR Merge` |
| `[critical-rules-013] Parent/Child Issue Closure` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | `Close children first, then parent. Read [git-workflow --task cleanup](skills/git-workflow/SKILL.md).` |
| `[critical-rules-039] Parent Issue Left Open After All Children Closed` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | `Must close parent plan when all children verified complete.` |
| `[critical-rules-039] Process Gaps Are Bugs — completed issues not auto-closed` | `.opencode/skills/verification-before-completion/SKILL.md` | `Process Gaps Are Bugs — completed issues not auto-closed` |
| `[critical-rules-070] Issue Closure Outside Cleanup Workflow — agent MUST NOT close GitHub Issues through direct API calls` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | `The agent MUST NOT call `github_issue_write(method=update, state=closed)` or equivalent on` |
| `[critical-rules-018] Sub-issue Linkage Verification — phase count mismatch` | `.opencode/skills/issue-operations-sub-issues/SKILL.md` | `Sub-issue Linkage Verification — phase count mismatch` |
| `[critical-rules-023] Posting AI-Authored Content Without Byline Verification` | `.opencode/guidelines/080-code-standards.md` | `Verify byline presence before ANY API call posting AI-authored content.` |
| `[critical-rules-037] Structural Decision Solicitation Under for_pr Scope` | `.opencode/guidelines/010-approval-gate.md` | `No `question` tool for structural decisions when `halt_at >= pr_created`.` |
| `[critical-rules-049] Standalone Submodule-Only PR Creation During Cleanup` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | `Creating a PR whose sole purpose is to update a` |
| `[critical-rules-039] Parent Issue Left Open After All Children Closed` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | `Must close parent plan when all children verified complete.` |
| `[critical-rules-040] Un-Squashed PR — creating single-issue PR with multiple commits` | `.opencode/skills/git-workflow-pr/SKILL.md` | `Single-issue: exactly 1 commit. Work branch: N commits = N` |
| `[critical-rules-041] Listing Merged PRs Without Calling Cleanup` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | `"check prs" = cleanup trigger → `git-workflow --task check-pr`.` |
| `[critical-rules-060] Functional/Behavioral Test Substitution Prohibition — substituting structural/grep/metadata checks when behavioral tests cannot execute` | `.opencode/guidelines/080-code-standards.md` | `"Functional test" and "behavioral test" are synonymous — both verify` |
| `[critical-rules-PR-ORG] Stacked PR Is the Only Valid Organization` | `.opencode/skills/git-workflow-pr/SKILL.md` | `Creating N branches for N issues under any authorization scope` |
| `[critical-rules-accountability-ownership] Accountability/Remediation Ownership Model` | `.opencode/skills/audit/SKILL.md` | `ALL failures are agent-owned. Remediation is the default action. Escalation` |
| `[critical-rules-066] Terminology Standardization — all context references must use standardized vocabulary` | `.opencode/guidelines/020-go-prohibitions.md` | `All references to "context budget", "context cost", and "context awareness"` |

**Total rules to move: 123** (verified count from the table above; tool-call evidence: `grep -cE "^### \[critical-rules-" .opencode/guidelines/000-critical-rules.md` returned 141 total headers, 18 of which are universal per the Keep list below, leaving 123 skill-specific).

**Unique target files: 30**

## Universal Rules to Keep

These rules apply to ALL agents at ALL times, not just when a specific skill is dispatched. They MUST remain in `000-critical-rules.md` with their full `### [critical-rules-NNN] <description>` headers intact.

| Rule ID | Title |
|---|---|
| `[critical-rules-006] CRITICAL VIOLATION` | Question-as-Authorization — treating rhetorical/complaint questions as implementation authorization |
| `[critical-rules-006] CRITICAL VIOLATION` | Routing-bypass rationalization as self-authorization variant |
| `[critical-rules-026] CRITICAL VIOLATION` | Deleting Branches/Stashes Improperly |
| `[critical-rules-026] CRITICAL VIOLATION` | Git Configuration and Destructive Command Authorization |
| `[critical-rules-006] CRITICAL VIOLATION` | Pushing Agent Intelligence Decisions to the User |
| `[critical-rules-029] CRITICAL VIOLATION` | Non-Idempotent API Mutations |
| `[critical-rules-029] CRITICAL VIOLATION` | Inline Mutation Scripts |
| `[critical-rules-021] CRITICAL VIOLATION` | Secret Exfiltration in Agent Output |
| `[critical-rules-022] CRITICAL VIOLATION` | Issue Body Erasure — replacing with shorter content |
| `[critical-rules-006] CRITICAL VIOLATION` | for_pr Gap-Fill Halt — asking developer for structural decisions scope model resolves |
| `[critical-rules-045] CRITICAL VIOLATION` | Creating .opencode/.opencode/ Nested Directories |
| `[critical-rules-052] CRITICAL VIOLATION` | `git rm` and file deletion require spec + authorization |
| `[critical-rules-merge] CRITICAL VIOLATION` | Human-Only Merge — agents MUST NOT merge PRs |
| `[critical-rules-XXX] CRITICAL VIOLATION` | Dispatching SKILL.md to sub-agents — category error |
| `[critical-rules-XXX] CRITICAL VIOLATION` | Starting work from non-trunk-tip state — orchestrator MUST dispatch pre-work before any file modification |
| `[critical-rules-XXX] CRITICAL VIOLATION` | Pre-commit/pre-push submodule pointer verification — MUST verify submodule pointer updates are included in commits |
| `[critical-rules-XXX] CRITICAL VIOLATION` | Direct `github_issue_write` for spec content bypassing spec-creation pipeline |
| `[critical-rules-stop] CRITICAL VIOLATION` | "stop" command triggers terminal halt — zero output, zero tool calls, zero proposals |

**Total universal rules to keep: 18** (verified count; tool-call evidence: regex match against the unique rule headers).

## Implementation Phases

### Phase 1: Embed moved rules into target files
For each (source rule, target file, key phrase) entry in the "Rules to Move" table:
- Read the rule body from `000-critical-rules.md`
- Append the rule body to the target file in an appropriate location
- Verify the key phrase appears in the target file via `grep -F "<key phrase>" <target file>` (must return ≥1 line)
- This phase covers SC-3 and indirectly reduces the count of `Read [` cross-refs in 000 once moved rules no longer reference the preloaded guidelines from 000

### Phase 2: Remove intro cross-references and stubs
- Delete the two intro cross-references to AGENTS.md and the guidelines directory (covers SC-1)
- For each `Read [` cross-ref pointing to a preloaded guideline that remains in a moved rule's body, replace the cross-ref with the rule's own text or remove the cross-ref entirely (covers SC-2)

### Phase 3: Remove moved rules from 000-critical-rules.md
For each moved rule, delete the `### [critical-rules-NNN]` block from the source file. After all removals, the file must contain exactly 18 `### [critical-rules-NNN]` headers with no duplicates (covers SC-9, SC-10).

### Phase 4: Remove per-entry dark prose and Why This Matters tables
- Replace per-entry "Professional engineers... amateurs..." framing with direct rule statements
- Delete all "Why This Matters" tables (both headers and bodies)
- Preserve file-level framing if it appears in frontmatter or intro
- Covers SC-4 and SC-5

### Phase 5: Remove redundant FORBIDDEN/REQUIRED subsections
- For each remaining universal rule, check whether the FORBIDDEN/REQUIRED subsection adds content beyond the rule header
- Use the SC-8 token-superset definition to identify restating paragraphs
- Delete any paragraph that qualifies as a title-restatement (covers SC-8)

### Phase 6: Verify all SCs
Run each SC's verification method and confirm PASS. Specifically:
- SC-1..SC-5: grep-based absence checks
- SC-6: grep-based presence check (3 distinct regexes)
- SC-7: 18 fixed-string header matches
- SC-8: token-superset diff for each remaining rule body
- SC-9: duplicate header check
- SC-10: total header count == 18

## Files Affected

- `.opencode/guidelines/000-critical-rules.md` — 123 rules removed; 18 universal rules preserved
- 30 target files (listed in the "Rules to Move" table above) — receive moved rules

## Risks

- **Lost rules**: If a rule is moved but the target file is not updated, the rule disappears from the agent's instruction set. Mitigation: SC-3 requires behavioral verification that each moved rule's key phrase appears in its target file.
- **Over-removal**: Removing a rule that turns out to be universal could leave a safety gap. Mitigation: The "Universal Rules to Keep" enumeration is explicit; any rule not in that table and not in the "Rules to Move" table must be classified before deletion.
- **Duplicate preservation**: If SC-9 is not verified, the file could end up with duplicate headers. Mitigation: SC-9 explicitly checks for duplicates.

## Alternatives Considered

| Alternative | Reason rejected |
|---|---|
| Leave 000-critical-rules.md as-is | The session-start preloaded file should contain only universal rules; the current 141-header / 1211-line file wastes context budget. |
| Archive the file to a non-preloaded reference path | The 18 universal rules in 000 must remain preloaded; the file is not entirely removable. |
| Split into multiple preloaded files | Increases the preloaded instructions array size, which compounds the original problem. |
| Use file size as success criteria | Rejected per `.opencode/guidelines/091-incremental-build.md` — implementation correctness is measured by tested verified correct code operations, not by file size. |

## Dependencies

- None. This is a self-contained refactoring of existing content.

## Policy References

- `.opencode/guidelines/091-incremental-build.md` — Document size metrics are NOT valid proxies for implementation complexity
- `.opencode/guidelines/080-code-standards.md` — Same prohibition; implementation correctness is measured by tested verified correct code operations
- `.opencode/guidelines/130-authority-source.md` — Code is the authoritative source; documentation must match code reality
