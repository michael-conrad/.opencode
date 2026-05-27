<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: coherence-maintenance

## Purpose

Detect drift between baseline coherence state and current guidelines/skills. Identifies rules added, removed, or modified since baseline generation.

## Entry Criteria

- Baseline file exists at `./tmp/artifacts/baseline-*.json`
- `audit_phase: coherence_gate`
- `github.owner`, `github.repo` available

## Exit Criteria

- Drift report generated
- PASS if no drift OR controlled drift
- FAIL if uncontrolled drift detected
- Migration candidates identified

## Procedure

### Step 1: Load Baseline

Find latest baseline:
```python
baseline_files = glob("./tmp/artifacts/baseline-*.json")
latest_baseline = max(baseline_files, key=lambda f: extract_date(f))
baseline = json.loads(read(latest_baseline))
```

### Step 2: Extract Current State

Re-extract guideline rules and skill behaviors (same as `coherence-extraction`):
```python
current_state = {
    "guidelines": extract_current_rules(".opencode/guidelines/"),
    "skills": extract_current_behaviors(".opencode/skills/")
}
```

### Step 3: Compare Against Baseline

```python
drift = {
    "rules_added": [],
    "rules_removed": [],
    "rules_modified": [],
    "behaviors_added": [],
    "behaviors_removed": [],
    "behaviors_modified": [],
    "cross_refs_changed": []
}
```

Algorithm:
```python
for current_rule in current_state["guidelines"]["rules"]:
    baseline_rule = find_in_baseline(baseline, current_rule["id"])
    if not baseline_rule:
        drift["rules_added"].append(current_rule)
    elif rule_modified(baseline_rule, current_rule):
        drift["rules_modified"].append({
            "rule_id": current_rule["id"],
            "baseline": baseline_rule,
            "current": current_rule
        })

for baseline_rule in baseline["guidelines"]["rules"]:
    if not find_in_current(current_state, baseline_rule["id"]):
        drift["rules_removed"].append(baseline_rule)
```

Repeat for skill behaviors.

### Step 4: Classify Drift

| Drift Type | Severity | Classification |
|-----------|----------|----------------|
| Rule added | LOW | Controlled — new rule |
| Rule removed | HIGH | Controlled — migration complete OR Uncontrolled — orphan |
| Rule modified | MEDIUM | Controlled — intentional change OR Uncontrolled — conflict |
| Behavior added | LOW | Controlled — new skill/behavior |
| Behavior removed | HIGH | Uncontrolled — check for skill decomposition |
| Cross-ref changed | MEDIUM | Controlled — intentional update |

Controlled drift has corresponding migration or deprecation message.
Uncontrolled drift has no justification.

### Step 5: Identify Migration Candidates

Rules/skills suitable for extraction:

```python
migration_candidates = []
for skill_behavior in current_state["skills"]["behaviors"]:
    if is_procedural_workflow(skill_behavior):
        migration_candidates.append({
            "skill": skill_behavior["skill"],
            "behavior": skill_behavior["task"],
            "reason": "Procedural workflow suitable for skill extraction"
        })
```

### Step 6: Build Evaluation Criteria

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| CM-1 | All baseline rules present in current | No uncontrolled removals |
| CM-2 | All rule modifications intentional | Controlled modifications |
| CM-3 | No orphan skills | Each skill has baseline reference |
| CM-4 | Cross-refs consistent | Guideline ↔ skill mapping valid |
| CM-5 | Migration candidates identified | Procedural workflows flagged |

### Step 7: Cross-Validate via task()

```python
task(
    subagent_type="general",
    prompt=f"""Use adversarial-audit skill --task cross-validate with:

baseline_file: {baseline_path}
spec_issue_number: {spec_issue_number}
audit_phase: coherence_gate
authorization_scope: {authorization_scope}
halt_at: {halt_at}
pr_strategy: {pr_strategy}
pipeline_phase: {pipeline_phase}

# NOTE: cross-validate does NOT dispatch auditors — it receives
# pre-resolved auditor_artifact_paths and reads YAMLs from disk.
auditor_artifact_paths: {auditor_artifact_paths}

worktree.path: {worktree.path}
github.owner: {github.owner}
github.repo: {github.repo}
"""
)
```

