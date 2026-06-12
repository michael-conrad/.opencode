#!/usr/bin/env bash
# Behavioral test SC-11: plan state init + --contract-path enforces domain
set -euo pipefail

TOOL="$(cd "$(dirname "$0")/../../" && pwd)/tools/plan"

echo "=== SC-11: state init + --contract-path domain enforcement ==="

CONTRACT=$(mktemp /tmp/contract-sc11.XXXXXX.yaml)
python3 -c "
import yaml
with open('$CONTRACT', 'w') as f:
    yaml.dump({'variables': {'color': {'type': 'string', 'domain': ['red','green','blue']}}}, f)
"

STATE_DIR="/tmp/sc11-state-$$"
mkdir -p "$STATE_DIR"

# Init state
"$TOOL" state init "$STATE_DIR/" > /dev/null 2>&1 || {
    echo "FAIL: state init failed"
    rm -rf "$CONTRACT" "$STATE_DIR"
    exit 1
}

# Out-of-domain should be rejected
set +e
OUTPUT=$("$TOOL" state update "$STATE_DIR/" --var-name color --var-value purple --contract-path "$CONTRACT" 2>&1)
rc=$?
set -euo pipefail

if [ "$rc" -eq 0 ]; then
    echo "FAIL: out-of-domain value was accepted"
    rm -rf "$CONTRACT" "$STATE_DIR"
    exit 1
fi

echo "PASS: out-of-domain 'purple' rejected (exit=$rc)"

# In-domain should be accepted
set +e
OUTPUT=$("$TOOL" state update "$STATE_DIR/" --var-name color --var-value red --contract-path "$CONTRACT" 2>&1)
rc=$?
set -euo pipefail

if [ "$rc" -ne 0 ]; then
    echo "FAIL: in-domain value was rejected"
    rm -rf "$CONTRACT" "$STATE_DIR"
    exit 1
fi

echo "PASS: in-domain 'red' accepted"

rm -rf "$CONTRACT" "$STATE_DIR"
echo ""
echo "SC-11: ALL PASS"