#!/bin/bash
# Per-scenario fixture setup for 2413-sc3-research-dependency-contract
# Creates analytical artifacts in the test repo's .issues/2413/ directory.
# The interface-compatibility.yaml intentionally has NO dependency_contract section.

setup_2413_sc3_fixture() {
    local wd="$1"
    local artifacts_dir="$wd/.issues/2413/artifacts"

    # Create artifacts directory
    mkdir -p "$artifacts_dir"

    # Write interface-compatibility.yaml WITHOUT dependency_contract (RED state)
    cat > "$artifacts_dir/interface-compatibility.yaml" << 'EOF'
# Interface compatibility for issue 2413
# RED STATE: no dependency_contract section — research step 9 must auto-backfill

interfaces:
  - interface: "interface-compatibility.yaml artifact schema (spec-creation pipeline output)"
    kind: modified
    compatibility: backward_compatible
    phases: [1]
    detail: "A new dependency_contract section is added to the artifact. Existing keys unchanged."
  - interface: "research.md step 9 dependency_contract extraction"
    kind: modified
    compatibility: backward_compatible
    phases: [2]
    detail: "Step 9 validates or auto-backfills the dependency_contract section."

removed_interfaces: []
breaking_changes: []
EOF

    # Write analysis summary (required by research.md entry criteria)
    cat > "$artifacts_dir/analysis-summary.yaml" << 'EOF'
issue: 2413
title: "Fix interface-compatibility.yaml dependency_contract emission"
phases:
  - phase: 1
    scs: [SC-1]
    files:
      - .opencode/skills/spec-creation/tasks/analyze.md
  - phase: 2
    scs: [SC-2]
    files:
      - .opencode/skills/writing-plans/tasks/research.md
  - phase: 3
    scs: [SC-3]
    files:
      - .opencode/skills/writing-plans/contracts/
success_criteria:
  - id: SC-1
    description: "Spec-creation-generated interface-compatibility.yaml always contains a dependency_contract section"
  - id: SC-2
    description: "Research.md step 9 auto-backfills dependency_contract when section is missing"
  - id: SC-3
    description: "Plan creation for a spec proceeds without DEPENDENCY_CONTRACT_NOT_FOUND"
EOF

    # Write other required artifacts with minimal content
    for artifact in blast-radius concern-map code-path-inventory cross-cutting-matrix state-analysis testability-assessment; do
        cat > "$artifacts_dir/$artifact.yaml" << EOF
# $artifact for issue 2413
issue: 2413
EOF
    done

    # Write spec.md
    mkdir -p "$wd/.issues/2413"
    cat > "$wd/.issues/2413/spec.md" << 'EOF'
# Spec #2413 — Fix interface-compatibility.yaml dependency_contract emission

## Problem
The interface-compatibility.yaml artifact lacks a dependency_contract section.

## Success Criteria
- SC-1: Spec-creation-generated interface-compatibility.yaml always contains a dependency_contract section
- SC-2: Research.md step 9 auto-backfills dependency_contract when section is missing
- SC-3: Plan creation proceeds without DEPENDENCY_CONTRACT_NOT_FOUND

## Affected Files
- .opencode/skills/spec-creation/tasks/analyze.md
- .opencode/skills/writing-plans/tasks/research.md
EOF
}

setup_2413_sc3_fixture "$1"
