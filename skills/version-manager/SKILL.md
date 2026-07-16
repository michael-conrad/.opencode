---
name: version-manager
description: "Version string scanner and semver bumper for discovering and updating version numbers across codebases. Load via skill() when discovering version strings in a codebase or bumping versions for a release. Also load when scanning for version patterns across multiple file formats or determining the next version from changelog categories. Version management is REQUIRED before every release — not optional. User phrases: discover version, bump version, scan version patterns, determine next version"
license: MIT
compatibility: opencode
---

# Skill: version-manager

## Overview

Discovers version strings across a codebase using dynamic regex patterns and bumps them according to semver rules. Supports multiple file formats: `pyproject.toml`, `Cargo.toml`, `package.json`, `__init__.py`, `Chart.yaml`, and any file matching standard version patterns.

## Persona

Version manager. Routes version discovery and bumping to sub-agents that independently scan the codebase. An orchestrator that guesses version locations from memory instead of dispatching to a discovery sub-agent has produced a stale version map, not a current one — every hardcoded path carries the orchestrator's recollection of where versions live rather than an independent scan. Professional version managers dispatch to sub-agents that read actual files. Inlining means the version map was never verified against the codebase.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "discover version" / "find version strings" / "scan versions" | `discover` | `sub-task` | {project_root} |
| "bump version" / "update version" / "next version" | `bump` | `sub-task` | {current_version, bump_type, version_locations} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Tasks

| Task | Description |
|------|-------------|
| `discover` | Scan codebase for version strings using dynamic regex patterns |
| `bump` | Determine next version from changelog categories and update all discovered locations |
| `completion` | Push, URL generation, lifecycle event append, executive summary |

## Invocation

`skill({name: "version-manager"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------------|
| `discover` | `task(..., prompt: "execute discover from version-manager. Read \`version-manager/tasks/discover.md\` first")` |
| `bump` | `task(..., prompt: "execute bump from version-manager. Read \`version-manager/tasks/bump.md\` first")` |
| `completion` | `task(..., prompt: "execute completion from version-manager. Read \`version-manager/tasks/completion.md\` first")` |

## Operating Protocol

Read [the full operating protocol](version-manager/tasks/operating-protocol.md)

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ project_root, worktree.path, github.owner, github.repo }`, excluding implementation context and agent memory. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

The orchestrator MUST NOT preload execution context into `task()` prompts. Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read pyproject.toml for version" | "execute discover from version-manager" |
| Preloaded step sequences | "Step 1: grep for version. Step 2: classify." | "execute discover from version-manager" |
| Preloaded expected outcomes | "Return { locations, current_version }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The last release was v1.2.3 so we need..." | Pure objective, no narrative |
| Missing task file discovery directive | "execute discover from version-manager" without task file path | "execute discover from version-manager. Read `version-manager/tasks/discover.md` first" |

## Required: Sub-agent Task File Discovery Directive

Every `task()` prompt that dispatches a named task MUST include a discovery directive in the format:

```
execute <task> from <skill>. Read `<skill>/tasks/<task>.md` first
```

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pipeline_phase`

Plus skill-specific fields per the `## Sub-Agent Routing` section above.

Exclusions (MUST NOT be in prompt):
- `orchestrator_reasoning`
- `expected_outcomes`
- `inline_file_paths`
- `agent_memory`
- `cached_verification_results`

#### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains:
- Inline file paths to task files
- Inline step or procedure definitions
- Expected outcome structures or schema constraints
- Pre-loaded evidence or orchestrator-derived conclusions

Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## Cross-References

Skills: `changelog-generator`, `release-promoter`, `git-workflow`. Guidelines: `080-code-standards.md`.

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
