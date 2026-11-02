# Plan — .opencode#2706 registration-on-demand for remote-first issues

Source spec: `.opencode/.issues/2706/spec.md` (validated PASS, round 1, 2026-11-02). Every item below traces to an SC in that spec; no item exceeds its scope. The change touches deck Markdown prose only — no build tooling, no runtime code.

## Execution order

1. Item 3 (RED half only — pre-change walkthrough, on trunk-fresh card text)
2. Item 1 (issues §7 edit + verification)
3. Item 2 (verify §10 edit + verification)
4. Item 3 (GREEN half — post-change walkthrough)
5. Item 4 (reference integrity + root-agnostic sweep, gates the commits of Items 1–2)

Items 1 and 2 are independent of each other and may execute in either order after the Item 3 RED; Item 3's GREEN requires both; Item 4 runs last and gates the branch's commits. No cycles: every RED/GREEN runs against a state its predecessors produced.

## Item 1 (SC-1, R-1): registration-on-demand mandate in `skills/issues/SKILL.md` §7

- Deliverable: one addition to §7, placed after the existing repair-on-discovery rule — a registration-on-demand sentence stating that pipeline work targeting an issue (spec creation, plan, implementation, or an audit dispatch) whose local record is absent begins by registering the record at the remote-assigned number via the store tool's create command, before any other store work on that issue. Cross-references to other cards use the canonical `Read [Text](path)` form.
- RED: `grep -c "registration-on-demand" .opencode/skills/issues/SKILL.md` returns 0 — the mandate text is absent from current trunk text. Fails before the change.
- GREEN: the sentence exists in §7 and states the trigger (record absence at work start), the action (register via create at the remote-assigned number), and the ordering (before any other store work).
- Verification instrument: the grep returns ≥1 with the mandate located in §7; a clean-room read of §7 confirms the sentence is unambiguous (no evadable qualifier — R-1's SHALL semantics carried by the card's normative prose).

## Item 2 (SC-2, R-2, R-3): artifact-presence gate extension in `skills/verify/SKILL.md` §10

- Deliverable: two additions to §10, placed after the existing mirror-repair sentence: (a) when the audited issue has no local record, the auditor first registers one per the `issues` card's registration-on-demand rule (canonical `Read` cross-reference to that rule), then re-checks presence; (b) when the audited artifact still does not exist after registration, the audit resolves to a defined no-artifact outcome — the report names the missing artifact and the stage that produces it, no verdict issues against a nonexistent artifact, and the outcome is a defined result of the audit, never an ad-hoc halt.
- RED: `grep -c "no-artifact outcome" .opencode/skills/verify/SKILL.md` returns 0 — the defined outcome is absent from current trunk text. Fails before the change.
- GREEN: both clauses exist in §10; the outcome clause is deterministic (names the two things the report must carry) and contains the "never an ad-hoc halt" sentence.
- Verification instrument: the grep returns ≥1 with both clauses located in §10; a clean-room read confirms determinism per SC-2's instrument column.

## Item 3 (SC-3): composition walkthrough, pre-change and post-change

- Deliverable: two clean-room walkthrough reports (pre-change and post-change) of the scenario "audit dispatched on a remote-first issue with no spec anywhere", each produced by a fresh-context sub-agent reading only the two cards' text at its point in the execution order.
- RED (execution step 1): the pre-change walkthrough, run on trunk-fresh card text, reports the dead end — no defined outcome reachable, or an invented artifact required. The RED fails when the walkthrough cannot reach a defined outcome; a walkthrough that reaches one fails the RED's premise and blocks Items 1–2 with the evidence.
- GREEN (execution step 4): the post-change walkthrough, run on the edited card text, reaches the defined outcome: register record → presence check → no-artifact outcome naming `spec.md` and the spec stage — with no undefined halt and no invented artifact.
- Verification instrument: both walkthrough reports exist in the issue store (`.opencode/.issues/2706/research/`); the pre-change report shows the dead end, the post-change report shows the defined outcome; judged for unambiguity and completeness per SC-3.

## Item 4 (SC-4, SC-5): reference integrity and root-agnostic sweep

- Deliverable: executed evidence that the edited cards keep the deck's reference-integrity and root-agnostic guarantees.
- RED (baseline, before Items 1–2's GREEN): `./.opencode/tools/reference-integrity` passes on trunk — establishes the baseline the change must preserve.
- GREEN (execution step 5): with Items 1–2 applied, `./.opencode/tools/reference-integrity` passes again, and the root-agnostic greps over the diff (`git diff` on the two files grepped for new `.opencode`-specific repo names, owner handles, and absolute paths beyond pre-existing text) return no new matches.
- Verification instrument: the tool's pass output and the greps' empty results, recorded with the change evidence; a failure blocks the commits of Items 1–2 until remediated.

## Dependencies

- Spec: `.opencode/.issues/2706/spec.md` — sole derivation source; all five SCs covered (Item 1→SC-1, Item 2→SC-2, Item 3→SC-3, Item 4→SC-4+SC-5); no untraced item.
- Trunk-fresh card text for the Item 3 RED and the Item 4 baseline: established by the `git-workflow-branch` card's trunk-freshness step before the first edit.
- No external dependencies; no deprecated surface touched (prose-only change to two live cards).
