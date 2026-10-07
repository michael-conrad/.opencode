---
number: 705
title: "[BUG] Spec and plan writers write SCs as current-state assertions instead of spec requirements"
status: "open"
labels: [bug, for_analysis]
created: "2026-05-20T19:26:51.880552Z"
updated: "2026-05-20T19:29:34.279822Z"
github_issue: 639
author: "Michael Conrad"
github_url: "https://github.com/michael-conrad/.opencode/issues/639"
promoted_at: "2026-05-20T19:19:36Z"
remote_issue: "639"
remote_url: "https://github.com/michael-conrad/.opencode/issues/639"
---

## Bug Report

**What went wrong:** Adversarial auditors evaluating spec #632 correctly FAILed success criteria (SCs) because implementations didn't exist yet. The SCs were written as current-state assertions ("outputs YAML", "returns matches ONLY") rather than spec requirements ("MUST output YAML", "MUST return matches ONLY"). This caused 5 cycles of remediation before a human caught the root cause: **the SC writing convention is wrong**, not the individual spec.

**Root cause:** The spec/plan writer skills and templates do not mandate MUST/SHALL requirement language with verification-phase annotations. SCs default to present-tense descriptive assertions that auditors interpret as current-state checks rather than future-state requirements.

**Impact:** Every spec that goes through adversarial audit risks multiple remediation cycles before a human catches that the SC wording convention is the problem.

**Evidence:**
- Spec #632 went through 5 audit cycles (10 auditor runs total) before root cause was identified
- Cycle 5 Kimi auditor correctly FAILed 13/18 SCs solely because "implementation doesn't exist"
- DeepSeek auditor in cycle 5 PASSED the same SCs by evaluating spec clarity instead of current state

**Proposed fix:**

1. **SC template convention:** All SCs MUST use requirement language (MUST, SHALL, MUST NOT) rather than descriptive language. Each SC MUST include Requirement column, Verification column (WHEN and HOW), and Type column.

2. **Auditor evaluation criteria change:** Auditors MUST evaluate SCs for clarity, completeness, unambiguousness, and verifiability — NOT for current-state satisfaction.

3. **Skill/template update:** The `spec-creation` and `writing-plans` skills should enforce the MUST/SHALL + verification-phase convention.

## Success Criteria

| SC | Requirement | Verification | Type |
|----|-------------|-------------|------|
| SC-1 | The spec-creation skill template MUST include an SC format convention that mandates MUST/SHALL requirement language and a verification-phase column | GREEN-phase: grep for MUST/SHALL pattern in spec-creation task template | Content |
| SC-2 | The writing-plans skill template MUST include the same SC format convention | GREEN-phase: grep for MUST/SHALL pattern in writing-plans task template | Content |
| SC-3 | The adversarial-audit skill MUST include evaluation criteria that distinguish SC quality from current-state satisfaction | GREEN-phase: grep for evaluation criteria in adversarial-audit SKILL.md or task files | Content |
| SC-4 | Existing spec SC convention docs (if any) MUST be updated to reflect the new MUST/SHALL + verification-phase format | GREEN-phase: grep for SC format convention in guideline files | Content |

## Accountability Model Alignment (per #763)

This bug intersects with #763 Principle 3: "Defective spec/plan is on the agent — agent owns defects, remediates."

Under #763, when an auditor detects SCs written as current-state assertions, the producing agent must autonomously remediate them — rewriting the SCs with MUST/SHALL language — not escalating to the developer.

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)