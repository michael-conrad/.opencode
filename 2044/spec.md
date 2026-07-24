---
number: 2044
title: "SPEC-FIX: behavior_run harness produces empty output — model dispatch timeout"
state: OPEN
---

## Problem

The `behavior_run` function in `.opencode/tests-v2/behaviors/helpers.sh` produces empty output when dispatched via `with-test-home opencode run`. The harness returns `exit_code: 1` with empty stdout and stderr, making behavioral tests unable to execute RED/GREEN cycles.

## Symptoms

- Behavioral tests fail immediately with no diagnostic output
- `behavior_run` returns exit code 1, empty stdout, empty stderr
- RED/GREEN cycles cannot execute — the harness never produces agent output to assert against
- Test failures are indistinguishable from infrastructure failures

## Affected File

`.opencode/tests-v2/behaviors/helpers.sh` — the `behavior_run` function

## Diagnosis

Ollama logs show 404 errors on `/v1/chat/completions` during the failing runs. The `behavior_run` function clones `.opencode` from remote (not local), so it cannot see unmerged feature branch changes. The 404 suggests the opencode CLI inside the test environment is routing API calls to an endpoint that ollama does not serve — likely an Ollama API version mismatch or the test environment's opencode binary is configured for a different API base URL.

Direct `with-test-home opencode run` (without the `behavior_run` wrapper) works correctly because it uses the production opencode binary and config, not the test environment's.

## Acceptance Criteria

- [ ] `behavior_run` produces non-empty stdout/stderr when the model is available
- [ ] `behavior_run` returns exit code 0 on successful model response
- [ ] Root cause of 404 on `/v1/chat/completions` identified and fixed
- [ ] Behavioral RED/GREEN cycles execute successfully through `behavior_run`