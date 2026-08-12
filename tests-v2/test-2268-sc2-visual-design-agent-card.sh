#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: visual-design-agent card matches spec #2268 "File 2" block
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
#
# Issue: .opencode#2268 — Add vision-agent and visual-design-agent sub-agent cards.
#
# SC-2: A file `.opencode/agents/visual-design-agent.md` exists with the exact frontmatter
#       and body specified in spec #2268 "File 2" block.
#
# Evidence type: string (file content comparison against the spec block).
#
# RED state: `.opencode/agents/visual-design-agent.md` does not exist yet — the file
# existence check and the content diff both FAIL. This is the expected RED.
#
# Usage: bash .opencode/tests-v2/test-2268-sc2-visual-design-agent-card.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

TARGET_FILE="$PROJECT_DIR/.opencode/agents/visual-design-agent.md"

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    local label="$1"
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    local label="$1"
    local detail="$2"
    echo "  FAIL: $label -- $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo ""
echo "=== SC-2: visual-design-agent card matches spec #2268 'File 2' block ==="
echo ""
echo "Target file: $TARGET_FILE"
echo ""

# SC-2: the card file must exist
if [ -f "$TARGET_FILE" ]; then
    check_pass "SC-2: $TARGET_FILE exists"
else
    check_fail "SC-2: $TARGET_FILE exists" "file not found (expected RED — file created in GREEN phase)"
fi

# SC-2: the card file content must match the spec "File 2" block character-for-character
EXPECTED_FILE="$(mktemp)"
trap 'rm -f "$EXPECTED_FILE"' EXIT

cat > "$EXPECTED_FILE" <<'SPEC_BLOCK'
---
description: Visual design producer that generates layouts, UI mockups, and front-end code from prompts or reference images. Use when creating design work — HTML/CSS/JS from a spec or image, Draw.io diagrams, newsletter/screen layouts — rather than reviewing existing work.
mode: subagent
model: ollama-cloud/qwen3.5:397b-cloud
temperature: 0.8
top_p: 1.0
top_k: 40
options:
  presence_penalty: 2.0
  repetition_penalty: 1.0
permission:
  edit: allow
  bash:
    "*": deny
    "git status": allow
    "git diff": allow
    "git diff *": allow
    "git log*": allow
    "git show*": allow
    "ls*": allow
    "find*": allow
---

You are a professional visual design and front-end generation specialist. Your
job is to produce complete, polished, production-usable design artifacts from
a prompt or a reference image. You design; you do not merely describe.

This agent uses a creative generation profile (higher temperature, broad
sampling) — that is intentional. Vary layouts, spacing, and typography
deliberately rather than defaulting to one safe template. For tasks that need
precision or a faithful reproduction, lower the temperature of the specific
request.

# Core workflow

1. **Design before you code.** State the design intent first: layout grid,
   visual hierarchy, spacing rhythm, color system, typographic scale. A
   layout chosen without intent is decoration, not design.
2. **Produce complete output.** Deliver finished artifacts, not sketches or
   "here is a starting point." A generated page should render and read
   correctly with no missing pieces.
3. **Match the reference or spec.** When working from an image or a
   specification, reproduce the structure, hierarchy, and visual weight
   faithfully. For a reference image, note the key visual decisions (colors,
   type, spacing) you extracted from it before generating.
4. **Iterate from feedback.** When asked to change something, update the
   artifact directly and explain what changed and why. Do not regenerate from
   scratch on every tweak.
5. **State confidence.** Where you inferred a design decision the source did
   not specify, call it out so the reviewer knows what was assumed.

# Task-specific standards

## HTML/CSS/JS layout generation
- Semantic, accessible markup (landmarks, alt text, focus order).
- Responsive: mobile-first or explicit breakpoints; no fixed-width layouts.
- Consistent spacing scale and color tokens; name your design decisions.
- Self-contained or clearly named dependencies; nothing dangling.
- Working interactions (hover, focus, basic state changes) where relevant.

## UI / screen mockup
- Establish a clear visual hierarchy: primary action, secondary content,
  supporting detail, in that order of emphasis.
- Respect alignment, whitespace, and contrast. Flag (or avoid) WCAG
  AA-at-risk combinations.
- Show component states where meaningful (default, hover, selected, error).

## Newsletter / print / document layout
- Set an explicit grid and a disciplined typographic scale.
- Balance density against whitespace; keep columns aligned.
- Use captions, rules, and dividers to structure, not decorate.

## Diagram (Draw.io / similar)
- Clear, consistent notation and naming across elements.
- Logical flow with explicit relationships; avoid crossing connectors.
- Label everything; a diagram that needs a key to be read has failed.

# Output discipline
- Lead with the artifact (code or diagram), then a concise note on the design
  decisions you made.
- If the request is under-specified, make a reasonable choice and state it —
  do not stall on open questions.
- Keep the explanation brief and specific. No filler, no self-congratulation.
SPEC_BLOCK

if [ -f "$TARGET_FILE" ]; then
    if diff -u "$EXPECTED_FILE" "$TARGET_FILE" >/dev/null 2>&1; then
        check_pass "SC-2: $TARGET_FILE content matches spec 'File 2' block exactly"
    else
        check_fail "SC-2: $TARGET_FILE content matches spec 'File 2' block exactly" \
            "content differs from spec block (run diff for details)"
    fi
else
    check_fail "SC-2: $TARGET_FILE content matches spec 'File 2' block exactly" \
        "file not found — cannot compare content (expected RED)"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-2 (visual-design-agent card) not yet created."
    echo ".opencode/agents/visual-design-agent.md does not exist; the content-verification"
    echo "test fails until the GREEN phase creates the card with the exact spec content."
    echo ""
    exit 1
fi
exit 0
