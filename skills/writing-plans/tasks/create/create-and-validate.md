# Task: create/create-and-validate

## Purpose

Write plan document to `.issues/{N}/plan.md`, validate structure, and handle approval cascade with scope-aware auto-approval.

## Entry Criteria

- Plan structure completed (plan-structure sub-task)
- Combined/separate decision made
- TDD tasks defined with checkpoints

## Exit Criteria

- Plan document written to `.issues/{N}/plan.md`
- Self-review and validation complete
- Verification revisit passed
- Plan reported in chat with `.issues/{N}/plan.md` path
- Approval cascade applied (auto-approval for pipeline scope)

## Procedure

### Step 6: Write Plan Document Header

- [ ] 1. Write Goal, Architecture, Tech Stack
- [ ] 2. Write file structure with clear responsibilities

### Step 7: Store Plan Document

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

- [ ] 1. Include compliance statement blockquote at top (after preamble) and bottom (before exit criteria)
- [ ] 2. Write plan to `.issues/{N}/plan.md`
- [ ] 3. Proceed to Step 8

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

### Phase body requirements — Checklist format with dispatch indicators

Each phase MUST use the implementation pipeline checklist format. Gate sequence and dispatch types are discovered from `implementation-pipeline/SKILL.md` §Dispatch Routing Table — never hardcoded. Phase bodies follow this format:

```
### Phase N: title

**Concern:** concern boundary
**Files:** exact paths or glob patterns
**SCs covered:** SC-N, SC-M

- [ ] 1. <STEP-LABEL> — `<skill-name>` for <concern> (**<clean-room|inline>**)
    → dispatch: "execute <task> from <skill-name>"
    → SC-N
- [ ] N. <STEP-LABEL> — `<skill-name>` for <concern> (**<clean-room|inline>**)
    → dispatch: "execute <task> from <skill-name>"
    → SC-N
```

**Format rules:**
- Every step is `- [ ] N.` with at least one sub-bullet — no prose-only steps
- Every step title contains `— <skill-name> for <concern> (**<clean-room|inline>**)` with a skill name in the dispatch marker
- Every step that maps to a success criterion has a `→ SC-N` annotation
- No step describes more than one atomic action — sub-operations get their own `- [ ] N.` entries
- Gate sequence is discovered from `implementation-pipeline/SKILL.md` §Dispatch Routing Table — never hardcoded
- Bare `(**clean-room**)` or `(**inline**)` without a preceding skill name is invalid

**Concern boundary annotations (prose-driven):**
When transitioning concerns: describe what is being left, what is being entered, what information is needed for handoff.

**Pre-RED common sub-step format:** Every sub-step in Pre-RED Common sections MUST use the `- [ ] N.` indented checkbox format — never `→` prose continuation lines. This applies to verification gate, read-spec, read-routing-table, and all other pre-RED sub-steps.

### Step 7.5: Spec-to-Plan Handoff Artifact Check

- [ ] 1. Enumerate expected spec artifacts: `sc-summary.yaml`, `verification-consistency-contract.yaml`, `revision-re-entry-contract.yaml`, `lifecycle.yaml`
- [ ] 2. Verify every expected artifact exists — missing artifacts flagged as MISSING-TRACEABILITY

### Step 7.6: SC Coverage YAML Cross-Reference Validation

- [ ] 1. Read `.issues/{issue-N}/sc-summary.yaml`
- [ ] 2. Verify every SC ID in YAML is mapped to at least one plan item
- [ ] 3. Verify every plan item's SC-ID references exist in YAML
- [ ] 4. Flag orphan SCs (unmapped) as MISSING-TRACEABILITY
- [ ] 5. Flag undefined SC references as SCOPE-CREEP
- [ ] 6. Record cross-reference result as evidence artifact

### Step 7.7: Spec-to-Plan Handoff Artifact Check

- [ ] 1. Enumerate all expected artifacts
- [ ] 2. Verify SC coverage YAML cross-reference
- [ ] 3. Verify lifecycle manifest indicates `plan_created` event
- [ ] 4. Generate spec-to-plan handoff manifest at `./tmp/{issue-N}/artifacts/spec-to-plan-manifest.yaml`

### Step 8: Generate Implementation Checklist

- [ ] 1. Read the plan at `.issues/{N}/plan.md`
- [ ] 2. Extract every phase → unit → file path
- [ ] 3. Write each as a checkbox item with `pending` default status
- [ ] 4. Save to `./tmp/{N}/checklist.md`
- [ ] 5. Verify `./tmp/{N}/checklist.md` exists and contains all phases, units, and file paths

### Step 9: Self-Review

- [ ] 1. Spec coverage check
- [ ] 2. Placeholder scan
- [ ] 3. Type consistency check
- [ ] 4. Fix any issues found

### Step 10: Validate Plan

