#!/bin/bash
# qualified-auditor-pool.sh — List of cross-validated AUDITOR_CANDIDATE models
#
# These 7 models passed both skill-listing and file-reading probes
# with dual-auditor cross-validation.
# This file is the qualification gate: only pool-listed models are eligible.
#
# See: docs/auditor-model-qualification/auditor-model-capability-qualification-analysis.tex
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

set -euo pipefail

cat <<'MODELS'
deepseek-v4-flash:cloud
gemma4:31b-cloud
gpt-oss:20b-cloud
mistral-large-3:675b-cloud
qwen3.5:397b-cloud
MODELS
