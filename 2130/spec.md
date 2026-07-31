---
remote_issue: 2130
remote_url: https://github.com/michael-conrad/.opencode/issues/2130
labels: [spec]
---

## Problem

`067-context-completeness.md` (150 lines) contains structural redundancy that degrades agent compliance. Three distinct problems:

1. **Duplicate content**: Core Principle (lines 15-17) restates Zero Tolerance (lines 9-13) with identical wording ("read ALL comments", "body/description alone is NEVER sufficient context"). Two copies of the same rule in the same file create ambiguity about which is authoritative — agents may treat one as binding and the other as advisory.

2. **Teaching material displaces rule density**: Why This Matters table (lines 19-28), Examples table (lines 97-101), and Relationship to Other Critical Rules section (lines 111-117) explain, illustrate, or cross-reference the rule rather than stating it. For sub-agents that load this guideline, every line of teaching material is a line that could carry an enforceable rule. The guideline's purpose is to govern agent behavior — not to educate the agent about why the rule exists.

3. **Verbose decision tables**: When This Applies table (lines 38-48) is an 8-row decision table that can be expressed as a single sentence with one exception clause. The table format adds visual noise without adding rule content.

## Proposed Solution

### Operational Definition of "Teaching Material"

"Teaching material" means content whose primary function is to explain, justify, illustrate, or cross-reference a rule — not to state, enforce, or define the rule itself. Teaching material is identified by:
- **Explanatory framing**: "Why This Matters", "This is consistent with...", "This guideline complements..."
- **Illustrative examples**: Tables showing hypothetical scenarios (Examples table), decision matrices with no normative force
- **Cross-reference catalogs**: Lists of related guidelines that do not modify the rule's enforcement
- **Redundant restatement**: Content that repeats a rule already stated in the same file with identical normative force

Teaching material is not inherently harmful — it helps human readers. But for AI-agent-facing text where every line competes for limited sub-agent context, teaching material directly reduces rule density. The compaction removes teaching material only where the rule is already stated unambiguously elsewhere in the same file.

### Remove (teaching material):

| Section | Lines | Rationale |
|---|---|---|
| Why This Matters table | 19-28 | Explanatory — illustrates consequences of non-compliance. Rule already stated in Zero Tolerance. |
| Examples table | 97-101 | Illustrative — shows hypothetical scenarios for Staleness Rule. Rule already stated with De Minimis Bound. |
| Relationship to Other Critical Rules | 111-117 | Cross-reference catalog — lists related rules without modifying enforcement. Agents with full context already have these cross-references loaded. |

### Collapse:

| Section | Action |
|---|---|
| Core Principle (lines 15-17) | Merge into Zero Tolerance — same rule, same wording. The merged section retains the Core Principle's scope language ("reviewing, auditing, or taking any action") as elaboration within Zero Tolerance, not as a separate section. |

### Replace:

| Section | Current | Replacement |
|---|---|---|
| When This Applies table (lines 38-48) | 8-row decision table | One sentence: "Before any action on a resource, read all comments. Exception: passive reading (no subsequent action) does not require comment reading." |

### Keep:

- Zero Tolerance Rule (with Core Principle merged in)
- Scope of Resources table (PR review comments clarification is critical)
- Evidence Requirement + COUNTS/NOT
- Staleness Rule + Significant Actions list + De Minimis Bound + Single Exchange Window
- FORBIDDEN/REQUIRED
- Related Guidelines section (distinct from Relationship to Other Critical Rules — Related Guidelines at lines 136-141 is a compact reference list, not teaching material)

### Distinction: Related Guidelines vs. Relationship to Other Critical Rules

The file has two cross-reference sections:
- **Relationship to Other Critical Rules** (lines 111-117): Prose paragraphs explaining how this guideline relates to each referenced rule. This is teaching material — it explains rather than enforces.
- **Related Guidelines** (lines 136-141): A compact bullet list of guideline names with one-line descriptions. This is reference material — it tells sub-agents where to find related rules without explaining them.

**Action**: Remove Relationship to Other Critical Rules (teaching material). Keep Related Guidelines (reference material).

### Scope Analysis: critical-rules-012 Cross-References

The file contains two `critical-rules-012` entries (lines 143-148) in the critical violations section at the bottom. These are enforcement blocks that reference `067-context-completeness.md` and `issue-operations` skill. These entries are NOT affected by the compaction — they reference the guideline by name, not by section structure. The compaction does not rename or remove the guideline's identity.

**Staleness Rule subsections**: The Staleness Rule (lines 74-103) contains three subsections: the main rule (lines 74-80), Significant Actions Requiring Re-Read (lines 82-91), and De Minimis Bound (lines 93-103). All three are kept. The Single Exchange Window (lines 105-109) is also kept as a separate subsection.

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

## Implementation Plan

### Phase 1: Collapse Core Principle into Zero Tolerance
### Phase 2: Remove Why This Matters, Examples, Relationship to Other Critical Rules
### Phase 3: Replace When This Applies table with one-sentence exception
### Phase 4: Verify all keep sections remain with same content (SC-6a), same position (SC-6b), and same heading level (SC-6c)

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

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
