# [SPEC] trunk-tip-verification gate unsatisfiable after legitimate trunk-tip pull — submodule pointer staleness treated as FAIL

> **Full spec and artifacts: [`/issues/2440/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2440/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2440/` — analytical artifacts, SC summary, dependency contracts

## Intent and Executive Summary

1. **Problem Statement:** The 8-step trunk-tip-verification pre-work gate in `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` reports FAIL for `parent_clean` (Step 2) and `submodule_pointer_match` (Step 7) when a submodule is checked out at its own remote trunk tip with a merged pointer commit — exactly the safe state produced by the documented dev-parking workflow. Because pointer-only parent commits are forbidden and fabricating parent edits is forbidden, no permitted action can clear the failure: the gate is BLOCKED-unsatisfiable by design for this state.

2. **Root Cause / Motivation:** The gate conflates two distinct states: the **safe state** (submodule checkout equals the submodule's own `origin/<default>` tip, pointer commit merged upstream) and the **hazardous state** (committed pointer references a local-only commit). Step 8's `git merge-base --is-ancestor` check (`SUBMODULE_UNMERGED_COMMIT`) already detects the hazardous state independently. Steps 2 and 7 must stop re-classifying the safe state as failure. This must be fixed now because every submodule-scoped feature branch is blocked at pre-work until it is fixed.

3. **Approach Chosen:** Reclassify the two safe-state failure signals as WARN (release-capture-pending) conditioned on the safe-state predicate — both predicate inputs (remote-tip equality, merged-commit) are already computed by existing steps 6 and 8, so no new checks or network calls are introduced. Separately, fix the invalid `continue` in Step 8's network-fail-open branch using an if/else construct valid inside `git submodule foreach`. Sync the Exit Criteria and Result Contract prose to the new classification, and protect the `SUBMODULE_UNMERGED_COMMIT` blocking behavior with a behavioral regression run.

4. **Alternatives Considered & Why Discarded:**
   - **Allow pointer-only parent commits to clear the failure** — rejected: directly contradicts the documented submodule discipline (pointer-only pushes are blocked by pre-push hooks; fabricated parent edits are a CRITICAL VIOLATION).
   - **Delete steps 2 and 7 from the gate** — rejected: both checks catch genuine dirt (non-pointer parent changes, real submodule pointer drift); removing them would eliminate hazard detection along with the false positive.
   - **Downgrade both checks unconditionally to WARN** — rejected: an unconditioned WARN would silently pass the hazardous state when the submodule checkout does NOT match the remote trunk tip; the safe-state predicate is what makes the reclassification sound.

5. **Key Design Decisions:**
   - **Safe-state predicate reuse over new checks** — the predicate (submodule HEAD == submodule's `origin/<default>` tip AND pointer commit is an ancestor of that tip) is derived entirely from steps 6 and 8's existing computations. Tradeoff: gate steps become order-dependent (steps 2 and 7 classification depends on steps 6 and 8 results) in exchange for zero new network calls and zero new check IDs.
   - **WARN, not SKIP, for the safe state** — WARN preserves visibility that a release-capture is pending. Tradeoff: consumers (pre-work) must treat WARN as non-blocking, which is an additive enum extension to the Result Contract.
   - **FAIL retained for genuine dirt** — `parent_clean` FAIL remains for non-pointer-only parent dirt and submodule dirt; only the pointer-only-safe-state subset reclassifies. Tradeoff: classification logic in Step 2 becomes conditional rather than a single command assertion.
   - **SUBMODULE_UNMERGED_COMMIT is invariant** — step 8's blocking behavior is never downgraded; the regression suite asserts it stays green.

6. **User Intent / Original Prompt:** "[BUG] trunk-tip-verification gate unsatisfiable after legitimate trunk-tip pull — submodule pointer staleness treated as FAIL" (michael-conrad/.opencode#2440), with session evidence from xBaseJ#65 (GitBucket parent repo `NewSRX-Tech-LLC/Patents`, verified 2026-09-08): failing checks `parent_clean` (pointer-only ` M <submodule>`) and `submodule_pointer_match` (`+90d612f` vs committed `01d63eb`); safety-establishing checks `submodule_on_default`, `submodule_clean`, `submodule_remote_match`, `submodule_merged_commit` all PASS.

## Not Included

- **pre-red-baseline SUBMODULE-DRIFT check (#2013)** — adjacent over-strictness in a different gate; tracked separately in #2013.
- **submodule-sync.md and pre-commit-pointer-check.md behavior** — pointer capture at release remains unchanged; this spec only changes pre-work gate classification.
- **New tooling, scripts, or git commands** — the fix reuses existing step computations; no new commands are introduced.
- **AGENTS.md prose changes** — the documented submodule discipline is already correct; the gate is what contradicts it.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | When the submodule checkout equals the submodule's remote trunk tip and the merged-commit check passes, a pointer-only ` M <submodule>` entry does not cause `parent_clean` FAIL; the gate reports it as WARN (release-capture-pending) and the gate status is DONE, not BLOCKED. | behavioral | `bash .opencode/tests-v2/with-test-home opencode run '<safe-state scenario>'` — assert stderr behavioral evidence that `parent_clean` classifies WARN and gate status is DONE | `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` Step 2; `.opencode/AGENTS.md` §Submodule Pointer Updates |
| SC-2 | Under the same safe-state predicate, a `+` prefix in `git submodule status` for a merged, trunk-tip-checked-out submodule yields `submodule_pointer_match: WARN`, not FAIL, and gate status DONE. | behavioral | Same `with-test-home opencode run` scenario — assert stderr shows `submodule_pointer_match: WARN` and no BLOCKED | `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` Step 7 |
| SC-3 | The network-unreachable fail-open branch in Step 8 skips the merged-commit check using a control-flow construct valid inside `git submodule foreach` (if/else), with no `continue` in the eval body, and still emits the WARN-skip message. | structural | Static inspection of the Step 8 snippet: grep asserts `continue` absent from the foreach eval body and the skip path preserved | `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` Step 8 |
| SC-4 | Exit Criteria and Result Contract list `parent_clean` and `submodule_pointer_match` as `PASS \| WARN \| FAIL` with WARN documented as release-capture-pending, and `SUBMODULE_UNMERGED_COMMIT` documented as the only BLOCKED trigger. | structural | Static content assertion on the task card's Exit Criteria and Result Contract sections | `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` Exit Criteria, Result Contract |
| SC-5 | After all changes, a local-only submodule pointer commit still causes BLOCKED with `SUBMODULE_UNMERGED_COMMIT` (existing `2313-sc1-prework-merged-commit.sh` stays green), and the new safe-state scenario asserts DONE with WARNs. | behavioral | Full gate suite run via `with-test-home`: `trunk-tip-enforcement.sh` + `2313-sc1-prework-merged-commit.sh` + new safe-state scenario, all green | `.opencode/tests-v2/behaviors/trunk-tip-enforcement.sh`; `.opencode/tests-v2/behaviors/git-workflow/2313-sc1-prework-merged-commit.sh` |

## Requirements

1. R-1. The gate SHALL classify a pointer-only ` M <submodule>` entry in `parent_clean` (Step 2) as WARN (release-capture-pending) instead of FAIL when the submodule checkout equals the submodule's `origin/<default>` tip and the merged-commit check passes.
2. R-2. The gate SHALL classify a `+` prefix in `submodule_pointer_match` (Step 7) as WARN instead of FAIL under the same safe-state predicate.
3. R-3. The gate SHALL retain `SUBMODULE_UNMERGED_COMMIT` (Step 8) as a BLOCKED trigger for a local-only submodule pointer commit; this behavior SHALL NOT be downgraded.
4. R-4. The gate SHALL retain FAIL for genuine parent dirt (non-pointer-only changes) and genuine submodule dirt.
5. R-5. The gate's Exit Criteria and Result Contract SHALL document `parent_clean` and `submodule_pointer_match` as `PASS | WARN | FAIL` with WARN defined as release-capture-pending, and SHALL document `SUBMODULE_UNMERGED_COMMIT` as the only BLOCKED trigger.
6. R-6. The Step 8 network-fail-open path SHALL skip the merged-commit check using a control-flow construct valid inside `git submodule foreach` (if/else) and SHALL NOT use `continue` inside the foreach eval body.
7. R-7. The safe-state predicate SHALL be derived from existing step computations (Step 6 remote-tip equality, Step 8 merged-commit) and SHALL NOT introduce new checks, new check IDs, or new network calls.
8. R-8. A WARN gate result SHALL NOT block pre-work or trigger re-dispatch; the gate status SHALL be DONE when only WARN-classified conditions are present.

## Items

### Item 1 (SC-1): Safe-state classification for parent_clean pointer-only dirt

- RED: Behavioral test constructs a fixture state (parent repo with one submodule checked out at its own `origin/<default>` tip, merged pointer commit, stale committed parent pointer) and asserts the gate classifies `parent_clean` as WARN, not FAIL/BLOCKED — the test fails against the current gate text.
- GREEN: Update Step 2 in `trunk-tip-verification.md` to add the safe-state WARN classification conditioned on the steps-6/8 predicate.
- verify: Behavioral run via `with-test-home`; stderr shows `parent_clean: WARN` and DONE status.
- commit: One commit scoped to the task card Step 2 change plus the new behavioral scenario script.

### Item 2 (SC-2): Safe-state classification for submodule_pointer_match `+` prefix

- RED: Behavioral test asserting `+` prefix on a merged trunk-tip submodule yields `submodule_pointer_match: WARN` and gate status DONE — fails against current gate text.
- GREEN: Update Step 7 classification in `trunk-tip-verification.md`, reusing the safe-state predicate established in Item 1.
- verify: Behavioral run via `with-test-home`; stderr shows `submodule_pointer_match: WARN`, DONE status, no BLOCKED.
- commit: One commit scoped to the task card Step 7 change.

### Item 3 (SC-3): Fail-open path in Step 8 avoids invalid `continue`

- RED: Structural test asserting `continue` is absent from the Step 8 foreach eval body and the skip path still warns — fails against the current snippet.
- GREEN: Rewrite the fail-open branch in Step 8 using if/else.
- verify: Static inspection of the Step 8 snippet; `2313-sc1-prework-merged-commit.sh` behavior for the merged/ancestor path unchanged.
- commit: One commit scoped to the Step 8 snippet rewrite.

### Item 4 (SC-4): Exit Criteria and Result Contract reflect WARN states

- RED: Structural test asserting the Result Contract and Exit Criteria contain the WARN classification and do not declare pointer staleness a failure — fails against current prose.
- GREEN: Update Exit Criteria and Result Contract sections; verify `trunk-tip-enforcement.sh` assertions on `parent_clean`/`submodule_pointer_match` are updated without weakening the `SUBMODULE_UNMERGED_COMMIT` blocking assertion.
- verify: Static content check of both sections; grep of `trunk-tip-enforcement.sh` for stale FAIL assertions on the two checks.
- commit: One commit scoped to contract prose plus test-assertion sync.

### Item 5 (SC-5): Behavioral regression — SUBMODULE_UNMERGED_COMMIT still blocks

- RED: Pre-change run of the combined behavioral suite (existing gate tests + new safe-state scenario) fails.
- GREEN: Combined behavioral run passes with all changes applied; `SUBMODULE_UNMERGED_COMMIT` blocking preserved.
- verify: Full `with-test-home` suite run with >=600s timeout and `rm -f tmp/.behavior-run.lock` before re-runs.
- commit: Regression evidence artifact committed with the final item.

## Dependencies

| Reference | Relationship | Status |
|-----------|-------------|--------|
| michael-conrad/.opencode#2440 (bug report) | Source issue; this spec supersedes its body with the spec | Satisfied |
| michael-conrad/.opencode#2013 | Adjacent over-strictness in a different gate (pre-red-baseline SUBMODULE-DRIFT); confirms the safe-state/hazard-state conflation pattern — must be read for context, not modified | Satisfied (out of scope) |
| `.opencode/skills/git-workflow-branch/tasks/pre-work.md` | Consumer of the gate status contract; must treat WARN as non-blocking — read-only verification during implementation | Satisfied |
| `.opencode/tests-v2/with-test-home` | Mandatory test harness for all behavioral evidence | Satisfied |
| Research card `multi-feature-branch-main-with-submodules` (`.opencode/.issues/research-cards/`) | Findings incorporated into REQ-I2 (pointer staleness between releases is expected safe state) | Satisfied |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-2 | Item 2 |
| R-3 | SC-5 | Item 5 |
| R-4 | SC-1, SC-2 | Items 1, 2 |
| R-5 | SC-4 | Item 4 |
| R-6 | SC-3 | Item 3 |
| R-7 | SC-1, SC-2 | Items 1, 2 |
| R-8 | SC-1, SC-2, SC-5 | Items 1, 2, 5 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| trunk-tip-verification task card | code | `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` | Read — defects verified at Steps 2, 7, 8, Exit Criteria, Result Contract |
| Submodule pointer discipline | doc | `.opencode/AGENTS.md` §Submodule Pointer Updates | Read — confirms stale parent pointers after submodule trunk-tip pull are expected |
| pre-work task card | code | `.opencode/skills/git-workflow-branch/tasks/pre-work.md` | Read — consumes gate BLOCKED/DONE status |
| Behavioral tests | code | `.opencode/tests-v2/behaviors/trunk-tip-enforcement.sh`, `.opencode/tests-v2/behaviors/git-workflow/2313-sc1-prework-merged-commit.sh` | Read — assert SUBMODULE_UNMERGED_COMMIT blocking |
| Session evidence xBaseJ#65 | external | GitBucket `NewSRX-Tech-LLC/Patents` issue #65 | Live session verification (2026-09-08): failing and passing checks enumerated |
| Research card | doc | `.opencode/.issues/research-cards/multi-feature-branch-main-with-submodules.md` | Read — confidence 0.7, incorporated into REQ-I2 |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Running the safe-state behavioral test costs minutes of execution time — the defect is caught at gate 1 where the fix costs the same bounded delay. Skipping costs the full pipeline of rework — every submodule-scoped feature session rediscovering the BLOCKED-unsatisfiable state, wasting a session per feature.
- **SC-2:** Running the `+`-prefix behavioral assertion costs minutes. Skipping means the second false-positive signal ships unfixed and the gate stays unsatisfiable — the same per-session defect rediscovery, doubled.
- **SC-3:** Inspecting the Step 8 snippet statically costs one grep. Skipping means the invalid `continue` misbehaves or errors at runtime during a network outage — discovered under degraded conditions where diagnosis is most expensive.
- **SC-4:** Verifying the contract prose costs one read. Skipping means consumers (pre-work, future agents) implement against stale FAIL semantics and reintroduce blocking — a documentation-drift defect that surfaces as pipeline failures weeks later.
- **SC-5:** Running the full behavioral regression suite costs minutes. Skipping means a weakened `SUBMODULE_UNMERGED_COMMIT` check ships — the hazardous state (local-only pointer commit) passes pre-work silently, and the defect surfaces as a broken submodule pointer in a released build, costing 1000× more to diagnose and repair.

## Edge Cases

1. **Input boundary — all pointers stale vs. one stale:** The classification is per-submodule; a parent with mixed stale/clean submodule pointers classifies only the stale-safe entries as WARN. A single hazardous submodule (unmerged pointer commit) still BLOCKs the gate.
2. **State transition — network unreachable at Step 8:** The fail-open path skips the merged-commit check and emits the WARN-skip message (SKIP outcome, per existing step-8 semantics for unreachable remotes). Under this condition the safe-state predicate is incomplete; steps 2 and 7 SHALL NOT reclassify to WARN without the merged-commit result, and the existing skip semantics govern.
3. **Failure mode — genuine parent dirt alongside pointer dirt:** If `git status --porcelain` shows non-submodule modifications, `parent_clean` FAILs as before; the WARN classification applies only to the pointer-only subset of entries.
4. **Concurrency — behavioral suite lock contention:** Re-running the suite requires `rm -f tmp/.behavior-run.lock` first; a stale lock from a killed run otherwise hangs all subsequent runs.
5. **Recovery — test assertion drift:** If `trunk-tip-enforcement.sh` contains stale assertions on the old FAIL semantics, Item 4 updates them; the `SUBMODULE_UNMERGED_COMMIT` blocking assertion is regression-protected and MUST NOT be weakened (test-integrity mandate).

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
