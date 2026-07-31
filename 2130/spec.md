---
remote_issue: 2130
remote_url: https://github.com/michael-conrad/.opencode/issues/2130
labels: [spec]
---

## Intent and Executive Summary

**Problem Statement:** `067-context-completeness.md` (150 lines) contains structural redundancy — duplicate rule statements, teaching material, and verbose decision tables — that degrades agent compliance by reducing rule density in sub-agent context windows.

**Root Cause/Motivation:** The guideline was written for human readability (explanatory tables, illustrative examples, cross-reference prose) without accounting for AI-agent consumption where every line competes for limited sub-agent context. Two copies of the same rule ("read ALL comments") create ambiguity about which is authoritative. Teaching material (Why This Matters, Examples, Relationship to Other Critical Rules) displaces enforceable rule content.

**Approach Chosen:** Targeted compaction: collapse duplicate sections, remove teaching material, replace verbose tables with concise statements. Keep all enforceable rule content (Zero Tolerance, Scope of Resources, Evidence Requirement, Staleness Rule, FORBIDDEN/REQUIRED, Related Guidelines).

**Alternatives Considered & Why Discarded:**
- Partial compaction (keep shortened versions): Rejected — partial tables imply some misses are unimportant.
- Condense to prose: Rejected — the table format is the problem, not the content.
- No compaction: Rejected — duplicate Core Principle is a real defect.

**Key Design Decisions:**
- Teaching material is identified by function (explain/justify/illustrate), not by format.
- Cross-reference sections are split: explanatory prose (Relationship to Other Critical Rules) is removed; compact reference list (Related Guidelines) is kept.
- Compliance is enforced structurally (behavioral tests, pre-commit hooks), not motivationally.

**Cost-Benefit Justification:** The compaction removes 50+ lines of explanatory content to eliminate a concrete defect (duplicate authoritative rule) and increase rule density for sub-agents. The cost is lost explanatory context for human readers and sub-agents loading this guideline in isolation. The benefit is unambiguous rule authority (one "read ALL comments" statement) and higher rule-to-noise ratio in sub-agent context windows. For sub-agents that load this guideline, every line of teaching material is a line that could carry an enforceable rule — the compaction trades explanatory depth for enforcement clarity. This tradeoff is justified because: (1) the duplicate rule is a real defect that causes agent confusion, (2) behavioral tests and pre-commit hooks enforce compliance structurally, and (3) the Related Guidelines section preserves cross-reference navigation in compact form.

## Problem

`067-context-completeness.md` (150 lines) contains structural redundancy that degrades agent compliance. Three distinct problems:

1. **Duplicate content**: Core Principle (## Core Principle section) restates Zero Tolerance (## Zero Tolerance Rule section) with identical wording ("read ALL comments", "body/description alone is NEVER sufficient context"). Two copies of the same rule in the same file create ambiguity about which is authoritative — agents may treat one as binding and the other as advisory.

2. **Teaching material displaces rule density**: Why This Matters table (## Why This Matters section), Examples table (### Examples subsection), and Relationship to Other Critical Rules section (## Relationship to Other Critical Rules section) explain, illustrate, or cross-reference the rule rather than stating it. For sub-agents that load this guideline, every line of teaching material is a line that could carry an enforceable rule. The guideline's purpose is to govern agent behavior — not to educate the agent about why the rule exists.

3. **Verbose decision tables**: When This Applies table (## When This Applies section) is an 8-row decision table that can be expressed as a single sentence with one exception clause. The table format adds visual noise without adding rule content.

## Proposed Solution

### Operational Definition of "Teaching Material"

"Teaching material" means content whose primary function is to explain, justify, illustrate, or cross-reference a rule — not to state, enforce, or define the rule itself. Teaching material is identified by:
- **Explanatory framing**: "Why This Matters", "This is consistent with...", "This guideline complements..."
- **Illustrative examples**: Tables showing hypothetical scenarios (Examples table), decision matrices with no normative force
- **Cross-reference catalogs**: Lists of related guidelines that do not modify the rule's enforcement
- **Redundant restatement**: Content that repeats a rule already stated in the same file with identical normative force

Teaching material is not inherently harmful — it helps human readers. But for AI-agent-facing text where every line competes for limited sub-agent context, teaching material directly reduces rule density. The compaction removes teaching material only where the rule is already stated unambiguously elsewhere in the same file.

### Remove (teaching material):

| Section | Location | Rationale |
|---|---|---|
| Why This Matters table | ## Why This Matters section | Explanatory — illustrates consequences of non-compliance. Rule already stated in Zero Tolerance. |
| Examples table | ### Examples subsection | Illustrative — shows hypothetical scenarios for Staleness Rule. Rule already stated with De Minimis Bound. |
| Relationship to Other Critical Rules | ## Relationship to Other Critical Rules section | Cross-reference catalog — lists related rules without modifying enforcement. Agents with full context already have these cross-references loaded. |

### Collapse:

| Section | Action |
|---|---|
| Core Principle (## Core Principle section) | Merge into Zero Tolerance — same rule, same wording. The merged section retains the Core Principle's scope language ("reviewing, auditing, or taking any action") as elaboration within Zero Tolerance, not as a separate section. |

### Replace:

| Section | Current | Replacement |
|---|---|---|
| When This Applies table (## When This Applies section) | 8-row decision table | One sentence: "Before any action on a resource, read all comments. Exception: passive reading (no subsequent action) does not require comment reading." |

### Keep:

- Zero Tolerance Rule (with Core Principle merged in)
- Scope of Resources table (PR review comments clarification is critical)
- Evidence Requirement + COUNTS/NOT
- Staleness Rule + Significant Actions list + De Minimis Bound + Single Exchange Window
- FORBIDDEN/REQUIRED
- Related Guidelines section (distinct from Relationship to Other Critical Rules — Related Guidelines at ## Related Guidelines section is a compact reference list, not teaching material)

### Distinction: Related Guidelines vs. Relationship to Other Critical Rules

The file has two cross-reference sections:
- **Relationship to Other Critical Rules** (## Relationship to Other Critical Rules section): Prose paragraphs explaining how this guideline relates to each referenced rule. This is teaching material — it explains rather than enforces.
- **Related Guidelines** (## Related Guidelines section): A compact bullet list of guideline names with one-line descriptions. This is reference material — it tells sub-agents where to find related rules without explaining them.

**Action**: Remove Relationship to Other Critical Rules (teaching material). Keep Related Guidelines (reference material).

### Scope Analysis: critical-rules-012 Cross-References

The file contains two `critical-rules-012` entries (### [critical-rules-012] sections at the bottom of the file) in the critical violations section at the bottom. These are enforcement blocks that reference `067-context-completeness.md` and `issue-operations` skill. These entries are NOT affected by the compaction — they reference the guideline by name, not by section structure. The compaction does not rename or remove the guideline's identity.

**Staleness Rule subsections**: The Staleness Rule (## Staleness Rule section) contains three subsections: the main rule, Significant Actions Requiring Re-Read (### Significant Actions Requiring Re-Read subsection), and De Minimis Bound (### De Minimis Bound subsection). All three are kept. The Single Exchange Window (## Single Exchange Window section) is also kept as a separate subsection.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Core Principle content merged into Zero Tolerance — the phrase "read ALL comments" appears exactly once in the file (in the merged Zero Tolerance section), not twice | string | grep -c for 'read ALL comments' returns 1 |
| SC-2 | Why This Matters table removed | string | grep for absence of 'Why This Matters' |
| SC-3 | When This Applies table replaced with one-sentence exception containing "passive reading" | string | grep for 'passive reading' returns exactly 1 match |
| SC-4 | Examples table removed | string | grep for absence of 'Resource last read' |
| SC-5 | Relationship to Other Critical Rules section removed | string | grep for absence of 'Relationship to Other Critical Rules' |
| SC-6a | Zero Tolerance, Scope of Resources, Evidence Requirement, Staleness Rule (including Significant Actions, De Minimis Bound, Single Exchange Window), FORBIDDEN/REQUIRED, and Related Guidelines all remain with same content | string | diff each section against original; verify no content changes |
| SC-6b | Zero Tolerance, Scope of Resources, Evidence Requirement, Staleness Rule (including Significant Actions, De Minimis Bound, Single Exchange Window), FORBIDDEN/REQUIRED, and Related Guidelines remain in same position relative to each other | string | grep for each section header; verify order preserved |
| SC-6c | Zero Tolerance, Scope of Resources, Evidence Requirement, Staleness Rule (including Significant Actions, De Minimis Bound, Single Exchange Window), FORBIDDEN/REQUIRED, and Related Guidelines remain at same heading level (##) | string | grep for each section header at ## level; verify all at ## |

**Enforcement Gate:** All SCs MUST pass before the change is complete. If any SC fails, the change is reverted.

## Implementation Plan

- [ ] 1. **Collapse Core Principle into Zero Tolerance**
  - Edit `.opencode/guidelines/067-context-completeness.md`: Remove the ## Core Principle section header and body. Merge the scope language "reviewing, auditing, or taking any action" into the ## Zero Tolerance Rule section as elaboration.
  - Verify: `grep -c 'read ALL comments'` returns exactly 1.

- [ ] 2. **Remove Why This Matters, Examples, Relationship to Other Critical Rules**
  - Edit `.opencode/guidelines/067-context-completeness.md`: Delete the ## Why This Matters section (header + table + blank lines). Delete the ### Examples subsection (header + table + blank lines). Delete the ## Relationship to Other Critical Rules section (header + prose + blank lines).
  - Verify: grep for absence of 'Why This Matters', 'Resource last read', 'Relationship to Other Critical Rules'.

- [ ] 3. **Replace When This Applies table with one-sentence exception**
  - Edit `.opencode/guidelines/067-context-completeness.md`: Replace the ## When This Applies section (header + 8-row table) with: "Before any action on a resource, read all comments. Exception: passive reading (no subsequent action) does not require comment reading."
  - Verify: `grep -c 'passive reading'` returns exactly 1.

- [ ] 4. **Verify all keep sections remain with same content (SC-6a), same position (SC-6b), and same heading level (SC-6c)**
  - Run `diff` on each keep section against original to verify no content changes.
  - Run `grep` for each keep section header to verify order preserved.
  - Run `grep` for each keep section header at ## level to verify all at ##.

## Documentation Sources

- `.opencode/guidelines/067-context-completeness.md` — Authoritative source guideline being compacted. Verified by read tool at session start.

## Files Affected

- `.opencode/guidelines/067-context-completeness.md` — compacted

## Risks

1. **Semantic loss from collapsing Core Principle**: The Core Principle uses broader scope language ("reviewing, auditing, or taking any action") while Zero Tolerance uses narrower phrasing ("Acting on"). Merging them must preserve the broader scope. If the merge produces text that only covers "Acting on", agents may not apply the rule to reviewing and auditing. **Mitigation**: The merged section explicitly includes the broader scope language.

2. **Reduced agent compliance from removing Why This Matters**: The table concretely shows what gets missed and the consequence. Removing it may reduce agent motivation to follow the rule. **Mitigation**: The rule is enforced by pre-commit hooks and behavioral tests — not by agent motivation. Compliance is structural, not motivational.

3. **Sub-agent context loss from removing Relationship to Other Critical Rules**: Sub-agents that load this guideline in isolation may not know about related rules (Verification Honesty, Bug Discovery, Authority Source). **Mitigation**: The Related Guidelines section (kept) provides the same cross-references in a more compact format. Sub-agents with full context already have these cross-references loaded from the guidelines index.

4. **Duplicate "read ALL comments" phrase if Core Principle merge is incomplete**: If the merge leaves residual text containing "read ALL comments" in the old Core Principle location, SC-1 will fail. **Mitigation**: SC-1 explicitly tests for a single occurrence.

## Edge Cases

1. **Collapsing Core Principle creates duplicate "read ALL comments" phrase**: If the merge is done as a simple deletion of the Core Principle section header without removing the body text, the phrase "read ALL comments" appears twice. **Resolution**: The merge must remove the entire Core Principle section (header + body) and incorporate its scope language into Zero Tolerance. SC-1 catches this.

2. **Removing Why This Matters reduces agent compliance**: Agents that previously saw the consequence table may be less motivated to read comments. **Resolution**: Compliance is enforced by behavioral tests and pre-commit hooks, not by motivational content. If behavioral tests show regression, the table can be restored in a condensed form.

3. **Sub-agents need Relationship section for cross-reference context**: Sub-agents loading this guideline in isolation lose the prose explanation of how each related rule connects. **Resolution**: The Related Guidelines section (kept) provides the same cross-references. Sub-agents that need deeper context can read the referenced guidelines directly.

4. **When This Applies replacement loses nuance**: The 8-row table distinguishes between different action types (reviewing, acting, checking, responding, creating, reporting, reading). A one-sentence replacement may lose this granularity. **Resolution**: The exception clause ("passive reading does not require comment reading") captures the only meaningful distinction. All other rows are covered by "before any action on a resource."

5. **Examples table removal loses staleness illustration**: The table shows concrete scenarios for when re-reading is required. **Resolution**: The Staleness Rule text and De Minimis Bound already state the rule unambiguously. The examples are illustrative, not normative.

## Alternatives Considered

1. **Partial compaction (keep Why This Matters but shorten it)**: Keep the table but reduce it to 2-3 rows covering the most critical misses (authorization, direction change). **Rejected**: The table's value is completeness — a partial table implies some misses are unimportant. Either keep all rows or remove the table entirely.

2. **Keep Why This Matters but condense to prose**: Replace the table with 1-2 sentences explaining why comment reading matters. **Rejected**: The table format is the problem (visual noise), not the content. Prose would be shorter but still teaching material.

3. **Keep Relationship to Other Critical Rules but condense it**: Reduce from 3 bullet points to 1 sentence. **Rejected**: The section's purpose is explanatory — any version of it is teaching material. The Related Guidelines section already provides the cross-references.

4. **Keep When This Applies table but reduce rows**: Keep only the most common actions. **Rejected**: The one-sentence replacement with exception clause is strictly better — it covers all cases with fewer lines.

5. **No compaction at all**: Leave the file as-is. **Rejected**: The duplicate Core Principle is a real defect that causes agent confusion. The teaching material reduces rule density for sub-agents.

## Dependencies

- None.

---

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-07-31 | Revised spec: reframed Problem statement (semantic/behavioral justification), substantiated all claims with operational definitions, defined SCs operationally (SC-1/SC-3/SC-6), expanded scope analysis (critical-rules-012, Staleness Rule subsections, Related Guidelines vs Relationship distinction), replaced Risks escape hatch with honest assessment, added teaching material definition, added Alternatives Considered, added Edge Cases | Spec-audit FAIL — 8 of 11 holistic dimensions failed | OpenCode (deepseek-v4-flash) |
| 2026-07-31 | Fixed heading name: "Relationship to Other Guidelines" → "Relationship to Other Critical Rules" throughout spec. Split SC-6 into SC-6a (content preservation), SC-6b (position preservation), SC-6c (heading level preservation). Updated Phase 4 to reference SC-6a/SC-6b/SC-6c. | Validation found 2 defects: wrong heading name and compound SC-6 | OpenCode (deepseek-v4-flash) |
| 2026-07-31 | Added Intent and Executive Summary preamble with cost-frame justification. Replaced all line number references with stable section header anchors. Added Documentation Sources section. Added enforcement gate statement. Converted phases to checklist format with actionable sub-items. | Re-audit found 7 narrow structural failures | OpenCode (deepseek-v4-flash) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
