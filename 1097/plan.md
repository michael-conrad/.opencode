# [PLAN] Self-describing tool contract: --description flag for all tools/

> **Parent:** https://github.com/michael-conrad/.opencode/issues/1097
> **Local spec:** `.opencode/.issues/1097/spec.md`
> **Local state:** `./tmp/1097/state/` — Z3 pipeline state machine
> **Local artifacts:** `./tmp/1097/artifacts/` — per-step YAML contracts

## Scope

Single phase, work-of-1. Six implementation items (1-5) plus one enforcement test (6) mapped onto the 14-step `implementation-pipeline`.

## Item Mapping

The RED/GREEN cycle is scoped to the whole work unit:

| Pipeline Step | Maps To | What Happens |
|---|---|---|
| sc-coherence-gate | All items | Verify spec+plan coherence against codebase; confirm no superseding work |
| pre-red-baseline | All items | Capture baseline: `./tools/help` output (all "(no description)"), `bash tests/test-pep723-tools.sh` exit code |
| red-phase | Item 6 first (test) | Write `check_description_flag` in `tests/test-pep723-tools.sh` — test FAILS because tools don't support `--description` yet |
| red-doublecheck | Item 6 | Verify enforcement test exits non-zero (RED confirmed) |
| green-phase | Items 1-5 | Implement all tool changes, fix `help`, convert `session-to-timeline`, update guideline — test now PASSES |
| checkpoint-commit | All items | Commit all changes |
| structural-checks | All items | Run lint/format/typecheck |
| green-doublecheck | Item 6 | Re-run enforcement test — confirms PASS (GREEN confirmed) |
| green-vbc | SC-1 through SC-7 | Verification-before-completion against all 7 success criteria |
| adversarial-audit | All items | Dual-family auditor (resolve-models → dispatch auditor_1, auditor_2) |
| cross-validate | All items | Cross-validate auditor findings, produce unified verdict |
| regression-check | Existing tests | Run full `tests/test-pep723-tools.sh` — same PASS count as baseline |
| review-prep | All items | PR preparation: diff review, commit message, PR body |
| exec-summary | All items | Push, URL extraction, issue comment, byline |

## 14-Step Pipeline with Per-Item Detail

### Step 1: sc-coherence-gate

**Dispatch:** `task(subagent_type="general", prompt="execute sc-coherence-gate from implementation-pipeline")`

Sub-agent independently reads the spec, plan, and codebase to verify:
- All 20 tool files exist at expected paths
- `session-to-timeline` is the only non-PEP-723 script in `tools/`
- `guidelines/070-environment.md` PEP 723 section exists (no `--description` subsection yet)
- `tests/test-pep723-tools.sh` exists and has ENTRY_POINTS array
- No superseding or conflicting open issues

**Artifact:** `./tmp/1097/artifacts/pipeline-sc-coherence-gate-*.yaml`

### Step 2: pre-red-baseline

**Dispatch:** `task(subagent_type="general", prompt="execute pre-red-baseline from implementation-pipeline")`

Sub-agent captures current state:
- `./tools/help` — record every tool line showing "(no description)"
- `bash tests/test-pep723-tools.sh` — record exit code and PASS/FAIL count
- `./tools/session-to-timeline --help` (or head -1) — confirm non-PEP-723 shebang

**State init:** `solve state init ./tmp/1097/state/` — creates `current_step: pre-red-baseline`, `pipeline_state: init`

**Artifact:** `./tmp/1097/artifacts/pipeline-pre-red-baseline-*.yaml` — contains baseline snapshot for regression comparison

### Step 3: red-phase

**Dispatch:** `task(subagent_type="general", prompt="execute red-phase from implementation-pipeline")`

The RED sub-agent:
1. Reads the enforcement test file at `tests/test-pep723-tools.sh`
2. Adds `check_description_flag()` function:

```bash
check_description_flag() {
    local tool="$1"
    local desc
    desc=$("$tool" --description 2>/dev/null) || {
        echo "FAIL: $tool --description exited non-zero"
        return 1
    }
    if [[ -z "$desc" ]]; then
        echo "FAIL: $tool --description produced empty output"
        return 1
    fi
    echo "PASS: $tool --description"
}
```

3. Adds invocation in the main check loop over `$ENTRY_POINTS`:

