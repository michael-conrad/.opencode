---
title: '[SPEC] Shallow temp-copy build/test gate for release verification'
status: open
labels:
- needs-approval
- spec-draft
remote_issue: 2340
remote_url: https://github.com/michael-conrad/.opencode/issues/2340
promoted_at: '2026-08-26T18:31:19+00:00'
---

> **Full spec and artifacts: [`.opencode/.issues/2340/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2340)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2340/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Shallow temp-copy build/test gate for release verification

## 1. Intent and Executive Summary

| # | Field | Content |
|---|-------|---------|
| 1 | **Problem Statement** | The release-promoter skill tags and creates GitHub Releases without verifying that the release tree builds and tests successfully. A release with a broken build is promoted, and the defect is only discovered after tagging, requiring a re-release. |
| 2 | **Root Cause / Motivation** | release-promoter's tag.md and create-release.md proceed directly from a merged release PR to tag creation and release creation. There is no verification step that the release tree builds and tests against a clean, pinned-SHA checkout before promotion. A broken build must be caught before promotion, not after. |
| 3 | **Approach Chosen** | Add a verification gate to the release-promoter workflow that performs a shallow temp-copy checkout of the root repo at the release commit, resolves submodules to their gitlink-pinned SHAs (shallow per submodule), asserts that resolved SHA equals pinned SHA (drift assertion with hard fail), discovers and executes the repository's declared canonical build/test commands from AGENTS.md, and blocks promotion on any failure. |
| 4 | **Alternatives Considered & Why Discarded** | Running build/test directly in the working tree was considered but discarded: it does not represent a clean, pinned-SHA tree and can be contaminated by in-progress or uncommitted state. A full clone was considered but discarded: a shallow `--depth 1` clone at the release commit is sufficient and materially faster. |
| 5 | **Key Design Decisions** | (1) Build-system-agnostic: the gate reads the repo's declared canonical build/test commands from AGENTS.md rather than hardcoding a tool. (2) Deterministic: non-zero exit or drift = FAIL. (3) Pinned-SHA fidelity: submodules resolve via `git submodule update --init --depth 1` to gitlink-pinned SHAs, never `--remote`/`--recursive`. (4) Drift assertion prevents a green build of the wrong tree. |
| 6 | **User Intent / Original Prompt** | Add a shallow temp-copy build/test gate for release verification to the release-promoter skill. |

## 2. Not Included

- **Feature-merge CI pipeline** — Out of scope: the gate is a release-time verification step, not a change to the feature-merge CI pipeline.
- **Submodule SHA pinning on feature PRs** — Out of scope: how feature PRs pin submodule SHAs is unchanged.
- **release-promoter tag/creation logic** — Out of scope beyond adding the verification gate. Existing `tag` and `create-release` behavior is preserved.
- **Pre-existing defect: `release-promoter/tasks/completion.md`** — Referenced in SKILL.md but the file does not exist (critical-rules-074). Flagged as a finding; not in scope for this spec.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The gate performs a shallow (`--depth 1`) clone of the root repo at the release commit into a temp directory, producing a shallow checkout at that commit. | structural | Verify the clone command and result with `git` inspection against a fixture repo. |
| SC-2 | Submodules are resolved to their gitlink-pinned SHAs using `git submodule update --init --depth 1`, never `--remote` or `--recursive`. | structural | Inspect resolved SHAs against gitlink-pinned SHAs in a fixture repo. |
| SC-3 | The gate asserts that each resolved submodule SHA equals its gitlink-pinned SHA; any drift hard-fails the gate. | behavioral | Test executing the drift path against resolved vs pinned SHAs; drift → FAIL. |
| SC-4 | The gate discovers and executes the repository's declared canonical build/test commands from the repo's AGENTS.md, asserting zero failures (non-zero exit = FAIL). | behavioral | Integration test executing the repo's declared commands against a real checkout. |
| SC-5 | The PASS/FAIL gate runs once per release. | behavioral | Behavioral test via `opencode run` dispatching release-promoter; assert the gate executes exactly once per release. |
| SC-6 | The PASS/FAIL gate blocks release promotion (tag creation / release creation) on any failure; promotion proceeds only on PASS. | behavioral | Behavioral test via `opencode run` dispatching release-promoter with a failing gate; assert promotion is blocked. |

## 4. Requirements

- R-1. The gate SHALL perform a shallow clone (`--depth 1`) of the root repo at the release commit into a temporary directory.
- R-2. The gate SHALL resolve submodules to their gitlink-pinned SHAs.
- R-3. The gate SHALL use `git submodule update --init --depth 1` for submodule resolution and SHALL NOT use `--remote` or `--recursive`.
- R-4. The gate SHALL assert that each resolved submodule SHA equals the gitlink-pinned SHA.
- R-5. The gate SHALL discover and execute the repository's declared canonical build/test commands from the repo's AGENTS.md.
- R-6. The gate SHALL be build-system-agnostic, reading the repo's declared build/test commands from AGENTS.md rather than hardcoding a tool.
- R-7. The gate SHALL be deterministic: non-zero exit or drift = FAIL, zero failures = PASS.
- R-8. The gate SHALL run once per release.
- R-9. The gate SHALL block release promotion (tag creation and release creation) on any failure.
- R-10. The gate SHALL be integrated into the release-promoter workflow as a new step before tag creation.
- R-11. The gate SHALL NOT modify release-promoter tag/creation logic beyond adding the verification gate.

## 5. Items

### Item 1 (SC-1): Shallow temp-copy checkout at release commit

- RED: Enforcement test asserts a shallow `git clone --depth 1` produces a checkout at the release commit; currently no clone step exists → fails.
- GREEN: Implement the shallow clone step into the verify-build task.
- verify: Verify shallow checkout (depth 1) and HEAD == release commit.
- commit: Commit the verify-build task + test.

### Item 2 (SC-2): Submodule resolution to gitlink-pinned SHAs

- RED: Enforcement test asserts submodules resolve to gitlink-pinned SHAs and that update never uses `--remote`/`--recursive`; currently no submodule resolution → fails.
- GREEN: Implement `git submodule update --init --depth 1` in the verify-build task.
- verify: Verify resolved SHAs match pinned SHAs; verify command shape excludes `--remote`/`--recursive`.
- commit: Commit the submodule resolution + test.

### Item 3 (SC-3): Drift assertion (resolved SHA == pinned SHA)

- RED: Enforcement test asserts a drifted SHA causes a hard FAIL; currently no drift assertion → fails.
- GREEN: Implement SHA == pinned comparison with hard fail on any drift.
- verify: Execute the drift path against resolved vs pinned SHAs; assert PASS when all match, FAIL on any drift (behavioral evidence).
- commit: Commit the drift assertion + test.

### Item 4 (SC-4): Discover and execute declared canonical build/test commands

- RED: Enforcement test asserts the repo's declared build/test commands are executed and non-zero exit = FAIL; currently no execution → fails.
- GREEN: Implement discovery and execution of the repo's declared build/test commands from AGENTS.md.
- verify: Execute declared commands against a real checkout; assert zero failures = PASS, non-zero = FAIL.
- commit: Commit the build/test execution + test.

### Item 5 (SC-5): PASS/FAIL gate runs once per release

- RED: Behavioral test asserts the gate runs exactly once per release; currently no gate exists → fails.
- GREEN: Integrate the gate into release-promoter (SKILL.md dispatch table, tag.md prerequisite) so it runs once per release.
- verify: Behavioral test via `opencode run`; assert the gate executes exactly once per release.
- commit: Commit the gate integration + behavioral test.

### Item 6 (SC-6): PASS/FAIL gate blocks release promotion

- RED: Behavioral test asserts promotion is blocked on a FAILing gate; currently promotion proceeds unverified → fails.
- GREEN: Wire the gate so a FAIL blocks tag creation and release creation; promotion proceeds only on PASS.
- verify: Behavioral test via `opencode run` with a FAILing gate; assert promotion is blocked.
- commit: Commit the gate-block behavior + behavioral test.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/AGENTS.md` "Build / Lint / Test Commands" | Source of the declared canonical build/test command set the gate reads. | Satisfied |
| `release-promoter/SKILL.md` | Trigger Dispatch Table must gain the `verify-build` task entry. | Satisfied |
| `release-promoter/tasks/tag.md`, `create-release.md`, `operating-protocol.md` | Gate is inserted as prerequisite before tag creation; create-release is downstream; operating-protocol documents the gate. | Satisfied |
| multi-feature-branch-main-with-submodules research card | Supports the drift-assertion mitigation. | Satisfied |
| spec-writing-ai-agents-opencode-skill-architecture research card | Requires deterministic, testable gate rules. | Satisfied |

## 7. Traceability

| Requirement | SC(s) |
|-------------|-------|
| R-1 | SC-1 |
| R-2, R-3 | SC-2 |
| R-4 | SC-3 |
| R-5, R-6, R-7 | SC-4 |
| R-7, R-8 | SC-5 |
| R-9, R-10, R-11 | SC-6 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `.opencode/AGENTS.md` | config | `.opencode/AGENTS.md` | Read during analysis; "Build / Lint / Test Commands" table |
| `release-promoter/SKILL.md` | skill card | `.opencode/skills/release-promoter/SKILL.md` | Read during analysis; Trigger Dispatch Table |
| `release-promoter/tasks/tag.md` | task card | `.opencode/skills/release-promoter/tasks/tag.md` | Read during analysis; pre-tag steps |
| `release-promoter/tasks/create-release.md` | task card | `.opencode/skills/release-promoter/tasks/create-release.md` | Read during analysis; depends on tag |
| multi-feature-branch-main-with-submodules research card | research | `.opencode/.issues/research-cards/` | Read during analysis; confidence 0.7, submodule drift risk |
| spec-writing-ai-agents-opencode-skill-architecture research card | research | `.opencode/.issues/research-cards/` | Read during analysis; confidence 0.90, deterministic/testable rules |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Performing the shallow-checkout unit test costs one git-inspection call against a fixture. Skipping it means a structurally wrong checkout is not caught until the first release promotion runs the gate and fails on the release tree.
- SC-2: Verifying submodule resolution costs one submodule-status inspection. Skipping it means submodules resolve to latest rather than pinned SHAs, and the build runs on the wrong tree until drift or a build failure surfaces it.
- SC-3: Executing the drift path (drifted submodule SHA vs pinned SHA) costs one behavioral test run. Skipping it means a drifted submodule produces a green build of the wrong tree, discovered only after promotion when the released tree fails.
- SC-4: Executing the repo's declared build/test commands costs minutes of execution. Skipping it means a broken release tree ships unchanged to production, costing the full rework cycle (diagnose + fix + re-CI + redeploy) — a death spiral.
- SC-5: Running the behavioral run-once-per-release test costs minutes of `opencode run` execution. Skipping it means a gate that runs more than once per release (or not at all) ships without the intended verification cadence.
- SC-6: Running the behavioral gate-block test costs minutes of `opencode run` execution. Skipping it means a FAIL gate that fails to block promotion ships the defect to the released artifact — the behavior the gate exists to prevent.

## 11. Edge Cases

- **Input boundary — clone failure:** Condition: `git clone --depth 1` fails. Expected: gate FAILs, no checkout acquired. Resolution: promotion is blocked.
- **Input boundary — submodule init failure:** Condition: `git submodule update --init --depth 1` fails. Expected: gate FAILs, no submodules resolved. Resolution: promotion is blocked.
- **State transition — drift:** Condition: resolved submodule SHA differs from pinned SHA. Expected: gate FAILs (BUILD_TEST_FAILED terminal). Resolution: promotion is blocked.
- **State transition — build/test failure:** Condition: a declared build/test command exits non-zero. Expected: gate FAILs (BUILD_TEST_FAILED terminal). Resolution: promotion is blocked; report the failing command.
- **State transition — gate not wired:** Condition: verify-build is not integrated into release-promoter. Expected: promotion proceeds unverified. Resolution: Item 6 behavioral test catches the defect.
- **Failure mode — missing declared commands:** Condition: repo AGENTS.md lacks a build/test command entry. Expected: the gate FAILs with a clear missing-manifest error rather than skipping verification. Resolution: no commands to execute is treated as a gate failure, not a silent PASS.
- **Concurrency:** Condition: the gate runs once per release. No concurrent promotion paths exist; the release-promoter workflow is serial. Resolution: no additional concurrency control required.
- **Recovery:** Condition: BUILD_TEST_FAILED. Expected: promotion blocked; the failure is reported. Resolution: the developer must fix the build or the drift and re-run the gate before promotion is permitted.

## Notes

- Pre-existing defect: `release-promoter/tasks/completion.md` is referenced in SKILL.md but the file does not exist (critical-rules-074). Not in scope for this spec; flagged as a finding for separate remediation.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-26 | SC-4 evidence type reclassified from `semantic` to `behavioral`; removed the "or equivalent build manifest" escape hatch, pinning the command source to the repo's AGENTS.md (SC-4, R-5, R-6, Item 4, exec-summary body). | Validation finding: SC-4's verification method (integration test execution) is behavioral evidence per the canonical taxonomy — EVIDENCE_TYPE_MISMATCH; the "or equivalent" fallback is a determinism violation. | spec-creation validation pipeline |
| 2026-08-26 | Decomposed compound SC-5 into atomic SC-5 (runs once per release) and SC-6 (blocks release promotion on failure); updated SC table, sc-summary.yaml, requirements traceability, Items, Cost Frame, and Edge Cases. | Validation finding: SC-5 bundled two independently verifiable claims. | spec-creation validation pipeline |
| 2026-08-26 | SC-3 evidence type reclassified from `structural` to `behavioral`; updated SC table, sc-summary.yaml, Item 3, and Cost Frame. | Validation finding: SC-3's verification method (test executing the drift path and asserting the gate hard-fails) is behavioral evidence per the canonical taxonomy — EVIDENCE_TYPE_MISMATCH; matches the SC-4 precedent. | spec-creation validation pipeline |

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash) created
