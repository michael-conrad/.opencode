# Plan: [SPEC-FIX] Plan Writer Stores Remotely Instead of Locally

**Issue:** michael-conrad/.opencode#1072
**Created:** 2026-06-07

## Overview

Invert plan storage from remote API (GitHub Issue body / `[PLAN]` issue) to local `.issues/{N}/spec-artifacts/plan.md`. Plans, states, and tracking live in the local `.issues/` workspace per architecture. Only exec summary goes to remote.

## Phases

### Phase 1: Fix `create-and-validate.md` — Combined + Separate Plan Paths

**Affected file:** `skills/writing-plans/tasks/create/create-and-validate.md`

#### Items

| # | Item | Defect |
|---|------|--------|
| 1.1 | Step 7 COMBINED: replace remote body append with `.issues/{N}/spec-artifacts/plan.md` write | D1 |
| 1.2 | Step 7 SEPARATE: replace remote `[PLAN]` issue creation with `.issues/{N}/spec-artifacts/plan.md` write | D2 |
| 1.3 | Remove Step 6a (sub-issue creation) — phases are sections in local plan, not sub-issues | D2 |
| 1.4 | Step 13: remove label-removal and comment-posting for auto-approval (plan is local, approval on spec) | D3 |
| 1.5 | Step 11: replace remote issue URL report with local path `.issues/{N}/spec-artifacts/plan.md` | D4 |

### Phase 2: Fix `create.md` — Prerequisites, Exit Criteria, Cross-References

**Affected file:** `skills/writing-plans/tasks/create.md`

#### Items

| # | Item | Defect |
|---|------|--------|
| 2.1 | Prerequisites line 10: change "Spec stored as GitHub Issue" to reference `.issues/{N}/spec.md` | D5 |
| 2.2 | Exit Criteria line 31: change "Plan reported in chat with URL" to reference local artifact path | D5 |
| 2.3 | Step 5: update cross-references to local `.issues/` workspace paths | D5 |

### Phase 3: Fix `SKILL.md` — Plan Issue Model and Approval Cascade

**Affected file:** `skills/writing-plans/SKILL.md`

#### Items

| # | Item | Defect |
|---|------|--------|
| 3.1 | Update Plan Issue Model in Overview to describe `.issues/{N}/spec-artifacts/plan.md` | D6 |
| 3.2 | Remove sub-issue phase references from Operating Protocol rule 5 | D6 |
| 3.3 | Update approval cascade matrix — plan is local, approval is on the spec, no remote plan issue | D6 |

## TDD Per Item

Each item follows RED → GREEN → REFACTOR:
- **RED:** Verify current state (grep for remote pattern) — confirm test fails
- **GREEN:** Make the local-storage change
- **REFACTOR:** Verify no remnants of remote plan pattern remain
- **COMMIT:** Item committed as one working slice

## File Path Summary

- `.opencode/skills/writing-plans/tasks/create/create-and-validate.md` — Phase 1
- `.opencode/skills/writing-plans/tasks/create.md` — Phase 2
- `.opencode/skills/writing-plans/SKILL.md` — Phase 3