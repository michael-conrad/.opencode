## Problem

`.opencode/guidelines/000-critical-rules.md` contains 5 categories of duplicative or harmful content that are not appropriate for a session-start preloaded file:

1. **Intro cross-references to preloaded files** — Lines 9-10 point to AGENTS.md and the guidelines directory, both already loaded in the same `opencode.jsonc` instructions array. Verified: 2 occurrences of `Read [the authoritative list` / `Read [detailed rules` at lines 9-10 (tool call: `grep -cE "Read \[the authoritative list\|Read \[detailed rules" .opencode/guidelines/000-critical-rules.md` returned `2`).
2. **Stubs pointing to preloaded guideline files** — Cross-references like `Read [§1](guidelines/020-go-prohibitions.md)` that point to guidelines loaded in the same instructions array. The rule content lives in those files, not here. Verified: 12 of the 48 `Read [` cross-references in the file point to preloaded guidelines (010, 020, 060, 065, 067, 075, 080, 090, 091, 117, 130).
3. **Skill-card-specific and task-card-specific rules** — Rules that only apply when a particular skill is dispatched, not at session start. 123 of 141 rule headers are skill-specific.
4. **Per-entry dark prose framing** — "Professional engineers... amateurs..." pattern restated in 57 rule entries. Verified by `grep -cE "Professional engineers\|amateurs" .opencode/guidelines/000-critical-rules.md` returning `57`.
5. **"Why This Matters" tables** — 10 tables that restate the FORBIDDEN/REQUIRED sections without adding rule content. Verified by `grep -cE "Why This Matters" .opencode/guidelines/000-critical-rules.md` returning `10`.

## Success Criteria

