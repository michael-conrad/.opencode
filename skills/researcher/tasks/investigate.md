<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# investigate — FAIL Artifact Investigation & Remediation Scope

Execute an exhaustive investigation of a FAIL artifact from any pipeline step to determine remediation scope and steps. Produces a YAML-frontmatter + markdown body remediation artifact.

**Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)**

## Entry Criteria

- FAIL artifact path provided (written by the failing pipeline step)
- Prior pipeline artifacts available for consultation (`./tmp/artifacts/pipeline-{issue}-*`)
- `github.owner`, `github.repo` available

## Exit Criteria

- Remediation artifact produced with `remediation_scope`, `remediation_steps[]`, `escalation_required`
- All sources verified via tool calls
- Z3 solve tool consulted for constraint analysis (if applicable)

## Procedure

### Step 1: Read FAIL artifact YAML frontmatter

Read only the frontmatter (not full content) to extract failure context:

```yaml
step_label: <failed step>
status: FAIL
next_step: <what was supposed to happen>
escalation_required: <true/false>
```

### Step 2: Consult prior pipeline artifacts

Glob `./tmp/artifacts/pipeline-{issue}-*` and read only YAML frontmatter of each to understand pipeline progress.

### Step 3: Determine failure nature

Classify into one of:
- **Implementation defect** — code doesn't match spec → `remediation_scope: partial`, target the producing phase
- **Spec defect** — spec wrong/incomplete → `remediation_scope: spec_plan_and_implementation`, revise spec → plan → re-implement
- **Test defect** — test wrong, code correct → `remediation_scope: partial`, target = red-phase
- **Infrastructure failure** — tool unavailable, model unresponsive → `remediation_scope: none`, `escalation_required: true`
- **Evidence type mismatch** — SC declared `structural` but requires `behavioral` → `remediation_scope: spec_plan_and_implementation`

### Step 4: Consult Z3 solve tools (if applicable)

For constraint violations:
```
solve model --state-path ./tmp/state/{ISSUE}/pipeline/ --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
```
For general constraint analysis:
```
solve prove --expr "..."
```

### Step 5: Check prior remediation history

Glob `./tmp/artifacts/pipeline-{issue}-researcher-*`. If prior researcher artifacts exist, inspect `remediation_steps` to avoid repeating failed approaches.

### Step 6: Determine remediation steps

| `remediation_scope` | `target_step` | Action |
|---------------------|---------------|--------|
| `full` | `sc-coherence-gate` | Restart entire pipeline |
| `partial` | The failed step's label | Re-run from that step |
| `spec_plan_and_implementation` | `sc-coherence-gate` | Revise spec+plan, notify developer |
| `none` | — | `escalation_required: true` |

### Step 7: Write remediation artifact

Write to `./tmp/artifacts/pipeline-{issue}-researcher-{topic}-{STATUS}-{timestamp}.md`:

```yaml
---
step: <pipeline_step_label or "adhoc">
triggered_by_step: <the FAIL step label>
failure_artifact: <path to FAIL artifact>
prior_artifacts_consulted:
  - <paths>
remediation_scope: <full | partial | spec_plan_and_implementation | none>
remediation_steps:
  - target_step: <step_label>
    action: <description of what to do>
escalation_required: <true | false>
max_remediation_attempts: <previous + 1>
---
```

### Step 8: Build result contract

```yaml
status: DONE | BLOCKED
remediation_scope: <scope>
remediation_steps:
  - target_step: <step_label>
    action: "<description>"
escalation_required: <true | false>
artifact_path: "<path>"
summary: "<1-3 sentence summary>"
```

## Error Handling

| Error | Action |
|-------|--------|
| FAIL artifact path not provided | Return BLOCKED, require artifact path |
| FAIL artifact not found or unreadable | Return BLOCKED, report missing artifact |
| No prior artifacts found | Return DONE with `prior_artifacts_consulted: []` |
| Z3 solve tool unavailable | Flag in findings, continue without Z3 |
| All remediation attempts exhausted | Set `escalation_required: true` |

## Cross-References

- `implementation-pipeline/pipeline-executor.md` — step labels and remediation routing
- `implementation-pipeline/pipeline-state-machine.yaml` — Z3 contract
- `.opencode/tools/solve` — Z3 constraint tool
- `adversarial-audit/tasks/coherence-extraction.md` — SC evidence type analysis