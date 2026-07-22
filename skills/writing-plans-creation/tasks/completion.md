# Task: completion

<!-- Dimensions synced from .opencode/reference/holistic-dimensions.yaml -->
<!-- Sync locations: see cross-reference table in that file -->

Idempotent completion subtask for writing-plans. Ensures mandatory steps ran regardless of where the workflow halted.

## Entry Criteria

- Plan files have been created (or creation was attempted)
- Workflow has reached a halt point (success, partial, or error)

## Procedure

### State Check Phase

- [ ] 1. **Plan files created:** Verify plan index exists at `{N}/plan.md` and all phase files exist at `{N}/plan-{NN}-*.md` (for multi-phase), or single `{N}/plan.md` (for single-phase)
- [ ] 2. **Phase files created:** For multi-phase plans, verify phase files exist at `{N}/plan-{NN}-*.md` (local `.issues/` artifacts — NOT GitHub Issues)
- [ ] 3. **Self-review completed:** Verify self-review checklist was run (coverage, placeholders, type consistency)
- [ ] 4. **Chat exec summary + URL:** Verify chat output includes exec summary format with plan URL

### Pre-Completion Holistic Self-Check

**MANDATORY GATE — MUST NOT be skipped.** Before finalizing the plan, evaluate the plan against the 11 plan dimensions defined in `.opencode/reference/holistic-dimensions.yaml`.

- [ ] 0. Holistic self-check — Evaluate the plan against the 11 plan dimensions defined in `.opencode/reference/holistic-dimensions.yaml`
  - Context passed: `{ plan_context }`
  - Expected: PASS for all 11 plan dimensions
  - On FAIL: refuse to finalize — return the plan to the create task for revision with the failed dimensions listed
  - On PASS: proceed to Skill-Specific Completion

### Skill-Specific Completion

- [ ] 1. **Plan files** (if not already created):
   - Check evidence for plan index at `{N}/plan.md` and phase files at `{N}/plan-{NN}-*.md`
   - If missing: report as blocker — plan files must exist before completion

- [ ] 2. **Phase files** (if multi-phase and not already created):
   - Check evidence for phase files at `{N}/plan-{NN}-*.md` (local `.issues/` artifacts — NOT GitHub Issues)
   - If missing: report as blocker — phase files must exist before completion

- [ ] 3. **Self-review** (if not already performed):
   - Check evidence for self-review checklist completion
   - If missing: report as blocker — self-review must be performed before completion

- [ ] 4. **Chat executive summary** (if not already produced):
   - Verify exec summary was posted to chat with plan URL
   - If missing: generate and post exec summary now

### Shared Completion Delegation

Reference `.opencode/skills/completion-core/SKILL.md` for reporting:

- [ ] 1. Report executive summary in chat (always runs)
- [ ] 2. Action URL (plan issue URL) as the URL (ALWAYS last)

### Report Phase

Generate executive summary in chat:

```
**Summary:**

<1-2 sentences describing impact>

**Outcome:** <What the result means for stakeholders>

<URL if applicable, ALWAYS LAST>

🤖 <AgentName> (<ModelId>) <status>
```

## Exit Criteria

- All mandatory state checks completed
- Holistic self-check passed (or plan returned for revision)
- Chat executive summary generated and posted with plan URL
- Pipeline signal reported with correct next step
- AI byline present as last element

### Completion Guarantee

**MANDATORY:** Regardless of workflow outcome (success, partial, error), produce a status message containing:
- [ ] 1. What was completed
- [ ] 2. What was attempted but not completed
- [ ] 3. Why the halt occurred

This is the completion guarantee: NO writing-plans workflow ends without a status message.

### Pipeline Signal

```
CONTINUE: audit --task plan-fidelity,concern-separation
HALT
```

### Format Verification Before Halt (MANDATORY)

**Idempotent — safe to invoke multiple times. This verification runs before EVERY halt, regardless of path.**

- [ ] Executive summary present as **first** element
- [ ] Outcome line present after summary
- [ ] URL present IF relevant (after outcome, before byline)
- [ ] AI byline present as **LAST** element
- [ ] No stale todowrite items remain (all cleared or N/A)

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "..." |
| artifact_path | ".../artifacts/completion.yaml" |
| blocker_reason | "..." |
