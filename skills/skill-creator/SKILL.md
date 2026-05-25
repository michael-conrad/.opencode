---
name: skill-creator
description: Use when creating a new skill, updating an existing skill, validating skill cards, or managing duplicate content blocks (fragments) across guidelines or skills. Triggers on: new skill, update skill, create skill, skill template, skill structure, SKILL.md, validate skill cards, review skills, skill card review, fragment, duplicate content, sync content, content block, shared content, master copy, synchronize. Creating skills without validation produces broken enforcement gates. Every unvalidated skill is a gap in your quality system.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill Creator

## Overview

Creating skills IS TDD applied to process documentation. Write tests, watch them fail, write the skill, watch tests pass, refactor.

Also manages duplicate text blocks across skills (formerly `fragment-manager` skill): CRUD on master files (`.opencode/.guidelines/`), sync masters to copies, drift detection.

## Tasks

| Task | Words |
|------|-------|
| `init` | ≈200 |
| `package` | ≈150 |
| `validate` | ≈100 |
| `fragment-management` | ≈300 |

## Invocation

`skill({name: "skill-creator"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `init` | `task(..., prompt: "execute init task from skill-creator")` |
| `package` | `task(..., prompt: "execute package task from skill-creator")` |
| `validate` | `task(..., prompt: "execute validate task from skill-creator")` |
| `fragment-management` | `task(..., prompt: "execute fragment-management task from skill-creator")` |

**CLI equivalent (for human TUI use):** `/skill skill-creator --task <task>`

## Operating Protocol

1. **Iron Law:** no skill creation/update without failing test first (RED phase). Document baseline failure.
2. **No hardcoded identity values:** use `<AgentName>`, `<ModelId>`, `<github.owner>`, `<github.repo>`, `<dev.name>`, `<dev.email>` placeholders.
3. **Worktree awareness mandatory** for skills with git/file operations.
4. **Submodule path awareness:** All tools/scripts in generated skills MUST account for workdir being inside a submodule. Paths MUST NOT compose `.opencode/.opencode/` nesting. See `000-critical-rules.md` §Creating .opencode/.opencode/ Nested Directories and `060-tool-usage.md` §2 Workdir-Aware Path Composition.
5. **Enforcement test step mandatory** after creation/update — add behavioral test scenarios.
6. **Verification-enforcement gate** before skill generation.
7. **Required frontmatter:** name, description, type, license, provenance, compatibility.
8. **Session-init variable alignment:** use canonical dotted-name format.
9. **Fragment discipline:** master copy is single source of truth — never edit copies directly. Registry at `.opencode/.guidelines/registry.yaml`.

## Sub-Agent Routing

`init` runs with `{ skill_name, output_dir, worktree.path, github.owner, github.repo }`. `package` with `{ skill_folder, output_dir, worktree.path, github.owner, github.repo }`. `validate` with `{ skill_folders, validation_scope, worktree.path, github.owner, github.repo }`. `fragment-management` with `{ fragment_name, destination_paths, operation, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. When routing auditor sub-agents, include `audit_phase` in task context per SC-6. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync dev. Step 2: delete branch." | "execute cleanup task from git-workflow" |
| Preloaded expected outcomes | "Return { cleanup_status, branch_deleted }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pr_strategy`
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

## Cross-References

Skills: `verification-enforcement`, `coherence-auditor`. Guidelines: `080-code-standards.md`, `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: skill-creator-001
    title: "TDD mandatory — no skill without failing test first"
    conditions:
      all: ["failing_test_documented == false", "skill_creation_or_update_in_progress == true"]
    actions: [HALT]
    source: "skill-creator/SKILL.md"

  - id: skill-creator-002
    title: "No hardcoded identity values in skill files"
    conditions:
      all: ["skill_file_contains_hardcoded_identity == true"]
    actions: [REJECT, REPLACE(with placeholders)]
    source: "skill-creator/SKILL.md"

  - id: skill-creator-004
    title: "Worktree awareness mandatory for git/file skills"
    conditions:
      all: ["skill_performs_git_or_file_operations == true", "worktree_mode_section_present == false"]
    actions: [REJECT]
    source: "skill-creator/SKILL.md"

  - id: fragment-001
    title: "Master copy is single source of truth — never edit copies directly"
    conditions:
      all: ["destination_copy_edited == true", "master_updated == false"]
    actions: [REVERT, EDIT_MASTER_FIRST]
    source: "skill-creator/SKILL.md (merged from fragment-manager)"
```
