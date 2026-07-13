# Phase 4: Pre-Response Gate Audit

## Purpose

Update the Pre-Response Gate wording in AGENTS.md and prompts/default.txt to use agent-intent dispatch language instead of user-utterance matching language.

## Chain Dependencies

- **Depends on:** Phase 3 (descriptions rewritten — gate wording must match actual dispatch triggers)
- **Required by:** none (final phase)

## Steps

### Step 4.13: Update AGENTS.md §Universal Skill Dispatch Gate Step 1

Read `.opencode/AGENTS.md` §Universal Skill Dispatch Gate. Find Step 1: `"Evaluate the user message against ALL available skill descriptions."`

Replace with: `"Evaluate your current context and task intent against ALL available skill descriptions. (The match is between what you need to do next and what the skill does — not the literal user utterance.)"`

**SC coverage:** SC-5

**Evidence:** `grep` on AGENTS.md confirming new wording present.

### Step 4.14: Update `prompts/default.txt` Pre-Response Gate wording

Read `.opencode/prompts/default.txt` §Pre-Response Gate. Find the step that says `"Scan <available_skills> for matching triggers."`

Clarify to: `"Scan <available_skills> for matching agent-intent dispatch triggers."` — adding "agent-intent" qualifier to clarify the matching criterion is the agent's internal determination.

**SC coverage:** SC-6

**Evidence:** `grep` on default.txt confirming "agent-intent dispatch triggers" present.

### Step 4.15: Verify no `"evaluate the user message"` language remains

Run `grep -n "evaluate the user message" .opencode/AGENTS.md` and confirm zero matches (the old wording is completely replaced).

**Evidence:** Grep output showing 0 matches.

### Step 4.16: Run lint/format check on modified files

Run `uvx pymarkdownlnt scan .opencode/AGENTS.md .opencode/prompts/default.txt` to verify markdown correctness.

**Evidence:** Linter passes with no errors.

## VbC (Phase 4)

- [ ] SC-5: AGENTS.md Step 1 says "Evaluate your current context and intent" (or equivalent)
- [ ] SC-6: default.txt explicitly mentions "agent-intent" triggers
- [ ] No "evaluate the user message" language remains in AGENTS.md
- [ ] Markdown lint passes on both modified files

## Safety/Rollback

- Destructive operations: File edits to AGENTS.md and default.txt
- Rollback: `git checkout -- .opencode/AGENTS.md .opencode/prompts/default.txt`
- Data loss risk: low (tracked files)
