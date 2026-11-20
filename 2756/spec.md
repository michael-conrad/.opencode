# Spec — Store search for a matching existing spec before filing a new spec

## 1. Intent and Executive Summary

**Problem Statement** — The spec/issue work-entry flow lacks a required step to search the issue store for an already-existing spec covering the same requirement or behavior class before a new spec is filed. Observed 2026-11-19 in hermes-ingest-pubmed: during mid-session implementation, a developer requirement surfaced and the agent filed a new spec (`.issues/303/spec.md`) without searching; an equivalent, developer-sanctioned spec already existed (`.issues/302/spec.md`, filed earlier the same day on the developer's triage verdict). The duplicate was discovered only when the developer pointed at it, costing a correction cycle and a withdrawn record.

**Root Cause / Motivation** — No card text in the deck mandates a store search before a new spec filing, so the omission is procedural, not agent negligence: the flow's own structure permits duplicate filings when requirement wording differs from an existing spec's wording. The withdrawal/reconciliation burden and the risk of divergent requirement records both come from the missing step; it must be solved now because duplicate spec records corrupt the store's authority model (two specs, one requirement).

**Approach Chosen** — Extend the `spec` card's work-entry/filing flow and the `issues` card's work-entry conversion clause with an explicit search step: before filing any new spec, the agent searches the local issue store (and the linked remote tracker) for specs covering the same requirement/behavior class; when a match exists, the new requirement routes into the existing spec (amend/extend per the spec card's revision discipline, or convert per the issues card) instead of filing a new number.

**Alternatives Considered & Why Discarded** —
- *Rely on agent memory/context to notice duplicates* — rejected: the observed failure happened with the record in context-visible history; undelegated recall is not a control.
- *Post-hoc duplicate sweeps of the store* — rejected: treats the symptom after a withdrawal/reconciliation cycle has already cost the developer; the prevention point is at filing time.
- *Mandate semantic-similarity tooling for search* — rejected: exceeds the observed failure ground; plain search of the store's specs before filing satisfies the requirement without new tooling.

**Key Design Decisions** —
- The search step lives in the flow the agent already executes before filing, so no new pipeline stage is created (tradeoff: light procedure over structural separation).
- On match, routing means the requirement joins the existing spec's artifact — amend/extend — never a parallel record (tradeoff: single-spec authority over per-requirement granular records).
- The mandate binds the general filing path, not the triage-conversion path only, because the observed failure occurred in the general mid-session filing path.

**User Intent / Original Prompt** — GitHub issue michael-conrad/.opencode#2756 (filed 2026-11-19): "the spec/issue work-entry flow should include a store-search step before creating a new spec — search the local store (and the linked remote tracker) for specs covering the same requirement/behavior class; if one exists, route into it (amend/extend or convert per the issues card) instead of filing a new number." Authorized for triage 2026-11-20 ("approved for triage"); triage verdict: actionable work, converted in place to this governing spec.

## 2. Not Included

- Changes to any other deck card's content (e.g., `explore`, `plan`) — scope is the two flow owners of spec filing: the `spec` card and the `issues` card's work-entry clause.
- Automated similarity tooling or store indexing — plain search suffices to prevent the observed failure.
- Retrofitting historical duplicate pairs — the fix governs future filings.

## 3. Requirements

- **R-1** — The `spec` card SHALL mandate that, before filing any new spec, the agent search the issue store for an existing spec covering the same requirement or behavior class, and route into an existing match instead of filing a new number.
- **R-2** — The search SHALL cover the repository's local issue store and its linked remote tracker.
- **R-3** — When a match exists, the agent SHALL amend or extend that spec's artifact in place per the spec card's revision discipline (or the issues card's conversion mechanics when the situation is a conversion), never file a parallel spec record.
- **R-4** — The `issues` card's work-entry conversion clause SHALL carry the same search-before-filing mandate so triage conversions inherit the step.
- **R-5** — The mandate SHALL apply to every spec filing path, including mid-session work-entry, not only triage conversion.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | The `spec` card contains the search-before-filing mandate stating the store search that precedes any new spec filing | structural | grep `.opencode/skills/spec/SKILL.md` for the mandate text |
| SC-2 | The mandate names search coverage of both the local issue store and the linked remote tracker | structural | grep `spec/SKILL.md` matches for local store + remote tracker coverage wording |
| SC-3 | The mandate requires routing into an existing matching spec rather than a new filing, with the amend/extend-in-place instruction | structural | grep `spec/SKILL.md` matches for routing-in-place and amend/extend wording |
| SC-4 | The `issues` card's work-entry conversion clause carries the same search-before-filing mandate | structural | grep `.opencode/skills/issues/SKILL.md` for matching wording in the work-entry conversion (#2707) clause |
| SC-5 | The mandate binds the general filing path, not only triage conversion, in at least one of the two card texts | structural | read `spec/SKILL.md` filing-flow section: the mandate precedes "filing any new spec", not just conversion |
| SC-6 | A session entering the filing flow observes the search step: a hypothetical mid-session new-spec filing triggers the search step | behavioral | behavioral run: mock/mid-session dispatch scenario in which a requirement matches an existing spec; the run routes into the existing spec and files no new number |

## 5. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode#2707` (work-entry conversion, in `issues/SKILL.md`) | The clause R-4 amends is its text | Satisfied — present in `issues/SKILL.md` |
| `.opencode/skills/spec/SKILL.md` (filing flow, rules 5) | The flow R-1/R-3 amends is its text | Satisfied |
| .opencode#2756 remote issue (body mirror) | The remote body is reconciled to the converted spec | Pending — done in this workflow's reconciliation step |

## 6. Traceability

| Requirement | Success criteria |
|-------------|------------------|
| R-1 | SC-1, SC-5, SC-6 |
| R-2 | SC-2 |
| R-3 | SC-3 |
| R-4 | SC-4 |
| R-5 | SC-5 |

## 7. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Issue #2756 report | Issue body | https://github.com/michael-conrad/.opencode/issues/2756 | Read remote body 2026-11-20 |
| Observed duplicate pair | Issue-store record | hermes-ingest-pubmed `.issues/302`/`.issues/303` | Cited in the report body; not re-verified (outside this session's project_root) — recorded as stated provenance |
| `issues/SKILL.md` #2707 clause | Deck card | `.opencode/skills/issues/SKILL.md` §5 | Read 2026-11-20 in-session |

## 8. Cost Frame

- SC-1..SC-5: verification is a grep/read of two files — acting on it costs seconds; skipping it risks a deck change that does not carry the mandate anywhere a consumer route can find.
- SC-6: verification is one behavioral run — acting on it costs a session-orchestration cycle; skipping it risks a mandate that is present in text but never exercised in the observed flow class that produced the defect.

## 9. Edge Cases

- **Condition** — An already-filed new spec is later found to match an existing one. **Expected behavior** — R-3's in-place routing governs (amend/converge, withdraw the duplicate); the search step prevents future occurrences but does not govern the already-minted pair. **Resolution** — out of scope (§2 retrofitting exclusion).
- **Condition** — No remote-tracker-linked store for a target repo (remoteless or pull-only store). **Expected behavior** — the search covers the surfaces the repo holds (the store alone, or the platform CLI against the remote tracker alone), consistent with the issues card's §1/§2 surface rules. **Resolution** — mandate words coverage per held surface, not per platform specifics.
- **Condition** — Wording differs materially but the requirement/behavior class matches, as in the observed failure. **Expected behavior** — the search judgment matches on class, not wording; this is exactly the case SC-6 exercises. **Resolution** — none needed.

## 10. Completion gate

Every success criterion above passes before the deliverable is complete; partial implementation is not permitted.

---
Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
