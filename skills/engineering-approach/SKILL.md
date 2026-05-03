---
name: engineering-approach
description: Use when implementing a spec, or when design, verification, and scope discipline are needed. Triggers on: implement, build, develop, engineering checklist, design before code, verify before complete.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Engineering Approach

## Overview

Engineering discipline checklist enforcing: understand before solving, design before implementing, verify before declaring complete, no scope creep.

## Tasks

| Task | Words |
|------|-------|
| `verify-understanding` | ≈300 |
| `design-before-code` | ≈300 |
| `verify-before-complete` | ≈300 |
| `completion` | ≈100 |

## Invocation

`/skill engineering-approach --task design-before-code`, `--task verify-before-complete`. Overview with no flag.

## Operating Protocol

1. **Understand before solving:** read all relevant code before proposing changes.
2. **Design before implementing:** document approach, consider alternatives, obtain approval.
3. **Verify before complete:** run tests manually, check edge cases, validate success criteria.
4. **No scope creep:** implement ONLY what's in the approved spec.
5. **Pre-implementation verification:** verify API signatures, env vars, config formats against live docs.

## Sub-Agent Dispatch Audit

All tasks dispatch via `task(subagent_type="general")`. `verify-understanding` receives `{ issue_number, github.owner, github.repo }`. `design-before-code` receives `{ spec, github.owner, github.repo }`. `verify-before-complete` receives `{ spec, implementation_file_paths, github.owner, github.repo }`. `completion` receives `{ github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

## Cross-References

Guidelines: `000-critical-rules.md`, `010-approval-gate.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: eng-approach-002
    title: "Must design before implementing"
    conditions:
      all: ["implementation_requested == true", "design_documented == false"]
    actions: [HALT, DOCUMENT_DESIGN]
    source: "engineering-approach/SKILL.md"

  - id: eng-approach-003
    title: "Must verify before declaring complete"
    conditions:
      all: ["implementation_complete_claimed == true", "tests_run_manually == false"]
    actions: [HALT, RUN_TESTS, VERIFY_CRITERIA]
    source: "engineering-approach/SKILL.md"
