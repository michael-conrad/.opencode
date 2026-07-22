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
| "create spec" / "write spec" / "draft spec" | `create` | `spec-creation-validation --task create` | `orchestrator` | {issue_number} |
| "requirements" / "extract requirements" | `requirements` | `spec-creation-requirements --task requirements` | `orchestrator` | {issue_number} |
| "decompose" / "analytical artifacts" | `decompose` | `spec-creation-decomposition --task decompose` | `orchestrator` | {issue_number} |
| "blast radius" / "code path analysis" | `analytical-artifacts` | `spec-creation-decomposition --task analytical-artifacts` | `orchestrator` | {issue_number} |
| "holistic check" / "self-check" / "pre-completion check" | `holistic-self-check` | `spec-creation-validation --task holistic-self-check` | `orchestrator` | {issue_number} |
| "pipeline readiness" / "readiness gate" | `pipeline-readiness-gate` | `spec-creation-validation --task pipeline-readiness-gate` | `orchestrator` | {issue_number} |
| "risk assessment" / "risk" | `risk` | `spec-creation-validation --task risk` | `orchestrator` | {issue_number} |
| "traceability" / "verify traceability" | `traceability` | `spec-creation-validation --task traceability` | `orchestrator` | {issue_number} |
| "change control" / "revision history" | `change-control` | `spec-creation-change-control --task change-control` | `orchestrator` | {issue_number} |
| "operating protocol" / "update protocol" | `operating-protocol` | `spec-creation-operating-protocol --task operating-protocol` | `orchestrator` | {issue_number} |
| completion / workflow end | `completion` | `spec-creation-validation --task completion` | `orchestrator` | {workflow_state} |

## Invocation

`skill({name: "spec-creation"})` — call the skill, then dispatch to the sub-skill:

| Task | Dispatch | Canonical Dispatch String |
|------|----------|--------------------------|
| `create` | `orchestrator` | `task(..., prompt: "execute create from spec-creation-validation")` |
| `requirements` | `orchestrator` | `task(..., prompt: "execute requirements from spec-creation-requirements")` |
| `decompose` | `orchestrator` | `task(..., prompt: "execute decompose from spec-creation-decomposition")` |
| `analytical-artifacts` | `orchestrator` | `task(..., prompt: "execute analytical-artifacts from spec-creation-decomposition")` |
| `holistic-self-check` | `orchestrator` | `task(..., prompt: "execute holistic-self-check from spec-creation-validation")` |
| `pipeline-readiness-gate` | `orchestrator` | `task(..., prompt: "execute pipeline-readiness-gate from spec-creation-validation")` |
| `risk` | `orchestrator` | `task(..., prompt: "execute risk from spec-creation-validation")` |
| `traceability` | `orchestrator` | `task(..., prompt: "execute traceability from spec-creation-validation")` |
| `change-control` | `orchestrator` | `task(..., prompt: "execute change-control from spec-creation-change-control")` |
| `operating-protocol` | `orchestrator` | `task(..., prompt: "execute operating-protocol from spec-creation-operating-protocol")` |
| `completion` | `orchestrator` | `task(..., prompt: "execute completion from spec-creation-validation")` |
| `revise` | `orchestrator` | `task(..., prompt: "execute revise from spec-creation-validation")` |
| `validate` | `orchestrator` | `task(..., prompt: "execute validate from spec-creation-validation")` |
| `pre-spec-inspection` | `orchestrator` | `task(..., prompt: "execute pre-spec-inspection from spec-creation-decomposition")` |
| `blast-radius` | `orchestrator` | `task(..., prompt: "execute blast-radius from spec-creation-decomposition")` |
| `code-path-inventory` | `orchestrator` | `task(..., prompt: "execute code-path-inventory from spec-creation-decomposition")` |
| `cross-cutting-matrix` | `orchestrator` | `task(..., prompt: "execute cross-cutting-matrix from spec-creation-decomposition")` |
| `interface-compatibility` | `orchestrator` | `task(..., prompt: "execute interface-compatibility from spec-creation-decomposition")` |
| `state-analysis` | `orchestrator` | `task(..., prompt: "execute state-analysis from spec-creation-decomposition")` |

## Cross-References

Sub-skills: `spec-creation-requirements`, `spec-creation-decomposition`, `spec-creation-validation`, `spec-creation-change-control`, `spec-creation-operating-protocol`. Skills: `brainstorming`, `writing-plans`, `audit`, `approval-gate`.
