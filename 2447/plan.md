---
plan_schema_version: 1
issue: 2447
title: "SPEC-FIX: .opencode/.issues/ Is Not an Agent-Managed Issue Folder — Implementation Plan"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
dispatch:
  - phase 1: test-driven-development red/green + verification-before-completion verify + commit-inline
  - phase 2: test-driven-development red/green + verification-before-completion verify + commit-inline
  - phase 3: test-driven-development red/green + verification-before-completion verify + commit-inline
---

# Implementation Plan — SPEC-FIX: .opencode/.issues/ Is Not an Agent-Managed Issue Folder

- **Issue:** michael-conrad/.opencode#2447 — `.opencode/.issues/2447/spec.md`

## Goal

Remove the defective guidance that routes `.opencode` tickets through `local-issues` into `.opencode/.issues/` and directs worktree creation: drop the session-init setup hint, rewrite `.opencode/AGENTS.md` routing to mandate GitHub API filing against `michael-conrad/.opencode`, and (authorization-gated) remove the `.opencode/.issues/` worktree registration.

## Architecture

Three linear phases per the structure artifact: session-init output contract fix (Phase 1), `.opencode/AGENTS.md` routing prose rewrite (Phase 2), destructive worktree deregistration (Phase 3, HALT-gated). Fix delivery is a PR against `michael-conrad/.opencode` — the defective files live inside the read-only `.opencode/` tree.

## Files

- `.opencode/tools/session-init` — `collect_issue_artifact_paths()` (SC-1, SC-2)
- `.opencode/AGENTS.md` — § Issues Path Resolution, § .issues/ Is a Worktree (SC-3, SC-4)
- `.opencode/.issues/` worktree registration (SC-5)

## Dispatch

- Phase 1: direct (1-4) + task-card (5-14)
- Phase 2: direct (15-18) + task-card (19-28)
- Phase 3: direct (29-32) + task-card (33-40)

## Blast Radius

- Phase 1 ripple: every future session's system prompt loses the `.opencode` setup hint; root `.issues` entry unchanged; caller is the session-init plugin invocation only.
- Phase 2 ripple: `.opencode` ticket routing shifts local-issues → GitHub API; `opencode.jsonc` instructions array loads AGENTS.md so all agents see corrected guidance next session.
- Phase 3 ripple: local tickets under `.opencode/.issues/` become unreachable via `local-issues .opencode#N`; no parent-repo git impact.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete. SC-5 additionally requires explicit developer authorization for the destructive step and MUST NOT execute without it.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | session-init hint removal | session-init stdout contract (Local Issue Folders section) | SC-1, SC-2 | — | 1-14 | direct (1-4) + task-card (5-14) |
| 2 | AGENTS.md routing rewrite | `.opencode/AGENTS.md` issue-routing prose | SC-3, SC-4 | 1 | 15-28 | direct (15-18) + task-card (19-28) |
| 3 | worktree deregistration (authorization-gated) | `.opencode/.issues/` worktree removal | SC-5 | 2 | 29-40 | direct (29-32) + task-card (33-40) |

## Pre-Implementation Steps

- [ ] 1. Coherence gate (**direct**)
  - Re-read this plan's phase table against `.opencode/.issues/2447/artifacts/structure.yaml`; confirm every SC (SC-1 through SC-5) maps to exactly one phase and the DAG 1→2→3 has no cycles
  - If any SC is unmapped or the DAG is inconsistent, HALT with a blocker report
- [ ] 2. Baseline check (**direct**)
  - Run the existing session-init unit suite (`uv run pytest .opencode/tests/`) and record the current pass/fail counts as the pre-change baseline
  - Record `git -C .opencode worktree list` output as the pre-change worktree state baseline
  - If the baseline has pre-existing failures unrelated to this plan, record them and proceed; they are not remediation targets

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

1. C1 — SC-1 verified: session-init emits no worktree-creation setup hint for repo entries whose `.issues` dir is absent (behavioral evidence)
2. C2 — SC-2 verified: root-repo `.issues/` entry emission unchanged (behavioral evidence)
3. C3 — SC-3 verified: clean-room sub-agent judges the GitHub-API ticket-filing directive unambiguous (semantic evidence)
4. C4 — SC-4 verified: `.opencode#N → .opencode/.issues/` mapping absent from `.opencode/AGENTS.md` (string evidence)
5. C5 — SC-5 verified: `git -C .opencode worktree list` shows no `.issues` worktree (structural evidence), executed only after explicit developer authorization
6. C6 — All commits daisy-chained per item; no batching across SCs

