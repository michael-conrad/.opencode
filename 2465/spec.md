> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2465/

# Spec: Mandate trunk-tip freshness gates across read-phase skill cards

## Intent and Executive Summary

1. **Problem Statement** — Agents analyze, spec, plan, and execute against stale working-tree state because the deck's trunk-tip freshness gates anchor only at write-side workflow boundaries (pre-work, push, PR creation); read-phase activity has no gate. Live grep of the six read-phase skill cards shows zero references to the canonical trunk-tip-verification card, and a session began with the `.opencode` submodule pointer `+`-drifted while analysis proceeded on that state.

2. **Root Cause / Motivation** — The 8-step trunk-tip verification gate was designed for the implementation-start boundary and inherited only by the push and PR-creation gates. Read-phase skills (brainstorming pre-spec-inspection, spec-creation analyze, writing-plans, executing-plans, research, issue-review) read repository state with no freshness check, so stale-read contamination propagates downstream: spec and plan criteria anchor to drifted code paths, and the divergence surfaces at PR time — expensive — or never — worse. It must be solved now because every analysis/spec/planning session launched from a drifted tree compounds the drift before the write-side gate ever sees it.

3. **Approach Chosen** — A canonical freshness-gate task card in `git-workflow-branch` (read-only mode of the existing 8-step trunk-tip verification), a sync action in `submodule-sync` (ff-only pull on trunk; rebase onto `origin/$DEFAULT_BRANCH` + submodule sync on feature branches; conflicts halt to developer; sync never commits parent pointers), freshness entry criteria wired into the six read-phase skill cards, and rule-text extensions in `000-critical-rules.md`, `010-approval-gate.md`, and `.opencode/AGENTS.md`. Skill-card text fixes only — no coded fixes.

4. **Alternatives Considered & Why Discarded** —
   - **Separate read-only gate card (new task file)** instead of parameterizing `trunk-tip-verification.md` — discarded: a second card path multiplies reference targets; parameterization preserves the single canonical card and keeps existing write-side callers untouched.
   - **Coded enforcement** (session-init freshness probe, hooks, plugins, static checks) — discarded: developer scope directive forbids coded fixes; enforcement is behavioral, proven by behavioral enforcement tests via `opencode run`.
   - **Session-start freshness check in session-init (GAP-1)** — discarded for this spec: same no-coded-fixes constraint; covered indirectly because the first read-phase skill invocation of a session executes the gate.

5. **Key Design Decisions** —
   - **Parameterize, do not fork:** the read-only mode is added to the canonical `trunk-tip-verification` card; six callers reference one card path. Tradeoff: a slightly larger canonical card versus duplicated gate logic across seven cards and a rename-hazard contract.
   - **Gate versus sync separation:** the gate is read-only verification with no mutations; sync is the state-changing remediation executed when the gate reports stale. Tradeoff: two dispatches when stale instead of one combined action — but the gate alone stays safe to run unconditionally, including inline by a sub-agent, because it performs pure git reads.
   - **Fail-open on unreachable network:** the gate inherits the existing `trunk-tip-verification` fail-open precedent — offline analysis SHALL NOT hard-block. Tradeoff: a stale-but-unverified state may proceed, but hard-blocking analysis on network loss would stall all offline work.
   - **`.gitmodules`-only enumeration:** the parent repo plus registered submodules only; `.issues/` worktrees (gitignored, own branch) and unregistered nested repos are excluded. Tradeoff: none — misclassifying worktrees as submodules would corrupt state handling; the alternative directory scan is a known defect source (session-init dir-scan misclassification excluded by no-coded-fixes).

6. **User Intent / Original Prompt** — michael-conrad/.opencode#2465, "Mandate trunk-tip freshness gates across read-phase skill cards": extend repo-state freshness verification from write boundaries to read phases, classify sync as authorization-free hygiene, add bright-line rule text, and prove each change behaviorally. This spec was assembled from analysis artifacts produced by the spec-creation pipeline for that issue.

## Not Included

