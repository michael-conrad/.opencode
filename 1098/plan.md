# [PLAN] local-issues: print available repo qualifiers on repo-not-found errors

> **Parent:** https://github.com/michael-conrad/.opencode/issues/1098
> **Local spec:** `.opencode/.issues/1098/spec.md`
> **Local state:** `./tmp/1098/state/` — Z3 pipeline state machine
> **Local artifacts:** `./tmp/1098/artifacts/` — per-step YAML contracts

## Scope

Single phase, work-of-1. One implementation item (add `_print_available_repos()` + wire 3 error sites) mapped onto the 14-step `implementation-pipeline`.

## Item Mapping

| Pipeline Step | What Happens |
|---|---|
| sc-coherence-gate | Verify spec+plan coherence against live codebase; confirm no superseding work |
| pre-red-baseline | Capture baseline: `local-issues update --number 1 --status closed` stderr output, `local-issues update --number nonexistent#1 --status closed` stderr output |
| red-phase | Write enforcement test `tests/test-local-issues-mutation-errors.sh` — starts empty for now |
| red-doublecheck | Verify enforcement test exits non-zero (RED confirmed — no `_print_available_repos` yet) |
| green-phase | Implement `_print_available_repos()` helper; wire into `_require_qualified()`, `_ensure_repo()`, `_resolve_qualified()` |
| checkpoint-commit | Commit all changes |
| structural-checks | Run ruff on `tools/local-issues` |
| green-doublecheck | Re-run enforcement test — confirms PASS (GREEN confirmed) |
| green-vbc | Verification against all 6 SCs |
| adversarial-audit | Dual-family auditor dispatch |
| cross-validate | Cross-validate auditor verdicts |
| regression-check | Compare PASS count against baseline |
| review-prep | Diff review, commit message, PR body |
| exec-summary | Push, URL extraction, issue comment, byline |

## 14-Step Pipeline

### Step 1: sc-coherence-gate

**Dispatch:** `task(subagent_type="general", prompt="execute sc-coherence-gate from implementation-pipeline")`

Sub-agent independently reads the spec, plan, and codebase to verify:
- `tools/local-issues` is the target file and exists
- `_require_qualified()`, `_ensure_repo()`, `_resolve_qualified()` exist at expected locations
- `_discover_repos()` and `_resolve_repo_name()` are available helpers
- `tests/test-local-issues-mutation-errors.sh` does not exist yet (will create in red-phase)
- No superseding or conflicting open issues

**Artifact:** `./tmp/1098/artifacts/pipeline-sc-coherence-gate-*.yaml`

### Step 2: pre-red-baseline

**Dispatch:** `task(subagent_type="general", prompt="execute pre-red-baseline from implementation-pipeline")`

Sub-agent captures current error output:
- `local-issues update --number 1 --status closed` — stderr should show "Use qualified form" error
- `local-issues update --number nonexistent#1 --status closed` — stderr should show "repo not found" error
- Record exact error messages for regression comparison

**Artifact:** `./tmp/1098/artifacts/pipeline-pre-red-baseline-*.yaml`

### Step 3: red-phase

**Dispatch:** `task(subagent_type="general", prompt="execute red-phase from implementation-pipeline")`

The RED sub-agent:

1. Reads existing test files in `tests/` for pattern consistency
2. Creates `tests/test-local-issues-mutation-errors.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
OVERALL_RESULT=0

# SC-1: bare number on update prints error + repo listing
output=$(local-issues update --number 1 --status closed 2>&1 || true)
if echo "$output" | grep -q "Available qualifiers"; then
    echo "FAIL (SC-1 unexpected PASS): update bare number already shows qualifier listing"
    OVERALL_RESULT=1
fi
if echo "$output" | grep -q "Use qualified form"; then
    echo "PASS: update bare number shows qualifier error"
else
    echo "FAIL (SC-1): update bare number missing qualifier error"
    OVERALL_RESULT=1
fi

# SC-2: non-existent repo prints error + repo listing
output=$(local-issues update --number nonexistent#1 --status closed 2>&1 || true)
if echo "$output" | grep -q "Available qualifiers"; then
    echo "FAIL (SC-2 unexpected PASS): update bad qualifier already shows qualifier listing"
    OVERALL_RESULT=1
fi
if echo "$output" | grep -q "not found"; then
    echo "PASS: update bad qualifier shows not-found error"
else
    echo "FAIL (SC-2): update bad qualifier missing not-found error"
    OVERALL_RESULT=1
fi

# SC-6: exit code is 1
local-issues update --number 1 --status closed >/dev/null 2>&1 && {
    echo "FAIL (SC-6): update bare number should exit non-zero"
    OVERALL_RESULT=1
} || echo "PASS: exit code 1"

exit $OVERALL_RESULT
```

