---
name: spec-creation
description: "Specification authoring dispatcher that routes to sub-skills. Load via skill() when creating a spec, writing a specification, drafting requirements, authoring a spec document, or specifying a feature. Also load when decomposing a problem into success criteria, extracting requirements, or documenting change control. Also load when running holistic self-checks on specs before completion, or verifying spec quality against the 11-dimension holistic gate. Spec creation is REQUIRED before implementation. User phrases: create spec, write specification, draft requirements, author spec, holistic check"
license: MIT
compatibility: opencode
provenance: AI-generated
---

# Skill: spec-creation (Dispatcher)

## Overview

This is a **dispatcher skill** that routes to 5 sub-skills. All original trigger phrases are preserved for backward compatibility.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Sub-Skills

| Sub-Skill | Purpose | Task Count |
|-----------|---------|------------|
| `spec-creation-requirements` | Requirements extraction and documentation | 1 task file |
| `spec-creation-decomposition` | Analytical artifact generation (blast radius, code paths, etc.) | 9 task files + 3 contracts |
| `spec-creation-validation` | Spec creation, validation, holistic checks, risk, traceability | 6 task files |
| `spec-creation-change-control` | Change control documentation | 1 task file |
| `spec-creation-operating-protocol` | Operating protocol documentation (pipeline moved to SKILL.md) | 0 task files |

## Trigger Dispatch Table

| User says / Context | Task | Dispatches To | Dispatch | Context passed |
|---------------------|------|---------------|----------|----------------|
| "create spec" / "write spec" / "draft spec" | `create` | `spec-creation-validation --task create` | `sub-task` | {issue_number} |
| "revise spec" / "update spec" / "edit spec" | `revise` | `spec-creation-validation --task revise` | `sub-task` | {issue_number} |
| completion / workflow end | `completion` | `spec-creation-validation --task completion` | `sub-task` | {workflow_state} |

## Invocation

`skill({name: "spec-creation"})` — call the skill, then dispatch to the sub-skill:

| Task | Canonical Dispatch String |
|------|--------------------------|
| `create` | `task(..., prompt: "execute create from spec-creation-validation. Read \`spec-creation-validation/tasks/create.md\` first")` |
| `revise` | `task(..., prompt: "execute change-control from spec-creation-change-control. Read \`spec-creation-change-control/tasks/change-control.md\` first")` |
| `completion` | `task(..., prompt: "execute completion from spec-creation-validation. Read \`spec-creation-validation/tasks/completion.md\` first")` |

## Pipeline

### Workflow 1: `create` — Full pipeline (25 steps)

```
 1. [inline]  local-issues sync                          # ensure issues-data is current
 2. [sub-task] create-remote-stub                        # get spec #N (remote or local)
 3. [sub-task] pre-spec-inspection                       # check for superseding issues
 4. [sub-task] research-card-consultation                 # consult existing research cards
 5. [sub-task] requirements                               # extract and verify requirements
 6. [sub-task] concern-analysis                           # identify concern boundaries
 7. [sub-task] decompose                                  # break into discrete units
 8. [sub-task] blast-radius                               # analyze dependency impact
 9. [sub-task] cross-cutting                              # identify cross-cutting concerns
10. [sub-task] traceability                               # map requirements to SCs
11. [sub-task] code-path-analysis                         # enumerate execution paths
12. [sub-task] interface-compatibility                    # verify interface contracts
13. [sub-task] state-analysis                             # model state transitions
14. [sub-task] pipeline-readiness-gate                    # validate SC structure
15. [sub-task] testability-assessment                     # verify SC testability
16. [sub-task] risk                                       # assess risks and mitigations
17. [inline]  solve model                                 # dependency-ordering constraints
18. [inline]  solve check                                 # verify SAT
19. [inline]  plan plan                                   # phase solvability validation
20. [sub-task] interdependency-check                     # check for conflicting open specs
21. [sub-task] create (local only)                        # write spec.md + sub-artifacts
22. [sub-task] revise-remote-body                         # update links to .issues/{N}/ folder
23. [inline]  local-issues sync                           # push artifacts so links resolve
24. [sub-task] completion                                 # state check and report
25. [inline]  spec-audit                                  # quality audit
```

