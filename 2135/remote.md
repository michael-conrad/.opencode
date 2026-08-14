> **Full spec and artifacts: [`.opencode/.issues/2135/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2135/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2135/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

`130-authority-source.md` asserts "code wins" — the wrong framing for a spec-driven project. Specs are the primary artifact for intent, the authorization mechanism, and the review target; code is the implementation.

## Scope

- Rewrite `130-authority-source.md` as a dual-authority model: spec authoritative for intent, code authoritative for state; neither wins absolutely
- Replace the current rules with 6 new rules (Spec for intent/code for state, Spec before code, Documentation Drift Protocol, Spec revision revokes plan approval, Suppression of Reactive Remediation, Verification against spec)
- Remove 3 superseded sections and relocate their content: Superseding Issues + Overlap Detection Checklist and Plan Audit Code Deep Dive → spec-creation SKILL.md; Verification First → 065-verification-honesty.md
- Verify semantic preservation via clean-room sub-agent (no content loss, no mechanical compaction)
- Spec structure: 6-field preamble (incl. User Intent), Not Included, 9 SHALL-form requirements, per-SC Items (17 items, one per SC), Cost Frame

**Out of scope:** No changes to 010-approval-gate.md, approval-gate-006 semantics, or any guideline other than 130-authority-source.md and 065-verification-honesty.md; no changes to spec-creation SKILL.md beyond the relocated content; no new guidelines, skills, or tooling; no behavioral enforcement tests (static documentation change).

## Approach

Complete rewrite of `130-authority-source.md` establishing the dual-authority principle (spec for intent, code for state) with 6 rules replacing the current 8-rule structure. Three superseded sections are relocated to their target files rather than deleted: Superseding Issues + Overlap Detection Checklist and Plan Audit Code Deep Dive move to the spec-creation SKILL.md; Verification First moves to 065-verification-honesty.md. Semantic preservation is verified by clean-room sub-agent with content checklists, not grep or mechanical metrics.

## Impact

- **Top risks:** (1) Confusion between intent and state — mitigated by concrete examples in each rule; (2) Cross-reference breakage from the old "code wins" framing — mitigated by grep for 'code wins' across the codebase; (3) Mechanical compaction of relocated content — mitigated by SC-12 prohibition verified by clean-room sub-agent
- **Dependencies:** None
- **Review:** Spec revised 2026-08-13 — structural revision per spec-audit re-audit: added User Intent field, Not Included section, SHALL-form requirements, per-SC Items, and Cost Frame; removed prohibited tool-call cost framing from verification methods. Full spec: `.opencode/.issues/2135/`

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
🤖 Co-authored with AI: OpenCode (deepseek-v4-flash-free)
