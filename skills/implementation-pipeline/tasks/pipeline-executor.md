# Task: pipeline-executor

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Internal step dispatch table for a single implementation item within the pipeline. Each step dispatches to an existing skill's task file via `task()` using clean-room sub-agents. Step transitions are validated by Z3 via `solve check` against `pipeline-state-machine.yaml`.

This is NOT the orchestrator entry point. The orchestrator entry point is `assemble-work` — this task runs after `assemble-work` routes to it for the internal step dispatch sequence.

## Entry Criteria

- Authorization scope covers `for_implementation` or higher
- Feature branch exists (created by pre-work)
- Authorization context available

## Pre-Dispatch Gate: Coercion Rule

Before dispatching any step, the orchestrator MUST apply the bright-line coercion rule to all incoming result contracts:

```
status != DONE → FAIL
status == DONE with non-empty caveat_summary → FAIL
```

A status of `DONE_WITH_CONCERNS` is coerced to FAIL — caveats are defects, not completions. The orchestrator routes to remediation per the Remediation Routing section below.

## Context Required

- `authorization_scope`
- `halt_at`
- `pr_strategy`
- `pipeline_phase`
- `worktree.path`
- `github.owner`
- `github.repo`
- `issue_number`

## Dispatch Table

| Step # | Step Label | Dispatches To | Artifact Produced | YAML Contract Schema |
|--------|------------|---------------|-------------------|---------------------|
| 0 | `submodule-verify` | `git-workflow --task pre-work` (submodule state verification — resolve default branch via `git remote show origin \| sed -n 's/.*HEAD branch: //p'`, then `git submodule status` against that branch's tip) | `./tmp/{issue-N}/artifacts/pipeline-submodule-verify-{STATUS}-{timestamp}.yaml` | single-criterion |
| 1 | `sc-coherence-gate` | `adversarial-audit --task coherence-extraction` (evidence-type uplift + substrate classification) | `./tmp/{issue-N}/artifacts/pipeline-sc-coherence-gate-{STATUS}-{timestamp}.yaml` | `per_criterion[]` from #932 |
| 2 | `pre-red-baseline` | `implementation-pipeline --task pre-red-baseline` (doc-source-currency + SC-ID cross-ref traceability) | `./tmp/{issue-N}/state/state.yaml` + `./tmp/{issue-N}/artifacts/` YAML | pipeline state file |
| 3 | `red-phase` | `test-driven-development --task red` | `./tmp/{issue-N}/artifacts/pipeline-red-phase-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 4 | `red-doublecheck` | `verification-before-completion --task verify` | `./tmp/{issue-N}/artifacts/pipeline-red-doublecheck-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 5 | `post-red-enforcement` | `implementation-pipeline --task post-red-enforcement` (git diff --name-only -- src/ \| wc -l) | `./tmp/{issue-N}/artifacts/pipeline-post-red-enforcement-{STATUS}-{timestamp}.yaml` | single-criterion |
| 6 | `green-phase` | `test-driven-development --task green` | `./tmp/{issue-N}/artifacts/pipeline-green-phase-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 7 | `post-green-enforcement` | `implementation-pipeline --task post-green-enforcement` (git diff --name-only -- test/ \| wc -l) | `./tmp/{issue-N}/artifacts/pipeline-post-green-enforcement-{STATUS}-{timestamp}.yaml` | single-criterion |
| 8 | `checkpoint-tag-create` | `implementation-pipeline --task checkpoint-tag-create` (creates git tag per `000-critical-rules.md` §Checkpoint Rollback Exception) | `./tmp/{issue-N}/artifacts/pipeline-checkpoint-tag-create-{STATUS}-{timestamp}.yaml` | single-criterion |
| 9 | `checkpoint-commit` | `git-workflow --task commit-prep` | `./tmp/{issue-N}/artifacts/pipeline-checkpoint-commit-{STATUS}-{timestamp}.yaml` | single-criterion |
| 10 | `structural-checks` | `finishing-a-development-branch --task checklist` (enforces advisory-only mode: all linters run with `--check`/report-only flags, never auto-modify) | `./tmp/{issue-N}/artifacts/pipeline-structural-checks-{STATUS}-{timestamp}.yaml` | single-criterion |
| 11 | `green-doublecheck` | `verification-before-completion --task verify` (semantic-intent verification) | `./tmp/{issue-N}/artifacts/pipeline-green-doublecheck-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 12 | `green-vbc` | `verification-before-completion --task completion` | `./tmp/{issue-N}/artifacts/pipeline-green-vbc-{STATUS}-{timestamp}.yaml` | single-criterion |
| 13 | `adversarial-audit` | `adversarial-audit --task verification-audit` | `./tmp/{issue-N}/artifacts/pipeline-audit-{auditor_type}-{STATUS}-{timestamp}.yaml` | `per_criterion[]` (#932 schema) |
| 14 | `cross-validate` | `adversarial-audit --task cross-validate` | `./tmp/{issue-N}/artifacts/pipeline-cross-validate-{STATUS}-{timestamp}.yaml` | cross-validate YAML (#932 schema) |
| 15 | `regression-check` | `test-driven-development --task patterns` (regression) | `./tmp/{issue-N}/artifacts/pipeline-regression-check-{STATUS}-{timestamp}.yaml` | `per_criterion[]` |
| 16 | `review-prep` | `git-workflow --task review-prep` | review-prep status | single-criterion |
| 17 | `exec-summary` | `completion-core --task completion` | append lifecycle event + chat exec summary | single-criterion |

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

When a step returns FAIL and a prior checkpoint exists, apply rollback before research dispatch:

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

**Integration with Remediation Routing:** Before dispatching the research skill on FAIL, the orchestrator checks for a prior checkpoint tag matching `phase-<STEP_N-1>$SUBMODULE_SUFFIX`. If found, apply Phase Rollback first. If not found (step 1 failure), skip to research dispatch with clean checkout.

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

## Auto-Revision Routing (Non-Substantive Spec Defects)

When the SC-coherence gate (Step 1) detects a spec defect, the orchestrator classifies the defect as substantive or non-substantive before routing to remediation:

### Non-Substantive Defect Classification

A spec defect is **non-substantive** if it involves only:
- Evidence type mismatch (e.g., `behavioral` → `string` when the SC is structural)
- Verification method needs updating
- Artifact path needs correction
- SC wording clarification that does NOT alter implementation intent

A spec defect is **substantive** if it involves:
- New SCs needed (missing from spec)
- SCs that cannot be implemented as specified
- Scope or implementation approach changes
- Contradictory or impossible success criteria

### Non-Substantive Auto-Revision Flow

When the coherence gate finds a non-substantive spec defect:

- [ ] 1. **Orchestrator revises spec** — update the spec issue body with corrected evidence types, verification methods, or artifact paths
- [ ] 2. **Auto-update plan** — dispatch `writing-plans --task update` with the revised spec issue number
- [ ] 3. **Continue pipeline** — proceed to Step 2 (pre-red-baseline) without HALT for re-authorization
- [ ] 4. **No approval revocation** — `approval-gate-015` applies: the linked plan approval is NOT revoked

### Substantive Defect Flow

When the coherence gate finds a substantive spec defect:

- [ ] 1. **HALT** — report the defect to the developer
- [ ] 2. **No auto-revision** — the orchestrator does NOT revise the spec or plan
- [ ] 3. **Wait for developer input** — the developer must revise the spec and re-approve

## Remediation Routing

### FAIL → Researcher → Remediate Protocol

When a step returns FAIL:

- [ ] 1. **Read FAIL artifact YAML frontmatter** — the orchestrator reads only the YAML frontmatter from the FAIL artifact at `./tmp/{issue-N}/artifacts/pipeline-{step_label}-FAIL-{timestamp}.yaml`:
   - `status`, `next_step`, `escalation_required`, `step_label`
- [ ] 2. **Dispatch research** — the orchestrator dispatches the `research` skill with:
   - FAIL artifact path
    - ALL prior pipeline artifacts (glob `./tmp/{issue-N}/artifacts/pipeline-*`)
    - Spec issue number (#912)
    - Plan issue number (if applicable)
- [ ] 3. **Research determines scope** — the research skill produces a remediation artifact at `./tmp/{issue-N}/artifacts/pipeline-researcher-{topic}-{STATUS}-{timestamp}.md` containing:
   - `remediation_scope`: `full` | `partial` | `spec_plan_and_implementation` | `none`
   - `remediation_steps[]`: list of `{target_step, action}` pairs
   - `escalation_required`: `true` | `false`
- [ ] 4. **Orchestrator routes** — the orchestrator reads the research artifact's YAML frontmatter, extracts `remediation_steps[0].target_step`, and re-dispatches to that pipeline step via the dispatch routing table
- [ ] 5. **Re-run pipeline** — the pipeline re-executes from the target remediation step
- [ ] 6. **No arbitrary attempt caps** — each remediation is fresh research with full context. The research skill consults prior remediation artifacts to avoid repeating failed approaches. Max 3 attempts before escalation is guidance, not a hard gate — genuine progress extends the cap.
- [ ] 7. **Escalate on `escalation_required: true`** — if the research artifact sets `escalation_required: true`, the orchestrator halts and reports the blocker to the developer. No further dispatch occurs.

### Defective Deliverable Routing

When a sub-agent returns a defective deliverable (spec defect, plan defect, or other artifact), the orchestrator MUST route to the revision pipeline — NOT inline-fix or create a replacement:

- [ ] 1. **Classify defect type** — determine if the defect is in a spec, plan, or code artifact
- [ ] 2. **Route to revision pipeline**:
   - Spec defect → dispatch `spec-creation --task revise` with the defective issue number
   - Plan defect → dispatch `writing-plans --task update` with the defective plan issue number
   - Code defect → dispatch `implementation-pipeline` with the defective step label
- [ ] 3. **No inline fixes** — the orchestrator MUST NOT edit the defective artifact directly via `github_issue_write`, file edit, or any other direct mutation
- [ ] 4. **No replacement creation** — the orchestrator MUST NOT create a new issue or file to replace the defective artifact unless revision is structurally impossible (e.g., the original issue was deleted)
- [ ] 5. **Document structural impossibility** — if replacement is necessary, document the rationale in an issue comment on the replacement artifact

### Session Resume Rule

When resuming a session with existing artifacts:
- Glob `./tmp/{issue-N}/artifacts/pipeline-*` to find the latest artifact
- If the latest artifact is FAIL and a companion research-remediation-PASS artifact exists, follow the remediation plan in `remediation_steps` — do NOT re-dispatch the research skill
- If no research artifact exists, or the latest FAIL has no companion research artifact, run the standard FAIL → Research protocol from Step 1 above

## Frugal Result Contracts

Every step returns a YAML contract (never JSON) with only routing-significant data:

```yaml
status: DONE | BLOCKED | OVERFLOW
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
- `skills/research/SKILL.md` — research skill for remediation scope determination (absorbed researcher)
- `skills/completion-core/tasks/completion.md` — exec-summary pipeline step target
- `skills/adversarial-audit/tasks/coherence-extraction.md` — SC coherence gate with Z3 + evidence type checks
- `skills/solve/` — Solve skill card (Z3 constraint solving, contracts, state)
