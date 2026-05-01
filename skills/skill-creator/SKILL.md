---
name: skill-creator
description: Use when creating a new skill, updating an existing skill, or validating skill cards. Triggers on: new skill, update skill, create skill, skill template, skill structure, SKILL.md, validate skill cards, review skills, skill card review.
type: technique
license: Apache-2.0
provenance: AI-generated
compatibility: opencode
---

# Skill Creator

## Overview

Creating skills IS TDD applied to process documentation. Write tests, watch them fail, write the skill, watch tests pass, refactor. If you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing.

## Tasks

| Task | Words |
|------|-------|
| `init` | ≈200 |
| `package` | ≈150 |
| `validate` | ≈100 |

## Invocation

`/skill skill-creator --task init` (create from template), `--task package` (zip distributable), `--task validate` (semantic review). Overview with no flag.

## Operating Protocol

1. **Iron Law:** no skill creation/update without failing test first (RED phase). Document baseline failure.
2. **No hardcoded identity values:** use `<AgentName>`, `<ModelId>`, `<github.owner>`, `<github.repo>`, `<dev.name>`, `<dev.email>` placeholders.
3. **Worktree awareness mandatory** for skills with git/file operations.
4. **Enforcement test step mandatory** after creation/update — add behavioral test scenarios.
5. **Verification-enforcement gate** before skill generation.
6. **Required frontmatter:** name, description, type, license, provenance, compatibility.
7. **Session-init variable alignment:** use canonical dotted-name format.

## Sub-Agent Dispatch Audit

`init` dispatches with `{ skill_name, output_dir }`. `package` with `{ skill_folder, output_dir }`. `validate` with `{ skill_folders, validation_scope }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description }`. No inline work.

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
