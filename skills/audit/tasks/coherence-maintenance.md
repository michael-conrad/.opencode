<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> **⚠️ ROLE ANCHOR: You are the DISPATCHED AUDITOR SUB-AGENT.** Your role is to evaluate criteria and produce findings. You do NOT dispatch sub-agents, call `skill()`, or orchestrate pipeline routing. The orchestrator handles all dispatch. Read this file for evaluation criteria and procedure only — ignore any text describing orchestration responsibilities.

# Task: coherence-maintenance

## Purpose

Detect drift between baseline coherence state and current guidelines/skills. Identifies rules added, removed, or modified since baseline generation.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- Baseline file exists at `{project_root}/tmp/{issue-N}/artifacts/baseline-*.json`
- `github.owner`, `github.repo` available

## Exit Criteria

- Drift report generated
- PASS if no drift OR controlled drift
- FAIL if uncontrolled drift detected
- Migration candidates identified

## Procedure

## Coherence Maintenance Checklist

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/coherence-maintenance/`
- [ ] 1. Load Baseline — find latest baseline JSON, parse rules and behaviors
- [ ] 2. Extract Current State — re-extract guideline rules and skill behaviors
- [ ] 3. Compare Against Baseline — rules_added/removed/modified, behaviors drift
- [ ] 4. Classify Drift — controlled vs uncontrolled per severity
- [ ] 5. Identify Migration Candidates — procedural workflows suitable for extraction
- [ ] 6. Build Evaluation Criteria — define CM table with evidence types
- [ ] 7. Write verdict.yaml — write verdict to `./tmp/{issue-N}/artifacts/coherence-maintenance/verdict.yaml`
- [ ] 8. If FAIL: remediate, restart from step 0
- [ ] 9. Build Result Contract — YAML verdict with drift analysis

### Step 1: Load Baseline

Find latest baseline:
```python
baseline_files = glob("{project_root}/tmp/{issue-N}/artifacts/baseline-*.json")
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

### Step 7: Write verdict.yaml

Write verdict to `./tmp/{issue-N}/artifacts/coherence-maintenance/verdict.yaml`

### Step 8: Build Result Contract

```yaml
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
  "overall_verdict": "PASS | FAIL",
  "exec_summary": "Coherence check: {controlled_count} controlled, {uncontrolled_count} uncontrolled drift. Verdict: {overall}."
}
```

## Remediation

If any step FAILs, restart from step 0 (pre-clean).

## Error Handling

| Error | Action |
|-------|--------|
| Baseline not found | Return BLOCKED — run `coherence-extraction` first |
| Drift exceeds threshold | Return FAIL with drift report |
| Cross-ref unresolved | Flag skill for cross-ref update |

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:
- Step 1 (Load Baseline) → INVALID if skipped
- Step 2 (Extract Current State) → INVALID if skipped
- Step 3 (Compare Against Baseline) → INVALID if skipped
- Step 4 (Classify Drift) → INVALID if skipped
- Step 5 (Identify Migration Candidates) → INVALID if skipped
- Step 6 (Build Evaluation Criteria) → INVALID if skipped
- Step 7 (Build Result Contract) → INVALID if skipped

## Next Pipeline Step (MANDATORY CONTINUATION)

After coherence-maintenance completes:
- If verdict PASS: proceed to guideline-audit or coherence_gate completion
- If verdict FAIL: remediate findings, then re-audit

This step is MANDATORY — the pipeline does not terminate early.

## Cross-References

- `tasks/coherence-extraction.md` — baseline generation
- `000-critical-rules.md` — coherence maintenance requirement

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-07-07T00:00:00Z"
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
