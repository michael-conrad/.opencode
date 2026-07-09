# [SPEC-FIX] Three-tier finding classification (auto-fix/conditional/flag-for-review) enables non-binary outcomes across all skills

## Problem

The three-tier finding classification model (`auto-fix` / `conditional` / `flag-for-review`) is the upstream root cause of non-binary outcomes across the entire skill ecosystem. It is defined canonically in `skills/approval-gate/enforcement/adversarial-verification.md` and referenced by ~30+ task files.

The model creates a structural "minor defects are acceptable" persona:

| Tier | Meaning | Problem |
|------|---------|---------|
| `auto-fix` | Agent fixes without asking | Reasonable for non-substantive fixes |
| `conditional` | Agent flags, dev decides | Creates ambiguity about who owns the fix |
| `flag-for-review` | Advisory only, doesn't block | The core problem — "defects are acceptable" |

This contradicts `default.txt` line 103: "Correctness is the only success metric."

## Relationship to #1792

#1792 removes `flag-for-review` from audit task files as a surgical fix. This spec addresses the systemic root cause: the three-tier model itself, which is referenced across all skills (not just audit). The two specs are sequenced: #1792 first (audit-only), then this spec (cross-skill migration).

## Affected Files

### Canonical definition

- `skills/approval-gate/enforcement/adversarial-verification.md` — Redesign or remove the three-tier classification model

### Task files referencing the three-tier model (~30+ files)

- All audit task files (spec-audit, verification-audit, concern-separation, plan-fidelity, test-quality-audit, spec-summary, closure-verification, content-audit, guideline-audit, coherence-maintenance, drift-detection, cross-validate, resolve-models)
- `skills/verification-before-completion/tasks/verify.md` — Finding classification table uses three tiers
- `skills/verification-before-completion/tasks/completion.md` — Uses `conditional` classification
- `skills/finishing-a-development-branch/tasks/checklist.md` — Uses `flag-for-review` for process checks
- `skills/finishing-a-development-branch/tasks/prepare.md` — Uses `flag-for-review` for process checks
- All other skill task files that reference `auto-fix`, `conditional`, or `flag-for-review`

### Guidelines

- `guidelines/000-critical-rules.md:422` — Stale reference: "Auto-fix/conditional/flag-for-review classification"

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `adversarial-verification.md` three-tier model is redesigned or removed. No classification tier implies "defects are acceptable" | `string` |
| SC-2 | All ~30+ task files that reference `auto-fix`, `conditional`, or `flag-for-review` are migrated to the new classification model | `string` |
| SC-3 | `guidelines/000-critical-rules.md:422` is updated to reflect the new classification model | `string` |
| SC-4 | Behavioral test: an audit sub-agent does not produce `flag-for-review` findings — all findings are binary PASS/FAIL | `behavioral` |
| SC-5 | Behavioral test: a VbC sub-agent does not produce `conditional` findings — all findings are binary PASS/FAIL | `behavioral` |

## Constraints

- Must be sequenced after #1792 (which removes `flag-for-review` from audit tasks as a surgical first step)
- The `auto-fix` tier may be preserved for non-substantive fixes (formatting, typos) — the redesign should focus on eliminating the "defects are acceptable" tiers
- The `default.txt` persona is correct and must NOT be changed

## Dependencies

- #1792 — Surgical removal of `flag-for-review` from audit tasks (prerequisite)
