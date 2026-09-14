---
plan_schema_version: "1.0"
issue: 2439
title: "Shallow temp-copy build/test gate for release verification"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 4
dispatch:
  - "test-driven-development :: red, green; verification-before-completion :: verify; (orchestrator) commit-inline — Phase 1"
  - "test-driven-development :: red, green; verification-before-completion :: verify; (orchestrator) commit-inline — Phase 2"
  - "test-driven-development :: red, green; verification-before-completion :: verify; (orchestrator) commit-inline — Phase 3"
  - "test-driven-development :: red, green; verification-before-completion :: verify; (orchestrator) commit-inline — Phase 4"
---

# Implementation Plan — #2439 — Shallow Temp-Copy Build/Test Gate for Release Verification

- **Issue:** .opencode/.issues/2439/spec.md (https://github.com/michael-conrad/.opencode/issues/2439)

**Goal:** Add a once-per-release verification gate to the release-promoter skill that checks out the release commit into a shallow temp copy, resolves submodules to their gitlink-pinned SHAs, asserts no drift, runs the repository's declared canonical build and test commands, and blocks promotion on any failure.

**Architecture:** The gate is a new step in the release-promoter operating-protocol task card, inserted before tag creation, plus routing metadata in the release-promoter skill card. It is build-system-agnostic: build/test commands are discovered from the repository's declared build manifest (root AGENTS.md first, `.opencode/AGENTS.md` "Build / Lint / Test Commands" fallback) with a hard fail when discovery fails. Submodule resolution uses `git submodule update --init --depth 1` only — never `--remote` or `--recursive` — followed by a resolved-SHA == pinned-SHA assertion with hard fail on drift.

**Files:**
- `.opencode/skills/release-promoter/SKILL.md`
- `.opencode/skills/release-promoter/tasks/operating-protocol.md`
- `.opencode/skills/release-promoter/tasks/tag.md` (gate placement context)
- `.opencode/AGENTS.md` "Build / Lint / Test Commands" — read-only dependency (canonical command source)

---

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

---

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

## Blast Radius

- Affected files (LOW-MEDIUM, confined to the release-promoter skill deck in the .opencode submodule):
  - `.opencode/skills/release-promoter/SKILL.md` — verification gate routing metadata
  - `.opencode/skills/release-promoter/tasks/operating-protocol.md` — the gate step before tag creation
  - `.opencode/skills/release-promoter/tasks/tag.md` — gate placement reference
- Read-only dependencies: root `AGENTS.md` (currently lacks a build section — fallback is canonical), `.opencode/AGENTS.md` build-command table, submodule gitlink SHAs read at gate runtime
- The gate executes commands inside a temp-copy checkout; it never modifies the source tree.

## Enforcement Gate

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | Shallow temp-copy checkout at release commit | checkout construction | SC-1 | — | 3-11 | direct (3) + task-card (4-11) |
| 2 | Submodule pin resolution + drift assertion | pinned-SHA submodule integrity | SC-2, SC-3 | 1 | 12-22 | direct (12) + task-card (13-22) |
| 3 | Build manifest discovery + build/test execution gate | build-system-agnostic verification | SC-4, SC-5 | 2 | 23-33 | direct (23) + task-card (24-33) |
| 4 | Once-per-release gate placement + promotion blocking | gate semantics | SC-6 | 3 | 34-41 | direct (34) + task-card (35-41) |

Post-implementation steps (42-49) follow Phase 4 in this index.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- C1. The gate performs a shallow temp-copy checkout of the root repo at the release commit (SC-1, behavioral evidence).
- C2. Submodules resolve to gitlink-pinned SHAs via `git submodule update --init --depth 1`; no `--remote`/`--recursive` anywhere in the gate (SC-2, behavioral evidence).
- C3. Resolved-SHA == pinned-SHA assertion hard-fails on drift (SC-3, behavioral evidence).
- C4. Build/test commands are discovered from the declared build manifest with root-first / `.opencode` fallback; undiscoverable manifest hard-fails (SC-4, behavioral evidence).
- C5. Discovered build+test commands execute with zero-failure assertion; non-zero exit blocks promotion (SC-5, behavioral evidence).
- C6. The gate runs exactly once per release and any FAIL blocks release promotion (SC-6, behavioral evidence).
- C7. Post-implementation gates (audit, z3-check, structural checks, pre-PR gate, regression check) all pass; behavioral evidence type matches every SC.
- C8. `spec-cleared` label present in local issue.yaml; plan executed with stacked PR strategy.

## Pre-Implementation (Global)

- [ ] 1. Coherence gate (**direct**)
  - Re-read `.opencode/.issues/2439/spec.md` SC table and this plan's phase table.
  - Confirm every SC is mapped to exactly one phase and the phase DAG (1→2→3→4) is acyclic.
  - Confirm evidence types: all six SCs are `behavioral` — each verify step must produce `opencode run` stderr evidence, never structural substitutes.
- [ ] 2. Baseline check (**direct**)
  - Verify parent repo and `.opencode` submodule are on `$DEFAULT_BRANCH`, clean, at remote trunk tip (pre-work per git-workflow).
  - Create the feature branch (`feature/2439-release-build-test-gate`) before any file modification.
  - Clean stale pipeline artifacts: `rm -f ./tmp/2439/artifacts/pipeline-*` (create `./tmp/2439/artifacts/` if needed).

---

## Phase 1 — Shallow Temp-Copy Checkout at Release Commit

- **Concern:** checkout construction — produce a clean shallow temp-copy of the root repo at the release commit.
- **Files:** `.opencode/skills/release-promoter/tasks/operating-protocol.md`, `.opencode/skills/release-promoter/SKILL.md`
- **SCs:** SC-1
- **Dependencies:** none (pre-implementation steps only)
- **Entry conditions:** baseline verified; feature branch exists; Phase 0 regression baseline recorded.
- **Exit conditions:** SC-1 committed with its enforcement test; checkout command documented in the gate step of the operating protocol.

**Code path coverage:** new verification gate step in the operating protocol performing `git clone --depth 1 <repo> <tmpdir>` and checkout at the release commit inside the temp copy.
**Cross-cutting SCs:** SC-1 shares pinned-SHA checkout integrity with SC-2 and SC-3 (same temp-copy tree) — the tree produced here is the input surface for Phase 2.
**Interface boundaries:** orchestrator → sub-agent dispatch (SKILL.md routing gains the gate entry); operating-protocol task card gains the gate step; no existing step semantics change.
**State transitions:** repo at release commit (unverified) → temp-copy shallow checkout at release commit (CHECKOUT_OK).

**Cost frame:** Cost is measured in defect-discovery-latency, not tool calls. A behavioral checkout test costs minutes of execution time — it catches a broken checkout before tag creation, at gate 1 (break). Skipping it costs a release tagged from an unverifiable tree discovered after promotion — a full re-release cycle (death spiral). Correctness is the only metric.

- [ ] 3. Clean Phase 1 artifacts (**direct**)
  - `rm -f ./tmp/2439/artifacts/pipeline-pre-regression-* ./tmp/2439/artifacts/pipeline-red-*` for this phase slice.
- [ ] 4. Pre-regression — run regression test patterns (**task-card**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")` scoped to the release-promoter skill deck.
- [ ] 5. Pre-regression verify (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` on the pre-regression result.
- [ ] 6. RED — write failing enforcement test for SC-1 (**task-card**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts the gate issues a shallow temp-copy checkout at the release commit (`opencode run`, stderr assertion).
  - RED fails because no checkout step exists in the operating protocol yet. Confirm and record the failure.
- [ ] 7. GREEN — implement the checkout step (**task-card**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - What must be true: the operating protocol's gate step performs a shallow clone of the root repo into a temp directory and checks out the release commit; the SKILL.md routing mentions the verification gate.
  - Minimum change only — no submodule logic yet (Phase 2's concern).
- [ ] 8. Post-regression — run regression patterns after GREEN (**task-card**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
- [ ] 9. Verify SC-1 (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` with behavioral evidence requirement.
  - Evidence: `opencode run` stderr showing the shallow checkout at the release commit. Structural evidence is EVIDENCE_TYPE_MISMATCH → FAIL.
- [ ] 10. Commit SC-1 (**direct**)
  - Orchestrator runs `git add` on the operating-protocol file, SKILL.md, and the enforcement test, then commits — test + change as one atomic slice; no co-author trailers.
- [ ] 11. Phase completion block (**direct**)
  - Assert: RED→GREEN recorded for SC-1; verify verdict PASS with behavioral evidence; commit contains test + change together; work state updated for Phase 2 handoff.
  - Concern transition: the committed temp-copy checkout is the precondition tree for Phase 2's submodule resolution.


## Phase 2 — Submodule Pin Resolution + Drift Assertion

- **Concern:** pinned-SHA submodule integrity — initialize submodules at their gitlink-pinned SHAs and prove no drift.
- **Files:** `.opencode/skills/release-promoter/tasks/operating-protocol.md`
- **SCs:** SC-2, SC-3
- **Dependencies:** Phase 1 (the temp-copy checkout from SC-1 must exist and be committed)
- **Entry conditions:** Phase 1 exit criteria met; feature branch contains the SC-1 commit.
- **Exit conditions:** SC-2 and SC-3 committed with their enforcement tests; the gate's submodule resolution and drift assertion documented in the operating protocol.

**Code path coverage:** gate step extension — `git submodule update --init --depth 1` inside the temp checkout (never `--remote`/`--recursive`), plus a resolved-SHA assertion loop comparing `git submodule status` output against the pinned gitlink SHA with non-zero exit on drift.
**Cross-cutting SCs:** SC-1/SC-2/SC-3 share pinned-SHA checkout integrity; SC-2's RED tests exercise submodule init inside the Phase 1 checkout.
**Interface boundaries:** gate (executor) → submodule gitlink SHAs read at gate runtime from the checked-out tree; no skill-deck surface changes beyond extending the Phase 1 gate step.
**State transitions:** checkout without submodule content → submodules initialized at gitlink-pinned SHAs → asserted state (resolved == pinned) OR DRIFT_FAIL.

**Cost frame:** Cost is measured in defect-discovery-latency, not tool calls. Behavioral drift-assertion tests cost minutes — they catch submodule drift before a green build of the wrong tree ships (break). Skipping them costs a release promoted from drifted submodules, discovered in production — exponentially compounding rework (death spiral). Correctness is the only metric.

- [ ] 12. Clean Phase 2 artifacts (**direct**)
  - `rm -f ./tmp/2439/artifacts/pipeline-red-* ./tmp/2439/artifacts/pipeline-green-* ./tmp/2439/artifacts/pipeline-verify-*` for the SC-2 slice.
- [ ] 13. RED — write failing enforcement test for SC-2 (**task-card**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts the gate issues `git submodule update --init --depth 1` and that `--remote`/`--recursive` never appear (`opencode run`, stderr assertion).
  - RED fails because the gate has no submodule resolution yet. Confirm and record the failure.
- [ ] 14. GREEN — implement submodule pin resolution (**task-card**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - What must be true: the gate step initializes submodules at their gitlink-pinned SHAs using `git submodule update --init --depth 1` inside the temp checkout; no `--remote` or `--recursive` flag anywhere in the gate.
- [ ] 15. Verify SC-2 (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Evidence: `opencode run` stderr showing the pinned-SHA submodule init command and absence of forbidden flags.
- [ ] 16. Commit SC-2 (**direct**)
  - Orchestrator stages and commits the enforcement test + submodule resolution change as one atomic slice.
- [ ] 17. Clean SC-3 slice artifacts (**direct**)
  - `rm -f ./tmp/2439/artifacts/pipeline-red-* ./tmp/2439/artifacts/pipeline-green-* ./tmp/2439/artifacts/pipeline-verify-*` for the SC-3 slice.
- [ ] 18. RED — write failing enforcement test for SC-3 (**task-card**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts a SHA mismatch between resolved and pinned submodule SHAs produces a hard fail (`opencode run`, stderr assertion).
  - RED fails because no drift assertion exists yet. Confirm and record the failure.
- [ ] 19. GREEN — implement drift assertion (**task-card**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - What must be true: the gate compares resolved submodule SHAs against the pinned gitlink SHAs and hard-fails (non-zero, DRIFT_FAIL state) on any mismatch.
- [ ] 20. Verify SC-3 (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Evidence: `opencode run` stderr showing a drift scenario producing a hard fail.
- [ ] 21. Commit SC-3 (**direct**)
  - Orchestrator stages and commits the enforcement test + drift assertion as one atomic slice.
- [ ] 22. Phase completion block (**direct**)
  - Assert: SC-2 and SC-3 verified with behavioral evidence; both commits contain test + change; DRIFT_FAIL semantics recorded in work state.
  - Concern transition: the asserted pinned-SHA tree is the precondition for Phase 3's build/test execution.


## Phase 3 — Build Manifest Discovery + Build/Test Execution Gate

- **Concern:** build-system-agnostic verification — discover the repository's canonical build/test commands and execute them against the pinned tree.
- **Files:** `.opencode/skills/release-promoter/tasks/operating-protocol.md`
- **SCs:** SC-4, SC-5
- **Dependencies:** Phase 2 (gate runs inside the fully-initialized pinned-SHA tree)
- **Entry conditions:** Phase 2 exit criteria met; SC-3 commit present on the feature branch.
- **Exit conditions:** SC-4 and SC-5 committed with their enforcement tests; the gate's manifest discovery and build/test execution documented in the operating protocol.

**Code path coverage:** gate step extension — manifest discovery parsing AGENTS.md "Build / Lint / Test Commands" (root AGENTS.md first, `.opencode/AGENTS.md` fallback; hard fail when not discoverable), then execution of the discovered build command followed by the test command inside the temp checkout with a zero-failure assertion.
**Cross-cutting SCs:** SC-4/SC-5 share build-system-agnostic execution (discovery output feeds directly into execution); SC-5/SC-6 share gate semantics (non-zero exit becomes FAIL that blocks promotion).
**Interface boundaries:** gate (reader) → build manifest (read-only source). Contract: the manifest exposes a table of canonical build and test commands; missing or ambiguous manifest = hard FAIL (MANIFEST_FAIL). Discovered commands are shell strings executed in the temp checkout.
**State transitions:** build/test commands unknown → commands discovered from manifest OR MANIFEST_FAIL → build+test executed with zero failures OR BUILD_FAIL.

**Cost frame:** Cost is measured in defect-discovery-latency, not tool calls. Behavioral build/test gate tests cost minutes of execution in a temp checkout — they catch a broken build before tagging (break). Skipping them costs a re-release after a post-tag build failure — diagnosis, re-tag, re-promote (death spiral). Correctness is the only metric.

- [ ] 23. Clean Phase 3 artifacts (**direct**)
  - `rm -f ./tmp/2439/artifacts/pipeline-red-* ./tmp/2439/artifacts/pipeline-green-* ./tmp/2439/artifacts/pipeline-verify-*` for the SC-4 slice.
- [ ] 24. RED — write failing enforcement test for SC-4 (**task-card**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts the gate reads the declared build manifest to obtain build/test commands rather than assuming a build system (`opencode run`, stderr assertion).
  - RED fails because no discovery mechanism exists yet. Confirm and record the failure.
- [ ] 25. GREEN — implement manifest discovery (**task-card**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - What must be true: the gate discovers canonical build and test commands from the root AGENTS.md with `.opencode/AGENTS.md` fallback, and hard-fails (MANIFEST_FAIL) when commands cannot be discovered; no build system is hardcoded.
- [ ] 26. Verify SC-4 (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Evidence: `opencode run` stderr showing the manifest read and command discovery, including the missing-manifest hard fail.
- [ ] 27. Commit SC-4 (**direct**)
  - Orchestrator stages and commits the enforcement test + discovery change as one atomic slice.
- [ ] 28. Clean SC-5 slice artifacts (**direct**)
  - `rm -f ./tmp/2439/artifacts/pipeline-red-* ./tmp/2439/artifacts/pipeline-green-* ./tmp/2439/artifacts/pipeline-verify-*` for the SC-5 slice.
- [ ] 29. RED — write failing enforcement test for SC-5 (**task-card**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts a non-zero build or test exit produces FAIL and blocks promotion (`opencode run`, stderr assertion).
  - RED fails because no execution/assertion logic exists yet. Confirm and record the failure.
- [ ] 30. GREEN — implement build/test execution gate (**task-card**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - What must be true: the gate executes the discovered build command then test command inside the temp checkout and asserts zero failures; any non-zero exit is FAIL (BUILD_FAIL).
- [ ] 31. Verify SC-5 (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Evidence: `opencode run` stderr showing successful execution on a clean tree and a non-zero exit producing FAIL.
- [ ] 32. Commit SC-5 (**direct**)
  - Orchestrator stages and commits the enforcement test + execution gate as one atomic slice.
- [ ] 33. Phase completion block (**direct**)
  - Assert: SC-4 and SC-5 verified with behavioral evidence; both commits contain test + change; MANIFEST_FAIL and BUILD_FAIL semantics recorded in work state.
  - Concern transition: the verified build/test gate is wrapped by Phase 4's once-per-release placement.


## Phase 4 — Once-per-Release Gate Placement + Promotion Blocking

- **Concern:** gate semantics — the verification gate runs exactly once per release, before tag creation, and any FAIL blocks promotion.
- **Files:** `.opencode/skills/release-promoter/tasks/operating-protocol.md`, `.opencode/skills/release-promoter/SKILL.md`, `.opencode/skills/release-promoter/tasks/tag.md` (gate placement reference)
- **SCs:** SC-6
- **Dependencies:** Phase 3 (the gate wraps the completed checkout/drift/build steps)
- **Entry conditions:** Phase 3 exit criteria met; SC-5 commit present on the feature branch.
- **Exit conditions:** SC-6 committed with its enforcement test; the gate is wired into the release promotion flow ahead of tag creation.

**Code path coverage:** gate placement in the tag/create-release flow — the gate is invoked once per release before tag creation; a FAIL in any gate state (DRIFT_FAIL, MANIFEST_FAIL, BUILD_FAIL) halts promotion with no retries within a release run.
**Cross-cutting SCs:** SC-5/SC-6 share gate semantics — the non-zero exit FAIL from Phase 3 becomes the promotion blocker here.
**Interface boundaries:** release-promoter skill card routing metadata extended with the verification-gate entry (orchestrator → sub-agent dispatch); tag task card references the gate as a mandatory predecessor step; existing tag/creation logic otherwise unchanged.
**State transitions:** promotion pending → gate PASS (exactly once per release) → promoted; or any FAIL → blocked.

**Cost frame:** Cost is measured in defect-discovery-latency, not tool calls. A behavioral gate-placement test costs minutes — it proves a failed gate actually halts promotion before a tag is cut (break). Skipping it costs a promoted broken release that must be re-released after the fact (death spiral). Correctness is the only metric.

- [ ] 34. Clean Phase 4 artifacts (**direct**)
  - `rm -f ./tmp/2439/artifacts/pipeline-red-* ./tmp/2439/artifacts/pipeline-green-* ./tmp/2439/artifacts/pipeline-verify-*` for the SC-6 slice.
- [ ] 35. RED — write failing enforcement test for SC-6 (**task-card**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - The test asserts the gate is invoked once per release before tag creation and that a failure halts promotion (`opencode run`, stderr assertion).
  - RED fails because the gate is not yet wired into the promotion flow. Confirm and record the failure.
- [ ] 36. GREEN — implement gate placement and promotion blocking (**task-card**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - What must be true: the verification gate precedes tag creation exactly once per release; SKILL.md routing metadata includes the gate; any gate FAIL blocks promotion with no retry.
- [ ] 37. Post-regression — run regression patterns after GREEN (**task-card**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` across the full release-promoter deck.
- [ ] 38. Verify SC-6 (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Evidence: `opencode run` stderr showing single invocation per release and a failure halting promotion.
- [ ] 39. Commit SC-6 (**direct**)
  - Orchestrator stages and commits the enforcement test + gate placement as one atomic slice.
- [ ] 40. Phase completion block (**direct**)
  - Assert: SC-6 verified with behavioral evidence; commit contains test + change; all six SCs now have RED/GREEN/verify/commit slices complete.
- [ ] 41. Global regression check (**task-card**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` as the final pre-implementation-scope regression pass.
  - Report `[post-implementation] [PASS|FAIL]`.


## Post-Implementation (Global)

**Cost frame:** Cost is measured in defect-discovery-latency, not tool calls. Post-implementation audit and verification gates cost minutes — they catch deliverable/spec divergence before review (break). Skipping them costs an audit finding after PR creation — rework, re-review, re-CI (death spiral). Correctness is the only metric.

- [ ] 42. Adversarial audit (**task-card**)
  - Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence.
  - Audit the deliverable against the spec's six SCs and evidence types.
- [ ] 43. Z3 constraint check (**direct**)
  - Orchestrator runs `.opencode/tools/solve check --state-path ./tmp/2439/artifacts/state.yaml --contract-path .opencode/.issues/2439/dependency-contract.yaml` directly.
- [ ] 44. Structural checks (**task-card**)
  - Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")` — lint/typecheck-equivalent checks applicable to the skill deck.
- [ ] 45. Pre-PR gate (**task-card**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` reading all six SC verdicts; BLOCK if any verdict is FAIL (DONE_WITH_CONCERNS coerces to FAIL).
- [ ] 46. Final regression check (**task-card**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
- [ ] 47. Review prep (**task-card**)
  - Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`.
- [ ] 48. Create PR (**task-card**)
  - Dispatch `task(..., prompt: "execute create task from git-workflow-pr")` — stacked PR targeting the trunk, exactly one commit per issue after squash; then HALT (human-only merge).
- [ ] 49. Completion summary (**task-card**)
  - Dispatch `task(..., prompt: "execute completion task from completion-core")` — emit the single `plan_created` lifecycle event context (plan file path, phase_count 4) and the executive summary; report once, then HALT.


## lifecycle_events

- timestamp: 2026-09-13T21:50:00-04:00
  event: plan_created
  artifact: .opencode/.issues/2439/plan.md
  phase_count: 4
