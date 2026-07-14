# Behavioral Test Harness Specification (v2)

**Artifact-Only Generator Paradigm**

Every behavioral test script generates model-run artifacts and exits 0. Evaluation is the orchestrator's job — scripts NEVER evaluate model output.

> **MANDATORY: Bash tool timeout MUST be >= 600 seconds when running behavioral tests.**
> No `timeout` command inside scripts (nested timeouts create orphaned processes).
> See §Infrastructure Details — Bash Tool Timeout Mandate.

## Key Differences from v1

| Aspect | v1 (`.opencode/tests/`) | v2 (`.opencode/tests-v2/`) |
|--------|------------------------|----------------------------|
| CLI binary | `opencode-cli` | `opencode` (`/snap/bin/opencode`) |
| Model discovery | `opencode-cli models` | `opencode models` |
| Test runner | `with-test-home` (v1) | `with-test-home` (v2, rewritten) |
| Env isolation | Partial `env` passthrough | `env -i` with explicit allowlist |
| Smoke tests | Optional | Mandatory (`opencode models` + `opencode run "hello world"`) |
| Test project | Flat test home | `{test_home}/project/` with `git init` + `.opencode` clone |

## Table of Contents

1. [Paradigm: Artifact-Only Generators](#1-paradigm-artifact-only-generators)
2. [Artifact Directory Structure](#2-artifact-directory-structure)
3. [Writing a New Behavioral Test](#3-writing-a-new-behavioral-test)
4. [Running Tests](#4-running-tests)
5. [Infrastructure Details](#5-infrastructure-details)
6. [Relationship to Content-Verification Tests](#6-relationship-to-content-verification-tests)
7. [Cleanup](#7-cleanup)
8. [Triple Co-Application Reference](#8-triple-co-application-reference)
9. [Prompt Construction Mandate](#9-prompt-construction-mandate)

---

## 1. Paradigm: Artifact-Only Generators

A behavioral test script runs a model against a prompt, collects all output into `./tmp/`, writes a `manifest.yaml`, and exits 0. It NEVER calls assertion functions, NEVER runs evaluation logic, and NEVER produces a PASS/FAIL verdict.

**The script's job IS generation. The orchestrator's job IS evaluation.** A script that evaluates its own output has conflated two concerns — the artifact it produces is no longer a raw generation, and the evaluation cannot be independently verified by a clean-room sub-agent.

### MANDATORY: Every Script Must Include a Cross-Reference Header

Every `.sh` file in `tests-v2/behaviors/` must begin with:

```bash
#!/bin/bash
# Behavioral test: <scenario-name>
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
```

### MANDATORY: Exit Code Is Always 0

All scripts exit 0 unconditionally after artifact generation. The exit code signals "run completed, artifacts produced" — NOT "test passed."

### PROHIBITED Patterns

| Pattern | Why Prohibited | Correct Pattern |
|---------|----------------|-----------------|
| `assert_*` function calls | Script conflates generation with evaluation | Script runs `behavior_run`, exits 0 |
| `OVERALL_RESULT` variable | Script tracks internal pass/fail | Script has zero pass/fail tracking |
| `exit $OVERALL_RESULT` | Non-zero exit signals evaluation FAIL | `exit 0` unconditionally |
| Inline grep/pattern checks | Script evaluates output | Script generates artifacts for evaluation |

### Script Structure

```bash
#!/bin/bash
# Behavioral test: <scenario-name>
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="<scenario-name>"
SCENARIO_PROMPT="<prompt>"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
```

## 2. Artifact Directory Structure

Every `behavior_run` invocation produces an artifact directory at:

```
./tmp/behavioral-evidence-<SCENARIO_NAME>-<BEHAVIOR_PHASE>-<model-slug>/
```

**MANDATORY files:**

| File | Content | Required By |
|------|---------|-------------|
| `manifest.yaml` | Generation metadata (scenario, phase, model, timestamp, exit_code, harness_version) | Evaluation pipeline |
| `stdout.log` | Agent prose response | Evaluator reads agent output |
| `stderr.log` | Tool dispatch trace | Evaluator reads agent actions |
| `exit_code` | Numeric exit code from model run (0=OK, 1=harness failure) | Pipeline orchestration |
| `session.yaml` | SQLite DB → YAML export (or `source_db: null` if DB absent) | Session context for evaluation |

## 3. Writing a New Behavioral Test

### Step 1: Create the Script

Copy `template.sh` to a new file with a descriptive name. Set `SCENARIO_NAME` (kebab-case) and `SCENARIO_PROMPT` (the message sent to the model).

### Step 2: Run the Script

```bash
bash .opencode/tests-v2/behaviors/<scenario>.sh
```

### Step 3: Verify Artifacts

```bash
ls ./tmp/behavioral-evidence-<scenario>-GREEN-<model>/
```

Expected: `manifest.yaml`, `stdout.log`, `stderr.log`, `exit_code`, `session.yaml`.

## 4. Running Tests

### Single Scenario

```bash
bash .opencode/tests-v2/behaviors/<scenario>.sh
```

### Scope-Filtered Runs

```bash
bash .opencode/tests-v2/test-enforcement.sh --tag <tag>
```

### Model Override

```bash
DEFAULT_TEST_MODEL="ollama/other-model:cloud" \
BEHAVIOR_PHASE="RED" \
bash .opencode/tests-v2/behaviors/<scenario>.sh
```

## 5. Infrastructure Details

### Binary

- **`opencode`** at `/snap/bin/opencode` (v1.17.18) — the ONLY binary used
- **`opencode-cli`** at `/usr/bin/opencode-cli` (v1.14.33) — NOT used in v2

### `with-test-home` — XDG-Isolated Test Runner

**MUST be used for ALL opencode testing.** Never run `opencode run` directly — it causes SQLite session conflicts with the desktop app.

The wrapper creates an isolated temporary home directory (`tmp/test-home-<timestamp>`) with clean XDG state.

**Environment variable isolation** — uses `env -i` with ONLY these vars:
- `HOME`, `PWD`, `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, `XDG_RUNTIME_DIR`, `XDG_DATA_HOME`, `XDG_STATE_HOME`
- `PATH` (parent env)
- `SHELL`, `USER`, `LOGNAME`, `LANG`, `TERM` (parent env)
- `GB_TOKEN` (parent env, if set)

**FORBIDDEN** — no `GITHUB_TOKEN`, `GH_TOKEN`, `OPENCODE_CONFIG_CONTENT`, `NODE_ENV`, `VIRTUAL_ENV`, `CONDA_DEFAULT_ENV`, or shell-specific vars.

### Test Environment Setup Steps

1. Create test home directory at `{project_root}/tmp/test-home-{timestamp}`
2. Set XDG vars to test home paths
3. Set `PATH` to parent env PATH only
4. Create test sub-folder: `{test_home}/project/`
5. `git init` the test sub-folder
6. Clone `.opencode/` submodule from remote into the test project
7. Seed `opencode.jsonc` config with available models
8. Run `opencode models` to verify CLI works (smoke test)
9. Run `opencode run "hello world"` to verify model works (smoke test)

### Smoke Test Requirements

Both smoke tests MUST pass before the test home is considered ready:
- `opencode models` must return at least one `ollama/` model
- `opencode run "hello world"` must produce non-empty output without errors

### Concurrency Lock — `flock`

The harness uses `flock` (file lock) for mutual exclusion. A lock file at `tmp/.behavior-run.lock` is acquired via `flock -x -w 30` before the model run.

### Bash Tool Timeout Mandate — ZERO TOLERANCE

**The bash tool's `timeout` parameter is the ONLY kill signal that may be used when running behavioral tests.** Any use of the `timeout` command inside a bash script invoked by the bash tool is FORBIDDEN.

**Mandated bash tool invocation:**
```
# timeout=600000 (600 seconds, milliseconds). NEVER omit.
```

### Invocation Examples

```bash
# Run a single test message
bash .opencode/tests-v2/with-test-home /snap/bin/opencode run "hello" --model ollama/ornith:35b-256k

# Setup only (create env, run smoke tests, print path)
bash .opencode/tests-v2/with-test-home --setup

# Clean up the most recent test home
bash .opencode/tests-v2/with-test-home --clean

# Clean up ALL test homes
bash .opencode/tests-v2/with-test-home --clean-all
```

## 6. Relationship to Content-Verification Tests

| Test Type | Role | What It Proves | Scope |
|-----------|------|----------------|-------|
| Behavioral (this directory) | Artifact generation | Model produced output for a scenario | Runs model, dumps artifacts |
| Content-verification (`test-enforcement.sh`) | Text presence | Rule text exists in the right file | Greps files, no model needed |

## 7. Cleanup

```bash
# Remove the most recent test home
bash .opencode/tests-v2/with-test-home --clean

# Remove ALL test homes
bash .opencode/tests-v2/with-test-home --clean-all
```

## 8. Triple Co-Application Reference

This document is AI-agent-facing text. Per `080-code-standards.md` §Mandatory Triple Co-Application, the following three reference cards were consulted during its creation:

| Reference Card | What It Governs in This Document |
|----------------|----------------------------------|
| `250-dark-prose-reference.md` | Identity — rules use authority frame, not confirmshaming. MANDATORY/PROHIBITED patterns use direct mandates. |
| `255-distribution-shifting-reference.md` | Signal — required vs optional fields are explicitly marked. The paradigm statement uses corrupt-success contrast. |
| `257-procedural-discipline-reference.md` | Structure — dependency-order gate: artifact generation REQUIRES a model run. Controlled vocabulary pairs define exact vocabulary. |

## 9. Prompt Construction Mandate

Behavioral test prompts MUST trigger natural agent behavior — they MUST NOT interview the agent about what it *would* do.

### The Interview/Natural-Behavior Spectrum

| Prompt Type | Classification | Example | Verdict |
|-------------|---------------|---------|---------|
| Real-domain task | Natural behavior | "Implement feature X from spec #42" | ✅ Valid |
| Real-domain bug | Natural behavior | "The login button doesn't work" | ✅ Valid |
| "Describe how you would..." | Prose-recall (interview) | "Describe how you would handle authorization" | ❌ INVALID |
| "Explain the process for..." | Prose-recall (interview) | "Explain how you create a PR" | ❌ INVALID |

### Hard-Fail Rule

Any behavioral test that uses a prose-recall prompt is **FAIL** — the test does not measure actual agent behavior.

---

## Directory Structure

```
.opencode/tests-v2/
├── AGENTS.md                    # This file — test harness spec
├── with-test-home               # Core env setup script
├── default-model.sh             # Default model variable
├── test-enforcement.sh          # Content-verification runner
├── test-verification-honesty.sh # Verification honesty runner
└── behaviors/
    ├── helpers.sh               # behavior_run() and assertion helpers
    ├── template.sh              # Script template for new tests
    └── fixtures/                # Copied from .opencode/tests/behaviors/fixtures/
        ├── evidence/
        ├── gitbucket-fake-repo/
        ├── issues/
        ├── stories/
        ├── setup-fixture-issues.sh
        └── setup-story-fixtures.sh
```
