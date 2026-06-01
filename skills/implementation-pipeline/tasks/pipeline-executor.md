# Task: pipeline-executor

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

This is the core dispatch routing table for the 14-step serial implementation pipeline. Each step dispatches to an existing skill's task file via `task()` using clean-room sub-agents. Step transitions are validated by Z3 via `solve check` against `pipeline-state-machine.yaml`.

## Entry Criteria

- Authorization scope covers `for_implementation` or higher
- Feature branch exists (created by pre-work)
- Authorization context available

## Context Required

- `authorization_scope`
- `halt_at`
- `pr_strategy`
- `pipeline_phase`
- `worktree.path`
- `github.owner`
- `github.repo`
- `issue_number`

## 14-Step Dispatch Table

| Step # | Step Label | Dispatches To | Artifact Produced | YAML Contract Schema |
|--------|------------|---------------|-------------------|---------------------|
| 1 | `sc-coherence-gate` | `adversarial-audit --task coherence-extraction` | `./tmp/artifacts/pipeline-{issue}-sc-coherence-gate-{STATUS}-{timestamp}.yaml` | `per_criterion[]` from #932 |
| 2 | `pre-red-baseline` | `implementation-pipeline --task pre-red-baseline` (simple bash) | `./tmp/state/{issue}/pipeline/state.yaml` + `./tmp/artifacts/` YAML | pipeline state file |
| 3 | `red-phase` | `test-driven-development --task red` | `./tmp/artifacts/pipeline-{issue}-red-phase-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 4 | `red-doublecheck` | `verification-before-completion --task verify` | `./tmp/artifacts/pipeline-{issue}-red-doublecheck-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 5 | `green-phase` | `test-driven-development --task green` | `./tmp/artifacts/pipeline-{issue}-green-phase-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 6 | `checkpoint-commit` | `git-workflow --task commit-prep` | `./tmp/artifacts/pipeline-{issue}-checkpoint-commit-{STATUS}-{timestamp}.yaml` | single-criterion |
| 7 | `structural-checks` | `finishing-a-development-branch --task checklist` | `./tmp/artifacts/pipeline-{issue}-structural-checks-{STATUS}-{timestamp}.yaml` | single-criterion |
| 8 | `green-doublecheck` | `verification-before-completion --task verify` | `./tmp/artifacts/pipeline-{issue}-green-doublecheck-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 9 | `green-vbc` | `verification-before-completion --task completion` | `./tmp/artifacts/pipeline-{issue}-green-vbc-{STATUS}-{timestamp}.yaml` | single-criterion |
| 10 | `adversarial-audit` | `adversarial-audit --task verification-audit` | `./tmp/artifacts/pipeline-{issue}-audit-{auditor_type}-{STATUS}-{timestamp}.yaml` | `per_criterion[]` (#932 schema) |
| 11 | `cross-validate` | `adversarial-audit --task cross-validate` | `./tmp/artifacts/pipeline-{issue}-cross-validate-{STATUS}-{timestamp}.yaml` | cross-validate YAML (#932 schema) |
| 12 | `regression-check` | `test-driven-development --task patterns` (regression) | `./tmp/artifacts/pipeline-{issue}-regression-check-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 13 | `review-prep` | `git-workflow --task review-prep` | review-prep status | single-criterion |
| 14 | `exec-summary` | `completion-core --task completion` | push status + issue comment | single-criterion |

## Orchestrator Dispatch Model

For each step:

1. The orchestrator calls `task(subagent_type="general", prompt: "execute <step_label> from implementation-pipeline")`
2. The sub-agent executes the step, produces a YAML artifact at `./tmp/artifacts/pipeline-{issue}-{step_label}-{STATUS}-{timestamp}.yaml`
3. The sub-agent returns frugal result contract: `{status, artifact_path, summary}`
4. The orchestrator reads the YAML from disk only on FAIL (for remediation routing)
5. After each step, pipeline position is recorded via `solve state update` (3 per-variable calls)

## YAML Contract Schema

All steps use the unified `per_criterion[]` format from #932:

```yaml
step_label: <step_label>
issue_number: <issue_number>
generated_at: "<ISO8601>"
status: PASS | FAIL
summary:
  total_criteria: <int>
  pass: <int>
  fail: <int>
per_criterion:
  - criterion_id: "<SC-ID or step-check-id>"
    result: PASS | FAIL
    evidence: |-
      <tool-call evidence>
    next_step: proceed | re-evaluate
```

Simple steps (checkpoint-commit, structural-checks, green-vbc, exec-summary) use a single-criterion list.

## Naming Convention

All artifacts follow the #932 naming convention:
```
./tmp/artifacts/pipeline-{issue}-{step_label}-{STATUS}-{timestamp}.yaml
```

Where `{step_label}` values are defined above.

## Z3 State Integration

### pre-red-baseline Step
```
solve state init ./tmp/state/{ISSUE}/pipeline/
```
Creates state file with `current_step: pre-red-baseline`, `pipeline_state: init`.

### Every Subsequent Step (after artifact write)
Three sequential per-variable calls:
```
solve state update ./tmp/state/{ISSUE}/pipeline/ --var-name previous_step --var-value <current-step-label> --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
solve state update ./tmp/state/{ISSUE}/pipeline/ --var-name current_step --var-value <next-step-label> --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
solve state update ./tmp/state/{ISSUE}/pipeline/ --var-name pipeline_state --var-value running --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
```

### Coherence Gate Validation
```
solve check --state-path ./tmp/state/{ISSUE}/pipeline/ --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
```

Step results (PASS/FAIL, evidence paths) go into YAML disk artifact — never into solve state. Solve state tracks pipeline **position** only.

## Remediation Routing

### FAIL → Researcher → Remediate Protocol

When a step returns FAIL:

1. **Read FAIL artifact YAML frontmatter** — the orchestrator reads only the YAML frontmatter from the FAIL artifact at `./tmp/artifacts/pipeline-{issue}-{step_label}-FAIL-{timestamp}.yaml`:
   - `status`, `next_step`, `escalation_required`, `step_label`
2. **Dispatch researcher** — the orchestrator dispatches the `researcher` skill with:
   - FAIL artifact path
   - ALL prior pipeline artifacts (glob `./tmp/artifacts/pipeline-{issue}-*`)
   - Spec issue number (#912)
   - Plan issue number (if applicable)
3. **Researcher determines scope** — the researcher produces a remediation artifact at `./tmp/artifacts/pipeline-{issue}-researcher-{topic}-{STATUS}-{timestamp}.md` containing:
   - `remediation_scope`: `full` | `partial` | `spec_plan_and_implementation` | `none`
   - `remediation_steps[]`: list of `{target_step, action}` pairs
   - `escalation_required`: `true` | `false`
4. **Orchestrator routes** — the orchestrator reads the researcher artifact's YAML frontmatter, extracts `remediation_steps[0].target_step`, and re-dispatches to that pipeline step via the dispatch routing table
5. **Re-run pipeline** — the pipeline re-executes from the target remediation step
6. **No arbitrary attempt caps** — each remediation is fresh research with full context. The researcher consults prior remediation artifacts to avoid repeating failed approaches. Max 3 attempts before escalation is guidance, not a hard gate — genuine progress extends the cap.
7. **Escalate on `escalation_required: true`** — if the researcher artifact sets `escalation_required: true`, the orchestrator halts and reports the blocker to the developer. No further dispatch occurs.

### Session Resume Rule

When resuming a session with existing artifacts:
- Glob `./tmp/artifacts/pipeline-{issue}-*` to find the latest artifact
- If the latest artifact is FAIL and a companion researcher-remediation-PASS artifact exists, follow the remediation plan in `remediation_steps` — do NOT re-dispatch the researcher
- If no researcher artifact exists, or the latest FAIL has no companion researcher artifact, run the standard FAIL → Researcher protocol from Step 1 above

## Frugal Result Contracts

Every step returns a YAML contract (never JSON) with only routing-significant data:

```yaml
status: DONE | BLOCKED | DONE_WITH_CONCERNS | OVERFLOW
artifact_path: "./tmp/artifacts/pipeline-{issue}-{step_label}-{STATUS}-{timestamp}.yaml"
summary: "<1-3 sentence summary>"
```

Full evidence artifacts go to disk — never into result contracts.

## Status-in-Filename Convention

Artifact filenames include uppercase STATUS: `PASS`, `FAIL`, `UNVERIFIED`.

Example: `./tmp/artifacts/pipeline-928-red-phase-PASS-20260527T030000Z.yaml`

## Related Files

- `skills/implementation-pipeline/pipeline-state-machine.yaml` — Z3 legal transition definitions
- `skills/implementation-pipeline/SKILL.md` — dispatch routing table
- `skills/researcher/SKILL.md` — researcher skill for remediation scope determination
- `skills/researcher/tasks/investigate.md` — researcher investigation task
- `skills/researcher/tasks/findings.md` — researcher findings formatting
- `skills/completion-core/tasks/completion.md` — exec-summary pipeline step target
- `skills/adversarial-audit/tasks/coherence-extraction.md` — SC coherence gate with Z3 + evidence type checks
- `.opencode/tools/solve` — Z3 constraint tool
