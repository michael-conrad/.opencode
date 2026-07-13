# Phase 2: Template Update

## Purpose

Update the skill-creator routing-only template and validation rules to use the new agent-intent dispatch pattern established in Phase 1.

## Chain Dependencies

- **Depends on:** Phase 1 (needs canonical pattern from Step 1.4)
- **Required by:** Phase 3 (new descriptions must be validated against updated template)

## Steps

### Step 2.6: Update `routing-only-template.md`

Read `.opencode/skills/skill-creator/reference/routing-only-template.md`. Replace:
- `User phrases: [VERBATIM_PHRASES]` → `Triggers when: [agent-intent dispatch conditions]`
- Ensure the template's Agent-Intent Pattern section uses the canonical pattern from Phase 1 Step 1.4

**SC coverage:** SC-3

**Evidence:** `grep` on template file confirming no `User phrases:` remains.

**Dispatch:** Read file → edit_text with old→new replacement → verify.

### Step 2.7: Update `validate.md` REQ-2

Read `.opencode/skills/skill-creator/tasks/validate.md`. Find REQ-2 (or the rule that checks description format). Update it to:
- Accept descriptions with `Dispatch when` + `Triggers when:` format
- Reject descriptions with `User phrases:` suffix
- Add acceptance criteria for agent-intent framing

**SC coverage:** SC-4

**Evidence:** `grep` on validate.md confirming new pattern accepted, old pattern rejected.

## VbC (Phase 2)

After both steps complete, run verification-before-completion:
- [ ] SC-3: `grep` routing-only-template.md — no `User phrases:`
- [ ] SC-4: `opencode-cli run` with prompt to create a skill — verify validation passes without `User phrases:`

## Safety/Rollback

- Destructive operations: File edits to template and validate.md
- Rollback: `git checkout -- skills/skill-creator/reference/routing-only-template.md skills/skill-creator/tasks/validate.md`
- Data loss risk: low (tracked files, git recovery available)