### Workflow 2: `revise` — Change-control + re-audit (6 steps)

```
 1. [inline]  local-issues sync
 2. [sub-task] change-control                             # identify changes, version spec
 3. [sub-task] revise-remote-body                         # update with revised content
 4. [inline]  spec-audit                                  # re-audit (mandatory for audit-triggered revisions)
 5. [inline]  local-issues sync
 6. [sub-task] completion
```

### Workflow 3: `completion` — Idempotent close-out (1 step)

```
 1. [sub-task] completion                                 # state check and report
```

### Sub-task Step Contract

Every sub-task step follows the frugal contract pattern. The orchestrator passes only `{issue_number}` — no preloaded context, no file paths, no expected outcomes. The sub-agent reads its input from disk, writes its output to disk, and returns a frugal result contract.

**Dispatch contract:**

```
Orchestrator                          Sub-agent
    │                                      │
    │  task(..., {issue_number})            │
    │─────────────────────────────────────>│
    │                                      │
    │                         Reads input from .issues/{N}/spec.md
    │                         Reads prior artifacts from .issues/{N}/artifacts/
    │                         Writes output to .issues/{N}/artifacts/{name}.yaml
    │                                      │
    │  Result contract:                     │
    │    status: DONE | BLOCKED            │
    │    finding_summary: "<1-3 sentences>"│
    │    artifact_path: .issues/{N}/artifacts/{name}.yaml
    │    blocker_reason: ""               │
    │<─────────────────────────────────────│
    │                                      │
    │  Reads artifact file ONLY if         │
    │  routing-significant data needed     │
```

**Rules:**
1. Orchestrator passes ONLY `{issue_number}` — no preloaded context, no file paths, no expected outcomes, no orchestrator reasoning
2. Sub-agent reads from disk — `.issues/{N}/spec.md` for the spec body, `.issues/{N}/artifacts/` for prior step outputs
3. Sub-agent writes to disk — `.issues/{N}/artifacts/{name}.yaml` for its output
4. Sub-agent returns frugal result contract — `{status, finding_summary, artifact_path, blocker_reason}`
5. Orchestrator reads artifact files ONLY for routing-significant data — never for full content
6. No contract YAML files at `{project_root}/tmp/{N}/contracts/` — those are phantom infrastructure, stripped

### Step-by-Step Contract Table

