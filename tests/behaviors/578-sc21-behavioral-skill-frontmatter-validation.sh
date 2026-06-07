#!/bin/bash
# Behavioral test: 578-sc21-behavioral-skill-frontmatter-validation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-21 (behavioral): Agent discovers previously-broken skills in available_skills
#
# Behavioral test for spec #578 SC-21.
# SC-21: After frontmatter remediation, the AI agent can discover
# adversarial-audit, approval-gate, and completion-core in <available_skills>.
# These three skills previously had broken YAML frontmatter:
# - adversarial-audit: was missing --- opening delimiter (now fixed in this branch)
# - approval-gate: had no YAML frontmatter at all (now fixed in this branch)
# - completion-core: description didn't start with "Use when" (now fixed in this branch)
#
# The behavioral test asks the agent to list skills from <available_skills>
# and verifies that the previously-broken three are discoverable.
#
# Multi-model test: Runs against all models in BEHAVIORAL_MODEL_POOL.
# PASS requires ALL models to pass ALL assertions.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc21-behavioral-skill-frontmatter-validation"

SCENARIO_PROMPT="Read the <available_skills> section in your system prompt carefully. It lists all skills with their names, descriptions, and trigger keywords. Answer these numbered questions:

1. List every skill name from the available_skills section. Number them.
2. Specifically, do you see these three skills listed: adversarial-audit, approval-gate, completion-core? Answer yes or no for each.
3. What does each of those three skills' description start with? Quote the first few words of each description.
4. How many total skills are listed in available_skills?"

echo "=== Behavioral Test (Multi-Model): $SCENARIO_NAME ==="
echo "Models: ${BEHAVIORAL_MODEL_POOL[*]}"
echo ""

behavior_run_pool "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-21 ASSERTION 1: Agent must discover adversarial-audit in available_skills
# Previously broken: missing --- opening delimiter. Now fixed.
assert_required_pattern_present_all_models "adversarial-audit" "discovery of adversarial-audit in available_skills" || OVERALL_RESULT=1

# SC-21 ASSERTION 2: Agent must discover approval-gate in available_skills
# Previously broken: no YAML frontmatter at all. Now fixed with proper frontmatter.
assert_required_pattern_present_all_models "approval-gate" "discovery of approval-gate in available_skills" || OVERALL_RESULT=1

# SC-21 ASSERTION 3: Agent must discover completion-core in available_skills
# Previously broken: description didn't start with "Use when". Now fixed.
assert_required_pattern_present_all_models "completion-core" "discovery of completion-core in available_skills" || OVERALL_RESULT=1

# SC-21 ASSERTION 4: Agent must see descriptions starting with "Use when" for the fixed skills
# This verifies that the frontmatter description field is parsed and surfaced correctly.
assert_required_pattern_present_all_models "Use when" "description starts with Use when for fixed skill cards" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT