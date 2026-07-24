---
remote_issue: 2084
remote_url: "https://github.com/michael-conrad/.opencode/issues/2084"
last_sync: "2026-07-23T21:58:21Z"
source: github
---

# [SPEC] New `explore` skill — standalone codebase exploration for AI agents

## Problem Statement

Multiple skills need to explore the codebase before acting: writing-plans needs to find file paths, patterns, and analogous features before writing a plan; spec-creation needs to understand existing code before writing a spec; audit needs to verify claims against live code. Currently each skill does its own ad-hoc exploration inline, duplicating effort and producing inconsistent results.

A standalone `explore` skill provides a single, reusable, clean-room codebase exploration step that any skill can dispatch to. It returns raw findings only — no plan, no tests, no implementation steps. This is the pattern validated by the research: `flagrare/codebase-explore` is consumed by `atdd-plan`, `codebase-exploration` is consumed by `implementation-planning`, and `explore-codebase` is explicitly "Step 1 of the implementation workflow: Explore → Plan → Review → Execute."

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|---|---|---|---|
| SC-1 | SKILL.md exists at `skills/explore/SKILL.md` with semantic router description | `structural` | File exists, description describes codebase exploration intent |
| SC-2 | One task file: `tasks/explore.md` | `structural` | File exists at `skills/explore/tasks/explore.md` |
| SC-3 | Two contract templates (input + output) | `structural` | Files exist at `skills/explore/contracts/` |
| SC-4 | explore.md checks for prior attempts (branches, PRs, commits) | `behavioral` | Dispatch explore → verify git branch/log/PR search in stderr |
| SC-5 | explore.md identifies feature area (entry point, data flow, dependencies) | `behavioral` | Dispatch explore → verify file path discovery in output |
| SC-6 | explore.md finds analogous features (similar patterns in codebase) | `behavioral` | Dispatch explore → verify analogous feature references |
| SC-7 | explore.md maps conventions (file organization, naming, testing style, error handling) | `behavioral` | Dispatch explore → verify convention documentation |
| SC-8 | explore.md inventories reusable pieces (utilities, helpers, shared components) | `behavioral` | Dispatch explore → verify reusable utility list |
| SC-9 | explore.md checks constraints (lint rules, type system, feature flags, project guidelines) | `behavioral` | Dispatch explore → verify constraint documentation |
| SC-10 | explore.md returns raw findings only — no plan, no tests, no implementation steps | `behavioral` | Dispatch explore → verify output contains no plan/test/implementation sections |
| SC-11 | explore.md writes findings to `{issues_prefix}/{N}/artifacts/exploration.yaml` | `behavioral` | Dispatch explore → verify exploration.yaml exists on disk |
| SC-12 | Result contract returns `{status, artifact_path, finding_summary}` | `structural` | Contract template matches frugal format |

## Task Card: explore.md

**Purpose:** Explore the codebase to map conventions, reusable utilities, analogous features, and data flows relevant to a planned change. Returns raw findings — no plan, no tests, no implementation steps.

**Entry Criteria:**
- Issue number `{N}` is provided
- Project root and issues prefix are set
- Spec file exists at `{issues_prefix}/{N}/spec.md` (or problem statement is provided)

**Procedure:**
1. Check for prior attempts — search branches, PRs, and commits related to this work
2. Identify the feature area — determine which directories and files the change will touch
3. Find analogous features — search for similar patterns the codebase already solved
4. Map conventions — file organization, naming patterns, testing style, error handling, i18n, imports
5. Inventory reusable pieces — utilities, helpers, shared components, test helpers
6. Check constraints — lint rules, type system, build/bundling, feature flags, project guidelines
7. Write findings to `{issues_prefix}/{N}/artifacts/exploration.yaml`
8. Return result contract

**Exit Criteria:**
- Prior attempts checked (or "none found" documented)
- Feature area mapped with file paths
- Analogous features identified
- Conventions documented
- Reusable utilities listed
- Constraints checked
- Exploration findings written to disk

**Result Contract:**
```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences summarizing exploration scope and key findings>"
artifact_path: "<{issues_prefix}/{N}/artifacts/exploration.yaml>"
blocker_reason: "<reason if BLOCKED>"
```

## File Structure

```
skills/explore/
  SKILL.md
  tasks/
    explore.md
  contracts/
    explore-input-template.yaml
    explore-output-template.yaml
```

## Cross-References

Consumed by: `writing-plans` (structure step), `spec-creation` (analyze step), `audit` (verification step). Skills: `writing-plans`, `spec-creation`, `audit`.