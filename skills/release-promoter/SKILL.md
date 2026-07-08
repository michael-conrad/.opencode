---
name: release-promoter
description: "Use when creating git tags for releases or promoting releases to GitHub. Also use when creating annotated tags with v prefix or creating GitHub Releases from tags with changelog body. Invoke for: tag creation, release promotion, GitHub Release creation, annotated tag creation. Release promotion is REQUIRED after every release PR merge — not optional. Trigger phrases: tag, release, release-promoter, create release, promote release."
license: MIT
compatibility: opencode
---

# Skill: release-promoter

## Overview

Creates annotated git tags with v prefix and promotes releases to GitHub. After a release PR merges, this skill creates the tag and creates a GitHub Release with the changelog body.

## Persona

Release promoter. Routes tag creation and release promotion to sub-agents that independently verify the merge state. An orchestrator that creates tags from memory instead of dispatching to a verification sub-agent has produced a tag that may point to the wrong commit — every tag carries the orchestrator's recollection of what was merged rather than an independent merge-state check. Professional release promoters dispatch to sub-agents that verify the actual merge commit. Inlining means the tag was never verified against the merge state.

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
| "tag" / "create tag" / "annotated tag" | `tag` | `sub-task` | {next_version, merge_commit_sha} |
| "create release" / "github release" / "promote release" | `create-release` | `sub-task` | {next_version, changelog_body} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Tasks

| Task | Description |
|------|-------------|
| `tag` | Create annotated git tag with v prefix and push |
| `create-release` | Create GitHub Release from tag with changelog body |
| `completion` | Push, URL generation, lifecycle event append, executive summary |

## Invocation

`skill({name: "release-promoter"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------------|
| `tag` | `task(..., prompt: "execute tag from release-promoter. Read \`release-promoter/tasks/tag.md\` first")` |
| `create-release` | `task(..., prompt: "execute create-release from release-promoter. Read \`release-promoter/tasks/create-release.md\` first")` |
| `completion` | `task(..., prompt: "execute completion from release-promoter. Read \`release-promoter/tasks/completion.md\` first")` |

## Operating Protocol

- [ ] 1. **Tag format:** `v{semver}` (v prefix — de facto standard, Semver FAQ)
- [ ] 2. **Annotated tags:** Always use `git tag -a` with a message
- [ ] 3. **Release body:** Changelog entries for that version (standard GitHub practice)
- [ ] 4. **Post-merge only:** Only create tags after the release PR has merged

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ next_version, worktree.path, github.owner, github.repo }`, excluding implementation context and agent memory. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

The orchestrator MUST NOT preload execution context into `task()` prompts. Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Run git tag -a v1.2.3" | "execute tag from release-promoter" |
| Preloaded step sequences | "Step 1: create tag. Step 2: push." | "execute tag from release-promoter" |
| Preloaded expected outcomes | "Return { tag_name, tag_sha }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The release PR just merged so we need..." | Pure objective, no narrative |
| Missing task file discovery directive | "execute tag from release-promoter" without task file path | "execute tag from release-promoter. Read `release-promoter/tasks/tag.md` first" |

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

Skills: `version-manager`, `changelog-generator`, `git-workflow`. Guidelines: `080-code-standards.md`.

```yaml+symbolic
schema_version: "1.0"
last_updated: "2026-07-07T00:00:00Z"
rules:
  - id: release-promoter-001
    title: "Annotated tag with v prefix"
    conditions:
      all: ["tag_creation_pending == true", "tag_format != 'v{semver}'"]
    actions: [HALT]
    source: "release-promoter/SKILL.md"

  - id: release-promoter-002
    title: "Post-merge only — verify merge state before tagging"
    conditions:
      all: ["tag_creation_pending == true", "merge_state_not_verified == true"]
    actions: [HALT]
    source: "release-promoter/SKILL.md"
```

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
