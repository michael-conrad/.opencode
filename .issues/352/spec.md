# Synced from GitHub Issue #352 at 2026-05-02T23:40:00Z

# Spec: Remediate engineering-approach and guideline-auditor Skills

**STATUS: 1.0 (DRAFT — NEEDS APPROVAL)**

## Root Cause

Both `engineering-approach` and `guideline-auditor` have a stray `tasks/SKILL.md` file that lacks YAML frontmatter entirely. Neither follows the canonical skill task pattern (individual task `.md` files under `tasks/`). The SKILL.md files for both reference tasks under names that do not correspond to actual task files.

### engineering-approach
- **SKILL.md** declares tasks: `design-before-code` (~300 words) and `verify-before-complete` (~300 words)
- **tasks/ directory** contains: `SKILL.md` (no frontmatter, content is a task named `implement-design`) and `verify-understanding.md`
- No `design-before-code.md`, no `verify-before-complete.md` — declared tasks have no files
- `tasks/SKILL.md` is a task file masquerading as a skill index — it describes `implement-design` but has no frontmatter

### guideline-auditor
- **SKILL.md** declares one task: `audit` (~500 words)
- **tasks/ directory** contains: `SKILL.md` (no frontmatter, content is a task named `scan-guidelines`)
- No `audit.md` exists
- `tasks/SKILL.md` is a task file masquerading as a skill index — it describes `scan-guidelines` but has no frontmatter

### Shared Pattern
Both skills have the same defect: a task content file was erroneously placed at `tasks/SKILL.md` instead of being an individual `tasks/<task-name>.md` file. The SKILL.md task references point to names that have no corresponding files.

## Fix Approach

For each skill:

1. **Remove `tasks/SKILL.md`** from both skill directories — tasks must be individual `.md` files
2. **Create proper task files matching SKILL.md declarations**:
   - `engineering-approach`: Create `tasks/design-before-code.md`, `tasks/verify-before-complete.md`, `tasks/completion.md`
   - `guideline-auditor`: Create `tasks/audit.md`, `tasks/completion.md`
3. **Reconcile `verify-understanding.md`** — verify its content and purpose, ensure SKILL.md references it correctly
4. **Add proper YAML frontmatter** to all task files

## Success Criteria

1. `engineering-approach/SKILL.md` task table matches actual files in `engineering-approach/tasks/`
2. `guideline-auditor/SKILL.md` task table matches actual files in `guideline-auditor/tasks/`
3. No `tasks/SKILL.md` exists in either skill directory
4. All task `.md` files have proper YAML frontmatter
5. Both skills have a `completion.md` task file
6. Behavioral enforcement test confirms agent can invoke both skills correctly

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
