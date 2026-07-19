#!/bin/bash
# Behavioral test: sc3-pipeline-section
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Pipeline section exists in SKILL.md with 25-step create and 6-step revise procedures
# SC-7: No {project_root}/tmp/{N}/contracts/ paths in SKILL.md pipeline
# SC-8: Each sub-task step specifies what the sub-agent reads from disk
# SC-9: Each sub-task step specifies the result contract format {status, finding_summary, artifact_path, blocker_reason}
# SC-10: Create pipeline starts with local-issues sync, ends with local-issues sync
#
# RED phase: Must fail because no ## Pipeline section exists in spec-creation SKILL.md yet.
# The agent receives a real-domain spec-creation prompt and must follow a structured
# pipeline. Without the Pipeline section in SKILL.md, the orchestrator has no pipeline
# definition to follow — the test fails at evaluation.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc3-pipeline-section"
SCENARIO_PROMPT="create spec for issue #42"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
