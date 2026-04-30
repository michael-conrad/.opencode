#!/bin/bash
# Phase 0 Audit Script: AI-Agent Baseline Comparison
#
# Usage: bash .opencode/tools/audits/phase0-audit.sh [--baseline COMMIT_HASH]
#
# This script extracts current and baseline skill data for AI-agent baseline
# comparison. It produces a structured data file that an AI agent uses to
# classify each skill on 8 check dimensions:
#   1. Workflow completeness — does the skill describe the complete workflow?
#   2. Gating behavior — are mandatory/optional gates correctly classified?
#   3. Verification requirements — are verification steps present and correct?
#   4. Principles/concerns — are design principles and concerns documented?
#   5. Cross-references — are references to related skills/guidelines present?
#   6. Duplication detection — is content unnecessarily duplicated across files?
#   7. Mermaid diagrams — are workflow diagrams present where needed?
#   8. Platform-agnostic language — are hardcoded values replaced with tokens?
#
# Per-dimension classification:
#   CORRECT — matches baseline intent fully
#   PARTIAL — matches baseline intent partially (some gaps)
#   WRONG — contradicts baseline intent
#   MISSING — baseline had it, current doesn't
#   DUPLICATED — content unnecessarily repeated across SKILL.md and task files
#
# Output: Structured data at .opencode/docs/audits/phase0-audit-data.md
# Report (AI-agent authored): .opencode/docs/audits/phase0-audit-report.md
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "${BASH_SOURCE[0]}")/../../tests/behaviors/_find_project_root.sh"
PROJECT_DIR="$(_find_project_root)"
BASELINE_COMMIT="${1:-61ca465}"
OUTPUT_DIR="${PROJECT_DIR}/docs/audits"
DATA_FILE="$OUTPUT_DIR/phase0-audit-data.md"
SKILLS_DIR="$PROJECT_DIR/skills"

mkdir -p "$OUTPUT_DIR"

echo "=== Phase 0 Audit: AI-Agent Baseline Comparison ==="
echo "Baseline commit: $BASELINE_COMMIT"
echo "Skills directory: $SKILLS_DIR"
echo "Output: $DATA_FILE"
echo ""

cat > "$DATA_FILE" << 'DATA_HEADER'
# Phase 0 Audit Data: Skills vs Pre-Regression Baseline

**Baseline Commit:** BASELINE_PLACEHOLDER
**Audit Date:** DATE_PLACEHOLDER
**Methodology:** AI-Agent Baseline Comparison (8 check dimensions)

## Check Dimensions

| # | Dimension | Description |
|---|-----------|-------------|
| 1 | Workflow completeness | Does the skill describe the complete workflow from start to finish? |
| 2 | Gating behavior | Are mandatory/optional gates correctly classified with Tier 1/2 mandates? |
| 3 | Verification requirements | Are verification steps present, correct, and producing evidence artifacts? |
| 4 | Principles/concerns | Are design principles and domain concerns documented? |
| 5 | Cross-references | Are references to related skills and guidelines present? |
| 6 | Duplication detection | Is content unnecessarily duplicated between SKILL.md and task files? |
| 7 | Mermaid diagrams | Are workflow diagrams present where the baseline had them or where needed? |
| 8 | Platform-agnostic | Are hardcoded identity values replaced with runtime tokens? |

## Per-Dimension Classification

| Value | Meaning |
|-------|---------|
| CORRECT | Matches baseline intent fully |
| PARTIAL | Matches baseline intent partially (some gaps) |
| WRONG | Contradicts baseline intent |
| MISSING | Baseline had it, current doesn't |
| DUPLICATED | Content unnecessarily repeated across files |

DATA_HEADER

sed -i -e "s/BASELINE_PLACEHOLDER/$BASELINE_COMMIT/" "$DATA_FILE"
sed -i -e "s/DATE_PLACEHOLDER/$(date -u +%Y-%m-%d)/" "$DATA_FILE"

echo "" >> "$DATA_FILE"
echo "## Per-Skill Data" >> "$DATA_FILE"
echo "" >> "$DATA_FILE"

SKILL_COUNT=0