### Step 8: Build Result Contract

```json
{
  "status": "DONE",
  "audit_type": "coherence-maintenance",
  "baseline_file": "<baseline_path>",
  "current_state": {
    "rules_count": <N>,
    "behaviors_count": <M>
  },
  "drift": {
    "rules_added": [...],
    "rules_removed": [...],
    "rules_modified": [...],
    "controlled_count": <K>,
    "uncontrolled_count": <L>
  },
  "migration_candidates": [...],
  "cross_validation": [...],
  "overall_consensus": "PASS | FAIL",
  "exec_summary": "Coherence check: {controlled_count} controlled, {uncontrolled_count} uncontrolled drift. Consensus: {overall}."
}
```

## Error Handling

| Error | Action |
|-------|--------|
| Baseline not found | Return BLOCKED — run `coherence-extraction` first |
| Drift exceeds threshold | Return FAIL with drift report |
| Cross-ref unresolved | Flag skill for cross-ref update |

## Dispatch Mandate (CRITICAL — per critical-rules-048)

This task is a **reference document** that defines evaluation criteria and result contracts. The orchestrator is responsible for:
1. Dispatching a sub-agent for `resolve-models` to obtain auditor pair
2. Dispatching auditor sub-agents in parallel
3. Dispatching a sub-agent for `cross-validate` with pre-resolved `auditor_artifact_paths`

This task MUST NOT be read and executed inline. Reading this file and performing the described steps via raw tool calls is a CRITICAL VIOLATION per critical-rules-048.

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:
- Step 1 (Load Baseline) → INVALID if skipped
- Step 2 (Extract Current State) → INVALID if skipped
- Step 3 (Compare Against Baseline) → INVALID if skipped
- Step 4 (Classify Drift) → INVALID if skipped
- Step 5 (Identify Migration Candidates) → INVALID if skipped
- Step 6 (Build Evaluation Criteria) → INVALID if skipped
- Step 7 (Cross-Validate) → INVALID if skipped
- Step 8 (Build Result Contract) → INVALID if skipped

## Next Pipeline Step (MANDATORY CONTINUATION)

After coherence-maintenance completes:
- If consensus PASS: proceed to guideline-audit or coherence_gate completion
- If consensus FAIL: remediate findings, then re-audit (resolve-models → auditors → cross-validate)

This step is MANDATORY — the pipeline does not terminate early.

## Cross-References

- `tasks/coherence-extraction.md` — baseline generation
- `tasks/cross-validate.md` — consensus computation with pre-resolved verdicts
- `coherence-auditor/tasks/maintenance-detect.md` — original drift detection
- `coherence-auditor/tasks/maintenance-verify.md` — original verification
- `000-critical-rules.md` — coherence maintenance requirement

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-08T00:00:00Z"
rules:
  - id: coherence-maintenance-001
    title: "Uncontrolled drift must be flagged before merge"
    conditions:
      all: ["uncontrolled_drift_count > 0", "merge_attempted == true"]
    actions: [HALT, REPORT_DRIFT]
    source: "coherence-maintenance.md §Step 4"

  - id: coherence-maintenance-002
    title: "Baseline must be current before coherence check"
    conditions:
      all: ["baseline_age_days > 30"]
    actions: [WARN_BASELINE_STALE, RECOMMEND_EXTRACTION]
    source: "coherence-maintenance.md §Step 1"

  - id: coherence-maintenance-003
    title: "Migration candidates require full analysis"
    conditions:
      all: ["migration_candidate_identified == true", "extract_analyze_completed == false"]
    actions: [HALT, RUN_ANALYZE]
    source: "coherence-maintenance.md §Step 5"
```