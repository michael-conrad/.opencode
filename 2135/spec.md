---
remote_issue: 2135
remote_url: https://github.com/michael-conrad/.opencode/issues/2135
labels: [spec]
---

## Intent and Executive Summary

- **Problem Statement**: `130-authority-source.md` asserts "code wins" — the filesystem is the only absolute source of truth. This framing is backwards for a spec-driven project where specs are the primary artifact for intent, the authorization mechanism, and the review target.
- **Root Cause / Motivation**: The project's own workflow demonstrates specs drive implementation, specs authorize changes, specs are what gets reviewed. The "code wins" position contradicts the project's actual practice. The guideline needs a dual-authority model: spec authoritative for intent, code authoritative for state.
- **Approach Chosen**: Complete rewrite of `130-authority-source.md` establishing a dual-authority principle, 6 rules, and relocation of 3 superseded sections to target files (spec-creation SKILL.md, 065-verification-honesty.md).
- **Alternatives Considered**: (1) Minimal patch — add a note that specs are authoritative for intent while keeping "code wins" for state. Rejected because the contradiction would cause confusion. (2) Single-authority (spec wins) — rejected because code is the only reliable source for current state. (3) Dual-authority — chosen as the correct model.
- **Key Design Decisions**: (1) Spec is authoritative for intent, code for state — neither wins absolutely. (2) Removed sections go to spec-creation SKILL.md (Superseding Issues + Plan Audit) and 065-verification-honesty.md (Verification First). (3) Semantic preservation is verified by clean-room sub-agent with content checklists, not grep.

## Problem

`130-authority-source.md` currently asserts "code wins" — the filesystem is the only absolute source of truth. This framing is backwards for a spec-driven project where specs are the primary artifact for intent, the authorization mechanism, and the review target. The project's own workflow demonstrates this: specs drive implementation, specs authorize changes, specs are what gets reviewed. The "code wins" position contradicts the project's actual practice.

## Proposed Solution

Complete rewrite establishing a dual-authority model:

### Principle

- **The spec is authoritative for intent** — what the system should do. The spec defines requirements, success criteria, and behavior.
- **The code is authoritative for current state** — what the system actually does. The code is the implementation of the spec.
- **Neither wins absolutely.** They converge through revision.

### Rules

1. **Spec for intent, code for state** — When a spec makes an incorrect claim about current code behavior, revise the spec to match reality (Documentation Drift Protocol). When code fails to implement the spec's intent, fix the code.

2. **Spec before code** — Every code change requires an approved spec. The spec defines what to build; the code implements it. (Already in 010-approval-gate.md.)

3. **Documentation Drift Protocol** — When spec and code diverge on matters of fact (the spec describes behavior the code doesn't have, or the code has behavior the spec doesn't describe), update the spec to reflect current state. This is an administrative sync, not a code change.

4. **Spec revision revokes plan approval** — If a spec is revised (substantive change to intent), linked plan approvals are revoked per approval-gate-006.

5. **Suppression of Reactive Remediation** — Do not change code to match a spec that is wrong about current state. Fix the spec first, then decide if the code needs changing.

6. **Verification against spec** — Before claiming completion, verify the code implements the spec's success criteria. The spec is the benchmark; the code is measured against it.

### Remove

- Rule 2 (Superseding Issues + Overlap Detection Checklist) — move to `spec-creation` skill card
- Rule 6 (Verification First) — already in 065
- Rule 8 (Plan Audit Code Deep Dive) — move to `spec-creation` skill card (alongside Superseding Issues content)

## Requirements

| ID | Requirement | Source |
|----|-------------|--------|
| REQ-1 | Spec for intent, code for state — When a spec makes an incorrect claim about current code behavior, revise the spec to match reality. When code fails to implement the spec's intent, fix the code. | Rule 1 |
| REQ-2 | Spec before code — Every code change requires an approved spec. | Rule 2 |
| REQ-3 | Documentation Drift Protocol — When spec and code diverge on matters of fact, update the spec to reflect current state as an administrative sync. | Rule 3 |
| REQ-4 | Spec revision revokes plan approval — Substantive spec revision revokes linked plan approvals per approval-gate-006. | Rule 4 |
| REQ-5 | Suppression of Reactive Remediation — Do not change code to match a spec that is wrong about current state; fix the spec first. | Rule 5 |
| REQ-6 | Verification against spec — Before claiming completion, verify the code implements the spec's success criteria. | Rule 6 |
| REQ-7 | Dual-authority principle — The spec is authoritative for intent; the code is authoritative for current state. Neither wins absolutely. | Principle |
| REQ-8 | Removed sections preservation — All semantic content from removed sections (Superseding Issues, Verification First, Plan Audit Code Deep Dive) is preserved in target locations. | Remove |
| REQ-9 | No mechanical compaction — Only semantic analysis determines what stays or goes; word count, line count, or quantitative metrics are not compaction targets. | Risks |

