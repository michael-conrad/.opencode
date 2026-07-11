# Behavioral Test Harness Specification

**Artifact-Only Generator Paradigm**

Every behavioral test script generates model-run artifacts and exits 0. Evaluation is the orchestrator's job — scripts NEVER evaluate model output.

> **MANDATORY: Bash tool timeout MUST be >= 600 seconds when running behavioral tests.**
> No `timeout` command inside scripts (nested timeouts create orphaned processes).
> See §Infrastructure Details — Bash Tool Timeout Mandate.

## Table of Contents

1. [Paradigm: Artifact-Only Generators](#1-paradigm-artifact-only-generators)
2. [Artifact Directory Structure](#2-artifact-directory-structure)
3. [Writing a New Behavioral Test](#3-writing-a-new-behavioral-test)
4. [Running Tests](#4-running-tests)
5. [Infrastructure Details](#5-infrastructure-details)
   - [Submodule Commit Precondition](#submodule-commit-precondition)
6. [Relationship to Content-Verification Tests](#6-relationship-to-content-verification-tests)
7. [Cleanup](#7-cleanup)
8. [Triple Co-Application Reference](#8-triple-co-application-reference)
9. [Prompt Construction Mandate](#9-prompt-construction-mandate)

---

## 1. Paradigm: Artifact-Only Generators

A behavioral test script runs a model against a prompt, collects all output into `./tmp/`, writes a `manifest.yaml`, and exits 0. It NEVER calls assertion functions, NEVER runs evaluation logic, and NEVER produces a PASS/FAIL verdict.

**The script's job IS generation. The orchestrator's job IS evaluation.** A script that evaluates its own output has conflated two concerns — the artifact it produces is no longer a raw generation, and the evaluation cannot be independently verified by a clean-room sub-agent.

### MANDATORY: Every Script Must Include a Cross-Reference Header

Every `.sh` file in `tests/behaviors/` must begin with:

```bash
#!/bin/bash
# Behavioral test: <scenario-name>
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
```

This header serves as a declaration: the script knows its role and confines itself to generation. A script without this header is out of specification.

### MANDATORY: Exit Code Is Always 0

All scripts exit 0 unconditionally after artifact generation. The exit code signals "run completed, artifacts produced" — NOT "test passed." A non-zero exit from a behavioral test script means a harness failure (model unavailable, infrastructure error), not a test failure.

### PROHIBITED Patterns

| Pattern | Why Prohibited | Correct Pattern |
|---------|----------------|-----------------|
| `assert_*` function calls | Script conflates generation with evaluation | Script runs `behavior_run`, exits 0 |
| `behavior_adversarial_eval` | Same conflation, more complex | Script only calls `behavior_run` |
| `OVERALL_RESULT` variable | Script tracks internal pass/fail | Script has zero pass/fail tracking |
| `exit $OVERALL_RESULT` | Non-zero exit signals evaluation FAIL | `exit 0` unconditionally |
| Inline grep/pattern checks | Script evaluates output | Script generates artifacts for evaluation |
| Calling evaluator sub-agents | Script orchestrates evaluation | Script returns artifact directory path |

### Script Structure

Every behavioral test script follows this template:

```bash
#!/bin/bash
# Behavioral test: <scenario-name>
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
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

**MANDATORY files** — every artifact directory MUST contain all of:

| File | Content | Required By |
|------|---------|-------------|
| `manifest.yaml` | Generation metadata (scenario, phase, model, timestamp, exit_code, harness_version) | Evaluation pipeline |
| `stdout.log` | Agent prose response | Evaluator reads agent output |
| `stderr.log` | Tool dispatch trace | Evaluator reads agent actions |
| `exit_code` | Numeric exit code from model run (0=OK, 1=harness failure) | Pipeline orchestration |
| `session.yaml` | SQLite DB → YAML export (or `source_db: null` if DB absent) | Session context for evaluation |

**Available when applicable** — these files are produced when the runtime provides them:

| File | Content | Source |
|------|---------|--------|
| `stdout.raw` | Raw model output before any processing | Model response stream |
| `stderr.raw` | Raw stderr before any processing | Harness output capture |
| `session-context.yaml` | Captured session context metadata | Context capture hook |
| `timing.log` | Wall-clock timing data | Harness instrumentation |

**Model-slug collision guard:** If the artifact directory already exists, a numeric suffix is appended (`-1`, `-2`, etc.) to prevent overwriting artifacts from a previous run.

**Graceful degradation:** The artifact directory is ALWAYS produced even if SQLite DB is absent. `session.yaml` always exists — either with full PRAGMA-discovered table data or `source_db: null`.

### manifest.yaml Schema

```yaml
scenario_name: <string>          # MANDATORY — matches SCENARIO_NAME
phase: RED|GREEN                 # MANDATORY — from BEHAVIOR_PHASE
model: <string>                  # MANDATORY — full model identifier
timestamp: <ISO-8601>            # MANDATORY — UTC generation time
exit_code: <0|1>                 # MANDATORY — 0=OK, 1=harness failure
harness_version: 1               # MANDATORY — incremented on format evolution
```

### session.yaml Schema

```yaml
source_db: <path>|null           # MANDATORY — SQLite DB location, or null if absent
harness_version: <int>           # MANDATORY — matches manifest
tables:                          # Present when source_db is not null
  <table_name>:                  # Per table
    columns: [<col1>, <col2>, ...]
    rows:
      - {<col1>: <val1>, <col2>: <val2>, ...}
```

Column discovery uses `PRAGMA table_info` at runtime — the schema is never hardcoded. This provides cross-version compatibility as the opencode SQLite schema evolves.

## 3. Writing a New Behavioral Test

### Step 1: Create the Script

Copy `template.sh` to a new file with a descriptive name. Set `SCENARIO_NAME` (kebab-case) and `SCENARIO_PROMPT` (the message sent to the model).

### Step 2: Run the Script

```bash
bash .opencode/tests/behaviors/<scenario>.sh
```

This produces artifacts at `./tmp/behavioral-evidence-<scenario>-GREEN-<model>/`.

### Step 3: Verify Artifacts

After the run, confirm the artifact directory is well-formed:

```bash
ls ./tmp/behavioral-evidence-<scenario>-GREEN-<model>/
```

Expected: `manifest.yaml`, `stdout.log`, `stderr.log`, `exit_code`, `session.yaml`.

### Step 4: Test Runs Are Not Evaluation

A script that runs without errors and produces artifacts is NOT a passing test — it is a successful generation. The artifacts must be evaluated by the orchestrator via clean-room sub-agents.

## 4. Running Tests

### Single Scenario

```bash
bash .opencode/tests/behaviors/<scenario>.sh
```

### Scope-Filtered Runs

Full-suite uber scripts are FORBIDDEN. Batch runs use scope filtering:

```bash
# Run by tag (when test-enforcement.sh supports tags)
bash .opencode/tests/test-enforcement.sh --tag <tag>

# Run individual scenarios with env overrides
DEFAULT_TEST_MODEL="ollama/other-model:cloud" \
BEHAVIOR_PHASE="RED" \
bash .opencode/tests/behaviors/<scenario>.sh
```

### Model Pool

By default, scripts use `DEFAULT_TEST_MODEL` from `tests/default-model.sh` (the single source of truth). Override via environment:

```bash
DEFAULT_TEST_MODEL="ollama/other-model:cloud" bash .opencode/tests/behaviors/<scenario>.sh
```

The `behavior_run_pool` function runs against all models in `BEHAVIORAL_MODEL_POOL` (auto-populated from `opencode-cli models`).

## 5. Infrastructure Details

### `helpers.sh` — Behavioral Test Helpers

Source this file in every test script:

```bash
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
```

Available functions:

| Function | Purpose |
|----------|---------|
| `behavior_run <name> <prompt> [model] [workdir]` | Run model against prompt, produce artifacts |
| `behavior_run_pool <name> <prompt>` | Run against all models in pool |
| `behavior_get_stdout` | Read latest stdout |
| `behavior_get_stderr` | Read latest stderr |

Helper variables:

| Variable | Default | Purpose |
|----------|---------|---------|
| `BEHAVIOR_TIMEOUT` | 420s | Max model run duration |
| `DEFAULT_TEST_MODEL` | `ollama/ornith:35b-256k` (from `default-model.sh`) | Default model |
| `BEHAVIOR_PHASE` | `GREEN` | RED or GREEN phase label |
| `BEHAVIOR_MAX_RETRIES` | 2 | Retry count on transient errors |
| `BEHAVIOR_RETRY_DELAY` | 30s | Wait between retries |
| `BEHAVIOR_TEST_HOME` | `.opencode/tests/with-test-home` | XDG-isolated test runner |
| `BEHAVIOR_HARNESS_VERSION` | 1 | Format version for artifacts |

### Concurrency Lock — `flock`

The harness uses `flock` (file lock) for mutual exclusion. In `helpers.sh` `behavior_run()`, a lock file at `tmp/.behavior-run.lock` is acquired via `flock -x -w 30` before the model run. If the lock cannot be acquired within 30 seconds, the script exits with `HARNESS_FAILURE: lock contention`. This prevents concurrent test invocations from corrupting shared state (SQLite DB, model dispatch).

The lock is released automatically when the subshell exits. No `mkdir`-based locking is used — `flock` is the sole lock mechanism.

### `with-test-home` — XDG-Isolated Test Runner

**MUST be used for ALL opencode-cli testing.** Never run `opencode-cli run` directly — it causes SQLite session conflicts with the desktop app.

The harness runs `opencode-cli run` with `--log-level INFO --print-logs` to capture tool dispatch traces in stderr for behavioral evidence collection. These flags are set in `helpers.sh behavior_run()` and should be used for any manual testing as well:

```bash
# Run a single test message (manual/testing)
bash .opencode/tests/with-test-home opencode-cli run '<message>' --log-level INFO --print-logs

# Clean up the most recent test home
bash .opencode/tests/with-test-home --clean

# Clean up ALL test homes
bash .opencode/tests/with-test-home --clean-all
```

The wrapper creates an isolated temporary home directory (`tmp/test-home-<timestamp>`) with clean XDG state.

### Bash Tool Timeout Mandate — ZERO TOLERANCE

**The bash tool's `timeout` parameter is the ONLY kill signal that may be used when running behavioral tests.** Any use of the `timeout` command (or timer-equivalent utilities) inside a bash script invoked by the bash tool is FORBIDDEN.

**Reason:** When the bash tool kills a script via its outer `timeout` mechanism, SIGTERM hits the script's shell process. If that shell has spawned a child process wrapped in `timeout`, GNU `timeout` does NOT forward SIGTERM to its child — it only kills its own `wait()`. The inner `opencode-cli run` becomes orphaned, still holding resources (the `flock` lock, test home directory handles, possibly the model connection). Every subsequent test invocation hangs on the orphaned lock. Recovery requires `kill -9` on the orphan process.

The prohibition covers ALL timer commands and constructs — not just `timeout(1)` but also `alarm()`, `SIGALRM` traps, timer-based `sleep N && kill $$` patterns, and any other mechanism that delivers a timed kill signal inside the bash script. The bash tool's single outer timeout is the ONLY allowed kill mechanism.

**Allowed — NOT a timer:**
- `opencode-cli run` session resumption: on SSE read timeout or transient model error, use `opencode-cli run "continue" --task_id <prior-task_id>` to resume the session. This is a model-level retry, not a process-level kill. Multi-turn sessions are the correct way to retry after SSE timeouts.
- `sleep` between retry attempts (sleep is not a kill mechanism)
- Pattern-matching stderr for `sse.*timeout` to trigger session resumption

**Mandated bash tool invocation:**
```
# timeout=600000 (600 seconds, milliseconds). NEVER omit.
```

**Existing violations:** `test-enforcement.sh:886` and `test-verification-honesty.sh:83` use `timeout` wrapping `opencode-cli run`. These MUST be refactored to remove the inner `timeout` and use session resumption for transient errors.

No exceptions. No justifications. No "it worked in testing." Every nested `timeout` will eventually orphan a child and hang the test suite.

### Isolated Test Repo Construction

**MANDATORY: Behavioral tests MUST NOT touch the main project root or its .issues/ directory.**

The test repo created by `behavior_run` is a fully isolated git repository. It clones `.opencode` from remote, checks out the feature branch commit, seeds fixture data, and runs `opencode-cli` inside itself. The main project's `.issues/`, `.opencode/` state, SQLite database, and any other mutable state MUST never be read, written, or otherwise touched by a behavioral test.

The `with-test-home` wrapper, combined with `behavior_run`'s isolated repo construction, enforces this: the test runs in `$TEST_HOME` with `$TEST_WORKDIR` pointing to the isolated repo. No path in the test chain resolves to the main project.

When `behavior_run` does not receive an explicit workdir, it creates an isolated git repository:

1. Creates a temp directory
2. `git init` — empty project
3. Clones `.opencode` submodule from configured remote URL
4. Checks out specific fixture commit if `BEHAVIOR_SUBMODULE_COMMIT` is set
5. Commits initial state
6. Injects fixture `.issues/` entries if fixture scripts exist

This ensures every behavioral test runs against a clean, isolated project state with no contamination from the live repository.

### Submodule Commit Precondition

When testing changes to `.opencode/` skills or guidelines, the behavioral test needs the `.opencode` submodule checked out to the feature branch commit containing those changes. The test harness supports this via the `BEHAVIOR_SUBMODULE_COMMIT` environment variable.

**`BEHAVIOR_SUBMODULE_COMMIT`** — Environment variable set in `helpers.sh` that pins the `.opencode` submodule checkout to a specific SHA. When set, the isolated test repo clones the submodule at that commit rather than remote HEAD. When unset, the submodule is checked out at remote HEAD.

**Push-before-test workflow:** The feature branch commit MUST be pushed to the remote before `behavior_run()` is called. The test repo clones `.opencode` from remote — unpushed commits are invisible to the test harness. The workflow sequence is:

1. Push the `.opencode` feature branch to remote
2. Get the commit SHA from the pushed branch
3. Set `BEHAVIOR_SUBMODULE_COMMIT=<sha>` before running the test
4. Run the behavioral test

**Consequence of unmet precondition:** If the feature branch commit is not pushed, the test repo clones the submodule at the pinned SHA (or remote HEAD if unset), using stale submodule state. The test runs against old code, not the feature branch changes. The failure mode is a test that passes against stale code but fails against the actual feature branch — a false PASS.

## 6. Relationship to Content-Verification Tests

Two test types verify different concerns:

| Test Type | Role | What It Proves | Scope |
|-----------|------|----------------|-------|
| Behavioral (this directory) | Artifact generation | Model produced output for a scenario | Runs model, dumps artifacts |
| Content-verification (`test-enforcement.sh`) | Text presence | Rule text exists in the right file | Greps files, no model needed |

Content-verification tests are FASTER (no model invocation) and are used for fast feedback loops. Behavioral tests are SLOWER (require model invocation) and produce artifacts for external evaluation.

Both types use scope-filtered runs — never full-suite uber scripts.

## 7. Cleanup

After testing, clean up test home directories:

```bash
# Remove the most recent test home
bash .opencode/tests/with-test-home --clean

# Remove ALL test homes
bash .opencode/tests/with-test-home --clean-all
```

Artifact directories under `./tmp/behavioral-evidence-*/` are preserved for evaluation. Clean them manually when no longer needed.

## 8. Triple Co-Application Reference

This document is AI-agent-facing text — its primary consumers are agents creating and modifying behavioral test scripts. Per `080-code-standards.md` §Mandatory Triple Co-Application, the following three reference cards were consulted during its creation:

| Reference Card | What It Governs in This Document |
|----------------|----------------------------------|
| `250-dark-prose-reference.md` | Identity — rules use authority frame (dark-prose-004), not confirmshaming. MANDATORY/PROHIBITED patterns use direct mandates. Agency-respecting (dark-prose-006): the document defines WHAT the specification requires and WHY — trusted agents determine HOW by reading the helper infrastructure. |
| `255-distribution-shifting-reference.md` | Signal — required vs optional fields are explicitly marked (MANDATORY / Available when applicable). The artifact directory structure uses positional distinction (required items at top, optional below) per dist-shift-003 (Re-Priming Anchor). The paradigm statement ("script's job IS generation — orchestrator's job IS evaluation") uses dist-shift-008 (Corrupt-Success Contrast) to polarize the completion distribution away from inline evaluation. |
| `257-procedural-discipline-reference.md` | Structure — p-dis-001 (Dependency-Order Gate): artifact generation REQUIRES a model run — no artifacts without output. p-dis-004 (Controlled Vocabulary Pair): MANDATORY/PROHIBITED tables define exact vocabulary. p-dis-006 (Verification-Signal Discipline): exit code signals "artifacts produced," not "test passed" — the two are distinct signals. |

## 9. Prompt Construction Mandate

Behavioral test prompts MUST trigger natural agent behavior — they MUST NOT interview the agent about what it *would* do. A prompt that asks the agent to describe, explain, or narrate a procedure tests prose recall, not actual behavior.

### The Interview/Natural-Behavior Spectrum

| Prompt Type | Classification | Example | Verdict |
|-------------|---------------|---------|---------|
| Real-domain task | Natural behavior | "Implement feature X from spec #42" | ✅ Valid |
| Real-domain bug | Natural behavior | "The login button doesn't work" | ✅ Valid |
| Real-domain question | Natural behavior | "What files does this function touch?" | ✅ Valid |
| "Describe how you would..." | Prose-recall (interview) | "Describe how you would handle authorization" | ❌ INVALID |
| "Explain the process for..." | Prose-recall (interview) | "Explain how you create a PR" | ❌ INVALID |
| "What would you do if..." | Prose-recall (interview) | "What would you do if a test fails?" | ❌ INVALID |
| "Walk me through..." | Prose-recall (interview) | "Walk me through your approach" | ❌ INVALID |

### Hard-Fail Rule

Any behavioral test that uses a prose-recall prompt (interview-style, "describe how you would", "explain the process", "what would you do", "walk me through") is **FAIL** — the test does not measure actual agent behavior. The test framework MUST reject such prompts at the evaluation stage.

### Valid Prompt Construction

Valid prompts are real-domain tasks that the agent would encounter in normal operation:

- **Implementation prompts:** "Implement SC-3 from spec #42" — triggers actual code writing
- **Bug report prompts:** "The parser crashes on empty input" — triggers actual debugging
- **Investigation prompts:** "Find all callers of function X" — triggers actual code search
- **Configuration prompts:** "Add a new environment variable for the API URL" — triggers actual config editing

The prompt must be something the agent would actually DO, not something it would DESCRIBE.

### Cross-References

- `080-code-standards.md` §Enforcement Test Mandate — behavioral tests are PRIMARY enforcement
- `091-incremental-build.md` §Behavioral Variant — "Prose-recall prompts are NOT accepted as behavioral tests"
- `executing-plans/tasks/start.md` — behavioral test prompt construction guidance
- `spec-creation/tasks/write.md` — behavioral test prompt construction guidance

---

*This specification replaces the previous inline-evaluation paradigm. All scripts must be artifact-only generators. No backward compatibility with assert_* functions or run-all.sh.*

---

## 10. Session Failure Diagnosis

When a behavioral test session fails (harness error, model timeout, or unexpected exit), use the diagnostic checklist below to identify the root cause before re-running.

### Diagnostic Checklist

| # | Check | Command / Method | Expected Outcome |
|---|-------|------------------|-----------------|
| 1 | Verify model availability | `opencode-cli models` | Target model is listed and reachable |
| 2 | Inspect artifact directory | `ls ./tmp/behavioral-evidence-<scenario>-<phase>-<model>/` | All mandatory files present (manifest.yaml, stdout.log, stderr.log, exit_code, session.yaml) |
| 3 | Check exit code | `cat ./tmp/behavioral-evidence-*/exit_code` | `0` (OK) — non-zero means harness failure |
| 4 | Read stderr for tool dispatch | `cat ./tmp/behavioral-evidence-*/stderr.log` | Tool calls dispatched as expected; no orphaned lock or timeout errors |
| 5 | Verify lock file not orphaned | `flock -x -w 1 tmp/.behavior-run.lock true` 2>/dev/null && echo "free" || echo "locked" | `free` — orphaned lock blocks all subsequent runs |
| 6 | Confirm test home is clean | `ls tmp/test-home-*/ 2>/dev/null` | No stale test home directories from prior aborted runs |

### Common Root Causes

| Cause | Symptom | Fix |
|-------|---------|-----|
| Orphaned `flock` from prior timeout-killed run | Check 5 shows `locked` | `rm -f tmp/.behavior-run.lock` and kill orphaned `opencode-cli` processes |
| Stale test home from aborted session | Check 6 shows multiple test homes | `bash .opencode/tests/with-test-home --clean-all` |
| Model not loaded / slow to load | Check 1 fails or times out | Pre-warm model: `opencode-cli run "ping" --model <model>` before test |
| Submodule commit not pushed | Test runs against stale submodule state | Push feature branch and set `BEHAVIOR_SUBMODULE_COMMIT=<sha>` |
| Bash tool timeout too short | Test killed by outer timeout, leaving orphaned lock | Set bash tool `timeout` parameter to ≥ 600000ms |

### Irrelevant Paths

The following paths are **not relevant** to test isolation failures and should not be investigated during session failure diagnosis:

- `~/.config/opencode/node_modules/` — Node.js dependencies for the opencode desktop app. These are unrelated to the test harness, which uses its own isolated XDG home via `with-test-home`. The presence or absence of `node_modules/` under `~/.config/opencode/` has no effect on test isolation, model dispatch, or artifact generation.
