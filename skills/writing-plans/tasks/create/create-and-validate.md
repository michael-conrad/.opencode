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

- Goal, Architecture, Tech Stack
- File structure with clear responsibilities

### Step 7: Store Plan Document

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

The generated plan body MUST include this compliance statement blockquote at the top (after the preamble) and at the bottom (before the exit criteria section).

**All paths (combined and separate):**
- Write plan to `.issues/{N}/plan.md`
- Proceed to Step 8

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

### Phase body requirements — Checklist format with dispatch indicators

Each phase MUST use the implementation pipeline checklist format. Gate sequence and dispatch types are discovered from `implementation-pipeline/SKILL.md` §Dispatch Routing Table — never hardcoded. Phase bodies follow this format:

```
### Phase N: title

**Concern:** concern boundary
**Files:** exact paths or glob patterns
**SCs covered:** SC-N, SC-M

- [ ] 1. <STEP-LABEL> (**<clean-room|inline>**). <description> → SC-N
- [ ] N. <STEP-LABEL> (**<clean-room|inline>**). <description> → SC-N
```

**Format rules:**
- Every step is `- [ ] N.` with at least one sub-bullet — no prose-only steps
- Every step title contains `(**clean-room**)` or `(**inline**)` dispatch indicator
- Every step that maps to a success criterion has a `→ SC-N` annotation
- No step describes more than one atomic action — sub-operations get their own `- [ ] N.` entries
- Gate sequence is discovered from `implementation-pipeline/SKILL.md` §Dispatch Routing Table — never hardcoded

**Concern boundary annotations (prose-driven):**
When transitioning concerns: describe what is being left, what is being entered, what information is needed for handoff.

### Step 7.5: Spec-to-Plan Handoff Artifact Check

Before writing the plan document, enumerate and validate spec artifacts that must be consumed by the plan:

```bash
ls .issues/{issue-N}/sc-summary.yaml
ls .issues/{issue-N}/verification-consistency-contract.yaml
ls .issues/{issue-N}/revision-re-entry-contract.yaml
ls ./tmp/{issue-N}/lifecycle.yaml
```

Every expected spec artifact MUST exist. Missing artifacts are flagged as MISSING-TRACEABILITY.

### Step 7.6: SC Coverage YAML Cross-Reference Validation

Cross-reference the SC coverage YAML against the plan structure:

1. Read `.issues/{issue-N}/sc-summary.yaml`
2. Verify every SC ID in the YAML is mapped to at least one plan item
3. Verify every plan item's SC-ID references exist in the YAML
4. Flag orphan SCs (unmapped) as MISSING-TRACEABILITY
5. Flag undefined SC references (in plan but not in YAML) as SCOPE-CREEP
6. Record the cross-reference result as an evidence artifact

### Step 7.7: Spec-to-Plan Handoff Artifact Check

Before finalizing the plan, verify spec-to-plan handoff artifacts:

1. Enumerate all expected artifacts from ``
2. Verify SC coverage YAML cross-reference: each SC in the spec has a corresponding plan item
3. Verify lifecycle manifest indicates `plan_created` event
4. Generate spec-to-plan handoff manifest at `./tmp/{issue-N}/artifacts/spec-to-plan-manifest.yaml`

### Step 8: Generate Implementation Checklist

Generate `./tmp/{N}/checklist.md` from the finalized plan phases. The checklist tracks implementation progress per phase, unit, and file.

**Format:**
```markdown
# Implementation Checklist — #{N}

## Phase {P}: {title}
### Unit {U}: {unit-title}
- [ ] {file-path} — {description}
```

**Procedure:**
1. Read the plan at `.issues/{N}/plan.md`
2. Extract every phase → unit → file path
3. Write each as a checkbox item with `pending` default status
4. Save to `./tmp/{N}/checklist.md`

**Exit criterion:** `./tmp/{N}/checklist.md` exists and contains all phases, units, and file paths from the plan.

### Step 9: Self-Review

- Spec coverage check
- Placeholder scan
- Type consistency check
- Fix any issues found

### Step 10: Validate Plan