- **Session-start freshness via session-init (GAP-1)** — excluded by the no-coded-fixes scope directive; session-init emits context only and is not modified. Covered indirectly: the first read-phase skill invocation of a session executes the freshness gate before any file reads.
- **Coded enforcement of any kind (hooks, plugins, static or mechanical checks)** — excluded by the developer scope directive; enforcement is behavioral via skill-card instructions proven by behavioral enforcement tests.
- **Write-side gate changes (pre-work, review-prep push-and-cleanup, PR-creation enforcement gate, finishing prepare)** — out of scope; these already enforce trunk-tip verification and MUST remain intact with no regression.
- **`.issues/` worktree freshness handling** — worktrees live on their own branch with their own remote (`issues-data`); they are gitignored and excluded from the freshness scope, which enumerates from `.gitmodules` only.
- **Remote-first spec numbering changes** — a standing `.issues/AGENTS.md` mandate already in force; no deck change required for it.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The `git-workflow-branch` trunk-tip-verification card defines a read-only freshness-gate mode that verifies the parent repo and `.gitmodules`-enumerated submodules against the remote trunk tip (fetch + rev compare), zero pending changes, and clean submodule trees, performs no mutations itself, and fails open on unreachable network | behavioral | `opencode run` (with-test-home) on a stale-state fixture; stderr shows the gate dispatched and executed (git fetch/rev evidence) before any file read; run preceded by commit→push→fetch/verify cycle | `git-workflow-branch/tasks/trunk-tip-verification.md`; `.opencode/tests-v2/AGENTS.md` |
| SC-2 | The submodule-sync card plus its `git-workflow-branch` SKILL.md routing defines the sync action: ff-only pull on trunk; on a feature branch, rebase onto `origin/$DEFAULT_BRANCH` plus submodule sync; a rebase conflict halts to the developer; the sync never commits parent-repo submodule pointers | behavioral | `opencode run`: stale fixture → agent executes sync before proceeding; conflict fixture → agent halts to developer; git log shows no pointer commit from sync | `git-workflow-branch/tasks/submodule-sync.md`; `git-workflow-branch/SKILL.md` |
| SC-3 | The brainstorming pre-spec-inspection task carries a freshness entry criterion that dispatches the canonical gate (read-only mode) before its file reads | behavioral | `opencode run` pre-spec-inspection prompt on stale fixture; stderr shows the gate dispatched before file-read evidence | `brainstorming/tasks/explore/pre-spec-inspection.md` |
| SC-4 | The spec-creation card plus its analyze task carries a freshness entry criterion for the analyze step | behavioral | `opencode run` spec-creation analyze prompt on stale fixture; stderr shows the gate dispatched before analysis reads | `spec-creation/SKILL.md` |
| SC-5 | The writing-plans card plus its create task carries a freshness entry criterion for plan creation | behavioral | `opencode run` writing-plans prompt on stale fixture; stderr shows the gate dispatched before plan-creation reads | `writing-plans/SKILL.md` |
| SC-6 | The executing-plans card carries a freshness entry criterion on plan read and a mid-plan currency check that re-verifies trunk freshness before continuing execution after an idle resume | behavioral | `opencode run` resume-after-drift fixture; stderr shows re-verification before continued execution | `executing-plans/SKILL.md` |
| SC-7 | The research card carries a freshness entry criterion before investigation reads | behavioral | `opencode run` research prompt on stale fixture; stderr shows the gate dispatched before investigation reads | `research/SKILL.md` |
| SC-8 | The issue-review card carries a freshness entry criterion before issue-review reads | behavioral | `opencode run` issue-review prompt on stale fixture; stderr shows the gate dispatched before reads | `issue-review/SKILL.md` |
| SC-9 | `000-critical-rules.md` extends the non-trunk-tip rule from write-side to read-side phases with a bright-line trigger list, and its gate step-count language matches the canonical card | behavioral | `opencode run` prompt implying read-phase work under stale state; agent refrains from read-phase progress without the gate; content-level step-count reconciliation check gates text structure (PASS still requires behavioral evidence) | `guidelines/000-critical-rules.md` |
| SC-10 | `010-approval-gate.md` classifies sync (pull/rebase/trunk submodule sync) as authorization-free hygiene with explicit no-deliberation framing | behavioral | `opencode run` analysis prompt under `for_analysis`; agent runs pull/sync without requesting authorization | `guidelines/010-approval-gate.md` |
| SC-11 | `.opencode/AGENTS.md` replaces the advisory mid-feature "periodically" submodule-sync wording with a bright-line trigger list (session resume, feature-branch rebase, PR creation) | behavioral | `opencode run` mid-feature resume prompt after trunk moved; agent cites a listed trigger and syncs | `AGENTS.md` (Submodule discipline section) |

## Requirements

R-1. Read-phase workflow boundaries — analysis, spec creation, planning, plan execution, and mid-feature resume — SHALL acquire trunk-tip freshness gates: read activity SHALL verify repository freshness, not only write activity.

R-2. `git-workflow-branch` SHALL carry one canonical freshness-gate task card that reuses and parameterizes the existing 8-step trunk-tip verification as a read-only mode.

R-3. The submodule-sync card SHALL define the sync action: ff-only pull on trunk; on a feature branch, rebase onto `origin/$DEFAULT_BRANCH` plus submodule sync; conflict resolution SHALL halt to the developer.

R-4. The six read-phase skill cards — brainstorming pre-spec-inspection, spec-creation analyze, writing-plans create, executing-plans (entry plus mid-plan currency), research, issue-review — SHALL each carry a freshness entry criterion wired to the canonical gate card.

R-5. `000-critical-rules.md` SHALL extend the non-trunk-tip rule from write-side-only to read-side phases with a bright-line trigger list.

R-6. `010-approval-gate.md` SHALL classify sync (pull/rebase/trunk submodule sync) as authorization-free hygiene.

R-7. `.opencode/AGENTS.md` SHALL replace the advisory mid-feature "periodically" sync wording with a bright-line trigger list (session resume, feature-branch rebase, PR creation).

R-8. The freshness scope SHALL be the parent repo plus submodules enumerated from `.gitmodules` only; unregistered and gitignored sub-repos (for example `.issues/` worktrees) SHALL be excluded.

R-9. Enforcement SHALL be behavioral: skill-card text fixes only, with each gate or rule change proven by a behavioral enforcement test executed via `opencode run`.

R-10. Existing write-side gates (pre-work, review-prep push-and-cleanup, PR-creation enforcement gate, finishing prepare) SHALL remain intact — this spec SHOULD introduce no regression to them.

R-11. The gate and the sync SHALL be distinct actions: the gate verifies freshness (read-only); when the gate reports stale, the agent runs sync before proceeding; sync is itself state-changing but hygiene-classified.

R-12. Sync SHALL be executable under the default `for_analysis` scope without an authorization stall.

R-13. The gate step-count language in `000-critical-rules.md` SHALL be reconciled with the canonical card when the rule is extended.

R-14. Each read-phase wiring SHALL reference the canonical gate card via the `Read [Text](path)` pattern rather than restating the 8 steps inline.

### Constraints

C-1. NO coded fixes: no session-init changes, no hooks, no plugins, no static or mechanical checks (developer scope directive).

C-2. Sync conflicts (rebase failures) halt to the developer; the deck SHALL NOT auto-resolve beyond the existing divergence logic in submodule-sync.

C-3. Sync SHALL NOT commit parent-repo submodule pointers; pointer capture remains pre-work's job.

C-4. The gate fails open on unreachable network, per the existing trunk-tip-verification precedent.

C-5. All changed files live in the `.opencode` submodule — this spec routes to michael-conrad/.opencode.

## Items

Every item is behavioral: the cycle is RED (behavioral test asserts the agent does NOT gate/sync at the read-phase entry) → GREEN (make the text change so the agent DOES) → verify → commit → push (commit and push precede the behavioral test run; the harness requires the effective commit contained in a remote ref). One SC per item.

### Item 1 (SC-1): Canonical read-only freshness-gate mode

- RED: Behavioral test on a stale-state fixture — agent reads analysis-phase files without dispatching the gate; fails.
- GREEN: Parameterize `trunk-tip-verification.md` with the read-only mode (fetch + rev compare, zero pending changes, clean submodule trees, no mutations, fail-open on unreachable network).
- verify: Behavioral stderr evidence of gate dispatch before file reads; gate performs no git mutations.
- commit: `git-workflow-branch` deck changes plus the item's behavioral test.

### Item 2 (SC-2): Sync action definition

- RED: Behavioral test — stale fixture, agent proceeds without sync; fails.
- GREEN: Extend `submodule-sync.md` (+ SKILL.md routing) with trunk ff-only pull, feature-branch rebase onto `origin/$DEFAULT_BRANCH` + submodule sync, conflict-halt, and never-commit-pointers constraints.
- verify: Behavioral evidence of sync before proceeding; conflict fixture halts; no pointer commit.
- commit: submodule-sync card, SKILL.md routing, plus the item's behavioral test.

### Item 3 (SC-3): brainstorming pre-spec-inspection entry criterion

