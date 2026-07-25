---
remote_issue: 2135
remote_url: https://github.com/michael-conrad/.opencode/issues/2135
labels: [spec]
---

## Problem

`130-authority-source.md` currently asserts "code wins" — the filesystem is the only absolute source of truth. Research on spec-driven development (SDD) reveals this is the wrong framing for this project:

- **Augment Code (2026)**: "Spec-driven development inverts the traditional workflow by treating specifications as the source of truth and code as a generated or verified secondary artifact."
- **Martin Fowler / Thoughtworks (2025)**: Three levels of SDD — spec-first, spec-anchored, spec-as-source. All treat the spec as authoritative for intent.
- **GitHub spec-kit**: "In this new world, maintaining software means evolving specifications. The lingua franca of development moves to a higher level, and code is the last-mile approach."

The project uses specs as the primary artifact — specs drive implementation, specs are the authorization mechanism, specs are what gets reviewed. The current "code wins" position is backwards.

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
- Rule 8 (Plan Audit Code Deep Dive) — project-specific doc reference

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Dual-authority principle stated (spec for intent, code for state) | string | grep for 'spec is authoritative for intent' |
| SC-2 | Rule 1: Spec for intent, code for state | string | grep for 'Spec for intent' |
| SC-3 | Rule 2: Spec before code | string | grep for 'Spec before code' |
| SC-4 | Rule 3: Documentation Drift Protocol | string | grep for 'Documentation Drift Protocol' |
| SC-5 | Rule 4: Spec revision revokes plan approval | string | grep for 'spec revision revokes' |
| SC-6 | Rule 5: Suppression of Reactive Remediation | string | grep for 'Suppression of Reactive Remediation' |
| SC-7 | Rule 6: Verification against spec | string | grep for 'Verification against spec' |
| SC-8 | Superseding Issues section removed | string | grep for absence of 'Superseding Issues' |
| SC-9 | Verification First section removed | string | grep for absence of 'Verification First' |
| SC-10 | Plan Audit Code Deep Dive section removed | string | grep for absence of 'Plan Audit Requires Code Deep Dive' |

## Implementation Plan

### Phase 1: Write new dual-authority principle
### Phase 2: Write 6 new rules
### Phase 3: Remove superseded rules (Superseding Issues, Verification First, Plan Audit)
### Phase 4: Verify all 6 rules present and removed content absent

## Files Affected

- `.opencode/guidelines/130-authority-source.md` — rewritten
- `.opencode/skills/spec-creation/SKILL.md` — receives Superseding Issues + Overlap Detection Checklist

## Risks

- **Confusion between intent and state**: Agents may struggle to distinguish "spec is wrong about current state" from "code doesn't implement spec intent." Mitigation: each rule includes concrete examples of both failure modes.
- **Cross-reference breakage**: Other files referencing the old "code wins" framing. Mitigation: grep for 'code wins' and 'code is the only absolute source of truth' across the codebase.

## Dependencies

- None.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
