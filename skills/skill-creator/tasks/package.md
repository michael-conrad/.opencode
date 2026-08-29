# Task: package

## Purpose

Packages a validated skill folder into a distributable zip archive using the `package_skill.py` script, preserving directory structure and metadata.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- Skill folder path (`{skill_folder}`) provided in context
- Output directory (`{output_dir}`) provided in context (optional — defaults to current directory)
- Worktree path (`{worktree.path}`) provided in context (prefix all paths when set)

If any entry criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Procedure

- [ ] 1. Read `skill-creator/scripts/package_skill.py` to confirm the packaging and validation behavior.
- [ ] 2. Run the packager:
   ```bash
   uv run .opencode/skills/skill-creator/scripts/package_skill.py <skill_folder> [<output_dir>]
   ```
- [ ] 3. Confirm the script validates the skill before packaging — it checks for SKILL.md presence, valid YAML frontmatter, `name` and `description` fields, and hyphen-case name constraints.
- [ ] 4. If validation fails, HALT and report the validation error. Do not package a skill that fails validation.
- [ ] 5. Confirm the zip archive is created at the output location, containing the skill folder contents with relative paths preserved (SKILL.md, tasks/, scripts/, references/, assets/, etc.).
- [ ] 6. Write the packaged zip path to the evidence artifact.
- [ ] 7. Return the result contract.

## Exit Criteria

- Packaged zip artifact produced at the expected output location
- Skill validated successfully before packaging
- Result contract returned

If any exit criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences of routing-significant output>"
artifact_path: "<path to the created zip archive>"
blocker_reason: "<reason if BLOCKED>"
```

## Context Required

- Related task: `skill-creator/tasks/validate.md` (validation may be run independently before packaging)
- Related script: `skill-creator/scripts/package_skill.py`
- Related guideline: `080-code-standards.md` (metadata preservation, no broken task references)
