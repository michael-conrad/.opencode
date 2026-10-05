# Task: init

## Purpose

Initializes a new skill directory with a templated SKILL.md and scaffolding (scripts, references, assets) using the `init_skill.py` script, ready for customization.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- Skill name (`{skill_name}`) provided in context — hyphen-case identifier, lowercase letters/digits/hyphens only, max 40 characters
- Output directory (`{output_dir}`) provided in context
- Worktree path (`{worktree.path}`) provided in context (prefix all paths when set)

If any entry criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Procedure

- [ ] 1. Read `skill-creator/scripts/init_skill.py` to confirm the scaffolding behavior (directory creation, SKILL.md template, example files).
- [ ] 2. Run the initializer:
   ```bash
   uv run .opencode/skills/skill-creator/scripts/init_skill.py <skill_name> --path <output_dir>
   ```
- [ ] 3. Confirm the skill directory was created. If it already exists, the script reports an error and returns non-zero — HALT and report, do not overwrite.
- [ ] 4. Verify the generated SKILL.md contains the required frontmatter (`name`, `description`, `license`, `provenance`) per `reference/skill-card-schema.md`.
- [ ] 5. Review the generated `description` field against the description-as-semantic-router standards in `reference/skill-card-description-standards.md`. The placeholder `[TODO: ...]` description MUST be completed by the developer or a subsequent editing task.
- [ ] 6. Verify the generated SKILL.md carries the Mandatory Task Discipline and Pre-Flight Guard sections from the template.
- [ ] 7. Customize or delete the example files in `scripts/`, `references/`, and `assets/` as appropriate — do not leave placeholder examples in a shipped skill.
- [ ] 8. Write the created skill directory path to the evidence artifact.
- [ ] 9. Return the result contract.

## Exit Criteria

- Skill directory and SKILL.md created with valid frontmatter
- Scaffolding directories (scripts, references, assets) created
- No placeholder `[TODO: ...]` content left in the shipped SKILL.md (or noted as pending developer completion)
- Result contract returned

If any exit criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences of routing-significant output>"
artifact_path: "<path to the created skill directory or evidence>"
blocker_reason: "<reason if BLOCKED>"
```

## Context Required

- Related task: `skill-creator/tasks/validate.md` (run after init to check the skill structure)
- Reference: `reference/skill-card-schema.md` (frontmatter binary constraints)
- Reference: `reference/skill-card-description-standards.md` (description field as semantic router)
- Related guideline: `080-code-standards.md` (no hardcoded identity values, attribution)
