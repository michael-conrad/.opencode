**STATUS:** Draft
**Created:** 2026-07-12
**License:** MIT
**Provenance:** AI-generated

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

`spec-creation/tasks/create.md` defines two mutually exclusive remote issue body formats across three separate steps:

- **Step 29 (Step 7r, line 611):** A 6-part flat format: Spec Reference Blockquote → Problem → Scope → Approach → Impact → AI Agent Instructions
- **Step 30 (Step 7, line 671):** "Prepend the blockquote" without defining the body content format that follows it
- **Step 31 (Step 7a, line 697):** A cards-based format: Spec Blockquote → Exec Summary → Cards (dependency order) → Key Decisions → Risk Callouts

These are structurally incompatible designs. An agent following Step 7r produces a Problem/Scope/Approach/Impact spec. An agent following Step 7a produces a Cards/KRs/RC spec. Most existing remote specs have incorrect formats because the agent's choice between Step 7r and Step 7a is ambiguous and model-dependent.

Additionally, Step 5 (line 51) instructs the agent to place a preamble (STATUS/CREATED/License/Provenance) and compliance blockquote "at the top (after the preamble/user greeting)" of "the generated spec body" — without clarifying whether this means the local spec.md or the remote issue body. This ambiguity has caused the preamble and compliance blockquote to leak into remote issue bodies, where they don't belong.

**Root Cause:** create.md was assembled from multiple iterations without reconciling redundant format definitions. Step 7r was added later describing a flat format, without noticing that Step 7a already defined a cards-based format. Step 5 was written for the local spec.md format but never scoped itself to local-only.

## Scope

**In scope:**
- Remove Step 7r's redundant 6-part flat format definition
- Merge Step 7r's unique content (AI Agent Instructions, URL construction rules, constraints table) into Step 7a
- Clarify Step 5 wording: preamble + compliance blockquote are for local spec.md only
- Verify no other steps in create.md cross-reference Step 7r
- Behavioral enforcement tests for the above

**Out of scope:**
- No changes to the local spec.md format (Steps 1a–1d remain untouched)
- No changes to the YAML artifact generation pipeline
- No changes to other task files in spec-creation
- No changes to other potential defects in create.md (duplicate writing instructions, ordering, step numbering — separate issue if approved)

## Root Cause Analysis

Verified by reading `create.md` lines 611–669 (Step 7r), 697–736 (Step 7a), and 51–65 (Step 5):

| Location | Content | Problem |
|----------|---------|---------|
| Step 7r (line 611) | 6-part flat: Problem/Scope/Approach/Impact | Contradicts Step 7a's cards format |
| Step 7a (line 697) | Cards: Exec Summary/Cards/Key Decisions/Risk Callouts | Lacks AI Agent Instructions section |
| Step 5 (line 51) | "Compliance blockquote at the top (after the preamble)" | Ambiguous — spec.md or remote body? |
| Step 7r URL rules (line 619–626) | Character-match verification, repo-awareness guard | Should move to Step 7a |
| Step 7r constraints table (line 659–667) | Length, structure, tone, independence | Should move to Step 7a |

## Alternatives Considered & Why Discarded

### Alternative A: Keep both formats, add disambiguation text
**Discarded.** An agent at the pre-output decision point will not read disambiguation text carefully enough to choose between two contradictory specs. The only reliable fix is to have one format definition.

### Alternative B: Remove Step 7a, keep Step 7r's flat format
**Discarded.** Issue #1877 proves the cards format works correctly in practice. The cards format provides better stakeholder readability (Key Decisions and Risk Callouts are explicit sections, not embedded in "Approach").

### Alternative C: Keep both formats and let the agent choose
**Discarded.** This is the current state, and it produces inconsistent results (most specs wrong, some right). Model-dependent format selection is unacceptable for a deterministic task procedure.

## Proposed Changes

### Card 1: Remove Step 7r

Delete the entire Step 7r section (lines 611–669) from `create.md`. This removes the contradictory 6-part flat format, the redundant blank template, and the duplicate AI Agent Instructions template.

**Risk:** Other steps may reference Step 7r's content. Audit all cross-references in `create.md` before deletion.

### Card 2: Merge Step 7r content into Step 7a