- [ ] 1. Check for TBD/TODO placeholders
- [ ] 2. Verify all steps are actionable
- [ ] 3. Verify success criteria are testable
- [ ] 4. Prose-structure check: phase descriptions remain prose
- [ ] 5. Verify each phase declares test output artifact paths using `./tmp/{issue-N}/artifacts/` convention
- [ ] 6. Verify `solve check` returns SAT — if UNSAT, HALT with blocker report
- [ ] 7. Verify `plan plan` returns SOLVED_SATISFICING or SOLVED_OPTIMALLY — if UNSOLVABLE, HALT
- [ ] 8. Verify each referenced pipeline step label exists in `implementation-pipeline/SKILL.md` dispatch routing table — if undefined, HALT with MISSING-TRACEABILITY

#### Phase Structure Validation (three-part structure)

- [ ] 1. **Pre-RED section exists:** Every phase has exactly one Pre-RED Common section → SC-4
- [ ] 2. **Post-RED section exists:** Every phase has exactly one Post-RED/green section → SC-4
- [ ] 3. **Chain ordering:** RED+green chains execute between Pre-RED and Post-RED sections → SC-4
- [ ] 4. **Pre-RED not duplicated:** Pre-RED steps appear exactly once per phase → SC-4
- [ ] 5. **Post-RED not duplicated:** Post-RED steps appear exactly once per phase → SC-4
- [ ] 6. **RED/GREEN step separation:** RED and GREEN are separate (not combined) steps → SC-7

#### Checklist Validation

- [ ] 1. **Checklist format:** Every step is `- [ ] N.` with at least one sub-bullet — no prose-only steps
- [ ] 2. **Dispatch indicator:** Every step title contains `— <skill-name> for <concern> (**<clean-room|inline>**)` — bare `(**clean-room**)` without skill name is rejected
- [ ] 3. **Gate sequence match:** Every step label exists in `implementation-pipeline/SKILL.md` §Dispatch Routing Table
- [ ] 4. **Atomic action:** No step describes more than one atomic action — sub-operations expanded into own `- [ ] N.` entries
- [ ] 5. **SC annotations:** All SCs referenced via `→ SC-N` annotations
- [ ] 6. **No TBD/TODO:** No TBD/TODO placeholders — all steps are actionable
- [ ] 7. **Admonishment present:** Compliance admonishment blockquote at top and bottom of plan body
- [ ] 8. **Phase dependency ordering:** No phase references a dependency that does not exist
- [ ] 9. **Skill name exists:** Every dispatch marker skill name references existing directory under `.opencode/skills/`. HALT with `SKILL_NOT_FOUND` if non-existent
- [ ] 10. **Exhaustive mapping:** No step uses bare `(**clean-room**)` without preceding skill name. HALT with `MISSING_SKILL_NAME`
- [ ] 11. **Post-RED pipeline gates:** Every phase has completeness-gate, adversarial-audit, completion-core with expanded checkbox sub-steps. HALT with `MISSING_POST_RED_GATE`
- [ ] 12. **Prose sub-step rejection:** No `→` arrow continuations that aren't `→ dispatch:` or `→ SC-N`. HALT with `PROSE_SUBSTEPS_DETECTED`

If any rule fails: HALT with MISSING-TRACEABILITY and report which rule(s) failed.

### Step 11: Verification Revisit (MANDATORY)

- [ ] 1. Invoke `/skill verification-enforcement --task revisit`
- [ ] 2. Scan for `⚠️ UNVERIFIED` markers — resolve if possible, escalate unresolvable claims

### Step 12: Report Plan Creation in Chat (MANDATORY)

- [ ] 1. Report in format: `Created plan at .issues/{N}/plan.md for [owner/repo#N](url) (description). N phases across N items.`
- [ ] 2. Append byline: `🤖 <AgentName> (<ModelId>)`

### Step 13: Cross-Reference Verification (MANDATORY)

- [ ] 1. Verify referenced skills and tasks exist via `ls` and `grep`
- [ ] 2. If any verification fails: flag as MISSING-TRACEABILITY

### Authorization Context for Task()

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

#### Task() Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`
- The `pipeline_phase` field is used to track which phase of a multi-phase plan is being executed

### Step 14: Plan Approval

- [ ] 1. Apply scope-aware auto-approval: if scope >= `for_plan`, record approval in chat report
- [ ] 2. If `halt_at == plan_created`: HALT after plan creation — do NOT proceed to implementation

### Step 15: Plan-Reference Sync

- [ ] 1. Read plan file from `.issues/{N}/plan.md` to confirm it exists
- [ ] 2. Call `github_issue_write` to append plan cross-reference to spec issue body (skip if already present)
- [ ] 3. Verify update succeeded by reading back the issue body

## Acceptance Criteria

| ID | Criterion |
| -- | -- |
| C1 | Plan header includes Goal, Architecture, Tech Stack |
| C2 | File structure lists all files with responsibilities |
| C3 | TDD tasks include mandatory Step 2 RED checkpoint |
| C4 | Phase descriptions include concern boundary annotations |
| C5 | Plan stored at `.issues/{N}/plan.md` |
| C6 | No TBD/TODO placeholders remain |
| C7 | Plan artifact created locally in `.issues/{N}/` |
| C8 | Status marker uses prose-driven format |
| C9 | Approval cascade honors `authorization_scope` |

## Context Required

- Related tasks: `create/plan-structure`
- Related skills: `verification-enforcement`
- Related guidelines: `000-critical-rules.md` (chat format)