```bash
echo "--- check_description_flag ---"
for entry in "${ENTRY_POINTS[@]}"; do
    check_description_flag "$entry" || OVERALL_RESULT=1
done
```

4. Runs the test — confirms it exits non-zero (RED confirmed — no tool supports `--description` yet)

**The RED sub-agent MUST NOT commit or push.**

**Artifact:** `./tmp/1097/artifacts/pipeline-red-phase-*.yaml`

### Step 4: red-doublecheck

**Dispatch:** `task(subagent_type="general", prompt="execute red-doublecheck from implementation-pipeline")`

Sub-agent verifies:
- `bash tests/test-pep723-tools.sh` exits non-zero
- `check_description_flag` failures count = ENTRY_POINTS count (every single tool fails)
- Logs the actual FAIL output as evidence

**If RED not confirmed → routes back to `red-phase` for fix.**

**Artifact:** `./tmp/1097/artifacts/pipeline-red-doublecheck-*.yaml`

### Step 5: green-phase

**Dispatch:** `task(subagent_type="general", prompt="execute green-phase from implementation-pipeline")`

The GREEN sub-agent implements ALL of Items 1-5. This is a single sub-agent because the items are tightly coupled (adding `--description` to tools, then fixing `help` to call it, then documenting the contract).

#### Item 2: Add `--description` to 11 PEP 723 tools with existing `DESCRIPTION:`

| Tool | Description |
|------|-------------|
| `help` | `List all agent tools in tools/ with their descriptions.` |
| `file-exists` | `Check whether one or more file/directory paths exist.` |
| `guidelines` | `Guidelines tools dispatcher.` |
| `gitbucket-api` | `GitBucket API CLI client.` |
| `py` | `Python source tools dispatcher.` |
| `md` | `Markdown tools dispatcher.` |
| `jupyter` | `Jupyter server tools dispatcher.` |
| `jupyter-start` | `Start Jupyter server on port 18888.` |
| `jupyter-stop` | `Stop the Jupyter server running on port 18888.` |
| `skildeck` | `Skill deck formal analysis CLI.` |
| `schema-version` | `Print current UTC datetime as YYYYMMDDHHMMSS.` |

Add to each `main()`:

```python
if len(sys.argv) == 2 and sys.argv[1] == "--description":
    print("<one-line description>")
    return 0
```

#### Item 3a: Add `--description` + `DESCRIPTION:` to 4 Python PEP 723 tools

| Tool | Description |
|------|-------------|
| `session-init` | `Session initialization script for AI agents.` |
| `solve` | `Z3 constraint solver for workflow correctness.` |
| `plan` | `AI planning tool wrapping unified-planning.` |
| `local-issues` | `Local issue tracking CLI tool for .issues/ directory.` |

- Add `DESCRIPTION:` prefix to `__doc__`
- Add `--description` handler

#### Item 3b: Add `--description` to 4 bash tools

| Tool | Description |
|------|-------------|
| `ollama-probe` | `Probe Ollama server capabilities.` |
| `resolve-models` | `Select 2 auditors from different families for adversarial audit.` |
| `ensure-node` | `Ensure Node.js toolchain is available in .opencode/.node/.` |
| `detect-secrets-wrapper.sh` | `Wrapper for detect-secrets pre-commit hook.` |

Add after `set -euo pipefail`:

```bash
if [[ "${1:-}" == "--description" ]]; then
    echo "<one-line description>"
    exit 0
fi
```

Must be BEFORE any `case $*` wildcard handler.

#### Item 4: Convert `session-to-timeline` to PEP 723

- Replace `#!/usr/bin/env python3` with `#!/usr/bin/env -S uv run --script`
- Add bash guard line: `"exec" "uv" "run" "--script" "$0" "$@"  # MUST GO BEFORE PEP 723 HEADER`
- Add `# fmt: off` before bash guard, `# fmt: on` after PEP 723 header
- Add PEP 723 metadata block:

```python
# /// script
# requires-python = "~=3.12"
# dependencies = []
# ///
```

- Add `DESCRIPTION:` prefix to `__doc__`
- Add `--description` handler to `main()`
- Code body unchanged

#### Item 1: Fix `tools/help`

Replace `get_description()`:

```python
import subprocess
from pathlib import Path

def get_description(script: Path) -> str:
    """Get tool description by calling <tool> --description."""
    try:
        result = subprocess.run(
            [str(script.absolute()), "--description"],
            capture_output=True, text=True, check=False,
            stdin=subprocess.DEVNULL, timeout=5,
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()
    except (subprocess.SubprocessError, OSError, TimeoutError):
        pass
    return "(no description available)"
```

- Remove `import ast`
- Remove `ast.get_docstring()` usage
- Keep `main()` unchanged

#### Item 5: Update `guidelines/070-environment.md`

In section "PEP 723 Self-Contained Scripts (MANDATORY)", after `# fmt: off`/`# fmt: on` rules, add:

```markdown
### --description Flag (MANDATORY)

Every tool in `tools/` MUST implement a `--description` flag that prints a one-line description of the tool's purpose to stdout and exits 0. This allows the `help` tool and other aggregators to discover tool descriptions without parsing source code.

For PEP 723 Python scripts (top of `main()`):

```python
if len(sys.argv) == 2 and sys.argv[1] == "--description":
    print("One-line description of the tool's purpose.")
    return 0
```

For bash scripts (top of script, before substantive logic):

```bash
if [[ "${1:-}" == "--description" ]]; then
    echo "One-line description of the tool's purpose."
    exit 0
fi
```

The description should be a single sentence stating what the tool does from the caller's perspective ("does X") rather than describing its implementation ("uses Y to do X").
```

#### Green-phase completion

After all items implemented, run `bash tests/test-pep723-tools.sh` — confirms exit code 0 (ALL checks pass including the new `check_description_flag`).

**The GREEN sub-agent MUST NOT commit or push.**

**Artifact:** `./tmp/1097/artifacts/pipeline-green-phase-*.yaml`

### Step 6: checkpoint-commit

**Dispatch:** `task(subagent_type="general", prompt="execute checkpoint-commit from implementation-pipeline")`

Creates a checkpoint commit with message:

```
feat: add --description flag to all tools/, fix help extraction, convert session-to-timeline to PEP 723
```

Covers all files modified by Items 1-5 and Item 6 (enforcement test update).

**Artifact:** `./tmp/1097/artifacts/pipeline-checkpoint-commit-*.yaml`

### Step 7: structural-checks

**Dispatch:** `task(subagent_type="general", prompt="execute structural-checks from implementation-pipeline")`

Run all relevant structural checks:
- `uvx ruff check --fix .opencode/tools/` (Python tools only)
- `uvx ruff format .opencode/tools/`
- `bash tests/test-pep723-tools.sh` (the enforcement test itself)

Fix any lint/format issues found.

**Artifact:** `./tmp/1097/artifacts/pipeline-structural-checks-*.yaml`

### Step 8: green-doublecheck

**Dispatch:** `task(subagent_type="general", prompt="execute green-doublecheck from implementation-pipeline")`

Re-run `bash tests/test-pep723-tools.sh` — confirms PASS with `check_description_flag` passing for all entry points.

Cross-check: `./tools/help` — no "(no description)" or "(no description available)" lines shown for any tool.

**Artifact:** `./tmp/1097/artifacts/pipeline-green-doublecheck-*.yaml`

### Step 9: green-vbc (Verification Before Completion)

**Dispatch:** `task(subagent_type="general", prompt="execute green-vbc from implementation-pipeline")`

Verify ALL 7 success criteria from the spec:

| SC | Type | Verification |
|----|------|-------------|
| SC-1 | behavioral | `./tools/help` — every tool line shows a description, none show "(no description)" or "(no description available)" |
| SC-2 | behavioral | Temporarily remove `--description` from one tool — `help` shows fallback for it; restore |
| SC-3 | string | Loop: for each executable in `tools/` (exclude dirs, `impl/`, `__pycache__`): `<tool> --description` exits 0, stdout non-empty |
| SC-4 | string | `head -1 tools/session-to-timeline` shows PEP 723 shebang; `grep '^# /// script$' tools/session-to-timeline` succeeds; `./tools/session-to-timeline --description` exits 0 |
| SC-5 | string | `grep '--description' guidelines/070-environment.md` — section exists |
| SC-6 | behavioral | `bash tests/test-pep723-tools.sh` passes |
| SC-7 | behavioral | Compare PASS count against baseline from Step 2 — same count, only `check_description_flag` added |

