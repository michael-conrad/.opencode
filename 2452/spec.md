---
remote_issue: 2452
remote_url: https://github.com/michael-conrad/.opencode/issues/2452
promoted_at: 2026-09-17T20:53:41Z
---

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2452/

## 1. Intent and Executive Summary

- **Problem Statement:** The brainstorming skill produces a handoff contract (`tmp/.../artifacts/preliminary/handoff.yaml` + 7 preliminary analytical artifacts) whose documented purpose is "enabling spec-creation to pick up where brainstorming left off without re-investigating." The spec-creation analyze step dispatches with only `{issue_number, project_root}` and never reads the handoff. Verified live 2026-09-17 on issue .opencode#2451: the developer approved a 6-part design in brainstorming; the analyze sub-agent — seeing only a title-only local issue with an empty body — independently derived a different 3-SC design, silently omitting 4 of the 6 approved parts.
- **Root Cause / Motivation:** The TDT analyze dispatch passes `{issue_number, project_root}` only — no handoff path field. The analyze task card does not instruct discovery of a brainstorming handoff. The handoff contract has no consumer wired into the spec-creation pipeline — it is produced but never read by design. The issue stub at analyze time carries title only, so the approved design exists nowhere the sub-agent can see.
- **Approach Chosen:** Belt-and-suspenders wiring (option 3 of the fix directions): thread an optional `brainstorm_handoff_path` through the analyze dispatch AND have brainstorming write a handoff pointer into the local issue directory at issue creation, so any clean-room reader discovers the approved design. The pointer covers dispatches that pre-date or bypass the context field.
- **Alternatives Considered & Why Discarded:** (a) Dispatch-path threading only — discarded: dispatches without the field (older callers, manual dispatches) still see a title-only stub, so silent drift persists. (b) Issue-directory pointer only — discarded: the explicit context field is the deterministic primary channel and costs one field; relying solely on discovery-by-glob leaves the primary path implicit. (c) Redesigning the handoff contract format — discarded: the format already exists and works; only its consumption is broken.
- **Key Design Decisions:** (1) `brainstorm_handoff_path` is an OPTIONAL dispatch-context field — absent field yields behavior identical to today, so the change is backward-compatible (tradeoff: two channels to keep in sync, accepted for coverage). (2) The pointer file lives in the local issue directory on the `issues-data` branch, never tracked by the parent repo (tradeoff: discovery requires issues-data checkout, which is guaranteed by the local-issues tool). (3) The handoff.yaml schema remains owned by brainstorming Step 2.5; the consumer reads it read-only (tradeoff: coupling is one-directional; upstream format changes propagate automatically). (4) Degraded mode (neither channel present) is documented, not an error — analyze proceeds with normal analysis (tradeoff: no halt on legacy paths, accepted because halting would break every non-brainstorm dispatch).
- **User Intent / Original Prompt:** Approved from brainstorming on .opencode#2452: "review the fix directions above and approve the belt-and-suspenders approach (option 3) or a subset" — the developer approved option 3.

## 2. Not Included

