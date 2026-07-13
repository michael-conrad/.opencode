# Phase 1: Audit & Frame

## Purpose

Audit all 43 skill descriptions, classify their current dispatch framing, and build the mapping table that drives Phases 2 and 3.

## Chain Dependencies

- **Depends on:** none (Phase 1 is the foundation)
- **Required by:** Phase 2 (needs mapping table)

## Steps

### Step 1.1: Extract all 43 current descriptions

Read the `description` frontmatter field from all 40 `skills/*/SKILL.md` files and 3 `skills/issue-operations/platforms/*/SKILL.md` files.

**Dispatch:** Use `grep` or `srclight` to extract the description field from each file. Store results as a YAML table at `.opencode/.issues/1899/artifacts/description-audit.yaml`.

**Evidence:** File existence of `description-audit.yaml` with all 43 entries.

### Step 1.2: Classify each description

For each of the 43 descriptions, classify as one of:
- **(a) agent-intent dominant** — description primarily says "Dispatch when the agent determines X"
- **(b) user-utterance dominant** — description primarily lists user phrases
- **(c) mixed** — description has both agent-intent conditions AND "User phrases:" suffix

Append classification to `description-audit.yaml`.

**Evidence:** YAML file with classification column populated for all 43.

### Step 1.3: Build agent-intent reformulation for each description

For each description, write an agent-intent reformulation:
- Lead with: `Dispatch when [CONDITION]. Also dispatch when [CONDITION_2].`
- Replace `User phrases: X, Y, Z` with `Triggers when: the agent determines [INTENT] or observes [CONTEXT].`

Store as `reformulation` field in `description-audit.yaml`.

### Step 1.4: Identify canonical description pattern

Derive the canonical pattern for all descriptions from the reformulations:
- `"Dispatch when [CONDITION]. Also dispatch when [CONDITION]. Triggers when: the agent determines [INTENT]."`

Store as `canonical-pattern.md` at `.opencode/.issues/1899/artifacts/canonical-pattern.md`.

**Evidence:** File existence with single canonical pattern definition.

### Step 1.5: Create behavioral test samples for representative dispatch categories

For each dispatch category (audit, template, rewrite, gate), create a behavioral test skeleton that sends a prompt requiring agent-intent dispatch (no user utterance match available). Store at `.opencode/tests/behaviors/` prefixed with `agent-intent-`.

**SC coverage:** SC-7 (representative sample of 43 skills, 1 per dispatch category).

## Phase Exit Criteria

- [ ] `description-audit.yaml` exists with all 43 entries, each having: current description, classification, reformulation
- [ ] `canonical-pattern.md` exists with the canonical description pattern
- [ ] Behavioral test skeleton files exist for representative dispatch categories
- [ ] All evidence artifacts committed to feature branch

## Safety/Rollback

No destructive operations in this phase (read-only audit plus artifact creation).
