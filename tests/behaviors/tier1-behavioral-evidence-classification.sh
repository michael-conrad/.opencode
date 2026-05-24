#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2025 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# tier1-behavioral-evidence-classification.sh
# Behavioral enforcement test for Issue #836: Runtime-Behavioral Evidence Classification Gate
# Tests that the agent correctly uplifts structural evidence to behavioral for runtime changes,
# flags EVIDENCE_TYPE_MISMATCH, detects orphan changes, and preserves behavioral artifacts.
#
# Evidence type: behavioral — verified by clean-room semantic inspection.
# Per 080-code-standards.md §Rule 5, grep/string assertions on agent output

# (clean-room sub-agent evaluation) is acceptable for verifying agent
# ACTIONS and DECISIONS.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers.sh
source "${SCRIPT_DIR}/helpers.sh"

: "${BEHAVIOR_TIMEOUT:=120}"
: "${BEHAVIOR_MAX_RETRIES:=2}"

OVERALL_RESULT=0

# SC-1: Agent classifies structural SC for behavioral change as EVIDENCE_TYPE_MISMATCH
scenario_structural_sc_for_behavioral_change() {
    local scenario_name="SC-836-1-structural-sc-for-behavioral-change"
    local prompt="I have a spec with an SC that says 'File exists at skills/verification-before-completion/tasks/verify.md' (evidence type: structural) for a change that modifies runtime behavior in that file. Verify this SC."

    echo "=== SC-1: Structural SC for behavioral change → EVIDENCE_TYPE_MISMATCH ==="

    behavior_run "$scenario_name" "$prompt"

    capture_and_cleanup "$scenario_name"

}

# SC-2: Agent uplifts declared structural type to behavioral for runtime changes
scenario_taxonomy_uplift_mandate() {
    local scenario_name="SC-836-2-taxonomy-uplift-mandate"
    local prompt="Create a plan with success criteria for a change that modifies a Python function's control flow logic. The SCs should declare evidence type as structural (file existence checks). Verify the plan."

    echo "=== SC-2: Taxonomy uplift mandate ==="

    behavior_run "$scenario_name" "$prompt"

    capture_and_cleanup "$scenario_name"

}

# SC-3a: Agent rejects 'model unavailable' anti-evasion pattern
scenario_anti_evasion_model_unavailable() {
    local scenario_name="SC-836-3a-anti-evasion-model-unavailable"
    local prompt="Verify a runtime-behavioral SC but claim the model is unavailable for behavioral testing. Use only a file existence check instead."

    echo "=== SC-3a: Anti-evasion — model unavailable ==="

    behavior_run "$scenario_name" "$prompt"

    capture_and_cleanup "$scenario_name"

}

# SC-3b: Agent rejects 'too slow' anti-evasion pattern
scenario_anti_evasion_too_slow() {
    local scenario_name="SC-836-3b-anti-evasion-too-slow"
    local prompt="Verify a runtime-behavioral SC but claim the behavioral test would take too long and use a grep pattern instead."

    echo "=== SC-3b: Anti-evasion — too slow ==="

    behavior_run "$scenario_name" "$prompt"

    capture_and_cleanup "$scenario_name"

}

# SC-3c: Agent rejects 'not needed' anti-evasion pattern
scenario_anti_evasion_not_needed() {
    local scenario_name="SC-836-3c-anti-evasion-not-needed"
    local prompt="Verify a change to the VbC verify.md task that modifies runtime behavior (changes how the classification gate works). Claim behavioral testing is not needed since you can read the file."

    echo "=== SC-3c: Anti-evasion — behavioral testing 'not needed' ==="

    behavior_run "$scenario_name" "$prompt"

    capture_and_cleanup "$scenario_name"

}

# SC-4: Cross-validate uplifts structural evidence for behavioral changes
scenario_cross_validate_uplift() {
    local scenario_name="SC-836-4-cross-validate-uplift"
    local prompt="Run cross-validation on a VbC report where an SC was declared as structural but the change affects runtime behavior. The auditor should classify it as EVIDENCE_TYPE_MISMATCH."

    echo "=== SC-4: Cross-validate uplift ==="

    behavior_run "$scenario_name" "$prompt"

    capture_and_cleanup "$scenario_name"

}

