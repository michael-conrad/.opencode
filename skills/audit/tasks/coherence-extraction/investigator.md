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

## Dispatch Contract

The orchestrator MUST provide the following context fields when dispatching this task:

| Field | Required | Description |
|-------|----------|-------------|
| `spec_local_dir` | Yes | Local directory containing spec files |
| `artifact_evidence_dir` | Yes | Directory for evidence artifacts |

**Missing required context:** If any required field is absent, return:

```yaml
status: BLOCKED
reason: MISSING_REQUIRED_CONTEXT
message: "Required context field(s) missing: <field_names>"
```

**Preloaded context rejection:** If the orchestrator includes inline reasoning, expected outcomes, file paths, or step sequences in the dispatch prompt, return:

```yaml
status: BLOCKED
reason: PRELOADED_CONTEXT_REJECTED
message: "Orchestrator preloaded context detected. Dispatch with canonical string only."
```


## Output Contract

| Field | Required | Format | Description |
|-------|----------|--------|-------------|
| `artifact_path` | Yes | `{project_root}/tmp/{issue-N}/artifacts/{chain}/...` | Path to the output artifact file |
| `artifact_format` | Yes | `yaml` | Format of the output artifact |
| `status` | Yes | `DONE | BLOCKED` | Task completion status |
| `summary` | Yes | `string` | 1-3 sentence summary of findings |

The output artifact MUST be written to `artifact_path` before returning.

## Frugal Contract

The sub-agent MUST return only the following fields to the orchestrator:

| Field | Required | Description |
|-------|----------|-------------|
| `status` | Yes | `DONE` / `BLOCKED` / `OVERFLOW` |
| `finding_summary` | Yes | 1-3 sentences of routing-significant output |
| `artifact_path` | Yes | Path to the full evidence artifact on disk |
| `blocker_reason` | If BLOCKED | Why the task was blocked |

Full evidence artifacts go to disk at `artifact_path`. The orchestrator reads only this contract — it does NOT re-read the artifact.