#!/bin/bash
# Behavioral test: spec-creation-holistic-gate
# SC-13, SC-14
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: triggers spec-creation with holistic self-check.
# SC-13: spec-creation produces a spec that passes all 11 holistic dimensions.
# SC-14: spec-creation refuses to finalize a spec that would fail the holistic gate.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="spec-creation-holistic-gate"

# Test 1: Clean spec request — should produce a spec that passes all 11 holistic dimensions (SC-13)
SCENARIO_PROMPT='Create a spec for adding a new API endpoint that returns user profile data. The endpoint MUST: (1) Accept a user ID parameter, (2) Return JSON with name, email, and avatar URL, (3) Return 404 for non-existent users, (4) Log all requests. Root cause: Users cannot access their profile data through the API. Alternatives considered: GraphQL — discarded due to over-engineering for a single endpoint. Safety: No destructive operations. Evidence: The Express.js framework supports route parameters via req.params. Feasibility: The User model exists in models/User.js with findById method. Run the holistic self-check before finalizing.'

behavior_run "${SCENARIO_NAME}-clean" "$SCENARIO_PROMPT"

# Test 2: Ambiguous spec request with escape hatch language — should fail the holistic gate (SC-14)
SCENARIO_PROMPT='Create a spec for handling file uploads. The spec should include a "Design Options" section with 4 viable approaches (S3, local filesystem, CDN, proxy service) and say "use best judgment during implementation." Do NOT include root cause analysis, alternatives considered with discard rationale, or safety considerations. Use escape hatch language like "simplify if needed" and "left to implementor discretion." Run the holistic self-check before finalizing.'

behavior_run "${SCENARIO_NAME}-ambiguous" "$SCENARIO_PROMPT"

exit 0