- RED: Behavioral test — agent runs pre-spec-inspection on a stale fixture with no gate; fails.
- GREEN: Add the freshness entry criterion to `pre-spec-inspection.md`, dispatched before file reads via the canonical card.
- verify: Behavioral stderr evidence of gate-before-reads ordering.
- commit: brainstorming card change plus the item's behavioral test.

### Item 4 (SC-4): spec-creation analyze entry criterion

- RED: Behavioral test — agent runs spec-creation analyze on a stale fixture with no gate; fails.
- GREEN: Add the freshness entry criterion to `spec-creation/SKILL.md` and the analyze task.
- verify: Behavioral stderr evidence of gate-before-analysis-reads ordering.
- commit: spec-creation deck changes plus the item's behavioral test.

### Item 5 (SC-5): writing-plans create entry criterion

- RED: Behavioral test — agent creates a plan on a stale fixture with no gate; fails.
- GREEN: Add the freshness entry criterion to `writing-plans/SKILL.md` and the create task.
- verify: Behavioral stderr evidence of gate-before-plan-creation-reads ordering.
- commit: writing-plans deck changes plus the item's behavioral test.

### Item 6 (SC-6): executing-plans entry plus mid-plan currency check

- RED: Behavioral test — resume-after-drift fixture, agent continues mid-plan without re-verification; fails.
- GREEN: Add the entry criterion on plan read and the mid-plan currency check to `executing-plans/SKILL.md`.
- verify: Behavioral stderr evidence of re-verification before continued execution.
- commit: executing-plans deck changes plus the item's behavioral test.

### Item 7 (SC-7): research entry criterion

- RED: Behavioral test — agent investigates on a stale fixture with no gate; fails.
- GREEN: Add the freshness entry criterion to `research/SKILL.md` before investigation reads.
- verify: Behavioral stderr evidence of gate-before-investigation ordering.
- commit: research card change plus the item's behavioral test.

### Item 8 (SC-8): issue-review entry criterion

- RED: Behavioral test — agent reviews an issue on a stale fixture with no gate; fails.
- GREEN: Add the freshness entry criterion to `issue-review/SKILL.md` before issue-review reads.
- verify: Behavioral stderr evidence of gate-before-reads ordering.
- commit: issue-review card change plus the item's behavioral test.

### Item 9 (SC-9): 000-critical-rules read-side extension

- RED: Behavioral test — prompt implying read-phase work under stale state; agent proceeds; fails.
- GREEN: Extend the non-trunk-tip rule to read-side phases with a bright-line trigger list; reconcile the gate step-count wording with the canonical card.
- verify: Behavioral evidence that the agent refrains from read-phase progress without the gate.
- commit: guideline change plus the item's behavioral test.

### Item 10 (SC-10): 010-approval-gate sync classification

- RED: Behavioral test — analysis prompt under `for_analysis`; agent requests authorization before pull/sync; fails.
- GREEN: Add sync to the authorization-free actions list in `010-approval-gate.md` with no-deliberation framing.
- verify: Behavioral evidence that the agent runs pull/sync without an authorization stall.
- commit: guideline change plus the item's behavioral test.

### Item 11 (SC-11): AGENTS.md bright-line trigger list

