# Phase 3: Per-Skill Description Rewrites

## Purpose

Rewrite all 43 skill descriptions (40 main + 3 platform sub-skills) to eliminate `User phrases:` and replace with agent-intent trigger conditions. Each rewrite follows a RED → GREEN cycle with behavioral test.

## Chain Dependencies

- **Depends on:** Phase 2 (template/validation rules define the target format)
- **Required by:** Phase 4 (rewrites must be complete before gate audit)

## Steps

### Step 3.8: Read and rewrite each description — batch per dispatch category

For each dispatch category identified in Phase 1, read the current SKILL.md description and rewrite it using the canonical pattern from Step 1.4.

**Dispatch category groupings:** Use the classification from `description-audit.yaml` to group skills and process them by category (e.g., all audit-category skills together, all template-category skills together).

For each skill:
1. Read `skills/{name}/SKILL.md` — extract the description frontmatter field
2. Write a reformulated description using the canonical agent-intent pattern
3. Apply `edit_text` to replace the description field in the file

**SC coverage:** SC-1, SC-2

**Evidence:** After each batch, `grep` on all SKILL.md description fields to confirm no `User phrases:` remains.

### Step 3.9: Verify SC-2 — first clause is agent-intent condition

After all 43 rewrites, run a `grep` or `srclight` check on all description fields to verify every description starts with `Dispatch when` or `Triggers when` — never a user-utterance phrase.

**SC coverage:** SC-2

**Evidence:** Structured results file at `.opencode/.issues/1899/artifacts/description-first-clause-check.yaml`.

### Step 3.10: Verify SC-1 — no `User phrases:` remains

Run `grep -r "User phrases:" .opencode/skills/*/SKILL.md .opencode/skills/issue-operations/platforms/*/SKILL.md` and confirm zero matches.

**SC coverage:** SC-1

**Evidence:** Grep output showing 0 matches.

### Step 3.11: Create behavioral enforcement tests (representative sample)

Per SC-7, create behavioral enforcement tests that verify the agent dispatches based on internal intent (not user utterance matching). Given 43 skills, test a representative sample of 1 skill per dispatch category (4–6 categories) with `assert_semantic` clean-room evaluation.

For each tested skill, create a test at `.opencode/tests/behaviors/agent-intent-{skill}-dispatch.sh` that:
1. Sends a prompt where the agent must self-determine the need (no literal user phrase match)
2. Runs `opencode-cli run` via the `with-test-home` wrapper
3. Uses `assert_semantic "SC-7" "agent dispatched {skill} based on internal intent"`

**SC coverage:** SC-7

**Evidence:** Test files exist and pass.

### Step 3.12: Run RED→GREEN per skill group

RED: Write the behavioral test → verify it fails (agent doesn't dispatch autonomously before rewrite).
GREEN: Rewrite the description → verify test passes.

This is the TDD cycle for behavioral enforcement. Each dispatch category group goes through RED→GREEN.

## VbC (Phase 3)

- [ ] SC-1: `grep` across all SKILL.md — zero `User phrases:` or `user says` patterns
- [ ] SC-2: Each description first clause is an agent-intent condition (e.g., `Dispatch when`, `Triggers when`)
- [ ] SC-7: Behavioral tests exist and pass for representative sample

## Safety/Rollback

- Destructive operations: 43 file edits (description fields)
- Rollback: `git checkout -- skills/*/SKILL.md skills/issue-operations/platforms/*/SKILL.md`
- Data loss risk: medium — bulk change; verify with `git diff --stat` before commit