for skill_dir in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    SKILL_COUNT=$((SKILL_COUNT + 1))

    echo "### $skill_name" >> "$DATA_FILE"
    echo "" >> "$DATA_FILE"

    if [ ! -f "$skill_dir/SKILL.md" ]; then
        echo "**SKILL.md not found** — cannot audit this skill." >> "$DATA_FILE"
        echo "" >> "$DATA_FILE"
        echo "  Skipped: $skill_name (no SKILL.md)"
        continue
    fi

    current_skill_lines=$(wc -l < "$skill_dir/SKILL.md")
    current_task_count=$(find "$skill_dir/tasks" -name "*.md" 2>/dev/null | wc -l)
    current_task_lines=0
    if [ "$current_task_count" -gt 0 ]; then
        for task_file in "$skill_dir/tasks"/*.md; do
            if [ -f "$task_file" ]; then
                task_lines=$(wc -l < "$task_file")
                current_task_lines=$((current_task_lines + task_lines))
            fi
        done
    fi

    baseline_skill_lines=$(git -C "$(dirname "$SKILLS_DIR")" show "$BASELINE_COMMIT:skills/$skill_name/SKILL.md" 2>/dev/null | wc -l || echo "0")

    has_optional="No"
    grep -qiE "optional|contextual|NOT mandatory|should.*use.*discretion" "$skill_dir/SKILL.md" 2>/dev/null && has_optional="YES ⚠️"

    has_mermaid="No ⚠️"
    grep -qi "mermaid\|flowchart\|stateDiagram" "$skill_dir/SKILL.md" 2>/dev/null && has_mermaid="YES"

    has_mandatory="No ⚠️"
    grep -qiE "MANDATORY|mandatory|MUST|NEVER|FORBIDDEN|CRITICAL" "$skill_dir/SKILL.md" 2>/dev/null && has_mandatory="YES"

    has_verification="No ⚠️"
    grep -qiE "verif|evidence|artifact|PASS|FAIL|UNVERIFIED" "$skill_dir/SKILL.md" 2>/dev/null && has_verification="YES"

    has_crossrefs="No ⚠️"
    grep -qiE "See.*skill|Related.*skill|See.*guideline|Related guideline" "$skill_dir/SKILL.md" 2>/dev/null && has_crossrefs="YES"

    has_hardcoded="No"
    grep -qiE "OpenCode|Claude|ollama-cloud|specific-agent|example-org|example-repo" "$skill_dir/SKILL.md" 2>/dev/null && has_hardcoded="YES ⚠️"

    has_duplication="Unknown"
    if [ "$current_task_count" -gt 0 ] && [ "$current_skill_lines" -gt 0 ]; then
        if [ "$current_task_lines" -gt 3000 ]; then
            has_duplication="Likely ⚠️"
        elif [ "$current_task_lines" -gt 1500 ]; then
            has_duplication="Possible"
        else
            has_duplication="Unlikely"
        fi
    fi

    baseline_exists="YES"
    if [ "$baseline_skill_lines" -eq 0 ]; then
        baseline_exists="NO (new skill)"
    fi

    echo "| Metric | Current | Baseline |" >> "$DATA_FILE"
    echo "|--------|---------|----------|" >> "$DATA_FILE"
    echo "| SKILL.md exists | YES | $baseline_exists |" >> "$DATA_FILE"
    echo "| SKILL.md lines | $current_skill_lines | $baseline_skill_lines |" >> "$DATA_FILE"
    echo "| Task file count | $current_task_count | N/A |" >> "$DATA_FILE"
    echo "| Task total lines | $current_task_lines | N/A |" >> "$DATA_FILE"
    echo "| Mandatory language | $has_mandatory | — |" >> "$DATA_FILE"
    echo "| Optional language | $has_optional | — |" >> "$DATA_FILE"
    echo "| Verification steps | $has_verification | — |" >> "$DATA_FILE"
    echo "| Cross-references | $has_crossrefs | — |" >> "$DATA_FILE"
    echo "| Mermaid diagrams | $has_mermaid | — |" >> "$DATA_FILE"
    echo "| Platform-agnostic | $([ "$has_hardcoded" = "No" ] && echo "YES" || echo "$has_hardcoded") | — |" >> "$DATA_FILE"
    echo "| Duplication risk | $has_duplication | — |" >> "$DATA_FILE"
    echo "" >> "$DATA_FILE"

    if [ "$baseline_exists" = "YES" ]; then
        echo "#### Baseline SKILL.md Content (first 50 lines)" >> "$DATA_FILE"
        echo '```' >> "$DATA_FILE"
        git -C "$(dirname "$SKILLS_DIR")" show "$BASELINE_COMMIT:skills/$skill_name/SKILL.md" 2>/dev/null | head -50 >> "$DATA_FILE" || echo "(not available)" >> "$DATA_FILE"
        echo '```' >> "$DATA_FILE"
        echo "" >> "$DATA_FILE"
    else
        echo "#### New Skill (no baseline predecessor)" >> "$DATA_FILE"
        echo "" >> "$DATA_FILE"
    fi

    echo "#### Current SKILL.md Content (first 50 lines)" >> "$DATA_FILE"
    echo '```' >> "$DATA_FILE"
    head -50 "$skill_dir/SKILL.md" >> "$DATA_FILE"
    echo '```' >> "$DATA_FILE"
    echo "" >> "$DATA_FILE"

    echo "  Extracted: $skill_name (skill: $current_skill_lines lines, tasks: $current_task_count files / $current_task_lines lines, baseline: $baseline_skill_lines lines)"
done

echo "" >> "$DATA_FILE"
echo "## Skill Count" >> "$DATA_FILE"
echo "" >> "$DATA_FILE"
echo "Current skills: $SKILL_COUNT" >> "$DATA_FILE"
echo "Baseline skills: $(git -C "$(dirname "$SKILLS_DIR")" ls-tree --name-only $BASELINE_COMMIT skills/ 2>/dev/null | wc -l)" >> "$DATA_FILE"

echo ""
echo "=== Data Extraction Complete ==="
echo "Data written to: $DATA_FILE"
echo "Skills processed: $SKILL_COUNT"
echo ""
echo "Next step: AI agent reviews data and produces the audit report at"
echo "  $OUTPUT_DIR/phase0-audit-report.md"
echo "Classifying each skill on 8 dimensions (CORRECT/PARTIAL/WRONG/MISSING/DUPLICATED)"