- RED: Behavioral test — mid-feature resume after trunk moved; agent relies on the advisory wording and skips sync; fails.
- GREEN: Replace the advisory wording with the bright-line trigger list in `.opencode/AGENTS.md` (Submodule discipline section).
- verify: Behavioral evidence that the agent cites a listed trigger and syncs.
- commit: AGENTS.md change plus the item's behavioral test.

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `git-workflow-branch/tasks/trunk-tip-verification.md` (canonical 8-step gate) | Must exist as the parameterization target for the read-only mode | Satisfied — verified present |
| `git-workflow-branch/tasks/submodule-sync.md` (sync card) | Must exist as the extension target for the sync action | Satisfied — verified present |
| `tests-v2` behavioral framework (`with-test-home`, stderr-based assertion helpers) | Must exist to execute the per-SC behavioral tests | Satisfied — verified present (`trunk-tip-enforcement.sh`, `submodule-pointer-enforcement.sh`, `2230-sc1-trunk-tip-dispatch.sh`) |
| `.opencode/guidelines/000-critical-rules.md` non-trunk-tip rule (Tier 1 block) | Must exist as the rule extension site | Satisfied — verified present |
| `guidelines/010-approval-gate.md` authorization-free actions list | Must exist as the classification site | Satisfied — verified present |
| `.opencode/AGENTS.md` Submodule discipline section | Must exist as the trigger-list replacement site | Satisfied — verified present |
| Research card `per-sc-decomposition-industry-standards.md` | Consulted for decomposition methodology (per-SC RED/GREEN, RTM traceability) | Satisfied — consulted in analysis |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 | Phase 1, Phase 2 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-2 | Phase 1 |
| R-4 | SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 | Phase 2 |
| R-5 | SC-9 | Phase 3 |
| R-6 | SC-10 | Phase 3 |
| R-7 | SC-11 | Phase 3 |
| R-8 | SC-1, SC-2 | Phase 1 |
| R-9 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11 | Phase 1, Phase 2, Phase 3 |
| R-10 | SC-1, SC-2 | Phase 1 |
| R-11 | SC-1, SC-2 | Phase 1 |
| R-12 | SC-2, SC-10 | Phase 1, Phase 3 |
| R-13 | SC-9 | Phase 3 |
| R-14 | SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 | Phase 2 |
| C-1 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11 | Phase 1, Phase 2, Phase 3 |
| C-2 | SC-2 | Phase 1 |
| C-3 | SC-2 | Phase 1 |
| C-4 | SC-1 | Phase 1 |
| C-5 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11 | Phase 1, Phase 2, Phase 3 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Canonical trunk-tip verification card | code (skill deck) | `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` | Read (8-step gate, fail-open precedent confirmed) |
| Submodule-sync card | code (skill deck) | `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` | Read (`.gitmodules` enumeration, ff-only, divergence handling confirmed) |
| git-workflow-branch and git-workflow skill cards | code (skill deck) | `.opencode/skills/git-workflow-branch/SKILL.md`, `.opencode/skills/git-workflow/SKILL.md` | Grep (only existing trunk-tip-verification consumers) |
| Six read-phase skill cards | code (skill deck) | `brainstorming/tasks/explore/pre-spec-inspection.md`, `spec-creation/SKILL.md`, `writing-plans/SKILL.md`, `executing-plans/SKILL.md`, `research/SKILL.md`, `issue-review/SKILL.md` | Grep (zero trunk-tip-verification references — the gap) |
| 000-critical-rules.md | doc (guideline) | `.opencode/guidelines/000-critical-rules.md` (non-trunk-tip rule and gate step-count wording) | Read + grep |
| 010-approval-gate.md | doc (guideline) | `.opencode/guidelines/010-approval-gate.md` (authorization-free actions list) | Grep (no pull/sync entry — the gap) |
| AGENTS.md | doc (agents) | `.opencode/AGENTS.md` (Submodule discipline section, mid-feature bullet) | Grep (advisory "periodically" wording confirmed) |
| Existing behavioral coverage | test | `.opencode/tests-v2/behaviors/` (`trunk-tip-enforcement.sh`, `submodule-pointer-enforcement.sh`, `2230-sc1-trunk-tip-dispatch.sh`) | `ls` (verified present; read-side coverage absent) |
| Exec-summary issue body format | doc (task card) | `issue-operations-core/tasks/creation.md` ("Step 5: Format body as exec summary") | Read |
| Cost-frame and spec-structure standards | doc (reference) | `.opencode/reference/cost-model-standards.md`, `.opencode/reference/spec-structure-standards.md` | Read |
| Source issue | issue | michael-conrad/.opencode#2465 (remote body: Problem, Scope, Approach, Affected files) | GitHub API read |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Adding the read-only gate mode costs minutes of card-authoring plus one gate dispatch at each read-phase entry (bounded seconds of git reads). Skipping costs the entire pipeline downstream — analysis, specs, and plans anchor to a drifted tree, and the divergence is discovered at PR time at 100×–1000× the cost, or never.
- SC-2: Authoring the sync action costs minutes of card-authoring plus one sync (a pull/rebase round-trip) only when staleness is detected. Skipping costs stale-read contamination persisting after detection — the gate reports stale, the agent proceeds stale, and the defect ships into the spec/plan with the same downstream discovery latency as skipping the gate entirely.
- SC-3: Wiring brainstorming's entry criterion costs minutes of card-editing plus one gate dispatch per analysis session. Skipping costs every analysis session launched from a drifted tree silently anchoring its findings to moved code — the contamination then flows into every spec produced from it.
- SC-4: Wiring spec-creation's analyze entry criterion costs minutes plus one gate dispatch. Skipping costs spec success criteria anchored to stale code paths — the class of defect that motivated this spec, discovered only when plan execution collides with reality.
- SC-5: Wiring writing-plans' entry criterion costs minutes plus one gate dispatch. Skipping costs plans that reference file areas which no longer exist or have moved, converting plan execution into discovery-by-conflict.
- SC-6: Adding the entry and mid-plan currency checks costs minutes plus one re-verification per idle resume. Skipping costs long-session plan execution against a trunk that moved while the agent was away — edits applied against assumptions invalidated hours earlier.
- SC-7: Wiring research's entry criterion costs minutes plus one gate dispatch. Skipping costs investigation findings attributed to stale state, which then poison every downstream verification that cites them.
- SC-8: Wiring issue-review's entry criterion costs minutes plus one gate dispatch. Skipping costs review verdicts rendered against drifted state — approvals of what the code was, not what it is.
- SC-9: Extending the rule text costs minutes of guideline-editing. Skipping costs the read-side mandate remaining unenforced at the Tier-1 rule layer — wired cards would instruct a gate that no bright-line rule requires, making every skip defensible.
- SC-10: Classifying sync as authorization-free costs minutes of guideline-editing. Skipping costs every freshness gate stalling at an authorization prompt under `for_analysis` — agents rationalize the skip, the gate decays into decoration, and stale-read contamination returns through the exception path.
- SC-11: Replacing the advisory wording costs minutes of AGENTS.md editing. Skipping costs mid-feature resume remaining advisory — "periodically" is followed only when convenient, so the exact sessions that need the sync (long resume after trunk movement) are the sessions that skip it.

