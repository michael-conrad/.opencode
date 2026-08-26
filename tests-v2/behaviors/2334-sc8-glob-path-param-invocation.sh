#!/bin/bash
# Behavioral test: 2334-sc8-glob-path-param-invocation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8 (#2334): A registered behavioral enforcement test demonstrates via stderr
# assertions that an agent instructed to enumerate files under .opencode/ emits a
# working path-parameter invocation action instead of concluding nonexistence from a
# silent-empty result.
#
# RED STATE: With the pre-change deck (no SC-1 verified-semantics anchor and the naive
# pattern-from-CWD glob forms intact), an agent asked to enumerate files under
# .opencode/ issues a pattern-from-CWD glob (e.g. `glob(pattern=".opencode/**/*.md")`)
# which the built-in tool silently rejects (hidden-directory skip, LIM-1) and then
# concludes the files do not exist. SC-8 is RED.
#
# GREEN STATE: With the remediated deck (SC-1 anchor in 060-tool-usage.md documenting
# the canonical path-parameter invocation idiom, plus the remediated invocation sites),
# the agent emits a working path-parameter invocation (e.g. `glob(pattern="**/*.md",
# path=".opencode")`) and reports the actual file list — no false nonexistence
# conclusion. SC-8 is GREEN.
#
# PROMPT CONSTRUCTION:
# Real-domain task: enumerate the files under .opencode/. This is a genuine file
# enumeration task that triggers natural agent behavior — the agent must choose a
# discovery tool and invocation form, run it, and report results. It is NOT a
# prose-recall interview about glob semantics, and it does NOT name glob, glob-tool,
# LIM, or the canonical idiom. A correct (GREEN) agent uses a working path-parameter
# invocation and reports the actual file list.
#
# session.yaml (SQLite DB export) is the PRIMARY evidence source.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2334-sc8-glob-path-param-invocation"
SCENARIO_PROMPT="Enumerate the markdown files under the .opencode directory of this repository. List the files you find under .opencode (for example any .md files or task cards). Use the repository's file-searching tools to discover the actual file list and report the concrete paths you found."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