- **Handoff contract format redesign** — the schema owned by brainstorming Step 2.5 works; changing it expands blast radius without addressing the consumption defect.
- **Spec-to-plan / plan-to-pipeline handoff gates** — #1759 territory; a distinct handoff seam.
- **Retroactive remediation of already-created specs** — #2451's spec was already revised through the revise cycle; fixing it again here duplicates completed work.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The spec-creation TDT analyze dispatch context carries an optional `brainstorm_handoff_path` field, and when a dispatch supplies it, the analyze sub-agent reads the handoff artifact as primary design input — observable as a handoff-file read in the analyze sub-agent's stderr tool actions before producing the spec | behavioral | `opencode run` via `tests-v2/with-test-home` with a brainstorming handoff present; assert stderr shows the analyze dispatch and a handoff-file read (`assert_stderr_pattern_present`) |
| SC-2 | The brainstorming exploration-workflow writes a handoff pointer file into the local issue directory (`{issues_prefix}{N}/`) as part of issue creation, and the pointer references the existing handoff artifact path | behavioral | Behavioral run of the brainstorming explore path; assert the pointer file exists in the issue directory after issue creation (observable file output = runtime behavior); structural path check as secondary corroboration only |
| SC-3a | When the dispatch context field is absent but the issue-directory pointer exists, the analyze sub-agent discovers and reads the pointer target (observable discovery read in stderr) | behavioral | Behavioral run with handoff absent from dispatch context but pointer present; assert stderr shows the discovery read (`assert_stderr_pattern_present`) |
| SC-3b | When neither channel is present (no dispatch field, no pointer), analyze completes with current empty-stub behavior and does not halt | behavioral | Behavioral run with neither channel present; assert analyze completes without halt (regression check — run exits normally, no BLOCKED state) |

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

**Dependency DAG:** SC-3a and SC-3b each depend on SC-1 and SC-2 (the fallback-discovery run variants exercise both channels independently; SC-1 and SC-2 are independent of each other).

## 4. Requirements

- R-1. The spec-creation TDT analyze dispatch context SHALL include an optional `brainstorm_handoff_path` field.
- R-2. The analyze task card SHALL instruct the sub-agent to read the handoff artifact as primary design input when `brainstorm_handoff_path` is present, and SHALL treat absent handoff as a normal degraded mode (record handoff-unavailable, proceed — no halt).
- R-3. The brainstorming exploration-workflow SHALL write a handoff pointer file into the local issue directory at issue creation, referencing the handoff artifact path, following issue-directory naming/frontmatter conventions.
- R-4. The analyze task card SHALL instruct discovery of the issue-directory pointer when the dispatch context field is absent, loading the approved design from the pointer target.
- R-5. The pointer write SHALL refresh the pointer target whenever the brainstorming design is revised alongside the handoff contract update.

## 5. Items

### Item 1 (SC-1): Dispatch threading + handoff consumption

- RED: Behavioral run with brainstorming handoff present and `brainstorm_handoff_path` threaded; assert stderr shows analyze dispatch + handoff-file read — test fails before the SKILL.md/analyze.md change
- GREEN: Add the optional field to the TDT analyze dispatch context; add handoff-consumption instructions to the analyze task card preceding its analysis steps
- verify: Behavioral assertion via `assert_stderr_pattern_present`; no prose-recall prompts
- commit: Skill-deck text change + behavioral test, one working slice

### Item 2 (SC-2): Issue-directory pointer write

- RED: Behavioral run of the brainstorming explore path; assert pointer file exists in `{issues_prefix}{N}/` after issue creation — fails before the exploration-workflow change
- GREEN: Add pointer-write step to brainstorming exploration-workflow at issue creation, alongside the Step 2.5 handoff contract
- verify: Behavioral run; file existence observed as runtime output; structural check secondary
- commit: Skill-deck text change + behavioral test, one working slice

### Item 3a (SC-3a): Fallback pointer discovery (depends on Items 1 and 2)

- RED: Behavioral run with field absent + pointer present; assert discovery read in stderr — fails before analyze discovery instructions exist
- GREEN: Add pointer-discovery instructions to the analyze task card
- verify: Behavioral run; `assert_stderr_pattern_present` for the discovery read
- commit: Skill-deck text change + behavioral test, one working slice

### Item 3b (SC-3b): Degraded no-halt mode (depends on Items 1 and 2)

