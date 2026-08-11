#!/bin/bash
# Behavioral test: 2249-sc6-generic-di-mandate
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6 (behavioral): A behavioral enforcement test SHALL be added under
# `.opencode/tests-v2/behaviors/` that dispatches a real-domain prompt via
# `opencode run` requiring the agent to design a solution/unit test where a DI
# approach exists, producing `session.yaml` artifacts.
#
# RED phase: The generic DI mandate (Dependency Injection (generic mandate)
# section in 080-code-standards.md) does NOT yet exist. When the agent is asked
# to design a C#/.NET service with injectable dependencies, it must NOT dispatch
# to / follow a generic DI mandate — it will fall back to manual parameter-
# passing or arbitrary wiring. This is the RED condition.
#
# GREEN phase: After the generic DI section is added to 080-code-standards.md,
# the agent designing the same C#/.NET service must follow the generic DI
# mandate — approaching the problem from the point of view of having an
# available DI approach of some worth, using the built-in
# Microsoft.Extensions.DependencyInjection (Clear standard tier) rather than
# hand-rolling manual wiring.
#
# The prompt is a real-domain task (design a C#/.NET service with injectable
# dependencies), NOT a prose-recall interview. See .opencode/tests-v2/AGENTS.md
# §11 Prompt Construction Mandate. The session.yaml (SQLite DB export) is the
# PRIMARY evidence source — a clean-room sub-agent evaluates whether the agent
# applied the generic DI mandate.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2249-sc6-generic-di-mandate"
SCENARIO_PROMPT="A C#/.NET service class WordCountService must be added to this project to report word-count statistics. The service depends on a Config object (loads thresholds) and a Secrets object (loads API credentials). Read the project's coding standards at .opencode/guidelines/080-code-standards.md to determine the mandated dependency injection approach, then describe exactly how the Config and Secrets dependencies must be wired into the service using that mandated approach, so the service is easy to test and refactor. Do not create or modify any files — just read the standards and describe the required DI wiring."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