## Traceability

| Requirement | Success Criteria | Phase |
|-------------|-----------------|-------|
| REQ-1 | SC-2 | Phase 2 |
| REQ-2 | SC-3 | Phase 2 |
| REQ-3 | SC-4 | Phase 2 |
| REQ-4 | SC-5 | Phase 2 |
| REQ-5 | SC-6 | Phase 2 |
| REQ-6 | SC-7 | Phase 2 |
| REQ-7 | SC-1 | Phase 1 |
| REQ-8 | SC-8a, SC-8b, SC-9a, SC-9b, SC-10a, SC-10b, SC-11a, SC-11b, SC-11c | Phase 3, Phase 5 |
| REQ-9 | SC-12 | Phase 4, Phase 5 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Dual-authority principle stated (spec for intent, code for state) | string | grep for 'spec is authoritative for intent' |
| SC-2 | Rule 1: Spec for intent, code for state | semantic | Clean-room sub-agent reads guideline and verifies ALL of: (a) the phrase 'spec is authoritative for intent' is present, (b) the phrase 'code is authoritative for current state' is present, (c) a statement that when spec and code diverge on matters of fact, the spec is updated to match reality. Cost: one sub-agent dispatch + two file reads. |
| SC-3 | Rule 2: Spec before code | semantic | Clean-room sub-agent reads guideline and verifies ALL of: (a) the phrase 'every code change requires an approved spec' is present, (b) grep for absence of the following exception phrases in the rule's section: 'unless', 'except when', 'may be skipped', 'optionally'. Cost: one sub-agent dispatch + one file read. |
| SC-4 | Rule 3: Documentation Drift Protocol | semantic | Clean-room sub-agent reads guideline and verifies ALL of: (a) the phrase 'Documentation Drift Protocol' is present, (b) a statement that updating the spec to match code state is an administrative sync (not a code change). Cost: one sub-agent dispatch + one file read. |
| SC-5 | Rule 4: Spec revision revokes plan approval | semantic | Clean-room sub-agent reads guideline and verifies ALL of: (a) the phrase 'spec revision revokes plan approval' is present, (b) a reference to approval-gate-006 is present. Cost: one sub-agent dispatch + one file read. |
| SC-6 | Rule 5: Suppression of Reactive Remediation | semantic | Clean-room sub-agent reads guideline and verifies ALL of: (a) the phrase 'Suppression of Reactive Remediation' is present, (b) a statement that code must not be changed to match a spec that is wrong about current state. Cost: one sub-agent dispatch + one file read. |
| SC-7 | Rule 6: Verification against spec | semantic | Clean-room sub-agent reads guideline and verifies ALL of: (a) the phrase 'Verification against spec' is present, (b) a statement that the spec is the benchmark and code is measured against it. Cost: one sub-agent dispatch + one file read. |
| SC-8a | Superseding Issues section absent from 130-authority-source.md | semantic | Clean-room sub-agent reads 130-authority-source.md and confirms the Superseding Issues + Overlap Detection Checklist section is absent from the original location. Cost: one sub-agent dispatch + one file read. |
| SC-8b | Superseding Issues content present in spec-creation SKILL.md | semantic | Clean-room sub-agent reads spec-creation SKILL.md and verifies the Superseding Issues + Overlap Detection Checklist content is present in the target location. Cost: one sub-agent dispatch + one file read. |
| SC-9a | Verification First section absent from 130-authority-source.md | semantic | Clean-room sub-agent reads 130-authority-source.md and confirms the Verification First section is absent from the original location. Cost: one sub-agent dispatch + one file read. |
| SC-9b | Verification First content present in 065-verification-honesty.md | semantic | Clean-room sub-agent reads 065-verification-honesty.md and verifies the Verification First content is present in the target location. Cost: one sub-agent dispatch + one file read. |
| SC-10a | Plan Audit Code Deep Dive section absent from 130-authority-source.md | semantic | Clean-room sub-agent reads 130-authority-source.md and confirms the Plan Audit Code Deep Dive section is absent from the original location. Cost: one sub-agent dispatch + one file read. |
| SC-10b | Plan Audit content present in spec-creation SKILL.md | semantic | Clean-room sub-agent reads spec-creation SKILL.md and verifies the Plan Audit Code Deep Dive content is present. Cost: one sub-agent dispatch + one file read. |
| SC-11a | Superseding Issues semantic preservation | semantic | Clean-room sub-agent reads both source (spec-creation SKILL.md) and original (130-authority-source.md) files, and verifies ALL of the following content items from the original Superseding Issues section are present in spec-creation SKILL.md: (a) the four-tier classification (FULL-SUPERSESSION, PARTIAL-OVERLAP, CONFLICT-RISK, INDEPENDENT), (b) the overlap detection checklist items (file-level search, symbol-level search, concern boundary comparison), (c) the evidence artifacts recording format. Cost: one sub-agent dispatch + two file reads. |
| SC-11b | Verification First semantic preservation | semantic | Clean-room sub-agent reads both source (065-verification-honesty.md) and original (130-authority-source.md) files, and verifies ALL of the following content items from the original Verification First section are present in 065-verification-honesty.md: (a) the requirement to verify filename/symbol existence before use in tool calls, (b) the Drift Protocol trigger condition (if the file does not exist, trigger the Drift Protocol). Cost: one sub-agent dispatch + two file reads. |
| SC-11c | Plan Audit semantic preservation | semantic | Clean-room sub-agent reads both source (spec-creation SKILL.md) and original (130-authority-source.md) files, and verifies ALL of the following content items from the original Plan Audit Code Deep Dive section are present in spec-creation SKILL.md: (a) the requirement to follow mandatory code deep dive when auditing plans, (b) the requirement to ground every audit finding in the actual filesystem and source code. Cost: one sub-agent dispatch + two file reads. |
| SC-12 | Rewrite does not use word count, line count, or any quantitative metric as a compaction target | semantic | Clean-room sub-agent reads the final guideline file and verifies NONE of the following mechanical compaction artifacts are present: (a) grep for absence of 'removed for length', 'truncated', 'compacted to fit', 'shortened for size', 'abbreviated for space' in the file, (b) clean-room sub-agent reads the file and verifies no content-free section headers (a heading with no body text below it) exist. Cost: one sub-agent dispatch + one file read. |

