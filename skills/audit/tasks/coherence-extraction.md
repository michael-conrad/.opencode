# Task: coherence-extraction

## Purpose

Generate baseline coherence state from guidelines and skills. Captures current rule-behavior alignment for later drift detection during `coherence-maintenance` runs.

> **DiMo Role: Generator.** This task generates baseline coherence data. Writes `evidence.yaml` with extracted rules and behaviors.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- Baseline not yet generated OR refresh requested
- `github.owner`, `github.repo` available
- Write access to `{project_root}/tmp/{issue-N}/artifacts/`

## Exit Criteria

- Baseline JSON written to `{project_root}/tmp/{issue-N}/artifacts/baseline-coherence.json`
- All rules extracted from guidelines
- All behaviors mapped from skills
- Cross-references validated
- Z3 solve check PASS — SC evidence type constraints structurally consistent
- No evidence type mismatches — all SC prose-to-declared-type classifications verified

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/coherence-extraction/`

### Step 1: Initialize Baseline Structure

```yaml
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

### Step 5b: Run Z3 Solve Check on SC Evidence Type Constraints

Run the Z3 solve check against the pipeline state machine to validate structural consistency of SC evidence type constraints:

```bash
tools/solve check \
  --state-path {project_root}/tmp/{issue-N}/state/ \
  --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
```

Then perform a manual structural consistency check on SC evidence type declarations:

```python
spec_content = read(spec_artifact_path)
sc_table = extract_sc_table(spec_content)
for sc in sc_table:
    evidence_type = sc.get("evidence_type", "string")
    # Detect structural contradictions:
    # e.g., a behavioral SC whose prose requires file-not-found behavior
    # that structural evidence can never provide
    contradictions = detect_contradictions(sc, evidence_type)
    if contradictions:
        fail_artifact["z3_violations"].append({
            "sc_id": sc["id"],
            "evidence_type": evidence_type,
            "contradictions": contradictions
        })
```

On PASS (SAT + no contradictions): proceed to Step 5c.

On FAIL (UNSAT or any contradiction found):
- [ ] 1. Write FAIL artifact to `{project_root}/tmp/{issue-N}/artifacts/coherence-z3-fail.json`
- [ ] 2. Include: solve output, per-SC contradictions, spec source reference
- [ ] 3. Return: `{"status": "BLOCKED", "reason": "Z3 solve check failed", "details": "<output>"}`

### Step 5c: Evaluate Prose vs Evidence Type Mismatch

Read the spec content that was analyzed. For each SC, compare what the prose describes (runtime behavior, structural presence, etc.) against the declared evidence type. Flag mismatches where prose describes behavioral/runtime outcomes but SC is declared as `structural` or `string`.

```python
spec_content = read(spec_artifact_path)
sc_table = extract_sc_table(spec_content)
for sc in sc_table:
    declared_type = sc.get("evidence_type", "string")
    prose_category = classify_prose_content(sc["criterion"], spec_content)
    mismatch = is_type_mismatch(prose_category, declared_type)
    if mismatch:
        fail_artifact["evidence_type_mismatches"].append({
            "sc_id": sc["id"],
            "declared_type": declared_type,
            "prose_describes": prose_category,
            "description": f"SC {sc['id']} prose describes {prose_category} behavior "
                           f"but declares evidence type '{declared_type}'"
        })
```

Mismatch classification:

| Prose Describes | Declared As | Result |
|---|---|---|
| Runtime agent behavior / tool dispatch / decision-making | `structural` | **MISMATCH — behavioral evidence required** |
| Runtime agent behavior / tool dispatch / decision-making | `string` | **MISMATCH — behavioral evidence required** |
| File existence / structural presence | `behavioral` | Flag as over-engineered (not a FAIL, but note) |
| String pattern in content | `structural` or `behavioral` | Flag as potential under-specification |
| Exact match | Same type | ✅ PASS |

On PASS (no mismatches): proceed to Step 6.

On FAIL (any mismatch):
- [ ] 1. Write FAIL artifact to `{project_root}/tmp/{issue-N}/artifacts/coherence-evidence-mismatch.json`
- [ ] 2. Include: per-SC mismatch details with prose excerpts and evidence type declaration
- [ ] 3. Return: `{"status": "BLOCKED", "reason": "Evidence type mismatch detected", "details": "<per-SC mismatches>"}`

### Step 6: Write Baseline File

Write to `{project_root}/tmp/{issue-N}/artifacts/baseline-coherence.json`:

```python
baseline_path = f"{project_root}/tmp/{issue-N}/artifacts/baseline-coherence-{datetime.now().strftime('%Y%m%d')}.json"
write(baseline_path, json.dumps(baseline, indent=2))
```

### Step 7: Write evidence.yaml

Write extracted data to `./tmp/{issue-N}/artifacts/coherence-extraction/evidence.yaml`

### Step 8: Build Result Contract

```yaml
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

## Result Contract

```yaml
status: DONE | FAIL
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-coherence-extraction-PASS-{timestamp}.yaml"
summary: "Baseline generated: {K} rules, {coverage} coverage, {orphan_rules} orphan rules."
remediation_required: true  # When status is FAIL: full mandatory re-audit required
```

## Error Handling

| Error | Action |
|-------|--------|
| No guidelines found | Return BLOCKED — baseline requires guidelines |
| No skills found | Return BLOCKED — baseline requires skills |
| Write permission denied | Return BLOCKED — cannot write baseline |
| Malformed rule in file | Skip rule, log warning |
| Z3 solve check failed | Return BLOCKED, include solve output and per-SC contradiction details |
| Evidence type mismatch detected | Return BLOCKED, per-SC mismatch details with prose excerpts |

## Cross-References

- `tasks/coherence-maintenance.md` — drift detection
- `tasks/coherence-extraction.md` — this file (self-reference for pipeline dispatch)
- `000-critical-rules.md` — baseline requirement
- `skills/implementation-pipeline/pipeline-state-machine.yaml` — Z3 contract for pipeline step validation
- `080-code-standards.md` §Evidence Type Taxonomy — evidence type declarations and enforcement matrix
- `skills/solve/` — Solve skill card (Z3 constraint solving, solve check, state)

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