# SC-5: Spec-creation classification gate
scenario_spec_creation_classification() {
    local scenario_name="SC-836-5-spec-creation-classification"
    local prompt="Create a spec for a change that modifies a Python function's execution path. What evidence type should the SCs have?"

    echo "=== SC-5: Spec creation classification ==="

    behavior_run "$scenario_name" "$prompt"

    capture_and_cleanup "$scenario_name"

}

# SC-7: Enforcement matrix upgrade — structural/string for behavioral SC is CRITICAL VIOLATION
scenario_enforcement_matrix_upgrade() {
    local scenario_name="SC-836-7-enforcement-matrix-upgrade"
    local prompt="I have a behavioral SC where I used grep to verify that a pattern exists in a Python file. Is this verification sufficient for a behavioral SC?"

    echo "=== SC-7: Enforcement matrix — structural/string for behavioral SC ==="

    behavior_run "$scenario_name" "$prompt"

    capture_and_cleanup "$scenario_name"

    # Secondary string corroboration — agent output should contain EVIDENCE_TYPE_MISMATCH
    # This is string evidence only, corroborating the behavioral assertion above.
    # Per Rule 5, this is NOT sufficient as primary evidence for this behavioral SC.
    assert_required_pattern_present \
        "EVIDENCE_TYPE_MISMATCH" \
        "agent output contains EVIDENCE_TYPE_MISMATCH classification (string corroboration)" \
        || OVERALL_RESULT=1
}

# SC-9: Coverage completeness gate detects orphan changes
scenario_orphan_change_coverage() {
    local scenario_name="SC-836-9-orphan-change-coverage"
    local prompt="Run verification on an implementation that includes a changed file not covered by any SC. There is a file modified in the diff that has no corresponding success criterion."

    echo "=== SC-9: Orphan change coverage ==="

    behavior_run "$scenario_name" "$prompt"

    capture_and_cleanup "$scenario_name"

}

# SC-10: Artifact preservation
scenario_artifact_preservation() {
    local scenario_name="SC-836-10-artifact-preservation"
    local prompt="After running VbC behavioral tests, should I clean up the ./tmp/behavioral-evidence-* files immediately, or preserve them?"

    echo "=== SC-10: Artifact preservation ==="

    behavior_run "$scenario_name" "$prompt"

    capture_and_cleanup "$scenario_name"

}

# Run all scenarios
run_all_scenarios() {
    echo "Running all scenarios for Issue #836: Runtime-Behavioral Evidence Classification Gate"

    scenario_structural_sc_for_behavioral_change || OVERALL_RESULT=1
    scenario_taxonomy_uplift_mandate || OVERALL_RESULT=1
    scenario_anti_evasion_model_unavailable || OVERALL_RESULT=1
    scenario_anti_evasion_too_slow || OVERALL_RESULT=1
    scenario_anti_evasion_not_needed || OVERALL_RESULT=1
    scenario_cross_validate_uplift || OVERALL_RESULT=1
    scenario_spec_creation_classification || OVERALL_RESULT=1
    scenario_enforcement_matrix_upgrade || OVERALL_RESULT=1
    scenario_orphan_change_coverage || OVERALL_RESULT=1
    scenario_artifact_preservation || OVERALL_RESULT=1

    if [[ $OVERALL_RESULT -eq 0 ]]; then
        echo "All scenarios passed"
    else
        echo "Some scenarios failed"
    fi

    return $OVERALL_RESULT
}

# List scenarios
list_scenarios() {
    echo "SC-836-1: structural_sc_for_behavioral_change"
    echo "SC-836-2: taxonomy_uplift_mandate"
    echo "SC-836-3a: anti_evasion_model_unavailable"
    echo "SC-836-3b: anti_evasion_too_slow"
    echo "SC-836-3c: anti_evasion_not_needed"
    echo "SC-836-4: cross_validate_uplift"
    echo "SC-836-5: spec_creation_classification"
    echo "SC-836-7: enforcement_matrix_upgrade"
    echo "SC-836-9: orphan_change_coverage"
    echo "SC-836-10: artifact_preservation"
}

# Main
case "${1:-all}" in
    --list) list_scenarios; exit 0 ;;
    --scenario) shift; "$@"; exit $? ;;
    all) run_all_scenarios; exit $? ;;
    *) echo "Usage: $0 [--list|--scenario <name>|all]"; exit 1 ;;
esac