Before or within Step 7a, add:
- The AI Agent Instructions section template (currently only in Step 7r)
- The URL construction rules (character-match verification, repo-awareness guard, substitution verification)
- The constraints table (length, structure, tone, independence, links, exclusions, platform)

Update Step 7a's example format to include the AI Agent Instructions section.

### Card 3: Fix Step 5 wording

Change "The generated spec body MUST include a compliance statement blockquote at the top (after the preamble/user greeting)" to explicitly state this applies to the **local `.issues/{N}/spec.md`** file, not the remote issue body.

Add a note: "The remote issue body uses the blockquote format from Step 6.8 followed by the exec summary format defined in Step 7a. Do NOT include preamble (STATUS/CREATED) or compliance blockquote in the remote issue body."

### Card 4: Behavioral enforcement tests

Write a behavioral test that sends a "create a spec" prompt and verifies the agent produces the cards-based format (Exec Summary → Cards → Key Decisions → Risk Callouts → AI Agent Instructions) rather than the flat format (Problem/Scope/Approach/Impact). Confirm RED state before change, GREEN after.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unavoidable, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | 
|----|-----------|---------------|---------------------|
| SC-1 | Step 7r (lines 611–669) removed from `create.md` | `string` | grep for "Step 7r" absent from create.md |
| SC-2 | AI Agent Instructions section template present in Step 7a | `string` | grep Step 7a block for "## AI Agent Instructions" |
| SC-3 | URL construction rules (character-match, repo-awareness, substitution) present in Step 7a | `string` | grep Step 7a for "character-match verification" and "repo-awareness" |
| SC-4 | Constraints table present in Step 7a | `string` | grep Step 7a for "Constraints table" or similar |
| SC-5 | Step 5 explicitly states preamble + compliance are local spec.md only | `string` | grep Step 5 for "local \`.issues/.*/spec.md\`" |
| SC-6 | No other step in create.md cross-references Step 7r | `string` | grep create.md for "Step 7r" — must return 0 matches |
| SC-7 | Behavioral test exists confirming cards format is produced (RED before fix, GREEN after) | `behavioral` | opencode-cli run with spec-creation prompt → verify stderr shows cards-based format |

## SC-to-Root-Cause Traceability

| SC ID | Root Cause Element | Content Area |
|-------|-------------------|--------------|
| SC-1 | Redundant Step 7r removed | Card 1: Remove Step 7r |
| SC-2 | Missing AI Agent Instructions in Step 7a | Card 2: Merge into Step 7a |
| SC-3 | Missing URL rules in Step 7a | Card 2: Merge into Step 7a |
| SC-4 | Missing constraints in Step 7a | Card 2: Merge into Step 7a |
| SC-5 | Step 5 ambiguity about preamble location | Card 3: Fix Step 5 |
| SC-6 | Cross-reference audit prevents breakage | Card 1: Verify no dangling refs |
| SC-7 | Agent produces wrong format | Card 4: Behavioral tests |

## Risk Traceability

| RISK-ID | Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-------------|------------|--------|------------|-------------|
| RISK-1 | Other steps reference Step 7r content | Medium | High — dangling refs produce broken spec generation | SC-6 audits all cross-references before deletion |
| RISK-2 | Step 5 fix misses remote body exclusion | Low | Medium — preamble leaks into remote body | SC-5 explicitly tests for spec.md-only wording |

## Risks

- **Dangling references**: Steps before 29 may reference Step 7r content. Full audit of `create.md` cross-references required before deleting Step 7r.

## Related Artifacts

- Research card: `.opencode/.issues/research-cards/create-md-remote-format-defect.md`
- Source: `.opencode/skills/spec-creation/tasks/create.md` lines 611–669 (Step 7r), 697–736 (Step 7a), 51–65 (Step 5)
- Canonical format reference: Issue #1877
- Spec-creation skill: `.opencode/skills/spec-creation/SKILL.md`

**Documentation Sources:**

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `create.md` lines 611–669, 697–736, 51–65 | Identify contradictory format definitions |
| GitHub Issues | `.opencode/issues/1877` | Verify correct cards format |
| GitHub Issues | `.opencode/issues/1900` | Verify wrong format produced by current skill |


Co-authored with AI: OpenCode (deepseek-v4-flash-free)
