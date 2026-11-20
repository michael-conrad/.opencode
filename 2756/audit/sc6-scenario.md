# Mock scenario — mid-session filing matching an existing spec (SC-6)

You are acting as the agent in an in-progress implementation session in a
deck-consuming repository ROOT (a repo with a local issue store at
`ROOT/.issues/` and a remote tracker). You have already implemented part of
a feature mid-session.

The developer says in chat:

> "One more requirement for this feature: when the session files a spec, it
> should record in the spec body what the remote tracker's issue state was at
> filing time."

The store contains an existing spec at `ROOT/.issues/118/spec.md` (provided
as a mock artifact below) covering exactly the same requirement class —
recording remote-tracker state in the spec body at filing time. Its wording
differs from the developer's phrasing, but the requirement and behavior
class match.

Your question, judged strictly against the deck card texts given to you
(the `spec` card and `issues` card excerpts referenced below):

1. Does the `spec` card's filing flow — as you read it — mandate a store
   search for a matching existing spec BEFORE any new spec is filed?
2. If a match exists (as it does here), what does the flow tell you to do
   with the developer's requirement — file a new spec record, or route it
   into the existing spec?
3. State the concrete next action the flow directs.

Answer each question citing the card text you were given.

---

## Mock existing spec artifact (ROOT/.issues/118/spec.md content)

Title: "Spec — spec bodies record remote-tracker state at filing time"
Requirements (excerpt): "(R-1) The spec card's filing flow SHALL capture
the linked remote tracker's issue state for the affected issues at filing
time and record it in the filed spec's documentation-sources section."
Success criteria and evidence traceability sections follow (elided — the
mock's point is the requirement class).

---
Verdict format (what you must return):
- Q1 answer (search step mandated: yes/no, with card-text citation)
- Q2 answer (file new / route into existing, with citation)
- Q3 answer (concrete next action)
- One-line overall verdict: does a session following these cards perform
  the store search and route into the existing spec?

---
## RED evidence record — pre-change texts (branch base 489c21ef8)

Dispatched 2026-11-20, clean-room sub-agent, prompt = this scenario + the
card texts at branch base 489c21ef8 (`git show 489c21ef8:skills/{spec,issues}/SKILL.md`,
persisted as sc6-pre-*-SKILL working copies returned by the dispatcher).

Returned verdict (unedited):
- Q1: No search step mandated — spec §5 "Write and persist" mandates only
  remote-first number reservation; issues §2 likewise; no searched-for-match-
  before-filing requirement exists in either card.
- Q2: File a new spec record (remote-first reservation per issues §2, then
  spec §5 persist); no card text routes a matching developer requirement
  into an existing spec.
- Q3: Reserve the number, file the remote issue, register the {N}/ folder,
  write spec.md — no store search occurs in the sequence.
- Overall verdict: RED for SC-6 — the search-and-route behavior is NOT
  produced by the pre-change cards.

---
## GREEN evidence record — change-carrying branch (tip a4219e7ff)

Dispatched 2026-11-20, clean-room sub-agent (no overlap with the RED
dispatch), prompt = this scenario + the card texts at branch tip
(`git show 2756-store-search-before-filing:skills/{spec,issues}/SKILL.md`,
persisted as sc6-post-*-SKILL working copies returned by the dispatcher).

Returned verdict (unedited):
- Q1: Yes — store search mandated before filing any new spec (spec card
  rule 5 "Search before filing .opencode#2756"; issues §5 conversion
  inherits the mandate).
- Q2: Route into the existing spec — no new spec record; match on
  requirement/behavior class rather than wording (both cards).
- Q3: Amend/extend `.issues/118/spec.md` in place under spec rule 6
  revision discipline; no number reserved or filed.
- Overall verdict: GREEN for SC-6 — the post-change flow performs the
  store search and routes into the existing spec, no new number filed.



---
Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
