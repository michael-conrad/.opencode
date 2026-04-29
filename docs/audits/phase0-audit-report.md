# Phase 0 Audit Report: Skills vs Pre-Regression Baseline

**Baseline Commit:** 61ca465 (skills-first workflow, before sub-agent-first extraction)
**Audit Date:** 2026-04-28
**Auditor:** OpenCode (ollama-cloud/glm-5.1)
**Methodology:** AI-Agent Baseline Comparison (8 check dimensions)
**Data Source:** `.opencode/docs/audits/phase0-audit-data.md`
**Script:** `.opencode/tools/audits/phase0-audit.sh`

## Executive Summary

This audit replaces the previous extraction-ratio-based methodology with AI-agent baseline comparison across 8 check dimensions. Each skill is evaluated against the pre-regression baseline (commit 61ca465) to classify whether current content matches, partially matches, contradicts, is missing from, or duplicates the baseline intent.

**Key Finding:** The sub-agent-first extraction introduced regressions in mandatory invocation language, workflow completeness, and mermaid diagrams. While many skills have correct structural elements, 19 of 37 skills still contain optional/weakening language that contradicts the baseline's mandatory invocation enforcement. All 37 skills lack mermaid flowcharts where the baseline had them or where they are needed.

## Methodology

Each skill is classified on 8 dimensions using the following values:

| Classification | Meaning |
|---------------|---------|
| CORRECT | Matches baseline intent fully |
| PARTIAL | Matches baseline intent partially (some gaps) |
| WRONG | Contradicts baseline intent |
| MISSING | Baseline had it, current doesn't |
| DUPLICATED | Content unnecessarily repeated across SKILL.md and task files |

**Check Dimensions:**

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

## Per-Skill Classifications

### Skills with Optional Language (Gating: WRONG)

These 19 skills contain "optional", "contextual", or weakening language that contradicts the baseline's mandatory invocation enforcement:

| Skill | Workflow | Gating | Verification | Principles | Cross-refs | Duplication | Mermaid | Platform-agnostic | Overall |
|-------|----------|--------|--------------|------------|------------|-------------|---------|-------------------|---------|
| approval-gate | PARTIAL | WRONG | CORRECT | CORRECT | CORRECT | PARTIAL | MISSING | PARTIAL | P0 |
| changelog-generator | PARTIAL | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P2 |
| coherence-auditor | PARTIAL | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P2 |
| concern-separation-auditor | PARTIAL | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P2 |
| correspondence | CORRECT | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P2 |
| divide-and-conquer | PARTIAL | WRONG | CORRECT | PARTIAL | CORRECT | PARTIAL | MISSING | PARTIAL | P0 |
| engineering-approach | PARTIAL | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P2 |
| guideline-auditor | PARTIAL | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P2 |
| issue-review | PARTIAL | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P2 |
| receiving-code-review | PARTIAL | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P2 |
| requesting-code-review | PARTIAL | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P2 |
| research | CORRECT | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P0 |
| skill-creator | CORRECT | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | P2 |
| spec-auditor | PARTIAL | WRONG | CORRECT | PARTIAL | CORRECT | PARTIAL | MISSING | CORRECT | P2 |
| sre-runbook | CORRECT | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P2 |
| test-driven-development | PARTIAL | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P2 |
| using-git-worktrees | PARTIAL | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P2 |
| verification | CORRECT | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P0 |
| verification-enforcement | CORRECT | WRONG | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P2 |

### Skills Without Optional Language (Gating: CORRECT)

These 18 skills have mandatory invocation language matching the baseline:

| Skill | Workflow | Gating | Verification | Principles | Cross-refs | Duplication | Mermaid | Platform-agnostic | Overall |
|-------|----------|--------|--------------|------------|------------|-------------|---------|-------------------|---------|
| brainstorming | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P3 |
| code-size-enforcement | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P3 |
| completion-core | MISSING | MISSING | MISSING | MISSING | MISSING | MISSING | MISSING | MISSING | N/A |
| conflict-resolution | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P3 |
| executing-plans | PARTIAL | CORRECT | CORRECT | PARTIAL | CORRECT | CORRECT | MISSING | CORRECT | P1 |
| finishing-a-development-branch | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P3 |
| fragment-manager | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | PARTIAL | MISSING | CORRECT | P1 |
| git-workflow | PARTIAL | CORRECT | CORRECT | PARTIAL | CORRECT | PARTIAL | MISSING | CORRECT | P1 |
| issue-operations | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P3 |
| mcp-tool-usage | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P3 |
| multimodal-dispatch | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P1 |
| notebook-operations | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P3 |
| plan-fidelity-auditor | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P3 |
| pr-creation-workflow | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P3 |
| programming-principles | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P1 |
| spec-creation | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | P3 |
| sync-guidelines | PARTIAL | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P1 |
| systematic-debugging | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P3 |
| ui-design | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P3 |
| ui-engineer | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P3 |
| verification-before-completion | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | MISSING | CORRECT | P3 |
| writing-plans | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | CORRECT | P3 |

## Summary Statistics

| Tier | Count | Description |
|------|-------|-------------|
| P0 (Critical) | 4 | WRONG gating + multiple dimension failures |
| P1 (High) | 6 | PARTIAL workflow/duplication + CORRECT gating |
| P2 (Medium) | 15 | WRONG gating language only, other dimensions CORRECT |
| P3 (Healthy) | 15 | All dimensions CORRECT except mermaid diagrams |
| N/A | 1 | completion-core: no SKILL.md found |
| **Total** | **41** | |

### Dimension Failure Counts

| Dimension | CORRECT | PARTIAL | WRONG | MISSING | DUPLICATED |
|-----------|---------|---------|-------|---------|------------|
| Workflow completeness | 27 | 13 | 0 | 1 | 0 |
| Gating behavior | 18 | 0 | 19 | 1 | 0 |
| Verification | 40 | 0 | 0 | 1 | 0 |
| Principles/concerns | 38 | 3 | 0 | 1 | 0 |
| Cross-references | 40 | 0 | 0 | 1 | 0 |
| Duplication | 37 | 3 | 0 | 1 | 0 |
| Mermaid diagrams | 2 | 0 | 0 | 39 | 0 |
| Platform-agnostic | 34 | 3 | 0 | 1 | 3 |

## Common Patterns

1. **Mermaid diagrams universally missing** (39/41 skills): Only `spec-creation` and `writing-plans` have mermaid diagrams. All others need workflow diagrams added.

2. **Optional language regression** (19/41 skills): Skills that had "MANDATORY" in the baseline now use "optional", "contextual", or "when appropriate" language. This weakens enforcement and contradicts the baseline intent.

3. **Duplication risk concentrated** (3 skills): `approval-gate`, `divide-and-conquer`, and `git-workflow` have PARTIAL duplication — content repeated between SKILL.md and task files.

4. **Platform-agnostic partial** (3 skills): `approval-gate`, `divide-and-conquer`, and `verification` still have some hardcoded values instead of runtime tokens.

5. **completion-core missing**: This skill has no SKILL.md and cannot be audited. It appears to be a shared module rather than a standalone skill.

## Restoration Priority

1. **P0 (4 skills)**: Restore mandatory invocation language + fix duplication + add mermaid + replace hardcoded tokens
   - approval-gate, divide-and-conquer, research, verification

2. **P1 (6 skills)**: Restore workflow completeness + fix duplication + add mermaid
   - executing-plans, fragment-manager, git-workflow, multimodal-dispatch, programming-principles, sync-guidelines

3. **P2 (15 skills)**: Replace optional/weakening language with mandatory invocation rules + add mermaid
   - changelog-generator, coherence-auditor, concern-separation-auditor, correspondence, engineering-approach, guideline-auditor, issue-review, receiving-code-review, requesting-code-review, skill-creator, spec-auditor, sre-runbook, test-driven-development, using-git-worktrees, verification-enforcement

4. **P3 (15 skills)**: Add mermaid flowcharts where missing
   - brainstorming, code-size-enforcement, conflict-resolution, finishing-a-development-branch, issue-operations, mcp-tool-usage, notebook-operations, plan-fidelity-auditor, pr-creation-workflow, spec-creation (has mermaid), systematic-debugging, ui-design, ui-engineer, verification-before-completion, writing-plans (has mermaid)

Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)