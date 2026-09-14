#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Issue 2442, SC-3 (RED-phase grep test).
#
# Asserts BOTH preserved rules are present in .opencode/AGENTS.md after the
# rewrite:
#   (1) the `git -C <tree>/.issues/` mandate for git operations against .issues/
#   (2) the parent-repo `git add .issues/` FORBIDDEN rule
#
# Test FAILs (non-zero exit) if either rule text was dropped during the rewrite.
#
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)

set -u

AGENTS_MD="$(cd "$(dirname "$0")/../.." && pwd)/AGENTS.md"

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

[ -f "$AGENTS_MD" ] || fail "AGENTS.md not found at $AGENTS_MD"

# Rule 1: `git -C <tree>/.issues/` mandate (git axis of the two-part rule)
if ! grep -qF 'git -C <tree>/.issues/' "$AGENTS_MD"; then
    fail "Rule 1 missing: 'git -C <tree>/.issues/' mandate for git operations against .issues/ was dropped from AGENTS.md"
fi

# Rule 2: parent-repo `git add .issues/` FORBIDDEN rule
if ! grep -qF 'git add .issues/' "$AGENTS_MD"; then
    fail "Rule 2 missing: parent-repo 'git add .issues/' FORBIDDEN rule was dropped from AGENTS.md"
fi

echo "PASS: both preserved .issues/ rules present in AGENTS.md"
exit 0
