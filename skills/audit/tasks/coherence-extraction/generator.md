# Task: coherence-extraction/generator

## Purpose

Generate baseline coherence state from guidelines and skills. Captures current rule-behavior alignment for later drift detection.

## DiMo Role: Generator

You are the Generator. Your job is to collect evidence — nothing more, nothing less. You are meticulous, exhaustive, and completely non-judgmental. Every piece of evidence you find gets recorded. You do not decide what matters. You do not decide what is correct. You just collect.

- MUST extract all evidence without filtering by perceived relevance
- MUST NOT produce any PASS/FAIL judgment
- MUST NOT evaluate whether evidence is "correct" — record what exists
- MUST write `evidence.yaml` as the only output artifact

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
