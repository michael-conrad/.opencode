# Task: plan-fidelity

## Purpose

Audit a plan for fidelity against its spec using clean-room generation and dual-adversarial comparison. Generates clean-room plan from spec's problem statement, compares against existing plan, identifies discrepancies.

## Entry Criteria

- Spec issue number provided
- Plan issue number provided (optional — may extract from spec)
- `audit_phase: plan_creation`
- `github.owner`, `github.repo` available

## Exit Criteria

- Clean-room plan compared against existing plan
- Discrepancies identified and classified
- PASS/FAIL consensus for each criterion
- Bidirectional findings reported

## Procedure

### Step 1: Extract Spec Problem Statement

Fetch spec issue:
```python
github_issue_read(method="get", owner=<owner>, repo=<repo>, issue_number=<spec_issue>)
```

Extract:
- Objective
- Problem Statement
- Context
- Constraints
- Success Criteria

Write to `./tmp/clean-room-input-<N>.md`.

### Step 2: Generate Clean-Room Plan

Invoke `writing-plans --task clean-room`:

```python
task(
    subagent_type="general",
    prompt=f"""Use writing-plans skill --task clean-room to generate plan from problem statement.

Input file: ./tmp/clean-room-input-<spec_issue>.md
worktree.path: {worktree.path}

Generate prose-driven plan (no template structure). Return plan as structured text."""
)
```

### Step 3: Fetch Existing Plan

If plan issue provided:
```python
github_issue_read(method="get", owner=<owner>, repo=<repo>, issue_number=<plan_issue>)
```

Otherwise, link from spec body.

### Step 4: Build Evaluation Criteria

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| PF-1 | All phases in clean-room appear in existing | One-to-one phase coverage |
| PF-2 | Phase order matches dependency order | No dependency reversal |
| PF-3 | Steps cover all success criteria | Each SC has corresponding step |
| PF-4 | No missing critical steps | Edge cases, error recovery included |
| PF-5 | Approach consistent | Clean-room and existing use same strategy |
| PF-6 | TDD checkpoints present | RED GREEN REFACTOR structure |

### Step 5: Dispatch Cross-Validate

Invoke `cross-validate` with comparison payload:

```python
task(
    subagent_type="general",
    prompt=f"""Use adversarial-audit skill --task cross-validate with:

evidence_payload:
---
CLEAN-ROOM PLAN:
{clean_room_plan}

EXISTING PLAN:
{existing_plan}

evaluation_criteria: <criteria_json>
audit_phase: plan_creation

worktree.path: {worktree.path}
github.owner: {github.owner}
github.repo: {github.repo}
"""
)
```

### Step 6: Classify Discrepancies

After verdict collection, classify each discrepancy:

| Finding Type | Classification | Action |
|-------------|----------------|--------|
| MISSING_PHASE | auto-fix | Add phase from clean-room |
| EXTRA_PHASE | flag-for-review | May be intentional |
| MISSING_STEP | auto-fix | Add step from clean-room |
| EXTRA_STEP | flag-for-review | May be intentional |
| APPROACH_DIFFERENCE | auto-fix | Clarify difference |
| MISSING_EDGE_CASE | conditional | Verify clean-room correctness |
| DEPENDENCY_REVERSAL | auto-fix | Reorder phases |
| MISSING_TDD_CHECKPOINT | conditional | Add RED checkpoint |

### Step 7: Generate Bidirectional Findings

For FAIL/DISAGREE criteria:

| Direction | Description |
|-----------|-------------|
| PLAN_INCOMPLETE | Existing plan missing clean-room elements |
| PLAN_OVERSCOPED | Clean-room smaller than existing |
| PLAN_DRIFT | Clean-room and existing diverged |

Present revision options.

### Step 8: Build Result Contract

```json
{
  "status": "DONE",
  "audit_type": "plan-fidelity",
  "spec_issue": <N>,
  "plan_issue": <M>,
  "clean_room_plan": "...",
  "comparison_result": {
    "missing_phases": [],
    "extra_phases": [],
    "missing_steps": [],
    "approach_differences": []
  },
  "cross_validation": [...],
  "overall_consensus": "PASS | FAIL",
  "auto_fixes_applied": [...],
  "flagged_for_review": [...],
  "exec_summary": "Plan fidelity: {pass_count}/{total} criteria. {discrepancies} discrepancies found."
}
```

## Failure Recovery

If clean-room generation fails:
1. Log failure
2. Continue with remaining criteria
3. Mark clean-room-dependent criteria as INCONCLUSIVE
4. Do NOT block audit

## Cross-References

- `tasks/cross-validate.md` — dual auditor dispatch
- `plan-fidelity-auditor/tasks/audit.md` — original procedure
- `writing-plans` skill — clean-room generation
- `000-critical-rules.md` — co-authored requirement

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-08T00:00:00Z"
rules:
  - id: plan-fidelity-001
    title: "Clean-room generation must not receive existing plan details"
    conditions:
      all: ["clean_room_input contains 'existing phase' OR 'current plan'"]
    actions: [REGENERATE_INPUT]
    source: "plan-fidelity.md §Step 2"

  - id: plan-fidelity-002
    title: "Semantic matching required before reporting differences"
    conditions:
      all: ["phase_names semantically_match == false", "phase_contents_match == true"]
    actions: [SKIP_REPORT]
    source: "plan-fidelity.md §Step 5"

  - id: plan-fidelity-003
    title: "Significant gaps require brainstorming recommendation"
    conditions:
      all: ["discrepancy_count > 3"]
    actions: [RECOMMEND_BRAINSTORMING]
    source: "plan-fidelity.md §Step 6"
```