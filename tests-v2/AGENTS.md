# Behavioral Test Harness Specification (v2)

**Artifact-Only Generator Paradigm**

Every behavioral test script generates model-run artifacts and exits 0. Evaluation is the orchestrator's job — scripts NEVER evaluate model output.

> **MANDATORY: Bash tool timeout MUST be >= 600 seconds when running behavioral tests.**
> No `timeout` command inside scripts (nested timeouts create orphaned processes).
> See §Infrastructure Details — Bash Tool Timeout Mandate.

## Key Differences from v1

| Aspect | v1 (`.opencode/tests/`) | v2 (`.opencode/tests-v2/`) |
|--------|------------------------|----------------------------|
| CLI binary | `opencode-cli` | `opencode` (resolved from PATH) |
| Model discovery | `opencode-cli models` | `opencode models` |
| Test runner | `with-test-home` (v1) | `with-test-home` (v2, rewritten) |
| Env isolation | Partial `env` passthrough | `env -i` with explicit allowlist |
| Smoke tests | Optional | Mandatory (`opencode models` + `opencode run "hello world"`) |
| Test project | Flat test home | `{test_home}/project/` with `git init` + local `.opencode` checkout |

## Table of Contents

1. [Paradigm: Artifact-Only Generators](#1-paradigm-artifact-only-generators)
2. [Artifact Directory Structure](#2-artifact-directory-structure)
3. [Writing a New Behavioral Test](#3-writing-a-new-behavioral-test)
4. [Running Tests](#4-running-tests)
5. [Infrastructure Details](#5-infrastructure-details)
6. [Relationship to Content-Verification Tests](#6-relationship-to-content-verification-tests)
7. [Cleanup](#7-cleanup)
8. [Triple Co-Application Reference](#8-triple-co-application-reference)
9. [Change Control](#9-change-control)
10. [Testing Lessons Learned — Failure Patterns and Remediation](#10-testing-lessons-learned--failure-patterns-and-remediation)
11. [Prompt Construction Mandate](#11-prompt-construction-mandate)
12. [Self-Contained GitBucket Container for Remote API Tests](#12-self-contained-gitbucket-container-for-remote-api-tests)

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

### Evaluation Source: `session.yaml` (SQLite DB Export) is PRIMARY

**All behavioral SC evaluation MUST use `session.yaml` (the SQLite DB export) as the PRIMARY evidence source.** The `event` table in the SQLite DB records every tool call, reasoning step, and text part in chronological order — this is the authoritative record of what the agent actually did.

`stdout.log` contains only agent prose (chat output). `stderr.log` contains only the `TEST_HOME=<path>` marker for DB discovery. Neither is a reliable source for tool dispatch verification.

**Assertion helpers that grep stderr or stdout (`assert_stderr_pattern_present`, `assert_required_pattern_present`, `assert_forbidden_pattern_absent`, `assert_tool_calls_made`, `assert_skill_called`, `assert_no_skill_called`) are FORBIDDEN for behavioral SC evaluation.** They operate on the wrong data source. All behavioral evaluation MUST use `session.yaml` via clean-room sub-agent inspection.

The `session-to-timeline` tool at `.opencode/tools/session-to-timeline` processes `session.yaml` into a condensed timeline of tool calls for evaluation. Use this for structured analysis of agent actions.

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
| `session.yaml` | SQLite DB → YAML export of the `event` table (tool calls, reasoning, text parts in chronological order) | **PRIMARY** evaluation source — all agent actions and decisions |
| `stdout.log` | Agent prose response (captured from `with-test-home` stdout) | Secondary — prose output only |
| `stderr.log` | `with-test-home` diagnostics including `TEST_HOME=<path>` for DB discovery | Infrastructure — DB path discovery only |
| `exit_code` | Numeric exit code from model run (0=OK, 1=harness failure) | Pipeline orchestration |

### Evaluation Source: `session.yaml` (SQLite DB Export) is PRIMARY

**`session.yaml` is the PRIMARY and ONLY reliable source for evaluating agent behavior.** It contains the full `event` table export — every tool call, reasoning step, and text part in chronological order with timestamps. This is the authoritative record of what the agent actually did.

`stdout.log` contains only the agent's prose response (what it wrote to chat). It is NOT a reliable source for tool dispatch verification — tool calls are recorded in the SQLite `event` table, not in stdout. `stderr.log` contains only the `TEST_HOME=<path>` marker used to discover the SQLite DB path.

**Assertion helpers that grep stderr or stdout (`assert_stderr_pattern_present`, `assert_required_pattern_present`, etc.) are FORBIDDEN for behavioral SC evaluation.** They operate on the wrong data source. All behavioral evaluation MUST use `session.yaml` (the SQLite DB export) via clean-room sub-agent inspection.

### `session.yaml` Export Mechanism

The `__export_sqlite_to_yaml` function in `helpers.sh` discovers the test home SQLite DB by parsing `TEST_HOME=<path>` from stderr (emitted by `with-test-home`), then exports all tables to JSON/YAML. The `session-to-timeline` tool further processes this into a condensed timeline of tool calls for evaluation.

If `session.yaml` contains `source_db: MISSING`, the SQLite DB was not found in the test home. This is a **hard FAIL** — the test environment is broken. Do NOT hunt for the DB elsewhere, do NOT substitute with stderr/stdout grep, do NOT synthesize or fabricate data. The only recovery mechanism is to verify the test does not violate clean-room separation mandates: the test must use a dedicated test home directory with the test project inside it, and `with-test-home` must emit `TEST_HOME=<path>` to stderr.

## 3. Writing a New Behavioral Test

### Step 0: Create Fixture Issues (MANDATORY if test references issue content)

If the test prompt references a spec, plan, or any issue content (e.g., `.issues/2211/spec.md`), the test MUST have corresponding fixture files in `fixtures/issues/{N}/`. The harness auto-injects all fixture issue directories into the test repo's `.issues/` directory via `setup_fixture_issues()`.

**Fixture creation procedure:**

1. Create the fixture directory: `mkdir -p .opencode/tests-v2/behaviors/fixtures/issues/{N}/`
2. Copy the spec, plan, and any other files the test needs:
   ```bash
   cp .opencode/.issues/{N}/spec.md .opencode/tests-v2/behaviors/fixtures/issues/{N}/
   cp .opencode/.issues/{N}/plan.md .opencode/tests-v2/behaviors/fixtures/issues/{N}/
   ```
3. The harness injects these into the test repo at `.issues/{N}/` (flat path) and `.issues/open/{N}/` (open directory).

**🚫 FORBIDDEN:** Writing a test that references issue content without creating fixture files. The test will fail at runtime because the issue directory doesn't exist in the isolated test environment.

**✅ REQUIRED:** Every test that references `.issues/{N}/` paths in its prompt MUST have corresponding fixture files. The prompt path MUST use `.issues/{N}/` (the root-level path injected by fixtures), NOT `.opencode/.issues/{N}/` (the submodule path which is not injected).

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
DEFAULT_TEST_MODEL="ollama/other-model:tag" \
BEHAVIOR_PHASE="RED" \
bash .opencode/tests-v2/behaviors/<scenario>.sh
```

**⚠️ `DEFAULT_TEST_MODEL` override requires the feature branch to be pushed to remote.** The test harness clones `.opencode/` from remote and checks out the local submodule HEAD commit. If the feature branch changes (including `seed_model_config()` fixes) are not pushed, the harness uses the remote default branch which has the old code. The `seed_model_config()` function in `with-test-home` dynamically interpolates `$default_model` into the `opencode.jsonc` `model` field — this fix was applied in commit `f5c66371`. Without it, the `model` field was hardcoded to `ollama/ornith:35b-256k` regardless of `DEFAULT_TEST_MODEL`.

**🚫 FORBIDDEN:** Asking the developer for authorization to push test framework fixes. Test framework changes that fix broken behavior are not implementation — they are infrastructure maintenance. The agent commits and pushes autonomously. The earlier pattern of asking "authorize push?" for a test harness bugfix was a routing-bypass self-authorization violation.

## 5. Infrastructure Details

### Binary

- **`opencode`** is copied from `.tools/opencode/opencode` into `$TEST_HOME/bin/opencode` by `with-test-home`. The `OPENCODE_CMD` variable is set to `("$TEST_HOME/bin/opencode")` — the test-home path, never a prod path.
- **NEVER resolve from PATH** — `command -v opencode` may find `/snap/bin/opencode` which hardcodes `SNAP_USER_DATA=~/snap/opencode/` and leaks production state.
- **NEVER hardcode `/snap/bin/opencode`** — the snap wrapper ignores `$HOME` and writes to the production SQLite DB.

**Why copy instead of PATH resolution:** The snap wrapper at `/snap/bin/opencode` → `/usr/bin/snap` ignores `$HOME` and hardcodes `SNAP_USER_DATA=~/snap/opencode/`, which leaks production state into test environments. Copying the standalone binary into the test home ensures the test uses the correct binary with the test home's `SNAP_USER_DATA` override.

**If the binary location changes**, update the `STANDALONE_BINARY` path in `with-test-home` and the test runner scripts.

### `with-test-home` — Fully Isolated Test Runner

**MUST be used for ALL opencode testing.** Never run `opencode run` directly — it causes SQLite session conflicts with the desktop app and leaks production state.

The wrapper creates an isolated temporary home directory (`tmp/test-home-<timestamp>`) with clean XDG state and runs commands inside a `env -i` subshell.

#### Environment Variable Isolation

Uses `env -i` with an explicit allowlist. Only these variables are passed through:

| Variable | Source | Purpose |
|----------|--------|---------|
| `HOME` | Set to test home | Isolates snap data, XDG state, and all home-directory config |
| `PATH` | Parent env | Allows opencode and other tools to be found |
| `XDG_CONFIG_HOME` | Set to test home | Isolates opencode config |
| `XDG_CACHE_HOME` | Set to test home | Isolates cache |
| `XDG_RUNTIME_DIR` | Set to test home | Isolates runtime files |
| `XDG_DATA_HOME` | Set to test home | Isolates data (SQLite DB, repos) |
| `XDG_STATE_HOME` | Set to test home | Isolates state (locks) |
| `SNAP_USER_DATA` | Set to test home | Overrides snap's hardcoded `~/snap/opencode/` to prevent production DB pollution |
| `SNAP_USER_COMMON` | Set to test home | Overrides snap's common data directory |
| `GIT_CONFIG_NOSYSTEM` | `1` | Prevents system git config from leaking |
| `SHELL` | Parent env | Required by some tools |
| `USER` | Set to `opencode-test-user` | Test identity |
| `LOGNAME` | Set to `opencode-test-user` | Test identity (hardcoded, not parent env leak) |
| `LANG` | Parent env | Locale |
| `TERM` | Parent env | Terminal type |
| `GB_TOKEN` | Parent env (if set) | GitBucket API token |

**FORBIDDEN** — no `GITHUB_TOKEN`, `GH_TOKEN`, `OPENCODE_CONFIG_CONTENT`, `NODE_ENV`, `VIRTUAL_ENV`, `CONDA_DEFAULT_ENV`, or shell-specific vars.

#### Working Directory

The command runs from `TEST_PROJECT` (the test project directory inside the test home). This ensures opencode discovers the test project's `.opencode/` as its project root, not the production project's.

#### Submodule Checkout

`.opencode/` is cloned from the remote URL (not `cp -a` from the parent repo). After cloning, the test harness checks out the same commit as the local `.opencode` submodule HEAD to pick up feature branch changes. If the commit is not pushed to remote, a WARNING is emitted and the remote default branch is used instead.

**Feature branch changes MUST be pushed to remote before running tests.** The clone from remote ensures the test environment has a clean git history and proper submodule state.

#### Model Config Generation

`seed_model_config()` generates a minimal `opencode.jsonc` with:
- `"model": "$default_model"` — uses `DEFAULT_TEST_MODEL` env var (falls back to `ollama/qwen3.6:35b-256k`). This is the single source of truth for which model runs the test.
- `"models": { "$bare": {} }` — only the requested model is registered. No hardcoded model entries.

The `model` field MUST match the `DEFAULT_TEST_MODEL` value. Previously the function hardcoded `"model": "ollama/ornith:35b-256k"` regardless of `DEFAULT_TEST_MODEL`, which caused behavioral tests to always attempt loading ornith (21GB) even when a smaller model was requested via env var. This is now fixed — the `model` field is dynamically interpolated from `$default_model`.

It does NOT copy the production `opencode.jsonc` — that file contains secrets, API keys, and environment-specific settings that must not leak into test environments.

#### uv/uvx Copy

`do_setup()` copies `uv` and `uvx` from `.tools/uv/` into `$TEST_HOME/bin/` so opencode can use them for Python-based plugin operations (e.g., vibeguard plugin npm installs). If `uv` is not found at `.tools/uv/uv`, the script exits with a FATAL error.

#### set-env.sh Debugging Aid

`do_setup()` writes `set-env.sh` into `$TEST_HOME/` with all `env -i` variables for debugging. This allows reproducing the test environment outside the harness:

```bash
source $TEST_HOME/set-env.sh
```

The file includes: HOME, PATH, XDG_CONFIG_HOME, XDG_CACHE_HOME, XDG_RUNTIME_DIR, XDG_DATA_HOME, XDG_STATE_HOME, SNAP_USER_DATA, SNAP_USER_COMMON, USER, GIT_CONFIG_NOSYSTEM, SHELL, LOGNAME, LANG, TERM, GB_TOKEN, GB_HOST, GITBUCKET_PORT.

#### SQLite DB Export on Timeout

`__export_sqlite_to_yaml()` in `helpers.sh` searches both stdout and stderr for `TEST_HOME=<path>` to discover the SQLite DB. Previously it only searched stdout — when a behavioral test timed out, stdout was empty and the export produced `source_db: MISSING`. Now it falls back to stderr, which always contains the `TEST_HOME=` marker emitted by `with-test-home`.

#### Isolation Verification Procedure

After running `with-test-home --setup`, verify isolation by inspecting the SQLite DB:

```bash
sqlite3 $TEST_HOME/.local/share/opencode/opencode.db "SELECT worktree FROM project;"
# Expected: /path/to/tmp/test-home-<timestamp>/project
# NOT:      /home/user/git/production-project
```

The `project.worktree` field MUST contain the test project path (under `tmp/test-home-*`), not the production project path. If it contains the production path, isolation is broken.

### Test Environment Setup Steps

1. Create test home directory at `{project_root}/tmp/test-home-{timestamp}`
2. Set `HOME` and all XDG vars to test home paths
3. Set `SNAP_USER_DATA`/`SNAP_USER_COMMON` to test home paths (overrides snap's hardcoded `~/snap/opencode/`)
4. Set `PATH` to parent env PATH only
5. Create test sub-folder: `{test_home}/project/`
6. `git init` the test sub-folder
7. Clone `.opencode/` from remote, then checkout local submodule commit
8. Copy standalone binary from `.tools/opencode/opencode` to `$TEST_HOME/bin/opencode`
9. Copy `uv` and `uvx` from `.tools/uv/` to `$TEST_HOME/bin/`
10. Write `set-env.sh` into test home with all `env -i` variables
11. Seed `opencode.jsonc` config with `model` set to `DEFAULT_TEST_MODEL` (dynamic, not hardcoded)
12. Run `opencode models` to verify CLI works (smoke test)
13. Run `opencode run "hello world"` to verify model works (smoke test)

### Smoke Test Requirements

Both smoke tests MUST pass before the test home is considered ready:
- `opencode models` must return at least one `ollama/` model
- `opencode run "hello world"` must produce non-empty output without errors

### Concurrency Lock — `flock`

The harness uses `flock` (file lock) for mutual exclusion. A lock file at `tmp/.behavior-run.lock` is acquired via `flock -x -w 30` before the model run.

### Bash Tool Timeout Mandate — ZERO TOLERANCE

**The bash tool's `timeout` parameter is the ONLY kill signal that may be used when running behavioral tests.** Any use of the `timeout` command (GNU timeout) inside a bash script invoked by the bash tool is FORBIDDEN — nested timeouts create orphaned processes that hold the flock lock and hang all subsequent test runs.

**Mandated bash tool invocation:**
```
# timeout=600000 (600 seconds, milliseconds). NEVER omit.
```

### Timeout Export Procedure — MANDATORY

When a behavioral test times out (bash tool kills the script), the agent MUST NOT retry blindly. Instead:

1. **Locate the test home directory** — the most recent `tmp/test-home-{timestamp}/` directory. The test harness creates one per run.
2. **Export the SQLite DB** — the DB survives the timeout. Export it to the artifact directory:
   ```bash
   mkdir -p tmp/behavioral-evidence-{scenario}-{phase}-{model}/
   python3 -c "
   import json, sqlite3
   db = 'tmp/test-home-{timestamp}/.local/share/opencode/opencode.db'
   conn = sqlite3.connect(db)
   conn.row_factory = sqlite3.Row
   c = conn.cursor()
   c.execute('SELECT * FROM event ORDER BY id')
   events = [dict(r) for r in c.fetchall()]
   result = {'source_db': db, 'harness_version': 1, 'tables': {'event': {'columns': ['id','aggregate_id','seq','type','data'], 'rows': events}}}
   with open('tmp/behavioral-evidence-{scenario}-{phase}-{model}/session.yaml', 'w') as f:
       json.dump(result, f, indent=2, default=str)
   "
   ```
3. **Inspect the agent's reasoning** — read the `message.part.updated.1` events from the exported session.yaml. The agent's text parts show what it was doing, what it found, and where it was when the timeout hit.
4. **Check tool calls** — if the agent made tool calls (read, grep, skill, task), the behavior is being tested. The timeout is a model speed issue, not a test defect.
5. **Adjust the prompt or fixtures** based on what the agent was doing at timeout:
   - If the agent was still reading/planning with zero tool calls → prompt is too complex, simplify it
   - If the agent was verifying SCs and found the right things → behavior is correct, timeout is just model speed
   - If the agent was going in the wrong direction → fix the prompt or fixtures
6. **Document the finding** — if the exported session.yaml shows correct behavior, that IS the behavioral evidence. The timeout does not invalidate the evidence the agent produced up to that point.

**🚫 FORBIDDEN:** Retrying the same test with the same model and same timeout expecting a different result. If the model is too slow for the prompt complexity, either simplify the prompt or use a faster model. Do not burn compute cycles on the same failing configuration.

### Test Isolation Mandates — ZERO TOLERANCE

The following mandates are non-waivable. Violation = pipeline halt.

| # | Mandate | Enforcement |
|---|---------|-------------|
| 1 | **`snap run` is FORBIDDEN** — `snap run opencode` hardcodes `SNAP_USER_DATA=~/snap/opencode/` and writes to the production DB. The only acceptable reference to `snap run` is as a forbidden pattern example in comments. | grep for `snap run` in executable code returns 0 matches |
| 2 | **`/snap/bin/opencode` is FORBIDDEN** — never hardcode the binary path. Always resolve `opencode` from PATH. | grep for `/snap/bin/opencode` returns 0 matches |
| 3 | **`timeout` command (GNU timeout) is FORBIDDEN** in test scripts. The bash tool `timeout` parameter is the ONLY kill signal. | grep for `^timeout ` in test scripts returns 0 matches |
| 4 | **`USER=opencode-test-user` MUST be set** in the test environment. Tests must use a non-production user identity. | grep for `opencode-test-user` in `with-test-home` returns match |
| 5 | **Default model MUST NOT be changed** without an approved spec. `DEFAULT_TEST_MODEL` in `default-model.sh` is the single source of truth. | grep for model strings outside `default-model.sh` returns 0 matches |
| 6 | **Smoke test is MANDATORY** — `opencode models` + `opencode run "hello world"` must pass before the test home is considered ready. | `do_setup()` in `with-test-home` runs both |
| 7 | **Isolation verification is MANDATORY** — after warmup, verify test home only contains opencode config/db/log files and production DB is untouched (sha256 comparison). | `do_setup()` in `with-test-home` runs isolation check |

### Invocation Examples

```bash
# Run a single test message
bash .opencode/tests-v2/with-test-home opencode run "hello" --model ollama/qwen3.6:35b-256k

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

## 9. Change Control

### Default Model

The default test model is defined in `default-model.sh` as `DEFAULT_TEST_MODEL`. This is the single source of truth — do not embed model strings elsewhere.

**DO NOT CHANGE the default model unless explicitly directed to do so by an approved spec.** The default model (`ollama/qwen3.6:35b-256k`) is verified to work with the test harness. Changing it without a spec risks:
- Breaking tests that depend on model behavior
- Introducing model-specific flakiness
- Circumventing the spec-first workflow

If a spec requires a different model, override via environment variable:
```bash
DEFAULT_TEST_MODEL="ollama/other-model:tag" bash .opencode/tests-v2/behaviors/<scenario>.sh
```

### Binary Resolution

`opencode` is copied from `.tools/opencode/opencode` into `$TEST_HOME/bin/opencode` by `with-test-home`. **DO NOT resolve from PATH** — `command -v opencode` may find `/snap/bin/opencode` which ignores `$HOME` and leaks production state. If the binary location changes, update the `STANDALONE_BINARY` path in `with-test-home` and the test runner scripts.

### Isolation Requirements

The isolation contract (environment variables, working directory, submodule checkout, model config generation, binary copy, uv/uvx copy, set-env.sh) is defined in §5. **DO NOT change isolation requirements without an approved spec.** Changes to the `env -i` allowlist, `HOME`/`SNAP_USER_DATA` handling, binary resolution, or submodule checkout pattern can silently break isolation and leak production state.

## 10. Testing Lessons Learned — Failure Patterns and Remediation

This section documents failure patterns discovered during implementation of #2170/#2172/#2173/#2175. These are mandatory reading for any agent running behavioral tests.

### 10.1 Stale Lock Contention

**Symptom:** `HARNESS_FAILURE: lock contention — another test is running (waited 30s)`

**Root cause:** A prior `behavior_run()` invocation was killed (bash tool timeout, SIGTERM, or crash) before releasing the `flock` at `tmp/.behavior-run.lock`. The lock file remains on disk with no process holding it, but the next test attempt sees the file and waits 30s before failing.

**Remediation:**
```bash
rm -f tmp/.behavior-run.lock
```
Then re-run the test. Always clean stale locks before re-running.

**Prevention:** The lock file is advisory — it does not auto-expire. Always run `bash .opencode/tests-v2/with-test-home --clean-all` between test sessions to clean up stale state.

### 10.2 Bash Tool Timeout (Default 120s Kills 35B Models)

**Symptom:** `HARNESS_FAILURE: behavior_run produced empty output after all retries` — stdout is empty, stderr has only `TEST_HOME=<path>`.

**Root cause:** The bash tool's default timeout is 120s (120000ms). A 35B model takes 5-10 minutes to produce a response for a cleanup workflow. The bash tool kills the script before the model finishes, producing empty stdout. The retry logic sees empty output and retries, but the same timeout kills it again.

**Remediation:**
```bash
# ALWAYS pass timeout=600000 (600 seconds) when running behavioral tests
bash .opencode/tests-v2/behaviors/<scenario>.sh
# ^ bash tool MUST have timeout: 600000
```

**Evidence check:** Even when the bash tool kills the script, the SQLite DB in the test home contains the partial session data. Export it manually:
```bash
TEST_HOME=$(grep '^TEST_HOME=' tmp/behavioral-evidence-<scenario>-<phase>-<model>/stderr.log | sed 's/^TEST_HOME=//')
python3 -c "
import json, sqlite3
db = '$TEST_HOME/.local/share/opencode/opencode.db'
conn = sqlite3.connect(db)
conn.row_factory = sqlite3.Row
c = conn.cursor()
c.execute('SELECT * FROM event ORDER BY id')
events = [dict(r) for r in c.fetchall()]
result = {'source_db': db, 'harness_version': 1, 'tables': {'event': {'columns': ['id','aggregate_id','seq','type','data'], 'rows': events}}}
with open('tmp/behavioral-evidence-<scenario>-<phase>-<model>/session.yaml', 'w') as f:
    json.dump(result, f, indent=2, default=str)
"
```
This exports the SQLite DB even when the test was killed mid-run, allowing evaluation of partial output.

### 10.3 Missing session.yaml Export (stderr Fallback)

**Symptom:** Artifact directory has `stdout.log`, `stderr.log`, `manifest.yaml`, `exit_code` but NO `session.yaml`. The `__export_sqlite_to_yaml()` function produced `source_db: MISSING`.

**Root cause:** `__export_sqlite_to_yaml()` in `helpers.sh` searches stdout for `TEST_HOME=<path>`. When the bash tool kills the script (timeout), stdout is empty. The function reports `source_db: MISSING`. The fix (applied in #2182) adds stderr fallback — `with-test-home` always emits `TEST_HOME=<path>` to stderr.

**Remediation (pre-fix):** Manually export the SQLite DB using the procedure in §10.2.

**Remediation (post-fix):** The `__export_sqlite_to_yaml()` function now searches stderr when stdout is empty. If `session.yaml` is still missing, the test home may have been cleaned. Check `ls tmp/test-home-*/` for the test home directory.

### 10.4 Fabricated Model Excuses — ABSOLUTE PROHIBITION

**Symptom:** Agent reports "model timed out", "model too large", "model not available", or "model unavailability" as justification for skipping a behavioral test or reporting it as PASS without running it.

**Root cause:** The agent fabricates model excuses instead of diagnosing the actual failure (stale lock, bash tool timeout, missing stderr fallback). This is a CRITICAL VIOLATION of verification honesty.

**Prohibition:** An agent MUST NOT claim model unavailability, model timeout, or model incompatibility without tool-call evidence. The remediation-first protocol applies:
1. Check for stale lock: `ls -la tmp/.behavior-run.lock`
2. Check bash tool timeout: verify `timeout` parameter >= 600000ms
3. Check stderr for `TEST_HOME=<path>` — the model DID run, the harness just couldn't capture output
4. Manually export SQLite DB from test home (see §10.2)
5. Only after ALL remediation attempts fail may the agent report FAIL with evidence of each attempt

**Evidence that the model works:** The model (qwen3.6:35b-256k) is verified to work with the test harness. It produces valid output for cleanup workflows in 5-10 minutes. Any claim that it "doesn't work" or "is too large" is a fabrication unless backed by tool-call evidence.

### 10.5 Post-Timeout Recovery Procedure

When a behavioral test times out (bash tool kills the script), follow this procedure:

1. **Locate the artifact directory:**
   ```bash
   ls -lt tmp/behavioral-evidence-<scenario>-*/
   ```

2. **Extract TEST_HOME from stderr:**
   ```bash
   TEST_HOME=$(grep '^TEST_HOME=' tmp/behavioral-evidence-<scenario>-<phase>-<model>/stderr.log | sed 's/^TEST_HOME=//')
   ```

3. **Verify the SQLite DB exists:**
   ```bash
   ls -la "$TEST_HOME/.local/share/opencode/opencode.db"
   ```

4. **Export session.yaml manually:**
   ```bash
   python3 -c "
   import json, sqlite3
   db = '$TEST_HOME/.local/share/opencode/opencode.db'
   conn = sqlite3.connect(db)
   conn.row_factory = sqlite3.Row
   c = conn.cursor()
   c.execute('SELECT * FROM event ORDER BY id')
   events = [dict(r) for r in c.fetchall()]
   result = {'source_db': db, 'harness_version': 1, 'tables': {'event': {'columns': ['id','aggregate_id','seq','type','data'], 'rows': events}}}
   with open('tmp/behavioral-evidence-<scenario>-<phase>-<model>/session.yaml', 'w') as f:
       json.dump(result, f, indent=2, default=str)
   "
   ```

5. **Evaluate the partial output:** The session.yaml contains all tool calls and reasoning up to the point of timeout. This is valid evidence for evaluating agent behavior — the agent's decisions up to the timeout are observable.

6. **Clean up and re-run with longer timeout:**
   ```bash
   rm -f tmp/.behavior-run.lock
   bash .opencode/tests-v2/with-test-home --clean-all
   # Re-run with timeout=900000 (900 seconds) in the bash tool
   ```

## 11. Prompt Construction Mandate

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

---

## 12. Self-Contained GitBucket Container for Remote API Tests

Tests that need to verify remote API behavior (e.g., verifying labels on a remote issue after creation) can opt in to a self-contained GitBucket instance provisioned by the test harness.

### Opt-In Flag

Set `BEHAVIOR_NEEDS_REMOTE=1` in the test script before calling `behavior_run()`:

```bash
BEHAVIOR_NEEDS_REMOTE=1 behavior_run "scenario-name" "prompt"
```

### Lifecycle

1. **Provisioning** (`__ensure_gitbucket()` in `helpers.sh`):
   - JDK downloaded to `.tools/jdk/` (Eclipse Temurin 21 JRE) on first call, cached
   - GitBucket JAR downloaded to `.tools/gitbucket/gitbucket.war` on first call, cached
   - GitBucket started on auto-assigned port (`--port=0`)
   - Port discovered from `tmp/gitbucket-data/PORT` file
   - Admin token generated via API, set as `GB_TOKEN` env var
   - Test repo created and wired as test project's `origin` remote
2. **Reset** (`__reset_gitbucket()`): kills process, deletes data dir, re-starts fresh
3. **Cleanup** (`--clean-all`): kills GitBucket process, preserves `.tools/` cache

### Environment Variables

| Variable | Set By | Purpose |
|----------|--------|---------|
| `BEHAVIOR_NEEDS_REMOTE` | Test script | Opt-in flag (set to `1` to enable) |
| `GITBUCKET_PORT` | `__ensure_gitbucket()` | Auto-assigned port number |
| `GB_TOKEN` | `__ensure_gitbucket()` | GitBucket admin API token |

### State Files

| File | Purpose |
|------|---------|
| `tmp/.gitbucket.pid` | GitBucket process PID |
| `tmp/.gitbucket.port` | Auto-assigned port number |
| `tmp/gitbucket-data/` | GitBucket data directory (ephemeral) |

### Cached Artifacts (Preserved Across Sessions)

| Path | Content |
|------|---------|
| `.tools/jdk/` | Eclipse Temurin 21 JRE |
| `.tools/gitbucket/gitbucket.war` | GitBucket WAR file |

### Clean State Between Tests

Call `__reset_gitbucket()` between test scenarios to ensure clean state:

```bash
__reset_gitbucket  # kills process, deletes data dir, re-starts
```

The `--clean-all` flag in `with-test-home` kills the GitBucket process and removes data dirs but preserves `.tools/` cache for reuse across sessions.
