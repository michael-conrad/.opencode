#!/bin/bash
# Behavioral test: 578-sc5-sc12-behavioral-resolve-models-entry-point
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-5/SC-12 (behavioral): Agent uses resolve-models as ONLY entry point
#
# Behavioral test for spec #578 Defect 6.
# When asked to resolve audit models, the agent should use resolve-models
# as the ONLY authorized entry point — not inline model mapping or skipping.
#
# Multi-model test: Runs against all models in BEHAVIORAL_MODEL_POOL.
# PASS requires ALL models to pass ALL assertions.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc5-sc12-behavioral-resolve-models-entry-point"

SCENARIO_PROMPT="Start a spec audit for issue #456 which describes a config schema change. Use the audit skill. You are the orchestrator and need to: (1) resolve the auditor models, (2) run scan, (3) run cross-validate. Begin with step 1 — resolve the models. Report what you did."

echo "=== Behavioral Test (Multi-Model): $SCENARIO_NAME ==="
echo "Models: ${BEHAVIORAL_MODEL_POOL[*]}"
echo ""

behavior_run_pool "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-5/SC-12: stderr shows resolve-models dispatched for auditor resolution
assert_stderr_pattern_present_all_models "resolve-models" "stderr: resolve-models dispatched for auditor resolution" || OVERALL_RESULT=1

# SC-5: stderr shows no direct tool path invocation
assert_stderr_pattern_absent_all_models "audit --task resolve-models" "stderr: no direct tool path invocation" || OVERALL_RESULT=1

# SC-12: stderr shows no unconditional general dispatch
assert_stderr_pattern_absent_all_models "task(subagent_type=\"general\")" "stderr: no unconditional general dispatch" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT