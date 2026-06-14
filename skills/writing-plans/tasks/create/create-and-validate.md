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

**All paths (combined and separate):**
- Write plan to `.issues/{N}/plan.md`
- Proceed to Step 8

### Phase body requirements — Reference to canonical pipeline checklist

Each phase MUST use the implementation pipeline checklist from the canonical source: `implementation-pipeline/SKILL.md` §Dispatch Routing Table. Phase bodies follow this format:

```
### Phase N: title

**Concern:** concern boundary
**Files:** exact paths or glob patterns
**SCs covered:** SC-N, SC-M

- [ ] 1. <FIRST-STEP-LABEL> — **<dispatch mode>**
- [ ] ... (remaining steps per `implementation-pipeline/SKILL.md` §Dispatch Routing Table)
- [ ] N. <LAST-STEP-LABEL> — **<dispatch mode>**
```

The full dispatch routing table with execution targets lives at `implementation-pipeline/SKILL.md`. This file is the single source of truth — every step label, dispatch target, and artifact produced is defined there. Do NOT duplicate routing details here.

**Concern boundary annotations (prose-driven):**
When transitioning concerns: describe what is being left, what is being entered, what information is needed for handoff.

### Step 7.5: Spec-to-Plan Handoff Artifact Check

Before writing the plan document, enumerate and validate spec artifacts that must be consumed by the plan:

```bash
ls .issues/{issue-N}/sc-summary.yaml
ls .issues/{issue-N}/verification-consistency-contract.yaml
ls .issues/{issue-N}/revision-re-entry-contract.yaml
ls .issues/{issue-N}/lifecycle.yaml
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

### Step 8: Self-Review

- Spec coverage check
- Placeholder scan
- Type consistency check
- Fix any issues found

### Step 9: Validate Plan

- Check for TBD/TODO placeholders
- Verify all steps are actionable
- Verify success criteria are testable
- Prose-structure check: phase descriptions remain prose
- **Verify each phase declares test output artifact paths** using `./tmp/{issue-N}/artifacts/` convention (not bare `./tmp/`)
- **Verify `solve check` returns SAT** — if UNSAT, HALT with blocker report
- **Verify `plan plan` returns SOLVED_SATISFICING or SOLVED_OPTIMALLY** — if UNSOLVABLE or unavailable, HALT with blocker report
- **Verify each referenced pipeline step label exists in `implementation-pipeline/SKILL.md`'s dispatch routing table** — if any label is undefined, HALT with MISSING-TRACEABILITY

#### Dispatch Table Validation

Every plan phase dispatch table MUST pass the following 8 validation rules:

1. **6-column requirement:** Every dispatch table must have exactly 6 columns: `Gate`, `Dispatch Type`, `Blind?`, `Sub-Agent Type`, `Receives Context`, `SCs`
2. **One row per gate:** Every gate must have exactly one row — no merged cells, no multi-step rows
3. **Dispatch Type constraint:** Dispatch Type must be `sub-task` for all gates except `CHECKPOINT-COMMIT` which may be `inline`
4. **Blind? column:** `yes (blind)` for sub-task gates, `N/A` for inline gates
5. **Receives Context validity:** Must be a valid JSON object for sub-task gates, `—` (em dash) for inline gates
6. **SCs column validity:** SCs column must reference valid SC IDs from the spec
7. **Standard gate set check:** Verify all 16 step labels exist in `implementation-pipeline/SKILL.md` §Dispatch Routing Table — if any are undefined or missing, HALT with MISSING-TRACEABILITY
8. **No hardcoded gate labels:** Gate labels MUST reference the canonical source (`implementation-pipeline/SKILL.md` §Dispatch Routing Table) — never hardcode

If any rule fails: HALT with MISSING-TRACEABILITY and report which rule(s) failed.

### Step 10: Verification Revisit (MANDATORY)

Invoke: `/skill verification-enforcement --task revisit`

Scans for `⚠️ UNVERIFIED` markers. Resolves if possible; escalates unresolvable claims.

### Step 11: Report Plan Creation in Chat (MANDATORY)

**Format — reference spec via full URL, plan via local artifact path:**
```
Created plan at `.issues/{N}/plan.md` for [<owner>/<repo>#<N>](https://github.com/<owner>/<repo>/issues/<N>) (<description>). <N> phases across <N> items.

🤖 <AgentName> (<ModelId>)
```

### Step 12: Cross-Reference Verification (MANDATORY)

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

### Step 13: Plan Approval

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

### Step 14: Plan-Reference Sync

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