3. Runs the test — confirms it exits non-zero (RED confirmed — `_print_available_repos` not yet implemented, so all checks fail as expected for RED)

**The RED sub-agent MUST NOT commit or push.**

**Artifact:** `./tmp/1098/artifacts/pipeline-red-phase-*.yaml`

### Step 4: red-doublecheck

**Dispatch:** `task(subagent_type="general", prompt="execute red-doublecheck from implementation-pipeline")`

Sub-agent verifies:
- `bash tests/test-local-issues-mutation-errors.sh` exits non-zero
- All SC checks report "FAIL" (expected — tool doesn't have `_print_available_repos` yet)
- Logs the actual FAIL output as evidence

**If RED not confirmed** → routes back to `red-phase` for fix.

**Artifact:** `./tmp/1098/artifacts/pipeline-red-doublecheck-*.yaml`

### Step 5: green-phase

**Dispatch:** `task(subagent_type="general", prompt="execute green-phase from implementation-pipeline")`

The GREEN sub-agent implements the change. Single file: `tools/local-issues`.

#### Change 1: Add `_print_available_repos()` helper

Insert after `_resolve_repo_name()` (around line 1046):

```python
def _print_available_repos() -> None:
    """Print current repo and all discovered child repos with qualifiers and paths."""
    current = Path(os.getcwd()).resolve()
    current_name = _resolve_repo_name()
    repos = _discover_repos()
    names = [current_name] + [r.name for r in repos]
    max_name_len = max(len(n) for n in names) if names else 0
    print("Available qualifiers (use name#N format):", file=sys.stderr)
    print(f"  {current_name:<{max_name_len}}     {current}", file=sys.stderr)
    for child in repos:
        print(f"  {child.name:<{max_name_len}}     {child}", file=sys.stderr)
```

#### Change 2: Wire into `_require_qualified()` (around line 667)

Add `_print_available_repos()` call immediately after the error print, before `sys.exit(1)`:

```python
    if repo_name is None:
        print("Error: Use qualified form {repo}#{N} for mutations.", file=sys.stderr)
        _print_available_repos()
        sys.exit(1)
```

#### Change 3: Wire into `_ensure_repo()` (around line 692)

```python
    if repo_path is None:
        print(f"Error: repo '{repo_name}' not found.", file=sys.stderr)
        _print_available_repos()
        sys.exit(1)
```

#### Change 4: Wire into `_resolve_qualified()` (around line 715)

```python
        print(f"error: repo '{repo_name_val}' not found", file=sys.stderr)
        _print_available_repos()
        sys.exit(1)
```

#### Green-phase completion

After all changes, run `bash tests/test-local-issues-mutation-errors.sh` and confirm exit code 0.

**The GREEN sub-agent MUST NOT commit or push.**

**Artifact:** `./tmp/1098/artifacts/pipeline-green-phase-*.yaml`

### Step 6: checkpoint-commit

**Dispatch:** `task(subagent_type="general", prompt="execute checkpoint-commit from implementation-pipeline")`

Creates a checkpoint commit with message:

```
feat: local-issues error messages print available repo qualifiers
```

Covers: `tools/local-issues` and `tests/test-local-issues-mutation-errors.sh`.

**Artifact:** `./tmp/1098/artifacts/pipeline-checkpoint-commit-*.yaml`

### Step 7: structural-checks

**Dispatch:** `task(subagent_type="general", prompt="execute structural-checks from implementation-pipeline")`

Run:
- `uvx ruff check --fix .opencode/tools/local-issues`
- `uvx ruff format .opencode/tools/local-issues`
- `bash tests/test-local-issues-mutation-errors.sh`

Fix any issues found.

**Artifact:** `./tmp/1098/artifacts/pipeline-structural-checks-*.yaml`

### Step 8: green-doublecheck

**Dispatch:** `task(subagent_type="general", prompt="execute green-doublecheck from implementation-pipeline")`

Re-run `bash tests/test-local-issues-mutation-errors.sh` — confirms PASS for all checks.

**Artifact:** `./tmp/1098/artifacts/pipeline-green-doublecheck-*.yaml`

### Step 9: green-vbc (Verification Before Completion)

**Dispatch:** `task(subagent_type="general", prompt="execute green-vbc from implementation-pipeline")`

Verify ALL 6 success criteria:

| SC | Type | Verification |
|----|------|-------------|
| SC-1 | string | `local-issues update --number 1 --status closed 2>&1` → output contains "Available qualifiers" section |
| SC-2 | string | `local-issues update --number nonexistent#1 --status closed 2>&1` → output contains repo not found + "Available qualifiers" |
| SC-3 | string | Same pattern for `close`, `delete`, `promote` with bare number |
| SC-4 | string | Same pattern for `close`, `delete`, `promote` with bad qualifier |
| SC-5 | string | `local-issues read --number nonexistent#1 2>&1` → "Available qualifiers" + exit code 1 |
| SC-6 | behavioral | Each mutation command → `echo $?` is 1 in all cases |

Each verification produces an evidence artifact at `./tmp/1098/artifacts/`.

**Artifact:** `./tmp/1098/artifacts/pipeline-green-vbc-*.yaml`

### Step 10: adversarial-audit

**Dispatch pre-step:** `resolve-models` to select auditor_1 and auditor_2 from different families.

**Dispatch:**
- `task(subagent_type="<auditor_1>", prompt="execute adversarial-audit from implementation-pipeline")`
- `task(subagent_type="<auditor_2>", prompt="execute adversarial-audit from implementation-pipeline")`

Each auditor independently:
1. Reads spec SCs and implementation
2. Verifies each SC against live tool-call evidence
3. Produces YAML verdict with findings per SC

**Artifact:** `./tmp/1098/artifacts/pipeline-adversarial-audit-*.yaml`

### Step 11: cross-validate

**Dispatch:** `task(subagent_type="general", prompt="execute cross-validate from implementation-pipeline")`

Cross-validate the dual auditor verdicts:
- CONCUR: both PASS → PASS
- CONCUR: both FAIL → FAIL (remediation routing)
- DISAGREE: one PASS, one FAIL → flag for orchestrator resolution

**Artifact:** `./tmp/1098/artifacts/pipeline-cross-validate-*.yaml`

### Step 12: regression-check

**Dispatch:** `task(subagent_type="general", prompt="execute regression-check from implementation-pipeline")`

Re-run `bash tests/test-local-issues-mutation-errors.sh` — assert same PASS count as green-doublecheck.

**Artifact:** `./tmp/1098/artifacts/pipeline-regression-check-*.yaml`

### Step 13: review-prep

**Dispatch:** `task(subagent_type="general", prompt="execute review-prep from implementation-pipeline")`

- `git diff --stat` against dev
- `git diff` review for correctness
- Draft PR body per `git-workflow` PR Body Requirements:
  - Summary: added `_print_available_repos()` helper, wired into 3 error sites
  - Outcome: mutation commands now print available repo qualifiers on error
  - Fixes: link to issue #1098
- Verify compare URL uses correct base branch (dev)

**Artifact:** `./tmp/1098/artifacts/pipeline-review-prep-*.yaml`

### Step 14: exec-summary

**Dispatch:** `task(subagent_type="general", prompt="execute exec-summary from implementation-pipeline")`

- Push branch to remote
- Create PR targeting dev (`.opencode` submodule repo)
- Extract PR URL from API response (never construct from template)
- Post progress comment to issue #1098 with PR URL
- Output executive summary: Summary → Outcome → PR URL → Byline

**Artifact:** `./tmp/1098/artifacts/pipeline-exec-summary-*.yaml`

## Artifact Layout

```
.tmp/1098/
  state/                          # Z3 pipeline state
    state.yaml                    # current_step, previous_step, pipeline_state
  artifacts/
    pipeline-sc-coherence-gate-{STATUS}-{timestamp}.yaml
    pipeline-pre-red-baseline-{STATUS}-{timestamp}.yaml
    pipeline-red-phase-{STATUS}-{timestamp}.yaml
    pipeline-red-doublecheck-{STATUS}-{timestamp}.yaml
    pipeline-green-phase-{STATUS}-{timestamp}.yaml
    pipeline-checkpoint-commit-{STATUS}-{timestamp}.yaml
    pipeline-structural-checks-{STATUS}-{timestamp}.yaml
    pipeline-green-doublecheck-{STATUS}-{timestamp}.yaml
    pipeline-green-vbc-{STATUS}-{timestamp}.yaml
    pipeline-adversarial-audit-{STATUS}-{timestamp}.yaml
    pipeline-cross-validate-{STATUS}-{timestamp}.yaml
    pipeline-regression-check-{STATUS}-{timestamp}.yaml
    pipeline-review-prep-{STATUS}-{timestamp}.yaml
    pipeline-exec-summary-{STATUS}-{timestamp}.yaml

.opencode/.issues/1098/
  spec.md                         # authoritative spec (mirrors GitHub issue #1098)
  plan.md                         # this file
  spec-artifacts/
    lifecycle.yaml                # append-only event log
```

## Remediation Routing

If any step returns FAIL:
1. Read FAIL artifact YAML from disk
2. Determine remediation scope
3. Re-run from the failed step (pre-cleanup that step's artifacts)
4. Max 3 remediation attempts before escalation

## Status

DRAFT
