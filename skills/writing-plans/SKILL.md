---
name: writing-plans
description: "Implementation plan creator dispatcher that routes to sub-skills. Load via skill() when creating an implementation plan from an approved spec, breaking down work into phases, planning implementation steps, or creating task breakdowns. Also load when retroactively creating a plan for an existing spec, or backfilling plan documentation. Also load when running holistic self-checks on plans before completion, or verifying plan quality against the 11-dimension holistic gate. Plans are REQUIRED. — distinct from plan (AI planning with PDDL/Z3) and plan-creation-pipeline (task()-dispatch pipeline). User phrases: create plan, write implementation plan, break down work, plan phases"
license: MIT
compatibility: opencode
provenance: AI-generated
---

# Skill: writing-plans (Dispatcher)

## Overview

This is a **dispatcher skill** that routes to 2 sub-skills. All original trigger phrases are preserved for backward compatibility.

## Sub-Skills

| Sub-Skill | Purpose | Task Count |
|-----------|---------|------------|
| `writing-plans-creation` | Plan creation pipeline, retroactive plan creation | 18 task files + 22 contracts |
| `writing-plans-holistic` | Standalone holistic self-check | 1 task file |

## Trigger Dispatch Table

| User says / Context | Task | Dispatches To | Dispatch | Context passed |
|---------------------|------|---------------|----------|----------------|
| "create plan" / "write plan" / "plan from spec" | `create` | `writing-plans-creation --task create` | `orchestrator` | {issue_number, spec_local_dir} |
| "update plan" / "revise plan" | `update` | `writing-plans-creation --task update` | `orchestrator` | {issue_number, spec_local_dir} |
| "retroactive plan" / "backfill plan" | `retroactive` | `writing-plans-creation --task retroactive` | `orchestrator` | {issue_number} |
| "validate plan" / "check plan" | `validate` | `writing-plans-creation --task validate` | `orchestrator` | {issue_number} |
| "holistic check" / "plan quality check" | `holistic-self-check` | `writing-plans-holistic --task holistic-self-check` | `orchestrator` | {issue_number} |
| "pre-plan readiness" / "readiness check" | `pre-plan-readiness` | `writing-plans-creation --task pre-plan-readiness` | `orchestrator` | {issue_number} |
| completion / workflow end | `completion` | `writing-plans-creation --task completion` | `orchestrator` | {workflow_state} |

## Invocation

`skill({name: "writing-plans"})` — call the skill, then dispatch to the sub-skill:

| Task | Dispatch | Canonical Dispatch String |
|------|----------|--------------------------|
| `create` | `orchestrator` | `task(..., prompt: "execute create from writing-plans-creation")` |
| `update` | `orchestrator` | `task(..., prompt: "execute update from writing-plans-creation")` |
| `retroactive` | `orchestrator` | `task(..., prompt: "execute retroactive from writing-plans-creation")` |
| `validate` | `orchestrator` | `task(..., prompt: "execute validate from writing-plans-creation")` |
| `solve` | `orchestrator` | `task(..., prompt: "execute solve from writing-plans-creation")` |
| `pre-plan-readiness` | `orchestrator` | `task(..., prompt: "execute pre-plan-readiness from writing-plans-creation")` |
| `clean-room` | `orchestrator` | `task(..., prompt: "execute clean-room from writing-plans-creation")` |
| `write` | `orchestrator` | `task(..., prompt: "execute write from writing-plans-creation")` |
| `completion` | `orchestrator` | `task(..., prompt: "execute completion from writing-plans-creation")` |
| `operating-protocol` | `orchestrator` | `task(..., prompt: "execute operating-protocol from writing-plans-creation")` |
| `holistic-self-check` | `orchestrator` | `task(..., prompt: "execute holistic-self-check from writing-plans-holistic")` |
| `research` | `orchestrator` | `task(..., prompt: "execute research from writing-plans-creation")` |
| `readiness` | `orchestrator` | `task(..., prompt: "execute readiness from writing-plans-creation")` |

## Cross-References

Sub-skills: `writing-plans-creation`, `writing-plans-holistic`. Skills: `spec-creation`, `approval-gate`, `implementation-pipeline`, `audit`.
