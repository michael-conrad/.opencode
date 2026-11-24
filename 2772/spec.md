<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2772; explorer→spec pipeline, developer directive 2026-11-24 -->

# Spec — One-in-flight sub-agent dispatch bound (floor directive)

## Intent and Executive Summary

**Problem Statement** — Agents dispatch multiple sub-agents concurrently: several `subagent` calls batched into one parallel tool-call block, and background dispatches accumulating during dispatch-and-continue work. The aggregate concurrent load overloads the backend model API, which interrupts all in-flight sub-agents at the same instant — observed across multiple sessions — and the work halts.

**Root Cause / Motivation** — The deck's floor is the only always-injected instruction surface, and it bounds sub-agent dispatch *authorization scope* (the Dispatched sub-agent scope section) while stating nothing about dispatch *concurrency*. Two platform surfaces actively push toward concurrent dispatch: the platform's tool-call instruction to "batch independent calls in one block" applies to `subagent` calls, and the `subagent` tool's `background` mode is a dispatch-and-continue side channel. Retired attic guidance previously encouraged parallel dispatch; its retirement left the platform batching instruction as the effective default, which is the failure the incidents show. The problem recurs — the developer names repeated halts — so the fix must be always-on, not card-loaded.

**Approach Chosen** — Author one directive into `.opencode/floor.md`, in or beside the existing Dispatched sub-agent scope section: at most one sub-agent invocation active at any time, counting foreground and background dispatches together; no batching of sub-agent dispatches in one parallel tool-call block, with an explicit statement that this overrides any platform instruction to batch independent calls for sub-agent dispatches; a dispatch holds the slot until it terminates and its result is reported, where a background dispatch's termination event is its completion notification; recovery stays inside the bound.

**Alternatives Considered & Why Discarded** —

- *Mechanical host-wide serialization plugin* (V2 tool-execute gate plus filesystem lock, plugins auto-discovered from `.opencode/plugins/`): rejected by the developer on 2026-11-24 — "directive only. no defective code plugins that will never work as expected." Independently, the plugin design carries a hard lifetime wrinkle: a background dispatch's tool call returns immediately, so a gate-lifecycle lock releases while the sub-agent still runs; correct hold-until-termination needs child-session event subscription, which is exactly the additional defect surface the developer declined.
- *Foreground-only dispatch* (prohibit background dispatch, blocking sequential calls): a stricter operationalization that makes hung-background slot holding impossible by construction — rejected by the developer's explicit choice on 2026-11-24: "one in flight counting" — background dispatch stays legal, counted toward the slot.
- *One-in-flight counting foreground dispatches only* (background not counted): rejected — it leaves the background accumulation channel open, and the observed failure includes accumulated concurrent sub-agents.
- *Wait and see* (no change): rejected — the failures recur and interrupt all in-flight sub-agents simultaneously; the cost of another incident is the motivating failure itself.

**Key Design Decisions** — Each names its tradeoff:

- *Absolute bound, zero exceptions.* Recovery dispatches are not carved out: `re-dispatch and continue` fires only after the failed or hung dispatch is abandoned. Tradeoff: a wedged background dispatch holds the slot until the developer token fires; accepted in exchange for a rule with no judgment calls at the moment of dispatch.
- *Background dispatch counts and holds the slot to its completion notification.* Tradeoff: background's legitimate long-run-with-conversation use survives, but no second dispatch can start during it; the agent treats notification arrival as the termination event.
- *Slot lifetime includes the result report.* The bound becomes verifiable in timeline evidence — a report visibly separates consecutive dispatches. Tradeoff: one additional obligation per dispatch cycle.
- *Directive-only, no mechanical enforcement.* Tradeoff: compliance rides on the always-injected text; the cross-session aggregate is consciously unbounded (developer decision 2026-11-24, recorded below in Not Included).

**User Intent / Original Prompt** — Developer statements, verbatim, all dated 2026-11-24:

> "the agent keeps dispatching too many concurrent sub-agents overloading the backend API and getting halted. brainstorm a fix spec for adding a directive to only dispatch 1 sub-agent at a time."

> "interrupted for all sub-agents at same time across mulitiple sessions"

> "absolute"

> "one in flight counting"

> "directive only. no defective code plugins that will never work as expected."

> "proceed to spec"

The design this spec records was presented to the developer incrementally — the invariant shape, the absolute bound, the background-counting variant, and the slot-lifetime-with-report clause — and finalized by the stage-transition statement "proceed to spec."

## Not Included

