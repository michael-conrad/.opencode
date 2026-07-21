# Task: coherence-extraction/generator

## Purpose

Generate baseline coherence state from guidelines and skills. Captures current rule-behavior alignment for later drift detection.

## Entry Criteria

- `evidence.yaml` not present at `artifact_evidence_dir`
- `spec_local_dir` provided and readable
- `artifact_evidence_dir` writable

## Exit Criteria

- `evidence.yaml` written with raw evidence (guideline rules, skill behaviors, cross-reference map)
- No judgments applied — raw evidence only

## Procedure

### Step 1: Pre-clean

- [ ] 1. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/coherence-extraction/`

### Step 2: Initialize Baseline Structure

Create baseline structure with guidelines, skills, and cross-references sections.

### Step 3: Extract Guideline Rules

Scan `.opencode/guidelines/*.md` and extract rules with IDs, titles, conditions, and actions.

### Step 4: Extract Skill Behaviors

Scan `.opencode/skills/*/SKILL.md` and extract behaviors, tasks, rules, and cross-references.

### Step 5: Build Cross-Reference Map

For each guideline rule, find skill behaviors that reference it. Identify orphan rules.

### Step 6: Write Evidence Artifact

Write `evidence.yaml` to `./tmp/{issue-N}/artifacts/coherence-extraction/evidence.yaml`.

## Output

```yaml
status: DONE|BLOCKED
artifact_path: "./tmp/{issue-N}/artifacts/coherence-extraction/evidence.yaml"
summary: "Baseline coherence data collected: X guidelines, Y skills, Z rules"
```
