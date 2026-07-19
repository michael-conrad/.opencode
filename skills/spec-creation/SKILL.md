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

## Sub-Skills

| Sub-Skill | Purpose | Task Count |
|-----------|---------|------------|
| `spec-creation-requirements` | Requirements extraction and documentation | 1 task file |
| `spec-creation-decomposition` | Analytical artifact generation (blast radius, code paths, etc.) | 9 task files + 3 contracts |
| `spec-creation-validation` | Spec creation, validation, holistic checks, risk, traceability | 6 task files |
| `spec-creation-change-control` | Change control documentation | 1 task file |
| `spec-creation-operating-protocol` | Operating protocol documentation | 1 task file |

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
| `revise` | `task(..., prompt: "execute revise from spec-creation-validation. Read \`spec-creation-validation/tasks/revise.md\` first")` |
| `completion` | `task(..., prompt: "execute completion from spec-creation-validation. Read \`spec-creation-validation/tasks/completion.md\` first")` |

## Cross-References

Sub-skills: `spec-creation-requirements`, `spec-creation-decomposition`, `spec-creation-validation`, `spec-creation-change-control`, `spec-creation-operating-protocol`. Skills: `brainstorming`, `writing-plans`, `audit`, `approval-gate`.
