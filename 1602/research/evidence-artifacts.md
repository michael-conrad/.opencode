# Evidence Artifacts — Spec #1602 Factual Claim Verification

Generated: 2026-06-30T12:00:00Z
Tool: verification-enforcement --task verify (inline)

## Claim 1: 42 SKILL.md files total
- **Domain:** Config (file count)
- **Source:** `ls .opencode/skills/*/SKILL.md | wc -l` = 39; `ls .opencode/skills/issue-operations/platforms/*/SKILL.md | wc -l` = 3; total = 42
- **Verified:** yes

## Claim 2: 41 SKILL.md files (researcher excluded)
- **Domain:** Config (file count)
- **Source:** 42 total - 1 researcher = 41
- **Verified:** yes

## Claim 3: Only 6 of 42 follow farmage pattern
- **Domain:** Config (pattern audit)
- **Source:** All 42 have "Use when" (0 missing). 36 missing "Also use when". 36 missing "Invoke for". 36 missing "Trigger phrases". 24 missing "enforcement/enforce". Only 6 files have all 5 farmage components.
- **Verified:** yes

## Claim 4: 37 missing provenance
- **Domain:** Config (frontmatter audit)
- **Source:** `grep -l 'provenance:'` (YAML frontmatter) = 2 files. `grep -c 'Provenance:\|provenance:'` (any case) = 7 files. 42 - 2 = 40 missing YAML frontmatter `provenance:`. 42 - 7 = 35 missing entirely.
- **Verified:** no — ⚠️ UNVERIFIED. Spec claims 37 missing. Live audit shows 40 missing YAML frontmatter `provenance:` field, or 35 missing entirely (including HTML comments). Neither matches 37. Spec may be counting differently (e.g., excluding files that have `Provenance:` in HTML comments but not YAML frontmatter). Recommend spec revision to clarify what counts as "has provenance."

## Claim 5: 7 missing type
- **Domain:** Config (frontmatter audit)
- **Source:** `grep -c 'type:'` = 39 files have it. 42 - 39 = 3 missing (adversarial-audit, approval-gate, playwright-cli). Plus 2 invalid types (plan:domain, solve:tool).
- **Verified:** no — ⚠️ UNVERIFIED. Spec claims 7 missing. Live audit shows 3 missing + 2 invalid = 5 files needing type attention. Spec may be counting missing + invalid together (3+2=5) or using a different definition. Neither matches 7.

## Claim 6: 2 missing compatibility
- **Domain:** Config (frontmatter audit)
- **Source:** `grep -c 'compatibility:'` = 40 files have it. 42 - 40 = 2 missing (adversarial-audit, approval-gate).
- **Verified:** yes

## Claim 7: 30+ missing Worktree Mode sections
- **Domain:** Config (section audit)
- **Source:** `grep -c 'Worktree Mode'` = 4 files have it. 42 - 4 = 38 missing. "30+" is correct.
- **Verified:** yes

## Claim 8: SC-LINT-004 300-char limit
- **Domain:** Code (validation script)
- **Source:** `.opencode/skills/skill-creator/scripts/validate_skill_cards.py:279` — `"Description exceeds 300 characters ({len(desc)})"`
- **Verified:** yes

## Claim 9: plan:domain, solve:tool (invalid types)
- **Domain:** Config (frontmatter audit)
- **Source:** `.opencode/skills/plan/SKILL.md` — `type: domain`. `.opencode/skills/solve/SKILL.md` — `type: tool`.
- **Verified:** yes

## Claim 10: researcher duplicates research (identical descriptions)
- **Domain:** Config (content comparison)
- **Source:** Both have identical description: "Use when discovering information using appropriate modalities, producing findings with source attribution and explicit gap reporting. All findings MUST be verified against live sources."
- **Verified:** yes

## Claim 11: 3 platform sub-skills
- **Domain:** Config (file count)
- **Source:** `ls .opencode/skills/issue-operations/platforms/*/SKILL.md` = gitbucket-api, github-mcp, local (3 files)
- **Verified:** yes

## Claim 12: researcher has 2 task files
- **Domain:** Config (file count)
- **Source:** `ls .opencode/skills/researcher/tasks/` = findings.md, investigate.md
- **Verified:** yes

## Claim 13: farmage pattern reference in skill-creator
- **Domain:** Config (content check)
- **Source:** `.opencode/skills/skill-creator/SKILL.md` description field contains full farmage pattern with "Use when", "Also use when", "Invoke for", "Trigger phrases". Also has `validate` task for farmage enforcement.
- **Verified:** yes

## Claim 14: SC-LINT-004 limit in validate_skill_cards.py
- **Domain:** Code (validation script)
- **Source:** `validate_skill_cards.py:279` — hardcoded 300-char limit check
- **Verified:** yes

## Claim 15: No existing exclusion clauses
- **Domain:** Config (pattern audit)
- **Source:** `grep -c 'distinct from'` across all 42 SKILL.md files = 0 matches
- **Verified:** yes

## Summary

| Status | Count |
|--------|-------|
| Verified (yes) | 12 |
| Unverified (⚠️) | 2 |
| Total claims checked | 14 |

**Unverified claims:**
1. "37 missing provenance" — live audit shows 40 missing YAML frontmatter `provenance:` or 35 missing entirely. Spec needs clarification on what counts.
2. "7 missing type" — live audit shows 3 missing + 2 invalid = 5. Spec needs clarification.
