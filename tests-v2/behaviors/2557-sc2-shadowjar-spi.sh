#!/bin/bash
# Behavioral test: 2557-sc2-shadowjar-spi
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2557 SC-2: when configuring JVM fat-jar packaging (shadowJar), the
# agent applies INCLUDE semantics and SPI preservation (mergeServiceFiles() /
# META-INF/services handling) and verifies the produced jar's service
# registrations as the outputs check.
#
# PROMPT CONSTRUCTION: real-domain task — a packaging requirement stated by the
# developer. Not an interview question.
#
# FIXTURE: fixtures/setup/2557-sc2-shadowjar-spi.sh creates a Gradle Java
# project with a ServiceLoader provider registration (META-INF/services) and a
# build manifest (AGENTS.md) declaring ./gradlew shadowJar as the canonical
# build. A Gradle wrapper pinned to a modern distribution is pre-generated so
# the daemon runs on a supported JVM.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2557-sc2-shadowjar-spi"
SCENARIO_PROMPT="This service needs to ship as a fat jar: configure the build so ./gradlew shadowJar produces a self-contained jar that bundles all runtime dependencies, and make sure the JDK ServiceLoader still finds our greeting providers from inside the fat jar. Build it and verify the jar is right."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_EXPECTED_ARTIFACT="build/libs/greeter-service-all.jar"
BEHAVIOR_GOAL_ACTIONS="edit,write,bash"
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
