#!/bin/bash
# list-cloud-candidates.sh — List cloud models by size indicator
#
# One purpose: output newline-delimited names of cloud models
# (models where ollama list shows SIZE of "-").
# No iteration, no dispatch, no evaluation.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

set -euo pipefail

ollama list 2>/dev/null | awk '$3 == "-" {print $1}' | sort