# Phase 1 — session-init hint removal

(step range 1-14)

- **Concern:** session-init stdout contract — the `## Local Issue Folders` section
- **Files:** `.opencode/tools/session-init` — `collect_issue_artifact_paths()` and the main output loop
- **SCs:** SC-1 (behavioral), SC-2 (behavioral)
- **Dependencies:** none (first phase)
- **Entry condition:** pre-implementation steps 1-2 complete; baseline recorded
- **Exit condition:** SC-1 and SC-2 verified with behavioral evidence; commit on the `.opencode` feature branch
- **Code Path Coverage:** `.opencode/tools/session-init :: collect_issue_artifact_paths()`; `.opencode/tools/session-init :: main() → '## Local Issue Folders' print loop`
- **Cross-Cutting SCs:** verification honesty (pytest output as evidence); attribution (preserve/append module-docstring byline); submodule discipline (PR against `michael-conrad/.opencode`; pointer rides with next real parent change)
- **Interface Boundaries:** session-init stdout contract modified — `.opencode` entry loses the worktree-setup hint entirely (removal, not annotation); root-repo entry unchanged; backward compatible for consumers
- **State Transitions:** session-init output state: hint-present → hint-absent for the `.opencode` entry (one-way, on next session start)

### Steps

- [ ] 3. Pre-cleanup (**direct**)
  - Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2447}/artifacts/pipeline-pre-regression-*`
- [ ] 4. Pre-regression record (**direct**)
  - Confirm the baseline pass/fail counts from step 2 cover the session-init unit suite; record as pre-regression evidence at `{project_root}/tmp/issue-2447/artifacts/pipeline-pre-regression-evidence.yaml`
- [ ] 5. Pre-regression (**task-card**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`
  - Context: issue 2447, phase 1, SC-1/SC-2, regression baseline from step 4
