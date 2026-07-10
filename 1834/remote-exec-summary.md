> **Full spec and artifacts: [`.issues/1834/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1834)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/1834/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exec Summary

The spec-creation skill and its task files are missing several critical quality mandates that cause downstream defects: no research card consultation mandate, no live documentation URL verification, no interdependency checking, weak SC-fail cascading language, no anti-lobotomization language in the spec body template, a "simple specs may skip" escape hatch, contract file naming drift, and missing #1063 pipeline enforcement gates. This spec mandates all nine fixes as mandatory pipeline gates with behavioral enforcement.

### Cards (dependency order)
1. **Remove complexity escape hatch (#1552)** — Eliminate "simple specs may skip" language; all sections become mandatory
2. **Add research card consultation mandate** — Pipeline gate before requirements extraction
3. **Add live documentation URL verification** — Mandatory URL liveness check before spec completion
4. **Add interdependency checking and marking** — Check for overlapping/conflicting open specs before creation
5. **Strengthen SC-fail cascading statement** — Replace weak "all-or-nothing gate" with strong preamble language
6. **Add anti-lobotomization language** — Explicit prohibition in every generated spec body
7. **Fix contract file naming drift** — Rename write-* to create-*
8. **Add missing #1063 pipeline enforcement gates** — Anti-merge, doc-source-currency, SC-ID traceability
9. **Verify and close stale open issues** — #1229, #1064
10. **Create research card** — Document spec-creation skill state

### Key Decisions
- **All sections mandatory**: No tier-based skipping — every section in the spec body template is required regardless of spec complexity
- **Research card consultation is a pipeline gate**: Not optional — agents MUST check research cards before writing specs
- **Live documentation URLs are verified**: Each URL must be confirmed reachable; local docs are fallback only
- **Interdependency marking is bidirectional**: Both this spec and interdependent issues are marked
- **SC-fail cascading is a preamble section**: Embedded in every generated spec, not just a task file instruction
- **Anti-lobotomization is a preamble section**: Embedded in every generated spec with an SC that explicitly forbids test lobotomization

### Risk Callouts
- **Scope breadth**: 10 phases across 9 subsumed/coordinated issues — risk of incomplete implementation if phases are not tracked independently
- **Contract rename breakage**: Renaming write-* to create-* may break downstream consumers that reference the old names — mitigated by updating all references in the same change
- **Stale issue verification**: #1229 and #1064 may have partial implementation — mitigated by explicit verification before closure
