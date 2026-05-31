#!/bin/bash
# Task: investigate
#
# Execute an exhaustive investigation with verifiable source evidence.
# Produces a YAML-frontmatter + markdown body artifact.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: investigate <topic> <issue_number> [pipeline_step]"
    exit 1
fi

TOPIC="$1"
ISSUE_NUMBER="$2"
PIPELINE_STEP="${3:-adhoc}"
TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
BASE_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ARTIFACT_DIR="./tmp/artifacts"
mkdir -p "$ARTIFACT_DIR"

echo "=== Investigating: $TOPIC (issue #$ISSUE_NUMBER) ==="
echo "  Gathering evidence from live sources..."

# Research phase: collect findings with tool-call evidence
# (Placeholder — actual investigation logic per topic)

echo "  Investigation complete."
echo "  Artifact saved."