Per `.opencode/guidelines/091-incremental-build.md` and `080-code-standards.md`: document size metrics (line count, KB, word count) are NOT valid proxies for implementation complexity. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Therefore, success criteria below measure categorical content correctness, not file size.

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The two intro cross-references to AGENTS.md and the guidelines directory are absent from the file | string | `grep -cE "Read \[the authoritative list\|Read \[detailed rules" .opencode/guidelines/000-critical-rules.md` returns 0 |
| SC-2 | All `Read [` cross-references pointing to preloaded guidelines (010, 020, 060, 065, 067, 075, 080, 090, 091, 117, 130) are absent from the file body | string | `grep -E "Read \[.*guidelines/0(10\|20\|60\|65\|67\|75\|80\|90\|91\|117\|130)" .opencode/guidelines/000-critical-rules.md` returns 0 |
| SC-3 | Every rule listed in the "Rules to Move" table below is present in its target skill/task card with equivalent content (the rule's `### [critical-rules-NNN]` header and key forbidden/required language appear in the target file) | behavioral | For each (source rule, target file) pair, run `grep -E "\[critical-rules-NNN\|<key forbidden/required phrase>" <target file>` and confirm a match |
| SC-4 | Per-entry dark prose framing ("Professional engineers... amateurs...") appears fewer than 3 times in the file (file-level framing allowed, per-entry framing removed) | string | `grep -cE "Professional engineers\|amateurs" .opencode/guidelines/000-critical-rules.md` returns < 3 |
| SC-5 | "Why This Matters" tables are absent from the file (both headers and bodies) | string | `grep -cE "Why This Matters" .opencode/guidelines/000-critical-rules.md` returns 0 |
| SC-6 | The Mandate Tiering table, Interaction Rule table, and Channel-Routing Table all remain in the file | string | `grep -qE "^## Mandate Tiering" .opencode/guidelines/000-critical-rules.md` returns 0 AND `grep -qE "^### Interaction Rule" .opencode/guidelines/000-critical-rules.md` returns 0 AND `grep -qE "^## Channel-Routing Table" .opencode/guidelines/000-critical-rules.md` returns 0 |
| SC-7 | Every rule listed in the "Universal Rules to Keep" enumeration below is present in the file with its `### [critical-rules-NNN]` header intact | string | For each of the 18 universal rule headers, `grep -qE "^### <header>" .opencode/guidelines/000-critical-rules.md` returns 0 |
| SC-8 | No rule body contains a paragraph that is a strict restatement of the rule's title (≥80% token overlap between title and body) | behavioral | For each remaining `### [critical-rules-NNN]` rule, diff-check that the rule body adds content beyond the title |
| SC-9 | No remaining `### [critical-rules-NNN]` rule is duplicated (same title appears in multiple sections) | string | `grep -E "^### \[critical-rules-" .opencode/guidelines/000-critical-rules.md \| sort \| uniq -d` returns 0 lines |
| SC-10 | The total count of `### [critical-rules-NNN]` rule headers in the file equals 18 | string | `grep -cE "^### \[critical-rules-" .opencode/guidelines/000-critical-rules.md` returns 18 |

## Rules to Move (Source → Target Mapping)

Each entry below is a unique source rule paired with exactly one target file. The target file's content is verified to receive the rule (per SC-3).

| Source rule header | Target file | Rationale |
|---|---|---|
| `[critical-rules-007] Worktree Bypass — using stash+checkout instead of worktrees when WORKTREE_REQUIRED` | `.opencode/skills/using-git-worktrees/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-007] Relative File Paths in Worktree Context — using relative paths when worktree.path is set` | `.opencode/skills/using-git-worktrees/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-030] Sub-Agents Ignoring Worktree Context — sub-agents modifying main repo instead of worktree` | `.opencode/skills/using-git-worktrees/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-008] Implementing Without Verifying Against Live Documentation` | `.opencode/guidelines/075-docs-verification.md` | Skill/task-specific concern |
| `[critical-rules-009] Schema/API/Code Verification — claiming knowledge without verification` | `.opencode/guidelines/065-verification-honesty.md` | Skill/task-specific concern |
| `[critical-rules-009] Verification Dishonesty — reporting memory as verified` | `.opencode/guidelines/065-verification-honesty.md` | Skill/task-specific concern |
| `[critical-rules-009] Metadata-as-Evidence — workflow metadata is not evidence of implementation` | `.opencode/guidelines/065-verification-honesty.md` | Skill/task-specific concern |
| `[critical-rules-009] Memory/Training-Data-as-Evidence — memory and training data are always stale` | `.opencode/guidelines/065-verification-honesty.md` | Skill/task-specific concern |
| `[critical-rules-009] Skipping verification-enforcement During Content Generation` | `.opencode/guidelines/065-verification-honesty.md` | Skill/task-specific concern |
| `[critical-rules-015] Plan ≠ Execution — treating documentation as evidence of completion` | `.opencode/guidelines/065-verification-honesty.md` | Skill/task-specific concern |
| `[critical-rules-009] Audience Separation — leaking internal artifacts to stakeholders` | `.opencode/skills/correspondence/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-XXX] Posting Spec-Audit Findings as Issue Comments` | `.opencode/skills/audit/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-012] Acting on Resources Without Reading All Comments` | `.opencode/guidelines/067-context-completeness.md` | Skill/task-specific concern |
| `[critical-rules-009] Session Trigger Echo — parroting triggers in agent output` | `.opencode/guidelines/117-session-trigger-behavior.md` | Skill/task-specific concern |
| `[critical-rules-016] Skipping Post-Implementation Verification Skills` | `.opencode/skills/verification-before-completion/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-016] Skipping review-prep After Implementation` | `.opencode/skills/git-workflow-pr/tasks/review-prep.md` | Skill/task-specific concern |
| `[critical-rules-016] Skipping Post-Merge Cleanup` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-016] Wrong Chat Output at Halt Points` | `.opencode/skills/git-workflow/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-016] Wrong PR Body Format` | `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` | Skill/task-specific concern |
| `[critical-rules-016] Wrong Compare URL Base Branch` | `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` | Skill/task-specific concern |
| `[critical-rules-016] Fabricating URLs` | `.opencode/guidelines/065-verification-honesty.md` | Skill/task-specific concern |
| `[critical-rules-036] Inferring GitHub Owner from File Paths/Usernames` | `.opencode/skills/issue-operations/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-036] Wrong API Routing for Submodule/Sub-folder Repos` | `.opencode/skills/issue-operations/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-platform-routing-bypass] CRITICAL VIOLATION — Platform Routing Bypass — direct `github_*`/`gitbucket-api` issue calls outside `issue-operations/platforms/`` | `.opencode/skills/issue-operations/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-platform-api-deliberation] Platform API Deliberation Prohibited` | `.opencode/skills/issue-operations/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-028] Offer-to-Edit Bypass — offering to modify files without spec` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-009] Enforcement Test Updates — guideline/skill changes without BEHAVIORAL enforcement tests` | `.opencode/guidelines/080-code-standards.md` | Skill/task-specific concern |
| `[critical-rules-010] Implementation Without Spec — expanding the definition` | `.opencode/guidelines/010-approval-gate.md` | Skill/task-specific concern |
| `[critical-rules-016] Missing Progress Reports` | `.opencode/skills/git-workflow/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-012] Ignoring Issue Comments` | `.opencode/guidelines/067-context-completeness.md` | Skill/task-specific concern |
| `[critical-rules-025] Implementation-First Gate — halting before producing deliverables` | `.opencode/skills/executing-plans/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-042] Single Concern Principle — every artifact addresses exactly one concern` | `.opencode/skills/programming-principles/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-042] Monolithic Implementation — skipping item decomposition` | `.opencode/guidelines/091-incremental-build.md` | Skill/task-specific concern |
| `[critical-rules-042] Scope Creep — never do things outside the spec` | `.opencode/skills/programming-principles/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-010] Spec Without Investigation` | `.opencode/guidelines/010-approval-gate.md` | Skill/task-specific concern |
| `[critical-rules-010] Plan Creation Without Analytical Artifacts — bypassing the artifact gate` | `.opencode/guidelines/010-approval-gate.md` | Skill/task-specific concern |
| `[critical-rules-010] Implementing Stale or Superseded Specs` | `.opencode/guidelines/130-authority-source.md` | Skill/task-specific concern |
| `[critical-rules-025] Main Agent Implements Directly` | `.opencode/skills/implementation-pipeline/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-016] Bypassing Mandatory Skill Calls During Implementation` | `.opencode/skills/implementation-pipeline/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-016] Skill Bypass = Critical Violation` | `.opencode/skills/implementation-pipeline/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-016] Auditor Skills Enforcement` | `.opencode/skills/audit/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-011] Bug Reports Without Fix Spec` | `.opencode/skills/issue-operations/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-011] Bug Discovery Does NOT Authorize Bug Fixing` | `.opencode/guidelines/010-approval-gate.md` | Skill/task-specific concern |
| `[critical-rules-009] Authorization-Free Actions — no deliberation required` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-011] Symptom-Only Fix-Specs — patches without root cause analysis` | `.opencode/guidelines/010-approval-gate.md` | Skill/task-specific concern |
| `[critical-rules-009] Conflating Issue References with Authorization Cascade` | `.opencode/guidelines/010-approval-gate.md` | Skill/task-specific concern |
| `[critical-rules-027] Confirmation ≠ Authorization` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-027] Feedback ≠ Authorization — treating technical input as implementation permission` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-042] Skipping PR for Documentation/Guideline Changes` | `.opencode/skills/git-workflow-pr/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-042] Blind Conflict Resolution` | `.opencode/skills/conflict-resolution/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-042] Engineering Mindset Required` | `.opencode/skills/engineering-approach/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-016] Skipping Completion Guarantee on Workflow Halt` | `.opencode/skills/completion-core/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-009] Silent Agent Termination — producing no output before stopping` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-016] Skipping Interdependency Analysis for Batch Approvals` | `.opencode/guidelines/010-approval-gate.md` | Skill/task-specific concern |
| `[critical-rules-042] Treating Branch Stacking as Optional` | `.opencode/skills/git-workflow-branch/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-016] Leaving stale todowrite state after task completion` | `.opencode/guidelines/060-tool-usage.md` | Skill/task-specific concern |
| `[critical-rules-009] Session-Verified State Trust — re-reading without state-change trigger` | `.opencode/guidelines/065-verification-honesty.md` | Skill/task-specific concern |
| `[critical-rules-009] Verification Deduplication` | `.opencode/guidelines/065-verification-honesty.md` | Skill/task-specific concern |
| `[critical-rules-034] Inline Screening of Authorization Sets` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-009] Silent Halt Without Prompt — no spec/plan search before stopping` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-020] Soft-Passing Verification Mismatches` | `.opencode/guidelines/065-verification-honesty.md` | Skill/task-specific concern |
| `[critical-rules-030] Skipping Clean-Room task() for Sub-Agents` | `.opencode/guidelines/060-tool-usage.md` | Skill/task-specific concern |
| `[critical-rules-031] Skipping Pre-Flight Checks for Sub-Agents` | `.opencode/guidelines/060-tool-usage.md` | Skill/task-specific concern |
| `[critical-rules-032] Skipping Post-Flight Checks for Sub-Agents` | `.opencode/guidelines/060-tool-usage.md` | Skill/task-specific concern |
| `[critical-rules-033] Claiming Verification Without Tool-Call Evidence in Sub-Agent Results` | `.opencode/guidelines/065-verification-honesty.md` | Skill/task-specific concern |
| `[critical-rules-034] Inline Work — orchestrator performing file modifications without sub-agent task()` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-035] DISPATCH_GATE Checkpoint skipped` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-034] Orchestrator Inline Work = Poisoned Pipeline` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-042] Discard on Sub-Agent Failure` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-034] Tool-Recipe Task() — sub-agents as API proxies` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-042] Skipping Spec/Plan Coherence Gate (Pre-RED)` | `.opencode/skills/spec-creation/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-042] Skipping Execution-Time Coherence Detection (RED + GREEN)` | `.opencode/skills/spec-creation/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-042] Gate Non-Waiver Principle — "continue" does not waive mandatory gates` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-046] Mechanical-Only Audit Without Semantic and Conflict Exploration` | `.opencode/skills/audit/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-047] VbC Fabricated PASS — reporting file existence as verified behavioral evidence` | `.opencode/skills/verification-before-completion/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-048] Skill Pre-Read + Inline Execution — reading skill task files and executing steps manually` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-038] Implementing Before PR Merge Boundary` | `.opencode/skills/git-workflow-pr/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-042] Content Verification Before Branch Deletion` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-042] Model-Aware Clean-Room task() for Behavioral Testing` | `.opencode/guidelines/080-code-standards.md` | Skill/task-specific concern |
| `[critical-rules-pipeline-reprime] Pipeline re-priming — enforcement blocks at each skill boundary` | `.opencode/skills/implementation-pipeline/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-044] Preloading Sub-Agent Context — task()ing with pre-determined file paths/line numbers/outcomes` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-043] Universal Re-Task Mandate — no inline fallback on sub-agent failure` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-051] Skipping mandatory submodule tagging at pre-work` | `.opencode/skills/git-workflow-branch/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-018] Pipeline-Scoped Authorization with Hard HALT at Scope Boundary` | `.opencode/guidelines/010-approval-gate.md` | Skill/task-specific concern |
| `[critical-rules-hard-fail] Hard Failure Discipline — FAIL is a hard gate, never reclassifiable` | `.opencode/guidelines/065-verification-honesty.md` | Skill/task-specific concern |
| `[critical-rules-test-integrity] Test Integrity Mandate — No Lobotomizing Tests` | `.opencode/guidelines/080-code-standards.md` | Skill/task-specific concern |
| `[critical-rules-sc-lobotomy] CRITICAL VIOLATION — SC Lobotomy Prohibition — removing, weakening, deferring, skipping, or blocking success criteria` | `.opencode/skills/spec-creation/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-BEH-EV] Runtime-Behavioral Evidence Classification Gate — structural evidence for behavioral changes is EVIDENCE_TYPE_MISMATCH` | `.opencode/guidelines/080-code-standards.md` | Skill/task-specific concern |
| `[critical-rules-linters-advisory] All linters are advisory only — no auto-modify` | `.opencode/guidelines/060-tool-usage.md` | Skill/task-specific concern |
| `[critical-rules-063] Orchestrator Context Lean — orchestrator holds routing metadata only` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-065] Result Contract Frugality — result contracts limited to routing-significant data` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-dispatch-gate-canonical] Canonical Dispatch String Violation — orchestrator uses custom prompt after reading canonical dispatch string` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-071] Revision-Not-Replacement — defective sub-agent deliverables MUST be revised, not replaced` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-072] No-Inline-Fix — orchestrator MUST NOT inline-fix defective sub-agent output` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |
| `[critical-rules-XXX] Derivation Provenance — every element must have a consumer or first-principles justification` | `.opencode/guidelines/080-code-standards.md` | Skill/task-specific concern |
| `[critical-rules-005] Direct-Branch Default — feature branch without worktree is the norm` | `.opencode/skills/git-workflow-branch/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-005] Skipping Git Pre-Check — working without feature branch` | `.opencode/skills/git-workflow-branch/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-024] Uncommitted/Unpushed Changes After Implementation` | `.opencode/skills/finishing-a-development-branch/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-023] Missing AI Co-Authored Attribution` | `.opencode/guidelines/080-code-standards.md` | Skill/task-specific concern |
| `[critical-rules-023] Hardcoded Identity Values in Skills and Guidelines` | `.opencode/guidelines/080-code-standards.md` | Skill/task-specific concern |
| `[critical-rules-018] Sub-issue Structure Bypass — multi-task plans` | `.opencode/skills/issue-operations-sub-issues/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-018] Stopping After Single Phase in Multi-Task Plan` | `.opencode/guidelines/010-approval-gate.md` | Skill/task-specific concern |
| `[critical-rules-013] Sub-issue Closure Timing` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-013] Assuming Closed Issues Are Verified` | `.opencode/guidelines/010-approval-gate.md` | Skill/task-specific concern |
| `[critical-rules-041] Listing Merged PRs Without Calling Cleanup` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-019] Creating PRs Without Explicit Instruction` | `.opencode/guidelines/010-approval-gate.md` | Skill/task-specific concern |
| `[critical-rules-018] Ignoring Spec-to-Plan Approval Cascade` | `.opencode/guidelines/010-approval-gate.md` | Skill/task-specific concern |
| `[critical-rules-013] Closing Issues Before PR Merge` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-013] Parent/Child Issue Closure` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-039] Parent Issue Left Open After All Children Closed` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-039] Process Gaps Are Bugs — completed issues not auto-closed` | `.opencode/skills/verification-before-completion/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-070] Issue Closure Outside Cleanup Workflow — agent MUST NOT close GitHub Issues through direct API calls` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-018] Sub-issue Linkage Verification — phase count mismatch` | `.opencode/skills/issue-operations-sub-issues/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-023] Posting AI-Authored Content Without Byline Verification` | `.opencode/guidelines/080-code-standards.md` | Skill/task-specific concern |
| `[critical-rules-037] Structural Decision Solicitation Under for_pr Scope` | `.opencode/guidelines/010-approval-gate.md` | Skill/task-specific concern |
| `[critical-rules-049] Standalone Submodule-Only PR Creation During Cleanup` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-039] Parent Issue Left Open After All Children Closed` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-040] Un-Squashed PR — creating single-issue PR with multiple commits` | `.opencode/skills/git-workflow-pr/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-041] Listing Merged PRs Without Calling Cleanup` | `.opencode/skills/git-workflow-cleanup/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-060] Functional/Behavioral Test Substitution Prohibition — substituting structural/grep/metadata checks when behavioral tests cannot execute` | `.opencode/guidelines/080-code-standards.md` | Skill/task-specific concern |
| `[critical-rules-PR-ORG] Stacked PR Is the Only Valid Organization` | `.opencode/skills/git-workflow-pr/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-accountability-ownership] Accountability/Remediation Ownership Model` | `.opencode/skills/audit/SKILL.md` | Skill/task-specific concern |
| `[critical-rules-066] Terminology Standardization — all context references must use standardized vocabulary` | `.opencode/guidelines/020-go-prohibitions.md` | Skill/task-specific concern |

