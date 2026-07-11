# Phase 1: Define the New Description Pattern

**Phase ID:** pattern-definition
**Issue:** .opencode#1855
**Dependencies:** None
**SC Coverage:** SC-1, SC-2, SC-3, SC-4

## Step 1: Update routing-only-template.md description template

**File:** `.opencode/skills/skill-creator/reference/routing-only-template.md`
**Change:** Replace the old description template (line 18) and farmage pattern docs (lines 20-27) with the new pattern.

**Old template (line 18):**
```
description: "Use when <primary use case>. Also use when <secondary use cases>. Invoke for: <comma-separated task list>. <Mandatory enforcement statement>. Trigger phrases: <comma-separated trigger phrase list>."
```

**Old farmage docs (lines 20-27):**
```
**Description format (farmage pattern):**
- `Use when` — primary use case (1 sentence)
- `Also use when` — secondary/edge case uses (1 sentence, omit if none)
- `Invoke for:` — comma-separated list of task names the skill handles
- Enforcement statement — e.g., "Spec creation is REQUIRED before implementation."
- `Trigger phrases:` — comma-separated list of natural language phrases an agent might say to invoke this skill
- Max 1024 characters (opencode limit)
- Exclusion clauses (`— distinct from <exclusion>`) for skills that could false-match
```

**New template:**
```
description: "<Noun phrase describing what the skill is>. Dispatch when <agent-facing trigger conditions>. Also dispatch when <additional trigger conditions>. <Enforcement statement>. User phrases: <preserved user-facing trigger phrases>."
```

**New farmage docs:**
```
**Description format (agent-intent pattern):**
- `<Noun phrase>` — what the skill IS (not when to use it)
- `Dispatch when` — agent-facing trigger conditions (what the agent is doing)
- `Also dispatch when` — additional agent-facing trigger conditions
- Enforcement statement — e.g., "Spec creation is REQUIRED before implementation."
- `User phrases:` — preserved user-facing trigger phrases (same content as old "Trigger phrases:")
- Max 1024 characters (opencode limit)
- Exclusion clauses (`— distinct from <exclusion>`) for skills that could false-match
```

**Validation rules (for the description field):**
- Description MUST NOT start with "Use when"
- Description MUST start with a noun phrase (agent-intent statement)
- Description MUST contain "Dispatch when"
- Description MUST contain "User phrases:"
- Description MUST NOT contain "Invoke for:"
- Description MUST NOT contain "Trigger phrases:"
- Description MUST NOT contain "Also use when"
- Description MUST NOT contain angle brackets (unchanged)
- Description MUST be ≤ 1024 characters (unchanged)

**RED/GREEN:** Write a content-verification test that greps for the new pattern in routing-only-template.md. RED: test fails (old pattern). GREEN: after update, test passes.

## Step 2: Update skill-card-spec.md reference

**File:** `.opencode/skills/skill-creator/reference/skill-card-spec.md`
**Change:** Add a note referencing the new description pattern from routing-only-template.md. The existing reference to routing-only-template.md is sufficient — the pattern is defined there. Add a brief note in the YAML frontmatter section about the description format requirements.

**RED/GREEN:** grep for "Dispatch when" in skill-card-spec.md. RED: not present. GREEN: present.

## Step 3: Update init_skill.py template

**File:** `.opencode/skills/skill-creator/scripts/init_skill.py`
**Change:** Replace the SKILL_TEMPLATE description placeholder (line 29).

**Old (line 29):**
```python
description: "[TODO: Use when ...]"
```

**New:**
```python
description: "[TODO: <noun phrase describing skill>. Dispatch when ...]"
```

**RED/GREEN:** Run init_skill.py with a test skill name, grep output for "Dispatch when". RED: not present. GREEN: present.

## Step 4: Update validate_skill_cards.py validation rules

**File:** `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`
**Change:** Reverse the description validation rules in `validate_req1()` (lines 141-153) and `validate_sc_lint_001()` (lines 183-195).

**Current behavior (validate_req1, lines 141-153):**
- Line 143: `if not desc.startswith("Use when")` → violation (REQUIRES "Use when" prefix)

**Target behavior (validate_req1):**
- MUST NOT start with "Use when" → violation
- MUST start with a noun phrase (heuristic: first word is not "Use")
- MUST contain "Dispatch when"
- MUST contain "User phrases:"
- MUST NOT contain "Invoke for:"
- MUST NOT contain "Trigger phrases:"
- MUST NOT contain "Also use when"
- MUST NOT contain angle brackets (unchanged)

**Current behavior (validate_sc_lint_001, lines 183-195):**
- Line 186: `if not desc.startswith("Use when")` → violation

**Target behavior (validate_sc_lint_001):**
- MUST NOT start with "Use when" → violation
- MUST contain "Dispatch when"
- MUST contain "User phrases:"
- MUST NOT contain "Invoke for:"
- MUST NOT contain "Trigger phrases:"
- MUST NOT contain "Also use when"

**RED/GREEN:** Create a test SKILL.md with old-pattern description, run validator → exit 1. Create a test SKILL.md with new-pattern description, run validator → exit 0.

## Phase 1 Completion

- [ ] All 4 files updated
- [ ] SC-1: New pattern documented in reference docs (string)
- [ ] SC-2: Validator rejects old pattern (behavioral)
- [ ] SC-3: Validator accepts new pattern (behavioral)
- [ ] SC-4: init_skill.py generates new pattern (string)
- [ ] Z3 check: verify phase output has PASS status