## SC Enforcement Gate

All SCs (SC-1 through SC-12) must pass with clean verdicts before the implementation is accepted. A single FAIL blocks acceptance. No SC may be deferred, weakened, or removed to achieve a pass.

## Edge Cases and Error Recovery

The following edge cases are defined for the implementation:

| Edge Case | Recovery Procedure |
|-----------|-------------------|
| Target file (spec-creation SKILL.md) does not exist at implementation time | HALT. Report missing target file. Do not create the file — the spec-creation SKILL.md must exist before content relocation. |
| Source section not found at expected location in 130-authority-source.md | HALT. Report that the section was not found. The spec's assumption about section location may be stale — verify current file state and update the spec if needed. |
| Semantic preservation check (Phase 5) reveals content loss | HALT. Report which content items are missing. Do not accept the implementation. The missing content must be restored before proceeding. |
| Target file already contains overlapping content | HALT. Report the overlap. Do not duplicate content. The existing content in the target file must be reconciled with the relocated content. |
| Mechanical compaction artifact detected in final guideline | HALT. Report the artifact location. The compaction must be reversed and the content restored before proceeding. |

## Implementation Plan

### Phase 1: Write new dual-authority principle [REQ-7]
### Phase 2: Write 6 new rules [REQ-1 through REQ-6]
### Phase 3: Remove superseded rules and relocate content [REQ-8]
  - Move Superseding Issues + Overlap Detection Checklist to spec-creation SKILL.md
  - Move Verification First to 065-verification-honesty.md
  - Move Plan Audit Code Deep Dive to spec-creation SKILL.md
### Phase 4: Verify all 6 rules present and removed content absent [REQ-9]
### Phase 5: Clean-room semantic audit — verify no content loss [REQ-8, REQ-9]
  - Dispatch clean-room sub-agent to verify SC-11a, SC-11b, SC-11c, SC-12

## Files Affected

- `.opencode/guidelines/130-authority-source.md` — rewritten
- `.opencode/skills/spec-creation/SKILL.md` — receives Superseding Issues + Overlap Detection Checklist + Plan Audit Code Deep Dive
- `.opencode/guidelines/065-verification-honesty.md` — receives Verification First content

## Risks

- **Confusion between intent and state**: Agents may struggle to distinguish "spec is wrong about current state" from "code doesn't implement spec intent." Mitigation: each rule includes concrete examples of both failure modes.
- **Cross-reference breakage**: Other files referencing the old "code wins" framing. Mitigation: grep for 'code wins' and 'code is the only absolute source of truth' across the codebase.
- **Mechanical compaction**: The rewrite must not use word count, line count, or any quantitative metric as a compaction target. Only semantic analysis determines what stays or goes. Mitigation: SC-12 explicitly prohibits mechanical compaction, verified by clean-room sub-agent.

## Dependencies

- None.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
