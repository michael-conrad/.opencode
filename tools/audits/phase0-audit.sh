#!/bin/bash
# Phase 0 Audit Script: Systematic comparison of all skills against pre-regression baseline
#
# Usage: bash .opencode/tools/audits/phase0-audit.sh [--baseline COMMIT_HASH] [--output DIR]
#
# This script audits all skills against the pre-regression baseline (commit 61ca465)
# to identify the full scope of regression. It compares:
#   1. SKILL.md line counts (current vs baseline)
#   2. Task file counts and total line counts (current vs baseline)
#   3. Knowledge extraction ratio (task lines / SKILL lines)
#   4. Optional/mandatory invocation language
#   5. Mermaid flowchart presence
#
# Output: Audit report at .opencode/docs/audits/phase0-audit-report.md
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
BASELINE_COMMIT="${1:-61ca465}"
OUTPUT_DIR="${2:-$PROJECT_DIR/docs/audits}"
REPORT_FILE="$OUTPUT_DIR/phase0-audit-report.md"

SKILLS_DIR="$PROJECT_DIR/skills"

mkdir -p "$OUTPUT_DIR"

echo "=== Phase 0 Audit: Skills vs Baseline $BASELINE_COMMIT ==="
echo "Skills directory: $SKILLS_DIR"
echo "Output: $REPORT_FILE"
echo ""

# Create report header
cat > "$REPORT_FILE" << 'REPORT_HEADER'
# Phase 0 Audit Report: Skills vs Pre-Regression Baseline

**Baseline Commit:** 61ca465 (skills-first workflow, before sub-agent-first extraction)
**Audit Date:** DATE_PLACEHOLDER
**Auditor:** OpenCode (ollama-cloud/glm-5.1)

## Methodology

