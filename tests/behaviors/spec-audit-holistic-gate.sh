#!/bin/bash
# Behavioral test: spec-audit-holistic-gate
# SC-3, SC-5, SC-6, SC-7, SC-8, SC-19, SC-21, SC-22, SC-23, SC-24, SC-25
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: triggers spec-audit on specs with various holistic gate defects.
# The auditor should halt at the holistic gate with DRAFT verdict and FAIL on
# the relevant dimension(s) for each spec variant.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="spec-audit-holistic-gate"

# Test 1: Ambiguous spec with "Design Options" section (4 viable approaches)
SCENARIO_PROMPT='Audit this spec for quality defects. The spec has a "Design Options" section listing 4 viable approaches with no recommendation. The spec says: "The system must handle file uploads. Design Options: (A) Use S3 directly, (B) Use a proxy service, (C) Store on local filesystem, (D) Use a CDN. Pick the best approach during implementation." Check the spec for implementability, testability, internal consistency, escape hatches, provenance, feasibility, safety, traceability, and correctness. Report a holistic gate verdict.'

behavior_run "${SCENARIO_NAME}-ambiguous" "$SCENARIO_PROMPT"

# Test 2: Clean spec with "Alternatives Considered & Why Discarded" — should PASS all 11
SCENARIO_PROMPT='Audit this spec for quality defects. The spec has an "Alternatives Considered & Why Discarded" section. The spec says: "The system MUST use S3 for file uploads. Alternatives considered: (A) Proxy service — discarded due to latency overhead, (B) Local filesystem — discarded due to scalability limits, (C) CDN — discarded due to cost at current scale. The implementation MUST: (1) Upload files to S3 bucket X, (2) Return presigned URL, (3) Log upload metadata to table Y. Each SC is testable via integration test. Rollback: delete S3 object on failure." Check all 11 holistic gate dimensions and report a verdict.'

behavior_run "${SCENARIO_NAME}-clean" "$SCENARIO_PROMPT"

# Test 3: Contradictory spec (preamble says X, body does Y) — FAIL on Internal Consistency
SCENARIO_PROMPT='Audit this spec for quality defects. The spec preamble says: "All data MUST be encrypted at rest." The body says: "Store session tokens in plaintext cookies." Check for internal consistency and report a holistic gate verdict.'

behavior_run "${SCENARIO_NAME}-contradictory" "$SCENARIO_PROMPT"

# Test 4: Untestable SC ("must be intuitive") — FAIL on Testability
SCENARIO_PROMPT='Audit this spec for quality defects. The spec says: "SC-3: The user interface MUST be intuitive and easy to use." Check for testability and report a holistic gate verdict.'

behavior_run "${SCENARIO_NAME}-untestable" "$SCENARIO_PROMPT"

# Test 5: Escape hatch language ("use best judgment") — FAIL on Escape Hatches
SCENARIO_PROMPT='Audit this spec for quality defects. The spec says: "SC-4: The system SHOULD handle errors gracefully. Use best judgment for error message formatting." Check for escape hatches and report a holistic gate verdict.'

behavior_run "${SCENARIO_NAME}-escape-hatch" "$SCENARIO_PROMPT"

# Test 6: Unsupported claims — FAIL on Provenance
SCENARIO_PROMPT='Audit this spec for quality defects. The spec says: "The system MUST process 10,000 requests per second based on industry benchmarks." No benchmark source is cited. Check for provenance and report a holistic gate verdict.'

behavior_run "${SCENARIO_NAME}-unsupported" "$SCENARIO_PROMPT"

# Test 7: Infeasible spec (references non-existent function) — FAIL on Feasibility
SCENARIO_PROMPT='Audit this spec for quality defects. The spec says: "Call the nonexistent_process_data() function to transform the output." This function does not exist in the codebase. Check for feasibility and report a holistic gate verdict.'

behavior_run "${SCENARIO_NAME}-infeasible" "$SCENARIO_PROMPT"

# Test 8: Unsafe spec (destructive op without rollback) — FAIL on Safety
SCENARIO_PROMPT='Audit this spec for quality defects. The spec says: "Phase 1: DELETE all records from the users table. No rollback plan is needed since this is a one-time migration." Check for safety and report a holistic gate verdict.'

behavior_run "${SCENARIO_NAME}-unsafe" "$SCENARIO_PROMPT"

# Test 9: Untraceable spec (orphan SCs) — FAIL on Traceability
SCENARIO_PROMPT='Audit this spec for quality defects. The spec has SC-1 through SC-5 but only SC-1 and SC-2 are referenced in the implementation plan. SC-3, SC-4, and SC-5 have no corresponding plan items. Check for traceability and report a holistic gate verdict.'

behavior_run "${SCENARIO_NAME}-untraceable" "$SCENARIO_PROMPT"

# Test 10: Incorrect spec (solves wrong problem) — FAIL on Correctness
SCENARIO_PROMPT='Audit this spec for quality defects. The problem statement says: "Users cannot reset their passwords." The spec proposes: "Add a dark mode toggle to the settings page." Check for correctness (does the spec solve the stated problem?) and report a holistic gate verdict.'

behavior_run "${SCENARIO_NAME}-incorrect" "$SCENARIO_PROMPT"

exit 0
