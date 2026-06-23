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
| 1 | `sc-coherence-gate` | `adversarial-audit --task coherence-extraction` | `./tmp/{issue-N}/artifacts/pipeline-sc-coherence-gate-{STATUS}-{timestamp}.yaml` | `per_criterion[]` from #932 |
| 2 | `pre-red-baseline` | `implementation-pipeline --task pre-red-baseline` (simple bash) | `./tmp/{issue-N}/state/state.yaml` + `./tmp/{issue-N}/artifacts/` YAML | pipeline state file |
| 3 | `red-phase` | `test-driven-development --task red` | `./tmp/{issue-N}/artifacts/pipeline-red-phase-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 4 | `red-doublecheck` | `verification-before-completion --task verify` | `./tmp/{issue-N}/artifacts/pipeline-red-doublecheck-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 5 | `green-phase` | `test-driven-development --task green` | `./tmp/{issue-N}/artifacts/pipeline-green-phase-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 6 | `checkpoint-commit` | `git-workflow --task commit-prep` | `./tmp/{issue-N}/artifacts/pipeline-checkpoint-commit-{STATUS}-{timestamp}.yaml` | single-criterion |
| 7 | `structural-checks` | `finishing-a-development-branch --task checklist` (enforces advisory-only mode: all linters run with `--check`/report-only flags, never auto-modify) | `./tmp/{issue-N}/artifacts/pipeline-structural-checks-{STATUS}-{timestamp}.yaml` | single-criterion |
| 8 | `green-doublecheck` | `verification-before-completion --task verify` | `./tmp/{issue-N}/artifacts/pipeline-green-doublecheck-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 9 | `green-vbc` | `verification-before-completion --task completion` | `./tmp/{issue-N}/artifacts/pipeline-green-vbc-{STATUS}-{timestamp}.yaml` | single-criterion |
| 10 | `adversarial-audit` | `adversarial-audit --task verification-audit` | `./tmp/{issue-N}/artifacts/pipeline-audit-{auditor_type}-{STATUS}-{timestamp}.yaml` | `per_criterion[]` (#932 schema) |
| 11 | `cross-validate` | `adversarial-audit --task cross-validate` | `./tmp/{issue-N}/artifacts/pipeline-cross-validate-{STATUS}-{timestamp}.yaml` | cross-validate YAML (#932 schema) |
| 12 | `regression-check` | `test-driven-development --task patterns` (regression) | `./tmp/{issue-N}/artifacts/pipeline-regression-check-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 13 | `review-prep` | `git-workflow --task review-prep` | review-prep status | single-criterion |
| 14 | `exec-summary` | `completion-core --task completion` | append lifecycle event + chat exec summary | single-criterion |

## Post-Step Checkpoint Creation

After each pipeline step returns DONE and the orchestrator logs the YAML artifact at `./tmp/{issue-N}/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`, create a checkpoint tag before advancing to the next step:

```bash
CONSUMER_REPO=<github.repo>
SUBMODULE_SUFFIX=-opencode

# Reap any prior tag for this step (re-dispatch from prior failure):
git tag -d "$CONSUMER_REPO/checkpoint/$ISSUE_NUM/phase-$N$SUBMODULE_SUFFIX" 2>/dev/null || true
git push origin --delete "$CONSUMER_REPO/checkpoint/$ISSUE_NUM/phase-$N$SUBMODULE_SUFFIX" 2>/dev/null || true

# Commit current state and tag checkpoint:
git add -A
git commit -m "checkpoint(#$ISSUE_NUM): step-$N complete"
git tag "$CONSUMER_REPO/checkpoint/$ISSUE_NUM/phase-$N$SUBMODULE_SUFFIX"
git push origin "$CONSUMER_REPO/checkpoint/$ISSUE_NUM/phase-$N$SUBMODULE_SUFFIX" 2>/dev/null || echo "Remote push skipped"
```

**Tag format:** `<parent>/checkpoint/<issue>/phase-<N>-<submodule>` per `git-workflow/SKILL.md` §Tag Convention.

**Suffix rule:** `<submodule>` is the submodule directory name from `.gitmodules` (e.g., `.opencode` → `-opencode`).

**Step N is 1-indexed** from the dispatch routing table above.

## Phase Rollback

When a step returns FAIL and a prior checkpoint exists, apply rollback before researcher dispatch:

```bash
CONSUMER_REPO=<github.repo>
SUBMODULE_SUFFIX=-opencode
LAST_PASS_PHASE=<from pipeline state file (current_step or previous_step in solve state)>

git status
git diff --stat
git reset --hard "$CONSUMER_REPO/checkpoint/$ISSUE_NUM/phase-$LAST_PASS_PHASE$SUBMODULE_SUFFIX"
git submodule update --init
```

Read restored pipeline state from `./tmp/{issue-N}/state/`. Re-dispatch the failed step with original dispatch parameters.

**First-step failure (no checkpoint):** Run `git checkout .` to clean working tree. Re-dispatch from current state without rollback.

**Integration with Remediation Routing:** Before dispatching the researcher skill on FAIL, the orchestrator checks for a prior checkpoint tag matching `phase-<STEP_N-1>$SUBMODULE_SUFFIX`. If found, apply Phase Rollback first. If not found (step 1 failure), skip to researcher dispatch with clean checkout.

## Orchestrator Dispatch Model

For each step:

- [ ] 1. The orchestrator calls `task(subagent_type="general", prompt: "execute <step_label> from implementation-pipeline")`
- [ ] 2. The sub-agent executes the step, produces a YAML artifact at `./tmp/{issue-N}/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`
- [ ] 3. The sub-agent returns frugal result contract: `{status, artifact_path, summary}`
- [ ] 4. The orchestrator reads the YAML from disk only on FAIL (for remediation routing)
- [ ] 5. After each step, pipeline position is recorded via `solve state update` (3 per-variable calls)

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
./tmp/{issue-N}/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml
```

Where `{step_label}` values are defined above.

## Z3 State Integration

### pre-red-baseline Step
```
solve state init ./tmp/{issue-N}/state/
```
Creates state file with `current_step: pre-red-baseline`, `pipeline_state: init`.

### Every Subsequent Step (after artifact write)
Three sequential per-variable calls:
```
solve state update ./tmp/{issue-N}/state/ --var-name previous_step --var-value <current-step-label> --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
solve state update ./tmp/{issue-N}/state/ --var-name current_step --var-value <next-step-label> --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
solve state update ./tmp/{issue-N}/state/ --var-name pipeline_state --var-value running --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
```

### Coherence Gate Validation
```
solve check --state-path ./tmp/{issue-N}/state/ --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
```

Step results (PASS/FAIL, evidence paths) go into YAML disk artifact — never into solve state. Solve state tracks pipeline **position** only.

## Remediation Routing

### FAIL → Researcher → Remediate Protocol

When a step returns FAIL:

- [ ] 1. **Read FAIL artifact YAML frontmatter** — the orchestrator reads only the YAML frontmatter from the FAIL artifact at `./tmp/{issue-N}/artifacts/pipeline-{step_label}-FAIL-{timestamp}.yaml`:
   - `status`, `next_step`, `escalation_required`, `step_label`
- [ ] 2. **Dispatch researcher** — the orchestrator dispatches the `researcher` skill with:
   - FAIL artifact path
    - ALL prior pipeline artifacts (glob `./tmp/{issue-N}/artifacts/pipeline-*`)
    - Spec issue number (#912)
    - Plan issue number (if applicable)
- [ ] 3. **Researcher determines scope** — the researcher produces a remediation artifact at `./tmp/{issue-N}/artifacts/pipeline-researcher-{topic}-{STATUS}-{timestamp}.md` containing:
   - `remediation_scope`: `full` | `partial` | `spec_plan_and_implementation` | `none`
   - `remediation_steps[]`: list of `{target_step, action}` pairs
   - `escalation_required`: `true` | `false`
- [ ] 4. **Orchestrator routes** — the orchestrator reads the researcher artifact's YAML frontmatter, extracts `remediation_steps[0].target_step`, and re-dispatches to that pipeline step via the dispatch routing table
- [ ] 5. **Re-run pipeline** — the pipeline re-executes from the target remediation step
- [ ] 6. **No arbitrary attempt caps** — each remediation is fresh research with full context. The researcher consults prior remediation artifacts to avoid repeating failed approaches. Max 3 attempts before escalation is guidance, not a hard gate — genuine progress extends the cap.
- [ ] 7. **Escalate on `escalation_required: true`** — if the researcher artifact sets `escalation_required: true`, the orchestrator halts and reports the blocker to the developer. No further dispatch occurs.

### Session Resume Rule

When resuming a session with existing artifacts:
- Glob `./tmp/{issue-N}/artifacts/pipeline-*` to find the latest artifact
- If the latest artifact is FAIL and a companion researcher-remediation-PASS artifact exists, follow the remediation plan in `remediation_steps` — do NOT re-dispatch the researcher
- If no researcher artifact exists, or the latest FAIL has no companion researcher artifact, run the standard FAIL → Researcher protocol from Step 1 above

## Frugal Result Contracts

Every step returns a YAML contract (never JSON) with only routing-significant data:

```yaml
status: DONE | BLOCKED | DONE_WITH_CONCERNS | OVERFLOW
artifact_path: "./tmp/{issue-N}/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml"
summary: "<1-3 sentence summary>"
```

Full evidence artifacts go to disk — never into result contracts.

## Status-in-Filename Convention

Artifact filenames include uppercase STATUS: `PASS`, `FAIL`, `UNVERIFIED`.

Example: `./tmp/928/artifacts/pipeline-red-phase-PASS-20260527T030000Z.yaml`

## Related Files

- `skills/implementation-pipeline/pipeline-state-machine.yaml` — Z3 legal transition definitions
- `skills/implementation-pipeline/SKILL.md` — dispatch routing table
- `skills/researcher/SKILL.md` — researcher skill for remediation scope determination
- `skills/researcher/tasks/investigate.md` — researcher investigation task
- `skills/researcher/tasks/findings.md` — researcher findings formatting
- `skills/completion-core/tasks/completion.md` — exec-summary pipeline step target
- `skills/adversarial-audit/tasks/coherence-extraction.md` — SC coherence gate with Z3 + evidence type checks
- `skills/solve/` — Solve skill card (Z3 constraint solving, contracts, state)