## Edge Cases

- **Condition:** No `.gitmodules` file exists in the parent repo (parent-only repository).
  **Expected behavior:** The gate verifies the parent repo alone and reports the zero-submodule scope factually.
  **Resolution:** None needed — enumeration over an empty `.gitmodules` set is valid.

- **Condition:** Parent repo is clean but behind origin tip (stale-parent); submodule checkouts drift (`+` pointer state); local trunk commits exist that cannot ff-pull.
  **Expected behavior:** The gate classifies the state read-only; on stale-parent the agent runs sync (ff-only pull) and re-verifies; local trunk commits cause ff-only to fail, which halts to the developer.
  **Resolution:** Sync on success → re-verify → proceed; ff-only failure → halt to developer with the state preserved.

- **Condition:** Dirty parent repo classified as safe-state (release-capture-pending) per the existing porcelain-check WARN predicate.
  **Expected behavior:** The gate emits the existing WARN and proceeds per current trunk-tip-verification semantics.
  **Resolution:** Inherited from the canonical card; no new handling.

- **Condition:** Network unreachable during the fetch step of the gate or the sync.
  **Expected behavior:** The gate fails open — analysis proceeds with a factual "freshness unverifiable (offline)" report; a sync that cannot reach the remote is reported, not fatal.
  **Resolution:** Fail-open per existing precedent; the agent proceeds and the report stays in chat output.

- **Condition:** Rebase conflict during feature-branch sync.
  **Expected behavior:** Halt to the developer with repository state preserved — no partial remediation, no auto-resolution beyond the existing divergence logic.
  **Resolution:** Developer resolves or directs; the agent re-runs the gate after resolution.

- **Condition:** Concurrent activity in the same working tree (parallel agents, developer edits during analysis).
  **Expected behavior:** Sync operates on the current tree at execution time and does not discard scratch work — rebase moves history, never deletes branches; `observe/*` scratch branches and `tmp/` writes survive a mid-session sync.
  **Resolution:** `observe/*` bases invalidated by a mid-session sync are accepted as scratch (discardable before halt per the `for_analysis` allowlist).

- **Condition:** Gate dispatched by a sub-agent with no dispatch capability.
  **Expected behavior:** The gate is pure git reads and stays executable inline by a sub-agent in its own context; no sub-agent dispatch is required to verify freshness.
  **Resolution:** Canonical card states inline execution is permitted for the read-only mode.

- **Condition:** Gitignored worktrees (`.issues/`) and unregistered nested repos present in the tree.
  **Expected behavior:** The gate and sync enumerate from `.gitmodules` only and never touch these paths.
  **Resolution:** Excluded by scope; directory scanning is prohibited.

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
