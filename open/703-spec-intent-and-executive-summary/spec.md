---
number: 703
title: "[SPEC] Intent and Executive Summary Preamble for Specs"
status: "open"
labels: [spec, approved-for-pr, spec-structure]
created: "2026-05-20T19:25:47.080628Z"
updated: "2026-05-20T19:29:33.916660Z"
github_issue: 733
author: "Michael Conrad"
github_url: "https://github.com/michael-conrad/.opencode/issues/733"
promoted_at: "2026-05-20T19:20:09Z"
remote_issue: "733"
remote_url: "https://github.com/michael-conrad/.opencode/issues/733"
---

## Intent and Executive Summary

**Problem Statement:** Specs drift over time and become hard to interpret later. Without recorded context, future readers — including AI agents — cannot reconstruct why a particular approach was chosen, what alternatives were considered, or what problem was being solved. This erodes the spec's value as a historical artifact.

**Root Cause:** Specs capture the *what* and the *how* but not the *why* — rationale, discarded alternatives, and design decisions are implicit in the author's mind at creation time but never persisted.

**Approach Chosen:** Add a structured preamble section (`## Intent and Executive Summary`) to every spec, positioned before the existing body. It captures the historical context without diluting the spec itself.

**Alternatives Considered:**
- Appending the section to the end (rejected — loses chronological prominence)
- Embedding context inline in existing sections (rejected — fragments the intent)
- A separate metadata YAML block (rejected — less readable, agents handle it worse)

**Key Design Decisions:**
- Preamble fields are plain Markdown prose (not YAML frontmatter)
- Preamble is mandatory for standard+ complexity specs; minimal specs may omit
- Preamble does NOT replace Summary/Objective — it precedes and contextualizes it
- Existing specs are NOT retrofitted (forward-only)

## Requirements

### Explicit Requirements

| ID | Requirement | Verification |
|----|-------------|-------------|
| R1 | `## Intent and Executive Summary` section defined as first section after STATUS/CREATED header, before any spec body | Guideline text specifies position |
| R2 | Preamble contains exactly 5 fields: Problem Statement, Root Cause / Motivation, Approach Chosen, Alternatives Considered & Why Discarded, Key Design Decisions | Guideline defines fields |
| R3 | Preamble is mandatory for standard+ complexity specs; minimal/bug-fix specs may omit | Exception rule documented |
| R4 | Existing specs are NOT retrofitted | Explicit non-requirement |
| R5 | Preamble does NOT replace existing Summary/Objective sections | Positional rule: precedes, does not replace |
| R6 | Missing preamble in a standard+ spec is a spec-producer defect, not a reviewer miss. The producing agent owns the omission and must remediate. Escalation only after verified remediation failure. | Behavioral test |

### Implicit Requirements

| ID | Requirement |
|----|-------------|
| I1 | Spec auditor must verify preamble presence for standard+ specs |
| I2 | Preamble fields populated at creation time, not post-hoc |
| I3 | All templates and examples updated to show preamble |
| I4 | Spec-auditor reports missing preamble as a producer defect, not reviewer oversight |

## Success Criteria

| SC | Criterion | Verification |
|----|-----------|-------------|
| SC-1 | All spec structure guidelines list `## Intent and Executive Summary` as the first section | `grep` for presence in 140, 142, 143, 144 |
| SC-2 | `write.md` Step 5 lists preamble for standard+ complexity specs | Read task file |
| SC-3 | Spec-auditor checks include preamble content area verification — reports missing preamble as SPEC-PRODUCER defect | Read audit task files; behavioral test for producer-defect classification |
| SC-4 | No existing specs were modified (forward-only) | `git diff --stat` against dev |

## Accountability Model Alignment (per #763)

This spec intersects with #763 Principle 5: "Missing text artifacts is a fail — agent owns producing all deliverables."

**Principle P5 alignment:** A missing preamble in a standard+ spec is a **spec-producer defect**, not a reviewer miss. The producing agent owns the omission and must autonomously remediate.

## Risk Table

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Forgetting preamble in new specs | Medium | Medium | Spec-audit check + mandatory status in write task |
| Preamble duplicates Summary content | Medium | Low | Guidance: preamble is historical context, Summary is spec purpose |
| Existing templates missed in update | Low | Medium | File-level checklist in affected files section |

## Edge Cases

- **Trivial bug fix spec (1 line change):** Preamble optional per complexity-tier model
- **Spec already has extensive rationale:** Preamble supplements, does not replace
- **Multi-phase spec with sub-issues:** Preamble goes in parent spec only

## Change Control

| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0 | 2026-05-20 | Initial spec | |

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5)