- *Plugin-based host-wide serialization across concurrently running sessions* — rejected by developer decision 2026-11-24 ("directive only. no defective code plugins that will never work as expected."). Rationale recorded, not deferred: the path is dropped, not postponed.
- *Changes to any tool, config file, or card beyond the floor clause* — the change's name is a floor directive; other surfaces were never requested.
- *A cross-session aggregate bound* — each session holds at most one slot, but nothing coordinates across concurrently running sessions; this is a consciously accepted limitation, decided by the developer in this discussion and recorded here so no later artifact reintroduces the rejected plugin mechanism to "fix" it.
- *Concurrency limits on `opencode run` process launches* — governed by the behavioral-test harness domain (its own lock mechanics), not by sub-agent dispatch discipline.
- *Concurrency limits on image generation* — different tool class; the developer bounded sub-agents specifically.

## Requirements

- **R-1** `.opencode/floor.md` SHALL state that at most one sub-agent invocation may be active at any time, counting foreground and background dispatches together.
- **R-2** `.opencode/floor.md` SHALL state that multiple sub-agent dispatches are never batched into one parallel tool-call block, and SHALL explicitly state that this overrides any platform instruction to batch independent calls for sub-agent dispatches.
- **R-3** `.opencode/floor.md` SHALL state that a dispatch holds the slot until it terminates (returns, fails, or is abandoned as hung) and its result is reported, and SHALL state that a background dispatch's termination event is its completion notification — never its immediate tool-call return.
- **R-4** `.opencode/floor.md` SHALL state that recovery stays inside the bound: the `re-dispatch and continue` token recovers a failed or hung sub-agent only after that dispatch is abandoned, and recovery never produces two in-flight dispatches.
- **R-5** The directive SHALL be authored within the Dispatched sub-agent scope section of `.opencode/floor.md`.

## Success criteria

- **SC-1 (behavioral)** — A session directed to perform several independent sub-agent-worthy tasks issues sub-agent dispatches strictly sequentially. Instrument: behavioral harness run; a clean-room sub-agent reads the exported session timeline (`session-to-timeline` dispatch events) and verifies no two sub-agent dispatch events overlap in time and none share a tool-call block.
- **SC-2 (behavioral)** — A background dispatch holds the slot until its completion notification arrives. Instrument: a scenario issuing a background dispatch followed by work that would invite a second dispatch; the timeline verifies the second dispatch postdates the notification.
- **SC-3 (behavioral)** — Consecutive dispatches are separated by a report between a dispatch's termination and the next dispatch's issue. Instrument: the same timeline read — a report/chat-output part exists between consecutive dispatch events.
- **SC-4 (behavioral)** — A failed dispatch's return frees the slot, and the next dispatch issues only after that return. Instrument: a scenario with a deliberately failing dispatch (immediate error return) followed by a second dispatch; the timeline verifies the ordering.
- **SC-5 (structural)** — `.opencode/floor.md` carries the directive with all four operative elements — the one-in-flight limit, the batching override, the slot lifetime with background-notification termination, and recovery inside the bound — within the Dispatched sub-agent scope section. Instrument: read the authored floor text and verify each element is present at that location.

