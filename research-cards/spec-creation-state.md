---
title: spec-creation Skill State
created: 2026-07-10
confidence: 0.9
tags:
  - spec-creation
  - skill-state
  - pipeline-gates
sources:
  - type: direct
    path: .opencode/skills/spec-creation/tasks/create.md
    description: Primary spec creation task file
  - type: direct
    path: .opencode/skills/spec-creation/tasks/operating-protocol.md
    description: Operating protocol with pipeline steps
  - type: direct
    path: .opencode/skills/spec-creation/tasks/requirements.md
    description: Requirements extraction task
  - type: direct
    path: .opencode/skills/spec-creation/SKILL.md
    description: Skill dispatch table
  - type: direct
    path: .opencode/skills/spec-creation/contracts/
    description: Contract templates
---

# spec-creation Skill State

## Current State

The spec-creation skill has been updated with all 9 mandatory fixes from issue #1834. The skill is fully operational with the following pipeline:

`brainstorming → spec-creation → audit --task spec-audit → approval-gate → writing-plans`

The pipeline consists of 13 steps in `operating-protocol.md` with chain dependencies and contract paths. All tasks dispatch to clean-room sub-agents via `task()` — inline execution is FORBIDDEN per the DISPATCH_GATE protocol.

## Known Defects and Status

All 9 fixes from #1834 are implemented:

| # | Fix | Status | Location |
|---|-----|--------|----------|
| 1 | Escape hatch removed from compliance requirement blockquote | ✅ Done | `create.md` Step 5 — compliance blockquote no longer includes "If you believe an exception applies" language |
| 2 | Research card consultation mandate in requirements extraction | ✅ Done | `requirements.md` Step 1.5 — checks `.opencode/.issues/research-cards/` for `confidence >= 0.7` before implicit requirements |
| 3 | Research card consultation in operating protocol | ✅ Done | `operating-protocol.md` Step 1.5 — sub-task before requirements extraction |
| 4 | Research card references in spec body (Step 1d.5) | ✅ Done | `create.md` Step 13.5 — references to consulted research cards in Documentation Sources section |
| 5 | Live documentation URL verification (Step 1d.6) | ✅ Done | `create.md` Step 13.6 — `webfetch`/`ddg-search_fetch_content` verification before submission |
| 6 | Interdependency section (Step 1d.7) | ✅ Done | `create.md` Step 13.7 — BLOCKS/BLOCKED_BY/RELATED/SUPERSEDES/SUPERSEDED_BY classifications |
| 7 | SC-fail cascading gate (Step 3) | ✅ Done | `create.md` Step 17 — any skipped/weakened SC marks ALL SCs as FAIL; autonomous remediation required |
| 8 | Anti-lobotomization preamble (Step 1d.8) | ✅ Done | `create.md` Step 13.8 — preamble + behavioral SC forbidding test lobotomization |
| 9 | Anti-merge gate (Step 1d.9) | ✅ Done | `create.md` Step 13.9 — checks merged PRs for conflicting SCs before finalizing |

Additional gates added beyond the 9 fixes:

| # | Gate | Status | Location |
|---|------|--------|----------|
| 10 | Doc-source-currency check (Step 1d.10) | ✅ Done | `create.md` Step 13.10 — verifies sources are not stale (>30 days guidelines, >90 days other) |
| 11 | SC-ID traceability check (Step 1d.11) | ✅ Done | `create.md` Step 13.11 — unique IDs, maps to requirements, defined verification method |
| 12 | Post-SC uplift check (Step 6.2) | ✅ Done | `create.md` Step 25 — re-classifies SC evidence types post-creation |
| 13 | Evidence artifact verification (Step 6.5) | ✅ Done | `create.md` Step 26 — each self-review checkpoint produces tool-call artifact |
| 14 | Interdependency check in operating protocol (Step 9.5) | ✅ Done | `operating-protocol.md` Step 9.5 — checks open `[SPEC]` issues for overlap before create |
| 15 | Contract rename (requirements-input-template → create-input-template) | ✅ Done | `contracts/` — `create-input-template.yaml` and `create-output-template.yaml` exist |
| 16 | #1063 gates (pipeline-readiness-gate between traceability and risk) | ✅ Done | `operating-protocol.md` Step 4.5 — sub-task with chain dependency `step_4` |
| 17 | Stale issue #1229 closed | ✅ Done | Closed as superseded by #1834 |

## Interdependency Map

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#1552](https://github.com/michael-conrad/.opencode/issues/1552) | SUPERSEDED_BY | Superseded by #1834 — its scope is fully covered |
| [#1229](https://github.com/michael-conrad/.opencode/issues/1229) | SUPERSEDED_BY | Closed as stale — superseded by #1834 |
| [#1063](https://github.com/michael-conrad/.opencode/issues/1063) | SUBSUMED | Pipeline-readiness gate requirement subsumed into #1834 |
| [#1703](https://github.com/michael-conrad/.opencode/issues/1703) | SUBSUMED | Subsumed into #1834's scope |
| [#1064](https://github.com/michael-conrad/.opencode/issues/1064) | RELATED | Related but still open — not addressed by #1834 |

## Fix Spec Scope

Issue #1834 covers all 10 phases. The skill is in a stable, fully-patched state with no known open defects in the spec-creation pipeline.

## Key Artifacts

- **SKILL.md**: 182 lines — dispatch table with 8 tasks, DISPATCH_GATE protocol, symbolic rules
- **create.md**: 759 lines — 34-step procedure with verification gates, SC table format, evidence type classification
- **operating-protocol.md**: 31 lines — 13-step pipeline with chain dependencies
- **requirements.md**: 69 lines — 4-step extraction with research card consultation
- **Contracts**: `requirements-input-template.yaml`, `create-input-template.yaml`, `create-output-template.yaml`
