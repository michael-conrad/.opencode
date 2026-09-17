---
remote_issue: 2452
remote_url: https://github.com/michael-conrad/.opencode/issues/2452
promoted_at: 2026-09-17T20:53:41Z
---

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2452/

## Problem Statement

The brainstorming skill produces a handoff contract (`tmp/.../artifacts/preliminary/handoff.yaml` + 7 preliminary analytical artifacts) whose documented purpose is "enabling spec-creation to pick up where brainstorming left off without re-investigating." The spec-creation analyze step dispatches with only `{issue_number, project_root}` and never reads the handoff. Verified live 2026-09-17 on issue .opencode#2451: the developer approved a 6-part design in brainstorming; the analyze sub-agent — seeing only a title-only local issue with an empty body — independently derived a different 3-SC design. The created spec silently omitted 4 of the 6 approved parts (257 canonical pattern, 091 Tier-1 bright-line, tests-v2 §15/§6a loophole closure, content-verification scenario) and prescribed a behavioral method (stderr assertions) that tests-v2/AGENTS.md §2 forbids. Developer rejection ("what a useless spec") was required to catch the drift; the spec then needed a full revise cycle plus artifact regeneration to reach fidelity.

## Root Cause

1. The spec-creation TDT analyze dispatch passes `{issue_number, project_root}` only — no handoff path field.
2. The analyze task card does not instruct discovery of a brainstorming handoff artifact.
3. The handoff contract (`handoff.yaml`, brainstorming exploration-workflow Step 2.5) has no consumer wired into the spec-creation pipeline — it is produced but never read by design.
4. The issue stub at analyze time carries title only; the approved design exists nowhere the sub-agent can see.

## Impact

Every spec created through the standard brainstorm→spec-creation path can silently diverge from the developer-approved design. Detection currently depends on the developer reading the spec and rejecting it — the exact rejection→discard→restart cost the workflow exists to prevent.

## Scope

- Thread the brainstorming handoff path through the spec-creation analyze dispatch (TDT context `{issue_number, project_root, brainstorm_handoff_path}`) and have the analyze task card consume it as primary design input when present
- Have brainstorming write the handoff (or a pointer to it) into the local issue directory at issue creation, so any clean-room reader of the issue discovers the approved design
- Belt-and-suspenders wiring: the issue-directory pointer also covers analyze dispatches that pre-date the dispatch-context change

**Out of scope:**
- Redesigning the brainstorming handoff contract format itself
- Spec-to-plan / plan-to-pipeline handoff gates (#1759 territory)
- Retroactive remediation of already-created specs

## Approach

Fix directions for review:

1. Thread the handoff path through the analyze dispatch (TDT context `{issue_number, project_root, brainstorm_handoff_path}`) and have the analyze task card consume it as primary design input when present.
2. Have brainstorming write the handoff (or a pointer to it) into the local issue directory at issue creation, so any clean-room reader of the issue discovers the approved design.
3. Both — belt and suspenders; (2) also covers dispatches that pre-date (1).

## Impact

Top risks:

1. **Silent spec drift persists** if only the dispatch path is fixed — mitigation: the issue-directory pointer covers dispatches that never receive the handoff context field.
2. **Clean-room sub-agents still see a title-only issue stub** — mitigation: pointer file discovered by the analyze task card's discovery instructions.
3. **Handoff artifact becomes stale** if the design changes after brainstorming — mitigation: revision flows rewrite the pointer target alongside spec revision.

Key dependency: brainstorming exploration-workflow Step 2.5 handoff contract already exists and defines the payload; this issue wires its consumption, not its format.

Call to action: review the fix directions above and approve the belt-and-suspenders approach (option 3) or a subset.

## Verification Evidence

- Brainstorming skill exploration-workflow Step 2.5 defines the handoff contract and states spec-creation consumes it.
- Spec-creation SKILL.md TDT: analyze dispatch context is `{issue_number, project_root}` — no handoff field.
- Live case: .opencode#2451 v1 spec (superseded) vs the developer-approved 6-part design; revision dispatch restored fidelity; aggregate validation then PASSed on all 11 dimensions + 12 structural checks.

Related (distinct scope): #1759 (spec-to-plan handoff gates), #1834 (holistic spec-creation fix).

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
🤖 OpenCode (huggingface/zai-org/GLM-5.3-Flash) created