### Success-criteria table

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | No overlap; none share a tool-call block | behavioral | Timeline read via `session-to-timeline` |
| SC-2 | Background slot held to completion notification | behavioral | Timeline ordering check |
| SC-3 | Report separates consecutive dispatches | behavioral | Timeline report-gap check |
| SC-4 | Failed dispatch's return frees slot before next dispatch | behavioral | Timeline ordering check |
| SC-5 | Floor text carries limit, override, slot lifetime, recovery within the section | structural | Read of the floor clause |

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/floor.md` — Dispatched sub-agent scope section | R-5 anchors the directive to this section; verified to exist and to govern dispatch authorization | Satisfied — read 2026-11-24 |
| Platform `subagent` tool catalog — background mode and completion-notify semantics | R-3's termination event depends on the documented notification-on-completion behavior | Satisfied — tool catalog read 2026-11-24 |
| `.opencode/tools/session-to-timeline` — extracts `subagent_type` dispatch events | SC-1/2/3/4 instruments parse exported timelines it produces | Satisfied — verified 2026-11-24 |

## Traceability

| Requirement | Success criteria |
|-------------|------------------|
| R-1 | SC-1, SC-5 |
| R-2 | SC-1, SC-5 |
| R-3 | SC-2, SC-3, SC-5 |
| R-4 | SC-4, SC-5 |
| R-5 | SC-5 |

Every SC traces to at least one requirement; every requirement traces to at least one SC — no orphans in either direction.

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `floor.md`, Dispatched sub-agent scope section | Deck file (always-injected surface) | `.opencode/floor.md` | Read 2026-11-24 — governs dispatch authorization scope; silent on concurrency |
| Platform `subagent` tool catalog | Platform tool documentation | Session tool catalog | Read 2026-11-24 — `background` mode returns immediately; completion notification arrives when the sub-agent finishes |
| Platform tool-call batching instruction | Platform-injected agent instruction | Session system instructions (present every session) | Read 2026-11-24 — the instruction directs agents to batch independent tool calls in one parallel block and carries no sub-agent carve-out; the root cause and R-2's override element depend on the instruction existing in that form |
| `.opencode/tools/session-to-timeline` | Deck tool | `.opencode/tools/session-to-timeline` | Verified 2026-11-24 — source extracts `subagent_type` dispatch fields |
| Issue-store search — `.opencode/.issues/` specs | Local issue store | `.opencode/.issues/**/spec.md` | Grep 2026-11-24 — nearest matches #1992 (nested-dispatch invariant), #1406 (dispatch-gate bypass), #1269 (routing discipline); none covers a dispatch concurrency bound |
| Remote tracker search — `michael-conrad/.opencode` | GitHub issue tracker | `gh issue list --search` (three queries: "concurrent sub-agent dispatch", "parallel sub-agent overload", "one sub-agent at a time") | Executed 2026-11-24 — nearest matches #277, #2437, #2640; no existing spec covers the same requirement or behavior class |
| Retired attic guidance encouraging parallel dispatch | Deck history (retired, unloaded) | `.opencode/attic/guidelines/020-go-prohibitions.md`, `.opencode/attic/prompts/default.txt` | Grep 2026-11-24 — parallelism-preference lines confirm the retired guidance pattern cited in the root cause |
| `.opencode/.issues/1992/spec.md` | Store spec (pre-rip record) | `.opencode/.issues/1992/spec.md` | Read 2026-11-24 — historical invariant that sub-agents do not dispatch sub-agents; cited as context only, not asserted as current platform truth |

## Cost Frame

- **SC-1** — Acting: one behavioral harness run (~600–900 s) plus one clean-room evaluation dispatch. Skipping: the unbounded-dispatch failure recurs silently — every session remains exposed to the aggregate overload and simultaneous interruption this spec exists to stop.
- **SC-2** — Acting: shares SC-1's harness run or one additional scenario. Skipping: the background side channel stays unverified, and its accumulation pattern — one of the two observed triggers — can regress undetected.
- **SC-3** — Acting: reuses the SC-1 timeline export; negligible marginal cost. Skipping: the report-separation discipline goes unverified and the bound loses its visibility in evidence.
- **SC-4** — Acting: one cheap scenario (a failing dispatch returns immediately). Skipping: recovery behavior stays unverified — the one path where a second dispatch is most tempting is the one nothing would catch.
- **SC-5** — Acting: one read of the authored floor text, already performed during verification. Skipping: a shipped directive silently missing an operative element (e.g. the batching override) leaves agents following the platform batching instruction — the exact observed failure.

## Edge Cases

- **Condition:** a background dispatch is believed hung (no completion notification, no progress). **Expected behavior:** no self-judged abandonment and no second dispatch; the slot frees only through the `re-dispatch and continue` token's abandonment flow. **Resolution:** the directive text carries the recovery clause (R-4).
- **Condition:** one user prompt contains several independent sub-agent-worthy tasks. **Expected behavior:** dispatches issue sequentially, each preceded by the previous dispatch's report; the batching override redirects the agent away from the same-block pattern the platform instruction suggests.
- **Condition:** a dispatch fails immediately (error return). **Expected behavior:** the slot is freed by the failed return; the next dispatch is legal and must not overlap the failure (SC-4).
- **Condition:** a session performs no sub-agent dispatches. **Expected behavior:** the directive adds no burden — ordinary tool calls, including batched calls of other tool types, are unaffected; the override clause is scoped to sub-agent dispatches.
- **Condition:** multiple concurrently running sessions each dispatch. **Expected behavior:** each holds at most its own slot; the aggregate is unbounded — the accepted limitation recorded in Not Included, not remediated by this spec.

## Completion gate

Every success criterion above passes before the deliverable is complete; partial implementation is not permitted. The deliverable is the floor directive plus nothing else — verification fails if the change ships with any criterion unverified.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
