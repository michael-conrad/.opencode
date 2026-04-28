# Phase 0 Audit Report: Skills vs Pre-Regression Baseline

**Baseline Commit:** 61ca465 (skills-first workflow, before sub-agent-first extraction)
**Audit Date:** 2026-04-28
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


## Per-Skill Findings

### approval-gate

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 1039 | 220 |
| Task files | 29 | N/A |
| Task total lines | 2474 | N/A |
| Extraction ratio | 2.38 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P0** | N/A |

### brainstorming

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 164 | 200 |
| Task files | 5 | N/A |
| Task total lines | 309 | N/A |
| Extraction ratio | 1.88 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P3** | N/A |

### changelog-generator

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 336 | 125 |
| Task files | 4 | N/A |
| Task total lines | 423 | N/A |
| Extraction ratio | 1.25 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P2** | N/A |

### code-size-enforcement

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 213 | 307 |
| Task files | 2 | N/A |
| Task total lines | 171 | N/A |
| Extraction ratio | .80 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P3** | N/A |

### coherence-auditor

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 305 | 95 |
| Task files | 5 | N/A |
| Task total lines | 271 | N/A |
| Extraction ratio | .88 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P2** | N/A |

### completion-core

**SKILL.md not found** — cannot audit this skill.

### concern-separation-auditor

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 304 | 350 |
| Task files | 3 | N/A |
| Task total lines | 285 | N/A |
| Extraction ratio | .93 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P2** | N/A |

### conflict-resolution

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 292 | 0
0 |
| Task files | 2 | N/A |
| Task total lines | 222 | N/A |
| Extraction ratio | .76 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P3** | N/A |

### correspondence

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 480 | 0
0 |
| Task files | 2 | N/A |
| Task total lines | 286 | N/A |
| Extraction ratio | .59 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P2** | N/A |

### divide-and-conquer

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 656 | 0
0 |
| Task files | 13 | N/A |
| Task total lines | 2023 | N/A |
| Extraction ratio | 3.08 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P0** | N/A |

### engineering-approach

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 375 | 183 |
| Task files | 2 | N/A |
| Task total lines | 231 | N/A |
| Extraction ratio | .61 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P2** | N/A |

### executing-plans

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 165 | 288 |
| Task files | 5 | N/A |
| Task total lines | 366 | N/A |
| Extraction ratio | 2.21 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P1** | N/A |

### finishing-a-development-branch

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 345 | 217 |
| Task files | 3 | N/A |
| Task total lines | 367 | N/A |
| Extraction ratio | 1.06 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P3** | N/A |

### fragment-manager

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 246 | 125 |
| Task files | 9 | N/A |
| Task total lines | 1039 | N/A |
| Extraction ratio | 4.22 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P1** | N/A |

### git-workflow

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 835 | 711 |
| Task files | 29 | N/A |
| Task total lines | 2757 | N/A |
| Extraction ratio | 3.30 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P1** | N/A |

### guideline-auditor

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 362 | 338 |
| Task files | 1 | N/A |
| Task total lines | 94 | N/A |
| Extraction ratio | .25 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P2** | N/A |

### issue-operations

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 778 | 0
0 |
| Task files | 10 | N/A |
| Task total lines | 1496 | N/A |
| Extraction ratio | 1.92 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P3** | N/A |

### issue-review

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 505 | 0
0 |
| Task files | 6 | N/A |
| Task total lines | 827 | N/A |
| Extraction ratio | 1.63 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P2** | N/A |

### mcp-tool-usage

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 113 | 419 |
| Task files | 1 | N/A |
| Task total lines | 83 | N/A |
| Extraction ratio | .73 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P3** | N/A |

### multimodal-dispatch

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 149 | 0
0 |
| Task files | 5 | N/A |
| Task total lines | 538 | N/A |
| Extraction ratio | 3.61 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P1** | N/A |

### notebook-operations

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 214 | 284 |
| Task files | 4 | N/A |
| Task total lines | 205 | N/A |
| Extraction ratio | .95 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P3** | N/A |

### plan-fidelity-auditor

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 342 | 0
0 |
| Task files | 4 | N/A |
| Task total lines | 360 | N/A |
| Extraction ratio | 1.05 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P3** | N/A |

### pr-creation-workflow

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 436 | 347 |
| Task files | 3 | N/A |
| Task total lines | 347 | N/A |
| Extraction ratio | .79 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P3** | N/A |

