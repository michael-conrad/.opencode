# Plan: [SPEC] Holistic Fix Spec for spec-creation Skill

**Issue:** [michael-conrad/.opencode#1834](https://github.com/michael-conrad/.opencode/issues/1834)
**Authorization Scope:** `for_pr` — plan auto-approved per cascade (approved-for-pr label present)
**Plan created:** 2026-07-10

## Goal

Apply nine mandatory fixes to the spec-creation skill task files to close quality gaps: remove the complexity escape hatch, add research card consultation, add live doc URL verification, add interdependency checking, strengthen SC-fail cascading, add anti-lobotomization language, fix contract naming drift, add #1063 pipeline enforcement gates, verify/close stale issues, and create a research card.

## Architecture

The spec-creation skill lives at `.opencode/skills/spec-creation/`. Six files are modified:
- `tasks/create.md` — primary target (escape hatch, preamble sections, interdependency, live URL, #1063 gates)
- `tasks/operating-protocol.md` — add research card step, interdependency step, contract ref updates
- `tasks/requirements.md` — add research card check
- `contracts/write-input-template.yaml` → `contracts/create-input-template.yaml` (rename)
- `contracts/write-output-template.yaml` → `contracts/create-output-template.yaml` (rename)
- `SKILL.md` — update contract references

One new file: `.opencode/.issues/research-cards/spec-creation-state.md`

Two stale issues to verify/close: #1229, #1064

## Affected Files

| File | Change Summary |
|------|---------------|
| `skills/spec-creation/tasks/create.md` | Remove escape hatch, add preamble sections (SC-fail cascading, anti-lobotomization), add interdependency section, add live URL verification, add #1063 gates |
| `skills/spec-creation/tasks/operating-protocol.md` | Add research card consultation step, interdependency checking step, update contract references write-* → create-* |
| `skills/spec-creation/tasks/requirements.md` | Add research card check step |
| `skills/spec-creation/contracts/write-input-template.yaml` | Rename to create-input-template.yaml |
| `skills/spec-creation/contracts/write-output-template.yaml` | Rename to create-output-template.yaml |
| `skills/spec-creation/SKILL.md` | Update contract references from write-* to create-* |
| `.opencode/.issues/research-cards/spec-creation-state.md` | New file documenting current state |

## Phase Table

| Phase | Description | Dependency | SCs |
|-------|-------------|------------|-----|
| 1 | Remove complexity escape hatch (#1552) | none | SC-1, SC-2 |
| 2 | Add research card consultation mandate | Phase 1 | SC-3, SC-4 |
| 3 | Add live documentation URL verification | Phase 2 | SC-5, SC-6 |
| 4 | Add interdependency checking and marking | Phase 3 | SC-7, SC-8 |
| 5 | Strengthen SC-fail cascading statement | Phase 4 | SC-9 |
| 6 | Add anti-lobotomization language | Phase 5 | SC-10, SC-11 |
| 7 | Fix contract file naming drift | Phase 6 | SC-12 |
| 8 | Add missing #1063 pipeline enforcement gates | Phase 7 | SC-13, SC-14, SC-15 |
| 9 | Verify and close stale open issues | Phase 8 | SC-16, SC-17 |
| 10 | Create research card | Phase 9 | SC-18 |

**Cross-cutting:** SC-19 (behavioral tests RED state), SC-20 (no SC weakening) — verified once in Phase 1, applies to all phases.

## Exit Criteria

1. All 10 phases implemented with SCs passing all verification methods
2. Behavioral enforcement tests exist in `.opencode/tests/behaviors/` showing RED→GREEN transition
3. Plan artifacts committed to `feature/1834-spec-creation-holistic-fix` branch
4. Plan validated as SAT by solve check
5. No SC weakened, deferred, or reclassified to lower evidence type

## Implementation Pipeline Gate Steps

Every plan phase below enumerates the full implementation pipeline with correct skill/task references per `implementation-pipeline/SKILL.md` Trigger Dispatch Table:

- **Coherence gate** (pre-RED): verify spec SCs are coherent with codebase
- **Pre-red-baseline**: establish current state before changes
- **RED**: write behavioral enforcement test that FAILS before change
- **GREEN**: make the change, verify test PASSES
- **VbC**: verification-before-completion per SC evidence type
- **Audit**: independent audit of deliverable
- **Cross-validate**: second independent verification
- **Regression check**: verify existing behavior unchanged
- **Finishing checklist**: finishing-a-development-branch checklist
- **Review-prep**: git-workflow review-prep
- **Cleanup**: git-workflow cleanup

## Admonishments

> **Compliance Requirement:** All steps and sub-steps in this plan MUST be followed in order. Failure to comply with any step will result in the feature branch being rejected and discarded.

> **SC-Fail Cascading:** Any SC that is skipped, deferred, weakened, or otherwise bypassed marks ALL SCs as FAIL. 100% clean PASS on ALL SCs is the only acceptable outcome.

> **Anti-Lobotomization:** Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion is a CRITICAL VIOLATION.

> **Plans are local artifacts only.** Do NOT create GitHub Issues for plan phases or sub-issues. Phase tracking is local `.issues/1834/plan-{NN}.md` only.

## Self-Review Evidence

This plan was created by reading:
- Issue #1834 body and comments
- `spec-creation/tasks/create.md` (current state)
- `spec-creation/tasks/operating-protocol.md` (current state)
- `spec-creation/tasks/requirements.md` (current state)
- `spec-creation/SKILL.md` (current state)
- `spec-creation/contracts/` (write-input-template.yaml, write-output-template.yaml)
- `.opencode/.issues/research-cards/` (existing research cards)
- `.opencode/.issues/1834/spec.md` (spec artifact)
- `.opencode/.issues/1834/sc-summary.yaml` (SC coverage)

Issue has `approved-for-pr` label — authorization scope `for_pr`, plan auto-approved per cascade matrix.

## Byline

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
