#!/bin/bash
# Task: findings
#
# Format research findings with YAML frontmatter + markdown body.
# Called by investigate to persist results.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: findings <topic> <status> [issue_number]"
    exit 1
fi

TOPIC="$1"
STATUS="$2"  # PASS | FAIL | UNVERIFIED
ISSUE_NUMBER="${3:-}"
TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")

if [ -n "$ISSUE_NUMBER" ]; then
    FILENAME="./tmp/artifacts/pipeline-${ISSUE_NUMBER}-researcher-${TOPIC}-${STATUS}-${TIMESTAMP}.md"
else
    FILENAME="./tmp/artifacts/research-${TOPIC}-${STATUS}-${TIMESTAMP}.md"
fi

mkdir -p "$(dirname "$FILENAME")"

cat > "$FILENAME" << EOF
---
step: adhoc
triggered_by_step: null
failure_artifact: null
prior_artifacts_consulted: []
remediation_scope: full
remediation_steps: []
escalation_required: false
---

# Research: ${TOPIC}

## Research Summary

<summary>

## Findings

...

## Remediation Rationale

...

## Sources Consulted

| Source | Type | Verification Method | Status |
|--------|------|-------------------|--------|
EOF

echo "Findings written to: $FILENAME"