### programming-principles

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 154 | 0
0 |
| Task files | 2 | N/A |
| Task total lines | 538 | N/A |
| Extraction ratio | 3.49 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P1** | N/A |

### receiving-code-review

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 121 | 159 |
| Task files | 3 | N/A |
| Task total lines | 198 | N/A |
| Extraction ratio | 1.63 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P2** | N/A |

### requesting-code-review

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 158 | 235 |
| Task files | 2 | N/A |
| Task total lines | 163 | N/A |
| Extraction ratio | 1.03 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P2** | N/A |

### research

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 118 | 0
0 |
| Task files | 3 | N/A |
| Task total lines | 251 | N/A |
| Extraction ratio | 2.12 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P0** | N/A |

### skill-creator

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 510 | 280 |
| Task files | 1 | N/A |
| Task total lines | 76 | N/A |
| Extraction ratio | .14 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | YES | N/A |
| **Tier** | **P2** | N/A |

### spec-auditor

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 1012 | 464 |
| Task files | 18 | N/A |
| Task total lines | 1480 | N/A |
| Extraction ratio | 1.46 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P2** | N/A |

### spec-creation

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 663 | 0
0 |
| Task files | 7 | N/A |
| Task total lines | 648 | N/A |
| Extraction ratio | .97 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | YES | N/A |
| **Tier** | **P3** | N/A |

### sre-runbook

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 661 | 0
0 |
| Task files | 3 | N/A |
| Task total lines | 810 | N/A |
| Extraction ratio | 1.22 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P2** | N/A |

### sync-guidelines

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 160 | 292 |
| Task files | 5 | N/A |
| Task total lines | 330 | N/A |
| Extraction ratio | 2.06 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P1** | N/A |

### systematic-debugging

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 360 | 216 |
| Task files | 3 | N/A |
| Task total lines | 282 | N/A |
| Extraction ratio | .78 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P3** | N/A |

### test-driven-development

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 169 | 217 |
| Task files | 3 | N/A |
| Task total lines | 150 | N/A |
| Extraction ratio | .88 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P2** | N/A |

### ui-design

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 221 | 0
0 |
| Task files | 7 | N/A |
| Task total lines | 200 | N/A |
| Extraction ratio | .90 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P3** | N/A |

### ui-engineer

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 209 | 0
0 |
| Task files | 5 | N/A |
| Task total lines | 216 | N/A |
| Extraction ratio | 1.03 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P3** | N/A |

### using-git-worktrees

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 220 | 0
0 |
| Task files | 4 | N/A |
| Task total lines | 345 | N/A |
| Extraction ratio | 1.56 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P2** | N/A |

### verification

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 104 | 0
0 |
| Task files | 3 | N/A |
| Task total lines | 247 | N/A |
| Extraction ratio | 2.37 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P0** | N/A |

### verification-before-completion

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 562 | 296 |
| Task files | 4 | N/A |
| Task total lines | 650 | N/A |
| Extraction ratio | 1.15 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P3** | N/A |

### verification-enforcement

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 345 | 0
0 |
| Task files | 4 | N/A |
| Task total lines | 162 | N/A |
| Extraction ratio | .46 | N/A |
| Optional language | YES ⚠️ | N/A |
| Mermaid flowchart | No ⚠️ | N/A |
| **Tier** | **P2** | N/A |

### writing-plans

| Metric | Current | Baseline |
|--------|---------|----------|
| SKILL.md lines | 750 | 285 |
| Task files | 7 | N/A |
| Task total lines | 471 | N/A |
| Extraction ratio | .62 | N/A |
| Optional language | No | N/A |
| Mermaid flowchart | YES | N/A |
| **Tier** | **P3** | N/A |


## Summary

| Tier | Count | Description |
|------|-------|-------------|
| P0 (Critical) | 4 | Optional invocation + high extraction + no mermaid |
| P1 (High) | 6 | High extraction ratio (>2.0x) |
| P2 (Medium) | 15 | Optional invocation language only |
| P3 (Healthy) | 15 | Ratio < 2.0x and mandatory language |
| **Total** | **40** | |

## Restoration Priority

1. **P0 skills**: Restore mandatory language + workflow content + add mermaid flowcharts
2. **P1 skills**: Restore workflow content to 500-600 words/task minimum
3. **P2 skills**: Replace optional language with mandatory invocation rules
4. **P3 skills**: Add mermaid flowcharts if missing, otherwise no action needed

---
Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)