- RED: Behavioral run with neither channel present; assert analyze completes without halt — fails before degraded-mode documentation exists
- GREEN: Document degraded mode in the analyze task card (neither channel → current behavior, no halt)
- verify: Behavioral run; assert analyze completes without halt (no BLOCKED state)
- commit: Skill-deck text change + behavioral test, one working slice

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| brainstorming exploration-workflow Step 2.5 (handoff contract) | Producer of the handoff artifact this spec wires consumption for — must exist and define the payload | Satisfied (verified live 2026-09-17) |
| .opencode#1759 (spec-to-plan handoff gates) | Adjacent seam, explicitly out of scope; must not be regressed | Pending (tracked separately) |
| tests-v2 behavioral harness (`with-test-home`, stderr assertion helpers) | Verification infrastructure for all three SCs | Satisfied |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-1, SC-3b | Items 1, 3b |
| R-3 | SC-2 | Item 2 |
| R-4 | SC-3a | Item 3a |
| R-5 | SC-2 | Item 2 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Brainstorming exploration-workflow Step 2.5 | doc | `skills/brainstorming/SKILL.md` | Read (live, 2026-09-17) |
| spec-creation TDT analyze dispatch | doc | `skills/spec-creation/SKILL.md` | Read (live, 2026-09-17) — context is `{issue_number, project_root}` |
| Analyze task card | doc | `skills/spec-creation/tasks/analyze.md` | Read (live, 2026-09-17) — no handoff discovery instructions |
| Live case #2451 | issue | `.opencode/.issues/2451/` | Read (live, 2026-09-17) — superseded v1 spec vs approved 6-part design |
| tests-v2 behavioral harness | doc | `.opencode/tests-v2/AGENTS.md` | Read (live, 2026-09-17) |

## 9. Cost Frame

**Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.**

- **SC-1:** Threading the dispatch field costs one context-field edit plus one behavioral run (~minutes) — low. Skipping costs every handoff-enabled dispatch re-investigating from scratch or, worse, silently diverging from the approved design — a full revise cycle per occurrence, and the divergence is invisible until the developer rejects the spec.
- **SC-2:** Writing the pointer file costs one additional step in the exploration workflow and one behavioral run. Skipping costs the belt in belt-and-suspenders: any dispatch that bypasses the context field sees a title-only stub and drifts undetected — the exact #2451 failure.
- **SC-3a:** Implementing fallback discovery costs one task-card section plus one behavioral run variant. Skipping costs the deterministic guarantee that approved designs survive dispatch-path variance — legacy or manual dispatches remain silent-drift vectors.
- **SC-3b:** Documenting degraded no-halt mode costs one task-card paragraph plus one behavioral run variant. Skipping costs the no-halt regression coverage — without it, spurious BLOCKED states would surface across every non-brainstorm spec.

## 10. Edge Cases

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| Handoff artifact deleted from `tmp/` after pointer written (stale pointer) | Analyze records handoff-unavailable and proceeds with normal analysis — no halt | Degraded mode per R-2 |
| Neither dispatch field nor pointer present (brainstorming never ran) | Analyze proceeds with current empty-stub behavior — identical to today, no error | Documented degraded mode; SC-3b verifies no-halt |
| Both channels present with conflicting paths | Dispatch-context field wins as primary; pointer is fallback only | Channel precedence fixed: field > pointer |
| Pointer points at a path outside the issue's `tmp/{issue-N}/` scope | Analyze records handoff-unavailable; does not follow the out-of-scope path | Read-scope discipline in analyze task card |
| Concurrent revision of design during analyze | Analyze reads the handoff once at consumption step; later revisions flow through the normal spec revise cycle | Single-read semantics; revision via existing revise pipeline |

---

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-17 | Decomposed compound SC-3 into SC-3a (fallback pointer discovery) and SC-3b (degraded no-halt mode), each with its own item, RED/GREEN cycle, and cost-frame entry; updated dependency DAG and traceability (R-2 → SC-3b, R-4 → SC-3a); added shared computation-frame header to §9 | Validation finding: SC-3 was compound — bundled two independent behaviors joined by 'and', violating per-SC decomposition. Non-blocking: missing §9 frame header | Validation findings from spec-creation validation step (orchestrator-dispatched revise, issue .opencode#2452) |

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