**Total rules to move: 123** (verified count from the table above; tool-call evidence: `grep -E "^### \[critical-rules-" .opencode/guidelines/000-critical-rules.md` returned 141 total headers, 18 of which are universal per the Keep list below, leaving 123 skill-specific).

**Unique target files: 30**

## Universal Rules to Keep

These rules apply to ALL agents at ALL times, not just when a specific skill is dispatched. They MUST remain in `000-critical-rules.md` with their `### [critical-rules-NNN]` headers intact.

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
For each (source rule, target file) entry in the "Rules to Move" table:
- Read the rule body from `000-critical-rules.md`
- Append the rule body to the target file in an appropriate location
- Verify the rule appears in the target file (tool-call evidence required for SC-3)

### Phase 2: Remove moved rules from 000-critical-rules.md
For each moved rule, delete the `### [critical-rules-NNN]` block from the source file.

### Phase 3: Remove per-entry dark prose and Why This Matters tables
- Replace per-entry "Professional engineers... amateurs..." framing with direct rule statements
- Delete all "Why This Matters" tables (both headers and bodies)
- Preserve file-level framing if it appears in frontmatter or intro

### Phase 4: Remove intro cross-references
- Delete the two intro cross-references to AGENTS.md and the guidelines directory

### Phase 5: Remove redundant FORBIDDEN/REQUIRED subsections
- For each remaining universal rule, check whether the FORBIDDEN/REQUIRED subsection adds content beyond the rule header
- If the subsection is a strict restatement of the header (per SC-8 verification), delete the subsection

### Phase 6: Deduplicate rule headers
- If SC-9 finds duplicates, remove duplicate occurrences

### Phase 7: Verify all SCs
Run each SC's verification method and confirm PASS.

## Files Affected

- `.opencode/guidelines/000-critical-rules.md` — 123 rules removed; 18 universal rules preserved
- 30 target files (listed in the "Rules to Move" table above) — receive moved rules

## Risks

- **Lost rules**: If a rule is moved but the target file is not updated, the rule disappears from the agent's instruction set. Mitigation: SC-3 requires behavioral verification that each moved rule appears in its target file.
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
