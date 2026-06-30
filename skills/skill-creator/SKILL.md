---
name: skill-creator
description: "Use when creating a new skill, updating an existing skill, validating skill cards, or managing duplicate content blocks (fragments) across guidelines or skills. Also use when enforcing the farmage description pattern on all skill cards, or auditing skill card structure for compliance. Invoke for: skill creation, skill update, skill validation, fragment management, skill card audit, description pattern enforcement. Validation is REQUIRED. Trigger phrases: create skill, new skill, update skill, validate skill, check skill, review skills, skill card audit, skill card review, fragment management, sync fragment, duplicate content."
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill Creator

## Overview

Creating skills IS TDD applied to process documentation. Write tests, watch them fail, write the skill, watch tests pass, refactor.

Also manages duplicate text blocks across skills (formerly `fragment-manager` skill): CRUD on master files (`.opencode/.guidelines/`), sync masters to copies, drift detection.

## Persona

Skill validator. Routes skill card validation and content checks to sub-agents that independently assess skill structure. An orchestrator that validates skills inline instead of dispatching to validation sub-agents has produced a self-check, not an independent card audit — every validation finding carries the orchestrator's own understanding of the skill rather than an independent structural analysis. Professional validators dispatch to audit sub-agents. Inlining means no skill was ever independently validated.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "init" / "create skill" / "new skill" | `init` | `sub-task` | {skill_name, output_dir} |
| "package" / "package skill" | `package` | `sub-task` | {skill_folder, output_dir} |
| "validate" / "validate skill" / "check skill" | `validate` | `sub-task` | {skill_folders} |
| "fragment" / "fragment management" / "sync fragment" | `fragment-management` | `sub-task` | {fragment_name, destination_paths} |
| "skill card audit" / "review skills" / "audit skill cards" | `validate` | `sub-task` | {skill_folders, audit_mode: "full"} |
| "description pattern" / "farmage pattern" / "enforce description pattern" | `validate` | `sub-task` | {skill_folders, audit_mode: "farmage"} |

## Tasks


| `init` |
| `package` |
| `validate` |
| `fragment-management` |

## Invocation

`skill({name: "skill-creator"})` — call the skill, then call via task():

| Task | Call via task() |

| `init` | `task(..., prompt: "execute init task from skill-creator")` |
| `package` | `task(..., prompt: "execute package task from skill-creator")` |
| `validate` | `task(..., prompt: "execute validate task from skill-creator")` |
| `fragment-management` | `task(..., prompt: "execute fragment-management task from skill-creator")` |

**CLI equivalent (for human TUI use):** `/skill skill-creator --task <task>`

## Operating Protocol

- [ ] 1. **Iron Law:** no skill creation/update without failing test first (RED phase). Document baseline failure.
- [ ] 2. **No hardcoded identity values:** use `<AgentName>`, `<ModelId>`, `<github.owner>`, `<github.repo>`, `<dev.name>`, `<dev.email>` placeholders.
- [ ] 3. **Worktree awareness mandatory** for skills with git/file operations.
- [ ] 4. **Submodule path awareness:** All tools/scripts in generated skills MUST account for workdir being inside a submodule. Paths MUST NOT compose `.opencode/.opencode/` nesting. See `000-critical-rules.md` §Creating .opencode/.opencode/ Nested Directories and `060-tool-usage.md` §2 Workdir-Aware Path Composition.
- [ ] 5. **Enforcement test step mandatory** after creation/update — add behavioral test scenarios.
- [ ] 6. **Verification-enforcement gate** before skill generation.
- [ ] 7. **Required frontmatter:** name, description, type, license, provenance, compatibility.
- [ ] 8. **Session-init variable alignment:** use canonical dotted-name format.
- [ ] 9. **Fragment discipline:** master copy is single source of truth — never edit copies directly. Registry at `.opencode/.guidelines/registry.yaml`.

## Sub-Agent Routing

`init` runs with `{ skill_name, output_dir, worktree.path, github.owner, github.repo }`. `package` with `{ skill_folder, output_dir, worktree.path, github.owner, github.repo }`. `validate` with `{ skill_folders, validation_scope, worktree.path, github.owner, github.repo }`. `fragment-management` with `{ fragment_name, destination_paths, operation, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. When routing auditor sub-agents, include `audit_phase` in task context per SC-6. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

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

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

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
