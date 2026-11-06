# work card rule 1: the agent's own resolution of a material open choice fails the short-path criteria

Source: converted in place from this record's filed bug report .opencode#2726 (2026-11-06, triage verdict: actionable work — path-selection criteria defect in `skills/work/SKILL.md` rule 1; developer verdict on the recorded run, filed verbatim: "that 'shortcut' is a deck regression which results in defective work").

## Problem

A work-order request with no stage named — "set the CLI option defaults per the usage recorded in git history in \<another repo\>" — was judged short-path by the `work` card rule 1 criteria and collapsed into a `.git/`-held scope statement, after which the agent began writing RED test assertions for a design no spec stated. The developer asked "where is the spec?"; the mid-cycle switch to the full path discarded the short-path cycle's work (RED edits held, the test run burned).

The field incident ran on deck `801591ec`, which already carries .opencode#2657's criterion-assessment binding (merged 2026-10-31, ancestor of `801591ec` — verified 2026-11-06). The reported misjudgment therefore survived the binding fix the deck already carries. Reading the incident against the current card text (HEAD 2d29de644, verified by direct read):

1. **The binding's found-fact enumeration is file/concern/surface-shaped.** The binding sentence names what binds as findings: "a second file the change needs, a second concern, an unnamed surface" — it names no choice-class fact. An agent whose own research resolves a material choice the request left open has produced a found fact (a product decision the developer did not state), but no enumerated fact class tells the assessment to bind on it.
2. **Criterion 3 admits the "no choice remains" misreading.** The criterion states "the request leaves no material choice open about what to build, and the agent supplies no product decision the developer did not state." An agent reading the request "set defaults per the usage in git history" judged the choices "resolved" — because its own research had resolved them — and read criterion 3 as satisfied. The criterion's test is not "no choice remains"; it is whether the developer's own request states the choice's resolution. Deriving the defaults from another repository's git history is the agent supplying the product decision — however well-evidenced the research, the choice's statement did not come from the developer.

Root cause: rule 1's criteria were assessed against the change's shape ("one file") and the phrase "choices 'resolved'", with the agent's own research output never counted against criteria 3/4, and the binding sentence's enumeration leaving that fact class unnamed.

## Scope

`skills/work/SKILL.md` rule 1 text only — criterion 3's reading and the binding sentence's found-fact enumeration. No other card, no scripts, no hooks, no harness. Routed through the deck's governance path: authored upstream (`michael-conrad/.opencode`), human merge only.

## Requirements

- R-1 (structural): the binding passage in rule 1 SHALL enumerate, beside the second-file / second-concern / unnamed-surface fact classes, a found choice-fact — a material choice the developer's request left open that the agent's own research, judgment, or work resolves — counting as the agent supplying a product decision the developer did not state; the existing self-certification sentence applies to it: the finding stands, and redefining the change so it reads as a pass takes the full path the same as the failure.
- R-2 (structural): criterion 3 SHALL state the resolution standard that excludes the reported misreading: a material choice counts as not-left-open only when the developer's own request states its resolution; research-derived evidence (defaults derived from another repository's git history, recorded usage, prior conventions) is evidence for the change's production — never a substitute for the developer's stated choice.

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | Rule 1's binding passage enumerates the agent-resolved-material-choice fact class beside the file/concern/surface facts, with the standing/self-certification sentences applying to it; the rest of rule 1's criteria text survives unchanged — criteria 1, 2, 4, 5, 6 and their numbering, and the deck-directed-edit exception sentence | structural | read `skills/work/SKILL.md`, locate the binding passage, check the enumeration and the unchanged criteria text |
| SC-2 | Criterion 3 states the developer-stated-resolution standard and excludes research-derived evidence from counting as the choice's statement | structural | read `skills/work/SKILL.md`, locate criterion 3's resolution standard |
| SC-3 | On a request that names no stage and leaves a material choice open which the agent resolves by researching (e.g., defaults per historical usage in another repo's history), the agent takes the full path — producing the spec — before writing any RED test assertion or other implementation edit | behavioral | tests-v2 behavioral scenario |

## Out of scope

- The work record's `.git/` placement — designer-intended (#2657's fix chose the git-directory path deliberately so the transient record needs no ignore rule); the invisibility harm compounds only when the wrong path is taken, and this spec corrects the selection. On the full path the scope statement already points at the spec artifact in the issue store.
- Recovery of discarded short-path work (held RED edits, burned test runs) — a consequence of correct path switching, already governed by the card's earliest-missing-stage rule.
- Changes to the criteria set itself (adding, removing, or renumbering criteria) — the fix states how criteria 3/4 read, not which criteria exist.
- `floor.md` or any other card's routing text — the work card is the criteria's definition ("no other card states a competing one").

## Approach

Amend rule 1 in place: extend the binding sentence's found-fact enumeration with the agent-resolved-choice fact class; state criterion 3's resolution standard in the criterion's own text (single-sourcing — each operative fact once, in the passage that owns it). Deck governance path: PR against `michael-conrad/.opencode`, human merge.

## Impact

Consumers: every no-stage-named request in any repository under this deck — the work card is the deck's primary change gate; every short-path collapse that skips a needed spec produces spec-less implementation, discarded work cycles, and developer-forced mid-cycle corrections. Risk of leaving unaddressed: any "small" request whose open choices the agent resolves from research takes the short path by shape, and each such miss ends in the reported discard pattern.
