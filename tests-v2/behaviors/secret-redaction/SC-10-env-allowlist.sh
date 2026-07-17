#!/bin/bash
# Structural verification: SC-10-env-allowlist
# Verifies that with-test-home uses env -i with the correct allowlist.
# Checks that the _run_isolated function contains all required variables.

set -euo pipefail

WITH_TEST_HOME=".opencode/tests-v2/with-test-home"
ERRORS=0

# Extract the _run_isolated function body
RUN_ISOLATED=$(sed -n '/^_run_isolated()/,/^}/p' "$WITH_TEST_HOME")

# Check env -i is used
if echo "$RUN_ISOLATED" | grep -q 'env -i'; then
    echo "PASS: env -i found in _run_isolated"
else
    echo "FAIL: env -i not found in _run_isolated"
    ERRORS=$((ERRORS + 1))
fi

# Check each required variable
REQUIRED_VARS=(
    "HOME"
    "PATH"
    "XDG_CONFIG_HOME"
    "XDG_CACHE_HOME"
    "XDG_RUNTIME_DIR"
    "XDG_DATA_HOME"
    "XDG_STATE_HOME"
    "SNAP_USER_DATA"
    "SNAP_USER_COMMON"
    "GIT_CONFIG_NOSYSTEM"
    "SHELL"
    "USER"
    "LOGNAME"
    "LANG"
    "TERM"
    "GB_TOKEN"
)

for var in "${REQUIRED_VARS[@]}"; do
    if echo "$RUN_ISOLATED" | grep -q "$var"; then
        echo "PASS: $var found in _run_isolated"
    else
        echo "FAIL: $var not found in _run_isolated"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check no forbidden vars
FORBIDDEN_VARS=(
    "GITHUB_TOKEN"
    "GH_TOKEN"
    "OPENCODE_CONFIG_CONTENT"
    "NODE_ENV"
    "VIRTUAL_ENV"
    "CONDA_DEFAULT_ENV"
)

for var in "${FORBIDDEN_VARS[@]}"; do
    if echo "$RUN_ISOLATED" | grep -q "$var"; then
        echo "FAIL: forbidden var $var found in _run_isolated"
        ERRORS=$((ERRORS + 1))
    else
        echo "PASS: forbidden var $var not found in _run_isolated"
    fi
done

if [ "$ERRORS" -gt 0 ]; then
    echo "FAIL: $ERRORS errors found"
    exit 1
fi

echo "PASS: all allowlist checks passed"
exit 0