| Step | Sub-agent Reads | Sub-agent Writes | Result Contract |
|------|----------------|-----------------|-----------------|
| create-remote-stub | (none — platform check only) | `.issues/{N}/remote.md` | `{status: DONE, finding_summary: "Issue #N created via ", artifact_path: ".issues/{N}/remote.md", spec_number: N}` |
| pre-spec-inspection | GitHub API for open specs, codebase | `.issues/{N}/artifacts/pre-spec-inspection.yaml` | `{status: DONE \| BLOCKED, finding_summary: "...", artifact_path: "...", blocker_reason: "..."}` |
| research-card-consultation | `.opencode/.issues/research-cards/*.md` | `.issues/{N}/artifacts/research-cards-consulted.yaml` | `{status: DONE, finding_summary: "...", artifact_path: "...", blocker_reason: null}` |
| requirements | brainstorming output | `.issues/{N}/artifacts/requirements.yaml` | same |
| concern-analysis | `.issues/{N}/artifacts/requirements.yaml` | `.issues/{N}/artifacts/concern-map.yaml` | same |
| decompose | `.issues/{N}/artifacts/requirements.yaml`, `.issues/{N}/artifacts/concern-map.yaml` | `.issues/{N}/artifacts/decomposition.yaml` | same |
| blast-radius | `.issues/{N}/artifacts/decomposition.yaml` | `.issues/{N}/artifacts/blast-radius.yaml` | same |
| cross-cutting | `.issues/{N}/artifacts/decomposition.yaml`, `.issues/{N}/artifacts/concern-map.yaml` | `.issues/{N}/artifacts/cross-cutting-matrix.yaml` | same |
| traceability | `.issues/{N}/artifacts/requirements.yaml`, `.issues/{N}/artifacts/decomposition.yaml` | `.issues/{N}/artifacts/traceability.yaml` | same |
| code-path-analysis | `.issues/{N}/artifacts/decomposition.yaml`, `.issues/{N}/artifacts/blast-radius.yaml` | `.issues/{N}/artifacts/code-path-inventory.yaml` | same |
| interface-compatibility | `.issues/{N}/artifacts/decomposition.yaml`, `.issues/{N}/artifacts/concern-map.yaml` | `.issues/{N}/artifacts/interface-compatibility.yaml` | same |
| state-analysis | `.issues/{N}/artifacts/decomposition.yaml`, `.issues/{N}/artifacts/interface-compatibility.yaml` | `.issues/{N}/artifacts/state-analysis.yaml` | same |
| pipeline-readiness-gate | `.issues/{N}/spec.md` (SC table), `.issues/{N}/artifacts/*.yaml` | `.issues/{N}/artifacts/sc-pipeline-readiness.yaml` | same |
| testability-assessment | `.issues/{N}/artifacts/requirements.yaml`, `.issues/{N}/artifacts/code-path-inventory.yaml` | `.issues/{N}/artifacts/testability-assessment.yaml` | same |
| risk | `.issues/{N}/artifacts/requirements.yaml`, `.issues/{N}/artifacts/decomposition.yaml` | `.issues/{N}/artifacts/risk.yaml` | same |
| interdependency-check | GitHub API for open specs | `.issues/{N}/artifacts/interdependency-check.yaml` | same |
| create (local) | All prior artifacts in `.issues/{N}/artifacts/` | `.issues/{N}/spec.md`, `.issues/{N}/sc-summary.yaml`, `.issues/{N}/verification-consistency-contract.yaml`, `.issues/{N}/spec-to-plan-handoff.yaml`, `.issues/{N}/revision-re-entry-contract.yaml`, `.issues/{N}/lifecycle.yaml` | `{status: DONE \| BLOCKED, finding_summary: "Spec #N written with M SCs", artifact_path: ".issues/{N}/spec.md", blocker_reason: null}` |
| revise-remote-body | `.issues/{N}/spec.md`, session-init values | (updates remote issue body) | `{status: DONE \| SKIPPED, finding_summary: "Remote body updated" \| "No remote API — skipped", artifact_path: null, blocker_reason: null}` |
| completion | `.issues/{N}/spec.md`, `.issues/{N}/artifacts/` | State check report | same |
| holistic-self-check | `.issues/{N}/spec.md` | `.issues/{N}/artifacts/holistic-self-check.yaml` | same |
| change-control | `.issues/{N}/spec.md` (current and prior versions) | `.issues/{N}/artifacts/change-control.yaml` | same |

### Inline Steps (orchestrator executes directly)

| Step | What the Orchestrator Does |
|------|---------------------------|
| local-issues sync | Run `.opencode/tools/local-issues sync` |
| solve model | Run `.opencode/tools/solve model` with contract |
| solve check | Run `.opencode/tools/solve check` |
| plan plan | Run `.opencode/tools/plan plan` |
| spec-audit | `skill({name: "audit"})` then `task(..., prompt: "execute spec-audit task from audit")` |

## Cross-References

Sub-skills: Load [spec-creation-requirements](skills/spec-creation-requirements/SKILL.md), Load [spec-creation-decomposition](skills/spec-creation-decomposition/SKILL.md), Load [spec-creation-validation](skills/spec-creation-validation/SKILL.md), Load [spec-creation-change-control](skills/spec-creation-change-control/SKILL.md), Load [spec-creation-operating-protocol](skills/spec-creation-operating-protocol/SKILL.md). Skills: Load [brainstorming](skills/brainstorming/SKILL.md), Load [writing-plans](skills/writing-plans/SKILL.md), Load [audit](skills/audit/SKILL.md), Load [approval-gate](skills/approval-gate/SKILL.md).
