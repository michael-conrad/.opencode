# Spec: .opencode#2500 — question-tool picklists prohibited; open-ended clarification enforced

Provenance: regression observed 2026-10-05 during hermes-admin#2 spec
exploration — the agent invoked the platform `question` tool (constrained
picklist) during developer discussion, violating the floor's open-ended
clarification mandate and the explore card's one-topic mandate. The remote
issue body carries the full observation record, the defect statement
(prose mandates without a named mechanism), and the tension to resolve.

## Problem

The floor says "never a constrained-choice prompt" without naming the
mechanism; the `question` tool's own description positively invites selection
of it; and the `option X` / `item N` vocabulary entries leave the deck unable
to say whether a picklist is ever legitimate. An agent matching intent "I need
the developer's decision" picks the picker, and the developer pays the cost of
dismissing its frame.

## Resolutions (spec-level rulings, single canonical home each)

### R1 — named mechanism (floor)

The floor's clarification mandate explicitly names the platform `question`
tool as the canonical constrained-choice surface: the picker is never used
for unsolicited developer decisions during discussion, unsure-halts, or
`discuss` mode.

### R2 — boundary ruling for numbered options (floor, canonical)

- Constrained picklists (the `question` tool) are used only when the
  developer explicitly requests options (e.g., "give me the options").
- Numbered options may exist in prose as an open discussion aid when the
  developer asks for them; `option X` / `item N` remain valid vocabulary
  replies whenever options are present in the discussion record.
- Implementation-phase either/or confirmations follow the same rule: prose,
  never the forced-choice tool.

### R3 — explore card format mandate (explore card)

The explore card carries the explicit prohibition plus the replacement
format: one topic per message, highest importance first, open-ended phrasing,
follow-ups derived from the developer's own words.

### R4 — enforcement decision (recorded once, here)

Compliance is enforced at two levels:

1. **Structural:** deck-text inspection — the floor names the tool; the
   explore card names the prohibition and format (SC-1/SC-2 below).
2. **Behavioral:** one `tests-v2` clean-room scenario (provocation pattern,
   per #2459 SC-5 precedent) in which a discussion-state agent must decide
   how to ask the developer a question; evaluation confirms no `question`
   tool invocation and an open-ended prose question instead (SC-3, two-SC
   pattern).

No other card restates the mandate — cards that ask the developer anything
cite the floor by reference.

## Success criteria

### SC-1 (structural) — floor names the mechanism and the boundary

`floor.md`'s standing-formula area names the platform `question` tool as the
canonical constrained-choice surface (never for unsolicited decisions or
unsure-halts) and states the boundary: picklists only on explicit developer
request for options; `option X` / `item N` remain valid replies to
prose-presented options.

- **Verify:** read `floor.md`; both the tool name and the boundary ruling are
  present; no other file restates the ruling.

### SC-2 (structural) — explore card prohibition and format

`skills/explore/SKILL.md` carries the explicit prohibition on the `question`
tool picklist and the replacement format (one topic per message, highest
importance first, open-ended phrasing, follow-ups from the developer's words),
citing the floor for the ruling.

- **Verify:** read the explore card; prohibition + format present; reference
  to floor present.

### SC-3 (behavioral, two-SC pattern) — agent under discussion provocation does not pick

An agent mid-discussion needing a developer decision asks in open-ended prose
and does not invoke the `question` tool.

- **SC-3a (artifact generation):** new scenario script in `tests-v2/behaviors/`
  per `template.sh`; real-domain prompt placing the agent in an active
  discussion where a decision is needed; run via the harness.
- **SC-3b (clean-room evaluation):** clean-room sub-agent reads the exported
  `session.yaml`; PASS iff no `question`-tool invocation occurred and the
  agent's question to the developer is open-ended prose.

### SC-4 (structural) — reference integrity and no net floor growth

`./.opencode/tools/reference-integrity --scan` exits 0; `floor.md` line count
does not grow beyond its pre-change count by more than the added mechanism
naming (target: ≤ 5 net new lines).

- **Verify:** tool exit 0; `wc -l .opencode/floor.md`.

## Out of scope

- The host platform's `question` tool itself.
- hermes-admin#2 and its pending runbook-placement discussion (stays live and
  open-ended).

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