1. Compare current SKILL.md line count vs baseline
2. Compare current task files vs baseline (or vs original SKILL.md content if tasks didn't exist)
3. Calculate knowledge extraction ratio (task total lines / SKILL lines)
4. Flag skills with ratio > 2.0x for detailed review
5. Flag skills with "optional", "contextual", "NOT mandatory" language
6. Flag skills lacking mermaid flowcharts

## Tiering

| Tier | Criteria | Action |
|------|----------|--------|
| P0 (Critical) | Optional invocation + extraction ratio > 2.0x + no mermaid | Restore mandatory language, restore workflow content, add mermaid |
| P1 (High) | Extraction ratio > 2.0x only | Restore workflow content to 500-600 words/task |
| P2 (Medium) | Optional language only | Replace with mandatory invocation language |
| P3 (Healthy) | Ratio < 2.0x and mandatory language | No action needed |

REPORT_HEADER

sed -i "s/DATE_PLACEHOLDER/$(date -u +%Y-%m-%d)/" "$REPORT_FILE"

# Count skills
SKILL_COUNT=$(ls -d "$SKILLS_DIR"/*/ 2>/dev/null | wc -l)
echo "Found $SKILL_COUNT skills to audit"

# Initialize tier counters
P0_COUNT=0
P1_COUNT=0
P2_COUNT=0
P3_COUNT=0

# Audit each skill
echo "" >> "$REPORT_FILE"
echo "## Per-Skill Findings" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

for skill_dir in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    
    # Skip skills without SKILL.md (they cannot be audited)
    if [ ! -f "$skill_dir/SKILL.md" ]; then
        echo "### $skill_name" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "**SKILL.md not found** — cannot audit this skill." >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "  Skipped: $skill_name (no SKILL.md)"
        continue
    fi
    
    # Current SKILL.md stats
    if [ -f "$skill_dir/SKILL.md" ]; then
        current_skill_lines=$(wc -l < "$skill_dir/SKILL.md")
    else
        current_skill_lines=0
    fi
    
    # Current task files stats
    current_task_count=$(find "$skill_dir/tasks" -name "*.md" 2>/dev/null | wc -l)
    if [ "$current_task_count" -gt 0 ]; then
        current_task_lines=0
        for task_file in "$skill_dir/tasks"/*.md; do
            if [ -f "$task_file" ]; then
                task_lines=$(wc -l < "$task_file")
                current_task_lines=$((current_task_lines + task_lines))
            fi
        done
    else
        current_task_lines=0
    fi
    
    # Baseline SKILL.md stats
    baseline_skill_lines=$(git show "$BASELINE_COMMIT:skills/$skill_name/SKILL.md" 2>/dev/null | wc -l || echo "0")
    
    # Check for optional language
    has_optional=0
    if [ -f "$skill_dir/SKILL.md" ]; then
        if grep -qiE "optional|contextual|NOT mandatory|should.*use.*discretion" "$skill_dir/SKILL.md" 2>/dev/null; then
            has_optional=1
        fi
    fi
    
    # Check for mermaid flowcharts
    has_mermaid=0
    if [ -f "$skill_dir/SKILL.md" ]; then
        if grep -qi "mermaid\|flowchart\|stateDiagram" "$skill_dir/SKILL.md" 2>/dev/null; then
            has_mermaid=1
        fi
    fi
    
    # Calculate extraction ratio
    if [ "$current_skill_lines" -gt 0 ]; then
        extraction_ratio=$(echo "scale=2; $current_task_lines / $current_skill_lines" | bc 2>/dev/null || echo "0")
    else
        extraction_ratio="N/A"
    fi
    
    # Determine tier
    tier="P3"
    extraction_gt_2=0
    if [ "$extraction_ratio" != "N/A" ]; then
        extraction_gt_2=$(echo "$extraction_ratio > 2.0" | bc 2>/dev/null || echo 0)
    fi
    if [ "$has_optional" -eq 1 ] && [ "$extraction_gt_2" -eq 1 ] && [ "$has_mermaid" -eq 0 ]; then
        tier="P0"
        P0_COUNT=$((P0_COUNT + 1))
    elif [ "$extraction_gt_2" -eq 1 ]; then
        tier="P1"
        P1_COUNT=$((P1_COUNT + 1))
    elif [ "$has_optional" -eq 1 ]; then
        tier="P2"
        P2_COUNT=$((P2_COUNT + 1))
    else
        P3_COUNT=$((P3_COUNT + 1))
    fi
    
    # Write skill finding to report
    echo "### $skill_name" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "| Metric | Current | Baseline |" >> "$REPORT_FILE"
    echo "|--------|---------|----------|" >> "$REPORT_FILE"
    echo "| SKILL.md lines | $current_skill_lines | $baseline_skill_lines |" >> "$REPORT_FILE"
    echo "| Task files | $current_task_count | N/A |" >> "$REPORT_FILE"
    echo "| Task total lines | $current_task_lines | N/A |" >> "$REPORT_FILE"
    echo "| Extraction ratio | $extraction_ratio | N/A |" >> "$REPORT_FILE"
    echo "| Optional language | $([ $has_optional -eq 1 ] && echo 'YES ⚠️' || echo 'No') | N/A |" >> "$REPORT_FILE"
    echo "| Mermaid flowchart | $([ $has_mermaid -eq 1 ] && echo 'YES' || echo 'No ⚠️') | N/A |" >> "$REPORT_FILE"
    echo "| **Tier** | **$tier** | N/A |" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    echo "  Audited: $skill_name (tier: $tier, ratio: $extraction_ratio)"
done

# Write summary
echo "" >> "$REPORT_FILE"
echo "## Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| Tier | Count | Description |" >> "$REPORT_FILE"
echo "|------|-------|-------------|" >> "$REPORT_FILE"
echo "| P0 (Critical) | $P0_COUNT | Optional invocation + high extraction + no mermaid |" >> "$REPORT_FILE"
echo "| P1 (High) | $P1_COUNT | High extraction ratio (>2.0x) |" >> "$REPORT_FILE"
echo "| P2 (Medium) | $P2_COUNT | Optional invocation language only |" >> "$REPORT_FILE"
echo "| P3 (Healthy) | $P3_COUNT | Ratio < 2.0x and mandatory language |" >> "$REPORT_FILE"
echo "| **Total** | **$((P0_COUNT + P1_COUNT + P2_COUNT + P3_COUNT))** | |" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Restoration Priority" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "1. **P0 skills**: Restore mandatory language + workflow content + add mermaid flowcharts" >> "$REPORT_FILE"
echo "2. **P1 skills**: Restore workflow content to 500-600 words/task minimum" >> "$REPORT_FILE"
echo "3. **P2 skills**: Replace optional language with mandatory invocation rules" >> "$REPORT_FILE"
echo "4. **P3 skills**: Add mermaid flowcharts if missing, otherwise no action needed" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)" >> "$REPORT_FILE"

echo ""
echo "=== Audit Complete ==="
echo "Report written to: $REPORT_FILE"
echo "P0: $P0_COUNT | P1: $P1_COUNT | P2: $P2_COUNT | P3: $P3_COUNT"