- Check for TBD/TODO placeholders
- Verify all steps are actionable
- Verify success criteria are testable
- Prose-structure check: phase descriptions remain prose
- **Verify each phase declares test output artifact paths** using `./tmp/{issue-N}/artifacts/` convention (not bare `./tmp/`)
- **Verify `solve check` returns SAT** — if UNSAT, HALT with blocker report
- **Verify `plan plan` returns SOLVED_SATISFICING or SOLVED_OPTIMALLY** — if UNSOLVABLE or unavailable, HALT with blocker report
- **Verify each referenced pipeline step label exists in `implementation-pipeline/SKILL.md`'s dispatch routing table** — if any label is undefined, HALT with MISSING-TRACEABILITY

#### Checklist Validation

Every plan phase checklist MUST pass the following 8 validation rules:

1. **Checklist format:** Every step is `- [ ] N.` with at least one sub-bullet — no prose-only steps, no collapsed multi-operation steps
2. **Dispatch indicator:** Every step title contains `(**clean-room**)` or `(**inline**)` — no step is missing a dispatch mode marker
3. **Gate sequence match:** Gate sequence matches `implementation-pipeline/SKILL.md` §Dispatch Routing Table — every step label must exist in the canonical source
4. **Atomic action:** No step describes more than one atomic action — every sub-operation from pipeline task files is expanded into its own `- [ ] N.` entry
5. **SC annotations:** All SCs referenced via `→ SC-N` annotations — every step that maps to a success criterion has a visible SC reference
6. **No TBD/TODO:** No TBD/TODO placeholders — all steps are actionable
7. **Admonishment present:** Compliance admonishment blockquote present at top and bottom of plan body
8. **Phase dependency ordering:** Phase dependency ordering matches spec architecture — no phase references a dependency that does not exist

If any rule fails: HALT with MISSING-TRACEABILITY and report which rule(s) failed.

### Step 11: Verification Revisit (MANDATORY)

Invoke: `/skill verification-enforcement --task revisit`

Scans for `⚠️ UNVERIFIED` markers. Resolves if possible; escalates unresolvable claims.

### Step 12: Report Plan Creation in Chat (MANDATORY)

**Format — reference spec via full URL, plan via local artifact path:**
```
Created plan at `.issues/{N}/plan.md` for [<owner>/<repo>#<N>](https://github.com/<owner>/<repo>/issues/<N>) (<description>). <N> phases across <N> items.

🤖 <AgentName> (<ModelId>)
```

### Step 13: Cross-Reference Verification (MANDATORY)

Verify referenced skills and tasks exist:
```bash
ls .opencode/skills/approval-gate/SKILL.md && grep -c "verify-authorization" .opencode/skills/approval-gate/SKILL.md
ls .opencode/skills/writing-plans/tasks/create/plan-structure.md && grep -c "Step.*RED" .opencode/skills/writing-plans/tasks/create/plan-structure.md
```

If any verification fails: flag as MISSING-TRACEABILITY.

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

**Scope-aware auto-approval — approval is on the spec, plan is a local artifact:**

```python
SCOPE_LEVELS = {
    "for_review_prep": 0, "for_spec": 1, "for_analysis": 2,
    "for_plan": 3, "for_implementation": 4,
    "for_pr": 5, "for_pr_only": 5, "for_review_only": 4
}

if scope_level >= SCOPE_LEVELS["for_plan"]:
    # Pipeline authorization covers plan approval
    # Plan is local — record approval in chat report
    pass
```

**If `halt_at == plan_created`:** HALT after plan creation. Do NOT proceed to implementation.

### Step 15: Plan-Reference Sync

After the plan is approved and before the procedure exits, sync a cross-reference from the spec issue to the plan:

1. Read the plan file from `.issues/{N}/plan.md` to confirm it exists
2. Call `github_issue_write(method='update', owner='<owner>', repo='<repo>', issue_number=<N>)` with the existing issue body preserved and a plan cross-reference appended:
   - If the issue body does not already contain a plan reference, append:
     `---\n**Plan:** See [plan.md](.issues/{N}/plan.md) for the implementation plan.\n`
   - If the issue body already contains a plan reference, skip (no duplicate)
3. Verify the update succeeded by reading back the issue body

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