Each verification produces an evidence artifact at `./tmp/1097/artifacts/`.

**Artifact:** `./tmp/1097/artifacts/pipeline-green-vbc-*.yaml`

### Step 10: adversarial-audit

**Dispatch pre-step:** `resolve-models` to select auditor_1 and auditor_2 from different families.

**Dispatch:** 
- `task(subagent_type="<auditor_1>", prompt="execute adversarial-audit from implementation-pipeline")`
- `task(subagent_type="<auditor_2>", prompt="execute adversarial-audit from implementation-pipeline")`

Each auditor independently:
1. Reads spec SCs and implementation
2. Verifies each SC against live tool-call evidence
3. Produces YAML verdict with findings per SC

**Artifact:** `./tmp/1097/artifacts/pipeline-adversarial-audit-*.yaml`

### Step 11: cross-validate

**Dispatch:** `task(subagent_type="general", prompt="execute cross-validate from implementation-pipeline")`

Cross-validate the dual auditor verdicts:
- CONCUR: both PASS → PASS
- CONCUR: both FAIL → FAIL (remediation routing)
- DISAGREE: one PASS, one FAIL → flag for orchestrator resolution
- DISAGREE: structural vs behavioral evidence mismatch → EVIDENCE_TYPE_MISMATCH classification

**Artifact:** `./tmp/1097/artifacts/pipeline-cross-validate-*.yaml`

### Step 12: regression-check

**Dispatch:** `task(subagent_type="general", prompt="execute regression-check from implementation-pipeline")`

Run `bash tests/test-pep723-tools.sh` — compare PASS count against baseline from Step 2. Assert same count (only `check_description_flag` added, no existing checks removed or broken).

**Artifact:** `./tmp/1097/artifacts/pipeline-regression-check-*.yaml`

### Step 13: review-prep

**Dispatch:** `task(subagent_type="general", prompt="execute review-prep from implementation-pipeline")`

- `git diff --stat` against base branch
- `git diff` review for correctness
- Draft PR body per `git-workflow` PR Body Requirements:
  - Summary: what changed
  - Outcome: help now shows real descriptions; --description contract established
  - Fixes: link to issue #1097
- Verify compare URL uses correct base branch (dev)

**Artifact:** `./tmp/1097/artifacts/pipeline-review-prep-*.yaml`

### Step 14: exec-summary

**Dispatch:** `task(subagent_type="general", prompt="execute exec-summary from implementation-pipeline")`

- Push branch to remote
- Create PR targeting dev
- Extract PR URL from API response (never construct from template)
- Post progress comment to issue #1097 with PR URL
- Append lifecycle event to `.issues/1097/spec-artifacts/lifecycle.yaml`
- Output executive summary: Summary → Outcome → PR URL → Byline

**Artifact:** `./tmp/1097/artifacts/pipeline-exec-summary-*.yaml`

## Z3 State Machine

State file at `./tmp/1097/state/` with Z3 contract at `skills/implementation-pipeline/pipeline-state-machine.yaml`.

After each step transition:
```bash
solve state update ./tmp/1097/state/ \
  --var-name previous_step <prev> \
  --var-name current_step <curr> \
  --var-name pipeline_state running \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml
solve check --state-path ./tmp/1097/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml
```

## Artifact Layout

```
.tmp/1097/
  state/                          # Z3 pipeline state
    state.yaml                    # current_step, previous_step, pipeline_state
  artifacts/
    pipeline-sc-coherence-gate-{STATUS}-{timestamp}.yaml
    pipeline-pre-red-baseline-{STATUS}-{timestamp}.yaml  # includes baseline snapshot
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

.opencode/.issues/1097/
  spec.md                         # authoritative spec
  plan.md                         # this file
  spec-artifacts/
    lifecycle.yaml                # append-only event log
```

## Remediation Routing

If any step returns FAIL:
1. Read FAIL artifact YAML from disk
2. Determine remediation scope — route to `researcher` skill if root cause unclear
3. Re-run from the failed step (with pre-cleanup of that step's artifacts)
4. Max 3 remediation attempts before escalation to developer

## Status

DRAFT
