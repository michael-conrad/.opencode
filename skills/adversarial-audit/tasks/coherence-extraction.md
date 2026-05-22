# Task: coherence-extraction

## Purpose

Generate baseline coherence state from guidelines and skills. Captures current rule-behavior alignment for later drift detection during `coherence-maintenance` runs.

## Entry Criteria

- Baseline not yet generated OR refresh requested
- `github.owner`, `github.repo` available
- Write access to `./tmp/artifacts/`

## Exit Criteria

- Baseline JSON written to `./tmp/artifacts/baseline-coherence-<issue>.json`
- All rules extracted from guidelines
- All behaviors mapped from skills
- Cross-references validated

## Procedure

### Step 1: Initialize Baseline Structure

```json
{
  "baseline_version": "1.0",
  "generated_at": "<ISO timestamp>",
  "guidelines": {
    "count": 0,
    "files": [],
    "rules": []
  },
  "skills": {
    "count": 0,
    "files": [],
    "behaviors": []
  },
  "cross_references": {
    "guideline_to_skill": [],
    "skill_to_guideline": [],
    "orphan_rules": []
  }
}
```

### Step 2: Extract Guideline Rules

Scan `.opencode/guidelines/*.md`:

```python
for guideline_file in glob(".opencode/guidelines/*.md"):
    content = read(guideline_file)
    rules = extract_rules(content)
    baseline["guidelines"]["rules"].append({
        "file": guideline_file,
        "rule_id": rule.get("id"),
        "title": rule.get("title"),
        "conditions": rule.get("conditions"),
        "actions": rule.get("actions"),
        "source": rule.get("source")
    })
```

Rule extraction pattern:
```yaml
schema_version: "2.0"
rules:
  - id: <rule-id>
    title: "<title>"
    conditions: [...]
    actions: [...]
```

### Step 3: Extract Skill Behaviors

Scan `.opencode/skills/*/SKILL.md`:

```python
for skill_file in glob(".opencode/skills/*/SKILL.md"):
    content = read(skill_file)
    behaviors = extract_behaviors(content)
    baseline["skills"]["behaviors"].append({
        "skill": skill_name,
        "tasks": extract_tasks(content),
        "rules": extract_rules(content),
        "cross_references": extract_cross_refs(content)
    })
```

Rule extraction from SKILL.md:
```yaml+symbolic
rules:
  - id: <skill>-<number>
    title: "<title>"
    conditions: [...]
    actions: [...]
```

### Step 4: Build Cross-Reference Map

For each guideline rule, find skill behaviors that reference it:

```python
for rule in baseline["guidelines"]["rules"]:
    referencing_skills = []
    for skill in baseline["skills"]["behaviors"]:
        if rule["id"] in skill["cross_references"]:
            referencing_skills.append(skill["skill"])
    if referencing_skills:
        baseline["cross_references"]["guideline_to_skill"].append({
            "rule_id": rule["id"],
            "referenced_by": referencing_skills
        })
    else:
        baseline["cross_references"]["orphan_rules"].append(rule["id"])
```

### Step 5: Compute Coherence Metrics

```python
baseline["metrics"] = {
    "guideline_coverage": len(baseline["cross_references"]["guideline_to_skill"]) / len(baseline["guidelines"]["rules"]),
    "orphan_rule_count": len(baseline["cross_references"]["orphan_rules"]),
    "skill_guideline_alignment": compute_alignment_score(baseline),
    "total_rules": len(baseline["guidelines"]["rules"]) + sum(len(s["rules"]) for s in baseline["skills"]["behaviors"])
}
```

### Step 6: Write Baseline File

Write to `./tmp/artifacts/baseline-coherence-<issue>.json`:

```python
baseline_path = f"./tmp/artifacts/baseline-coherence-{datetime.now().strftime('%Y%m%d')}.json"
write(baseline_path, json.dumps(baseline, indent=2))
```

### Step 7: Build Result Contract

```json
{
  "status": "DONE",
  "audit_type": "coherence-extraction",
  "baseline_path": "<baseline_path>",
  "metrics": {
    "guidelines_count": <N>,
    "skills_count": <M>,
    "total_rules": <K>,
    "coverage": "<percentage>",
    "orphan_rules": <count>
  },
  "exec_summary": "Baseline generated: {K} rules, {coverage} coverage, {orphan_rules} orphan rules."
}
```

## Error Handling

| Error | Action |
|-------|--------|
| No guidelines found | Return BLOCKED — baseline requires guidelines |
| No skills found | Return BLOCKED — baseline requires skills |
| Write permission denied | Return BLOCKED — cannot write baseline |
| Malformed rule in file | Skip rule, log warning |

## Cross-References

- `resolve-models` task — auditor model resolution (adversarial-audit --task resolve-models)
- `tasks/coherence-maintenance.md` — drift detection
- `coherence-auditor/tasks/extract-scan.md` — original extraction logic
- `coherence-auditor/tasks/extract-analyze.md` — original analysis logic
- `000-critical-rules.md` — baseline requirement

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-08T00:00:00Z"
rules:
  - id: coherence-extraction-001
    title: "Baseline must include all guideline rules"
    conditions:
      all: ["guidelines_scanned == true", "rule_count == 0"]
    actions: [BLOCK, REPORT_EMPTY_GUIDELINES]
    source: "coherence-extraction.md §Step 2"

  - id: coherence-extraction-002
    title: "Orphan rules require investigation"
    conditions:
      all: ["orphan_rule_count > 0"]
    actions: [FLAG_ORPHAN_RULES]
    source: "coherence-extraction.md §Step 4"

  - id: coherence-extraction-003
    title: "Baseline file must be timestamped"
    conditions:
      all: ["baseline_file_created == true", "timestamp_in_filename == false"]
    actions: [RENAME_BASELINE_WITH_TIMESTAMP]
    source: "coherence-extraction.md §Step 6"
```