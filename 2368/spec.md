> **Full spec and artifacts: [`.opencode/.issues/2368/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2368)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2368/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] Update skill-creator skill — Read-link code-standards & attribution-provenance

## Problem

The skill-creator skill card currently references `080-code-standards.md` in its Cross-References section but lacks mandatory `Read [Text](path)` links to `code-standards-shared.md` (created by #2362) and `attribution-provenance.md` (created by #2360). Without these Read-links, sub-agents dispatched to validate skill cards cannot access the extracted procedural standards and attribution/provenance rules that 080 condensation will remove from the preloaded context.

As 080-code-standings condenses (per #2352), its procedural content moves to shared references. Skill-creator must anchor these references via mandatory Read-links to ensure validation sub-agents independently load the full standards — the preloaded context will no longer carry them.

## Scope

### In Scope

- Add a mandatory `Read [Text](reference/code-standards-shared.md)` link to the skill-creator SKILL.md in a position where validation sub-agents encounter it before executing validation tasks.
- Add a mandatory `Read [Text](reference/attribution-provenance.md)` link to the skill-creator SKILL.md alongside the code-standards-shared link.
- Use the `Read [Text](path)` pattern (link text = condensation of the linked file's purpose) — never the forbidden "See ..." citation form.
- Verify that both Read-links resolve to existing files (or files the prerequisite specs will create).

### Out of Scope

- Modifying skill-creator task files or `validate_skill_cards.py` — this spec targets only the SKILL.md itself.
- Re-inlining attribution/provenance or code-standards content into the skill card.
- Condensing 080-code-standards.md itself (handled by #2352).
- Creating the shared reference files themselves (handled by #2362 and #2360).
- Removing the existing Cross-References section or its entries.

## Approach

The skill-creator SKILL.md has two natural insertion points for the Read-links:

1. In the **Operating Protocol** section, where rule 5 (condensation-anchor) already establishes a skill-card-level mandate. Add rules 6 and 7 for the two Read-links.
2. Alternatively, in the **Cross-References** section, converting the 080 reference from a bare filename to a Read-link form.

Approach: Add the Read-links as new numbered rules in the Operating Protocol section (after rule 5), following the same format. This positions them as actionable mandates that sub-agents encounter before executing validation tasks. The Cross-References section retains its existing entries as secondary navigation aids.

Each Read-link uses condensed link text (purpose-as-subject, not path restatement):
- `Read [the extracted code-standards procedural sections](reference/code-standards-shared.md)` — not `Read [code-standards-shared.md]`
- `Read [the attribution and provenance header standards](reference/attribution-provenance.md)` — not `Read [attribution-provenance.md]`

## Success Criteria

### SC-1: code-standards-shared Read-link added to skill-creator SKILL.md

The skill-creator SKILL.md SHALL contain a `Read [Text](reference/code-standards-shared.md)` link in the Operating Protocol section (or an equivalent position reachable by validation sub-agents), using condensed link text that summarizes the file's purpose (not a path restatement).

**Evidence type:** string (grep for the Read-link pattern)

**Verification method:** grep the SKILL.md for the reference path and confirm the link text is a condensation, not a path restatement.

**Cost frame:** An agent that skips this link runs validation without the canonical procedural standards — every structural gate that depends on those rules produces false results. The defect cost is the full re-validation of every card under incorrect standards. The link costs one line and one tool call.

**Documentation sources:**
- Read-link pattern: `.opencode/guidelines/000-critical-rules.md` "Read-Link Cross-Reference Rule"
- Condensation-anchor rule: `.opencode/skills/skill-creator/SKILL.md` Operating Protocol rule 5

### SC-2: attribution-provenance Read-link added to skill-creator SKILL.md

The skill-creator SKILL.md SHALL contain a `Read [Text](reference/attribution-provenance.md)` link in the same section as the code-standards-shared link, using condensed link text.

**Evidence type:** string (grep for the Read-link pattern)

**Verification method:** grep the SKILL.md for the reference path and confirm the link text is a condensation.

**Cost frame:** Without this link, validation sub-agents enforce attribution rules from memory — which means every card validated after 080 condensation is validated without the authoritative attribution standard. The cost is inconsistent enforcement across all skill cards.

**Documentation sources:**
- Read-link pattern: `.opencode/guidelines/000-critical-rules.md` "Read-Link Cross-Reference Rule"
- Attribution/provenance content: `.opencode/reference/attribution-provenance.md` (created by #2360)

### SC-3: Link text is condensation (not path restatement)

Both Read-links SHALL use link text that is a condensation of the linked file's purpose (outcome as subject, distinctive), not a restatement of the file path. A path-restatement link (`[code-standards-shared.md]`) FAILs the structural condensation-format gate (CONDENSATION-001).

**Evidence type:** string (grep link text)

**Verification method:** Inspect the link text of each Read-link and confirm it describes the file's purpose, not its path.

**Cost frame:** Path-restatement links pass grep but fail the structural validation gate — they are dead weight that a human reviewer catches but an automated gate rejects. The cost is the false PASS that delays detection to review.

**Documentation sources:**
- Condensation-anchor rule: `.opencode/skills/skill-creator/SKILL.md` Operating Protocol rule 5
- Condensation-format gate: `validate_skill_cards.py` CONDENSATION-001

### SC-4: Existing skill-creator content preserved

No existing content SHALL be removed from the skill-creator SKILL.md aside from the specific changes described in this spec. All existing rules, operating protocol items, cross-references, and structural sections SHALL remain intact.

**Evidence type:** structural (diff check)

**Verification method:** Compare the modified SKILL.md against the original to confirm only the two Read-links were added.

**Cost frame:** An agent that accidentally removes or rewords existing content during the edit produces a spec that conflicts with its own intent. The cost is the re-validation cycle.

**Documentation sources:** N/A — diff comparison against the original file.

## SC Summary

```yaml
sc_count: 4
scs:
  - id: "SC-1"
    description: "code-standards-shared Read-link added to skill-creator SKILL.md"
    evidence_type: string
    plan_item: 1
  - id: "SC-2"
    description: "attribution-provenance Read-link added to skill-creator SKILL.md"
    evidence_type: string
    plan_item: 2
  - id: "SC-3"
    description: "Link text is condensation (not path restatement)"
    evidence_type: string
    plan_item: 3
  - id: "SC-4"
    description: "Existing skill-creator content preserved"
    evidence_type: structural
    plan_item: 4
```

## Pipeline Readiness

- **Pre-spec inspection:** Completed — skill-creator SKILL.md read at `.opencode/skills/skill-creator/SKILL.md` (144 lines)
- **Requirements extracted:** Yes — from existing issue body
- **Decomposition:** 4 SCs, single-phase
- **Analytical artifacts:** N/A — this is a content-addition spec targeting a single file; the spec body contains sufficient context
- **Dependencies:** #2362 (code-standards-shared.md), #2360 (attribution-provenance.md) — these specs must be implemented first so the referenced files exist