- [ ] 6. Pre-regression-verify (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify pre-regression results; BLOCK if the baseline is not green on SC-relevant tests
- [ ] 7. RED for SC-1 (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-red-*`
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
  - The RED test: pytest in `.opencode/tests/` calling `collect_issue_artifact_paths()` with synthetic repo_info including the `.opencode` entry and no `.opencode/.issues` dir; assert the `setup: create worktree` hint string is absent — this test FAILS before the change
  - Confirm the test fails; record the failure as RED evidence
- [ ] 8. GREEN for SC-1 (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-green-*`
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - What must be true: `collect_issue_artifact_paths()` emits no worktree-creation setup hint for any repo entry whose `.issues` directory does not exist; the root-repo emission path is untouched
- [ ] 9. Post-regression for SC-1 (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-post-regression-*`
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 10. Verify SC-1 (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-verify-*`
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Evidence type: behavioral — pytest execution output asserting the hint is absent
- [ ] 11. COMMIT SC-1 (**direct**)
  - Stage the test and the session-init change together: `git -C .opencode add <files> && git -C .opencode commit -m "fix(session-init): drop .opencode worktree setup hint (SC-1)"`
  - No co-author trailers during implementation commits
- [ ] 12. RED for SC-2 (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-red-*`
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
  - The RED test: paired invariance pytest assertion — call `collect_issue_artifact_paths()` with synthetic repo_info and assert the root-repo `.issues/` entry emission is byte-identical to the pre-change output; this is the regression guard that fails if the hint removal perturbed the root entry
  - Confirm the invariance assertion's status and record as RED evidence
- [ ] 13. GREEN for SC-2 (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-green-*`
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - What must be true: the root-repo emission path is untouched by the SC-1 change; the invariance assertion passes; if the guard surfaced breakage, apply the minimal fix to restore byte-identical root emission
- [ ] 14. Post-regression, verify, COMMIT for SC-2 (**task-card** + **direct**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-post-regression-*`, `pipeline-verify-*`
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` — post-regression
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` — behavioral evidence for SC-2
  - COMMIT (**direct**): `git -C .opencode add <files> && git -C .opencode commit -m "test(session-init): root-repo .issues entry invariance guard (SC-2)"` — test committed with the (no-op or minimal-fix) implementation as one atomic slice

### Phase 1 Completion

- VbC assertions: SC-1 behavioral evidence present; SC-2 behavioral evidence present; both commits daisy-chained on the `.opencode` feature branch
- Concern transition: session-init output contract now states the correct `.opencode/.issues` policy — Phase 2 aligns `.opencode/AGENTS.md` prose against this post-SC-1 behavior

### Phase 1 Cost Frame

Computation frame: Cost is measured in defect-discovery-latency, not tool calls. Running the session-init unit suite costs minutes of execution time — a bounded delay that surfaces the hint defect at gate 1. Skipping the behavioral test costs weeks of re-exposure: the defective setup hint re-emits into every future session's system prompt, re-inviting forbidden worktree creation. Correctness is the only metric.

# Phase 2 — AGENTS.md routing rewrite

(step range 15-28)

- **Concern:** `.opencode/AGENTS.md` issue-routing prose
- **Files:** `.opencode/AGENTS.md` — § Issues Path Resolution, § .issues/ Is a Worktree
- **SCs:** SC-3 (semantic), SC-4 (string)
- **Dependencies:** Phase 1 (dependency-contract constraint: session-init output and AGENTS.md prose must state the same `.opencode/.issues` policy — the rewrite happens against post-SC-1 session-init behavior)
- **Entry condition:** Phase 1 complete with commits daisy-chained
- **Exit condition:** SC-3 and SC-4 verified; commit on the `.opencode` feature branch
- **Code Path Coverage:** `.opencode/AGENTS.md :: 'Issues Path Resolution' section`; `.opencode/AGENTS.md :: '.issues/ Is a Worktree' section`
- **Cross-Cutting SCs:** verification honesty (sub-agent read + grep evidence); attribution (preserve existing bylines in AGENTS.md); submodule discipline (PR against `michael-conrad/.opencode`)
- **Interface Boundaries:** `.opencode/AGENTS.md` routing contract modified — `.opencode#N` no longer maps to `.opencode/.issues/`; routes to GitHub API against `michael-conrad/.opencode`; breaking for `local-issues .opencode#N` ticket filing
- **State Transitions:** guidance state: local-issues-routed → github-api-routed (one-way)

### Steps

- [ ] 15. Pre-cleanup for SC-3 RED (**direct**)
  - Remove stale artifacts: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-red-*`
- [ ] 16. RED for SC-3 (**task-card**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
  - The RED test: clean-room sub-agent reads the current § Issues Path Resolution / § .issues/ Is a Worktree sections and judges that no unambiguous GitHub-API ticket-filing directive for `.opencode` exists — this check FAILS before the rewrite
  - Record the clean-room judgment as RED evidence
- [ ] 17. GREEN for SC-3 (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-green-*`
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - What must be true: `.opencode/AGENTS.md` issue-routing sections state unambiguously that `.opencode/` is read-only for agents and that `.opencode` defect reports and tickets are filed via the GitHub API against `michael-conrad/.opencode`; existing bylines preserved
- [ ] 18. Pre-cleanup for SC-3 verify (**direct**)
  - Remove stale artifacts: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-verify-*`
- [ ] 19. Verify SC-3 (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Evidence type: semantic — clean-room sub-agent reads the revised sections and confirms the GitHub-API routing directive is unambiguous
- [ ] 20. COMMIT SC-3 (**direct**)
  - Stage and commit: `git -C .opencode add .opencode/AGENTS.md && git -C .opencode commit -m "docs(agents): route .opencode tickets via GitHub API (SC-3)"`
- [ ] 21. RED for SC-4 (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-red-*`
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
  - The RED test: removal-assertion grep — assert `.opencode/AGENTS.md` contains no `.opencode#N → .opencode/.issues/` local-issues routing; this FAILS before the removal
  - Record grep output as RED evidence
- [ ] 22. GREEN for SC-4 (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-green-*`
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - What must be true: the `.opencode#N → .opencode/.issues/` mapping and any prose routing `.opencode` tickets through `local-issues` are removed from `.opencode/AGENTS.md` (satisfied by the SC-3 rewrite plus removal of residual mapping text)
- [ ] 23. Verify SC-4 (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-verify-*`
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Evidence type: string — grep confirms the local-issues routing mapping is absent
- [ ] 24. Post-regression for SC-4 (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-post-regression-*`
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 25. COMMIT SC-4 (**direct**)
  - Stage and commit: `git -C .opencode add .opencode/AGENTS.md && git -C .opencode commit -m "docs(agents): remove .opencode#N local-issues routing mapping (SC-4)"`
- [ ] 26. Phase 2 structural sanity (**direct**)
  - Grep `.opencode/AGENTS.md` to confirm no other section re-introduces `.opencode/.issues/` routing for agents (e.g., the parent-repo AGENTS.md routing table's `.opencode` repo entry is out of scope — root repo files are unchanged)
- [ ] 27. Phase 2 divergence check (**direct**)
  - Compare the `.opencode/.issues` policy stated by post-Phase-1 session-init output against the revised AGENTS.md prose; both must state: no agent-managed `.opencode/.issues/`, tickets via GitHub API
  - If they diverge, HALT with a blocker report — the dependency contract forbids divergence
- [ ] 28. Phase 2 record (**direct**)
  - Record SC-3 and SC-4 evidence artifact paths under `{project_root}/tmp/issue-2447/artifacts/` for the pre-PR gate

### Phase 2 Completion

- VbC assertions: SC-3 semantic evidence present; SC-4 string evidence present; commits daisy-chained; session-init/AGENTS.md policy divergence check passed
- Concern transition: documentation now matches the owner directive — Phase 3 removes the now-orphaned worktree registration

### Phase 2 Cost Frame

Computation frame: Cost is measured in defect-discovery-latency, not tool calls. The clean-room read and grep cost minutes — a bounded delay that surfaces the routing defect before merge. Skipping them costs weeks: agents keep filing `.opencode` tickets into an unsharable local branch, losing defect reports and repeating the removal cleanup each time. Correctness is the only metric.

# Phase 3 — worktree deregistration (authorization-gated)

(step range 29-40)

- **Concern:** `.opencode/.issues/` worktree removal
- **Files:** `.opencode` submodule git state — the `.opencode/.issues` worktree (branch `issues-data`)
- **SCs:** SC-5 (structural)
- **Dependencies:** Phase 2 (documentation must be updated before destructive removal; SC-5 additionally authorization-gated)
- **Entry condition:** Phase 2 complete; ⛔ **explicit developer authorization for the destructive step received beyond `approved-for-pr` (critical-rules-052)** — if authorization is absent, execute only steps 29-31 and HALT
- **Exit condition:** `git -C .opencode worktree list` shows no `.issues` worktree; removal evidence recorded
- **Code Path Coverage:** submodule git state: `.opencode/.issues` worktree (branch `issues-data`)
- **Cross-Cutting SCs:** authorization (destructive — explicit developer authorization required); attribution (n/a — no file edits); submodule discipline (worktree removal inside the submodule only; no parent-repo git impact)
- **Interface Boundaries:** removed interface — agent-managed `.opencode/.issues/` worktree; `local-issues .opencode#N` mutations no longer supported for ticket filing
- **State Transitions:** worktree state: registered → removed; branch `issues-data` retained per authorization scope. Rollback: re-register with `git worktree add` (reversible until branch deletion). Edge case: a dirty worktree blocks removal — require clean state first. Concurrency: another agent holding the worktree — resolve before removal.

### Steps

- [ ] 29. Authorization gate check (**direct**)
  - Inspect the developer message for explicit authorization of the destructive worktree removal (beyond the `approved-for-pr` label)
  - If absent: record `SC-5 BLOCKED on authorization` and skip to the Phase 3 HALT note — steps 32-40 MUST NOT execute
- [ ] 30. RED for SC-5 (**direct**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-red-*`
  - Run `git -C .opencode worktree list` — the output shows the `.issues` worktree, which is the failing state for the removal assertion
  - Record the output as RED evidence
- [ ] 31. Worktree state pre-check (**direct**)
  - Verify the worktree is clean: `git -C .opencode/.issues status --porcelain` returns empty
  - If dirty: report the dirty state and HALT — removal requires a clean worktree per the spec's concurrency edge case
- [ ] 32. GREEN for SC-5 — ⛔ EXECUTE ONLY WITH AUTHORIZATION (**direct**)
  - Execute `git -C .opencode worktree remove .issues` (and prune the orphan-branch registration)
  - Confirm the branch `issues-data` retention decision against the developer's authorization scope — branch deletion is irreversible and is NOT part of this plan
- [ ] 33. Verify SC-5 (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-verify-*`
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Evidence type: structural — `git -C .opencode worktree list` shows no `.issues` worktree
- [ ] 34. Edge-case verification (**direct**)
  - Confirm `local-issues` operations against `.opencode#N` fail fast with a clear error and do NOT silently recreate the directory
- [ ] 35. Record removal evidence (**direct**)
  - Write the `git -C .opencode worktree list` output and the authorization reference to `{project_root}/tmp/issue-2447/artifacts/pipeline-verify-sc5-evidence.yaml`
- [ ] 36. Post-regression for SC-5 (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-post-regression-*`
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` — confirm the session-init and AGENTS.md changes from Phases 1-2 are unaffected by the removal
- [ ] 37. COMMIT check (**direct**)
  - No repo commit required (git-state operation); confirm `git -C .opencode status --porcelain` is clean of unintended changes
- [ ] 38. Phase 3 completion record (**direct**)
  - Record SC-5 verdict and evidence path for the pre-PR gate
- [ ] 39. Issue evidence record (**direct**)
  - Record the removal evidence via the GitHub API as a comment on `michael-conrad/.opencode#2447` — NOT via `./.opencode/tools/local-issues comment .opencode#2447`, because step 32 removed the `.opencode/.issues` worktree that command targets (the `local-issues .opencode#N` store no longer exists after SC-5; routing evidence there would fail or silently recreate the directory)
  - Comment body: removal evidence summary + authorization reference; byline `🤖 <AgentName> (<ModelId>)` on the last line per posted-content attribution rules
- [ ] 40. Phase 3 HALT if gated (**direct**)
  - If step 29 found no authorization: report `SC-5 BLOCKED on explicit developer authorization (critical-rules-052)` with the RED evidence from step 30, and halt all remaining steps — phases 1-2 deliverables stand

### Phase 3 Completion

- VbC assertions: SC-5 structural evidence present OR SC-5 recorded BLOCKED-on-authorization with the gate intact; Phases 1-2 deliverables unaffected
- Concern transition: final phase — proceed to post-implementation

### Phase 3 Cost Frame

Computation frame: Cost is measured in defect-discovery-latency, not tool calls. The `git worktree list` verification costs seconds. Skipping the authorization gate costs irreversibly: a destructive removal executed without consent loses local ticket history with no recovery after branch deletion. Correctness — and consent — is the only metric.

# Post-Implementation

(step range 41-49)

- [ ] 41. Audit (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-audit-*`
  - Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence
  - Adversarial audit of the deliverable against all five SCs
- [ ] 42. Z3 check (**direct**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-z3-check-*`
  - Run `.opencode/tools/solve check --state-path {project_root}/tmp/issue-2447/artifacts/state.yaml --contract-path .opencode/.issues/2447/dependency-contract.yaml`
- [ ] 43. Structural checks (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-structural-checks-*`
  - Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")` — lint, typecheck, structural checks on changed files
- [ ] 44. Pre-PR gate (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-pre-pr-gate-*`
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` — reads all SC verdicts; BLOCKs if any FAIL
  - If SC-5 is recorded BLOCKED-on-authorization, the gate treats C5 as pending, not FAIL — the PR proceeds with SC-5 excluded from the completion claim
- [ ] 45. Regression check (**task-card**)
  - Pre-cleanup: `rm -f {project_root}/tmp/issue-2447/artifacts/pipeline-regression-check-*`
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` — final regression check before PR
- [ ] 46. Review prep (**task-card**)
  - Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
- [ ] 47. Create PR (**task-card**)
  - Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`
  - PR targets `michael-conrad/.opencode` (stacked; one branch, one PR); squash retains one commit per SC; co-author trailers added at squash time
  - HALT after PR creation — human-only merge
- [ ] 48. Completion summary (**task-card**)
  - Dispatch `task(..., prompt: "execute completion task from completion-core")` — completion executive summary
- [ ] 49. Final report and HALT (**direct**)
  - Report: SC-1..SC-4 verdicts with evidence paths; SC-5 verdict (done or BLOCKED-on-authorization); PR URL; byline format `🤖 <AgentName> (<ModelId>) ✅ completed`
  - HALT — silently, with no next-step proposal

## Post-Implementation Completion

- All five SCs have recorded verdicts; C1-C4 verified, C5 verified or explicitly pending authorization, C6 daisy-chain confirmed by commit history
- Ephemeral artifacts under `{project_root}/tmp/issue-2447/` are cleaned at PR merge cleanup (`git-workflow --task cleanup`), not before

## Cost Frame — Post-Implementation

Computation frame: Cost is measured in defect-discovery-latency, not tool calls. The audit, Z3 check, and pre-PR gate cost minutes combined. Skipping them costs a full rework cycle when a coerced DONE_WITH_CONCERNS or EVIDENCE_TYPE_MISMATCH verdict surfaces downstream: re-review, re-CI, and a PR that re-exposes the defective routing to every agent. Correctness is the only metric.

## Lifecycle Events

```yaml
lifecycle_events:
  - timestamp: "2026-09-17T19:41:00Z"
    event: plan_created
    plan_path: ".opencode/.issues/2447/plan.md"
    phase_count: 3
```

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.
