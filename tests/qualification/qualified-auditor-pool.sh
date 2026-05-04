#!/bin/bash
# qualified-auditor-pool.sh — Static list of cross-validated AUDITOR_CANDIDATE models
#
# These 9 models passed both skill-listing and file-reading probes
# with dual-auditor cross-validation. This is the canonical auditor pool.
# Do NOT add models that failed qualification or were not tested.
#
# See: docs/auditor-model-qualification/auditor-model-capability-qualification-analysis.tex
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

set -euo pipefail

cat <<'MODELS'
deepseek-v3.2:cloud
deepseek-v4-flash:cloud
deepseek-v4-pro:cloud
devstral-2:123b-cloud
glm-5.1:cloud
glm-5:cloud
kimi-k2.6:cloud
mistral-large-3:675b-cloud
qwen3.5:397b-cloud
MODELS
