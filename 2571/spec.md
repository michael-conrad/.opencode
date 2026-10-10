# Spec — email-ops dispatch reports gmail-tool unavailability, never falls back to other mail pathways

## Problem and provenance

Behavioral run evidence from `.opencode#2568` (SC-3 dispatch scenario,
clean-room evaluation `evaluation-1791603526.yaml`, artifacts preserved under
`tmp/2568/artifacts/`) recorded the following failure, R-18 task-card/skill-deck
wording class:

The dispatched `email-ops` subagent, finding no gmail tools in its
environment, loaded the `email-management` skill, followed its `tb`
(thunderbird-cli) install-on-need pathway, and launched a live internet
download of thunderbird-cli — instead of reporting gmail-tool unavailability
as the email-ops card's own reporting rule requires ("If the dispatched task
needs something the Gmail tools cannot do, say so explicitly rather than
approximating with another tool").

Root cause (card wording): the email-ops card binds gmail tools as its
mechanism but does not explicitly forbid falling back to other mail pathways
when they are absent; the email-management card body's setup-on-need install
path is reachable and actionable inside an email-ops dispatch.

Developer direction this spec traces to: "file a follow up spec" — issued in
response to the defect report above, covering the remediation proposed with
it ("a one-line remediation in the email-ops card: unavailable gmail tools
are reported, never worked around via other mail pathways inside a
dispatch").

Design context: under `.opencode#2568`'s deny-by-default design, an email-ops
session without gmail tools must surface that fact to the dispatching agent.
An unauthorized install inside a dispatched task is exactly the failure mode
the dispatched sub-agent scope-containment rule exists to prevent — a
dispatch prompt that does not name an action does not authorize it.

## Final state

1. The `email-ops` subagent card body (`.opencode/agents/email-ops.md`)
   carries an explicit rule stating: when the gmail tools are unavailable in
   the session's environment, the subagent reports that unavailability to the
   dispatching agent and stops — it never installs, configures, or
   substitutes other mail tooling (the `tb` CLI pathway included) inside a
   dispatched task.
2. The `email-management` card body keeps its desktop-profile `tb` pathway
   for main-agent use, unchanged — no body edits to that card.

## Success criteria

- **SC-1 (structural).** The `email-ops` card body contains the
  report-and-stop rule naming that unavailable gmail tools are never
  replaced by installing or configuring other mail tooling inside a
  dispatched task. Instrument: file inspection of
  `.opencode/agents/email-ops.md`.
- **SC-2 (structural).** The `email-management` card body is unchanged by
  this change's diff (the `tb` pathway remains for main-agent use).
  Instrument: direct diff inspection.
- **SC-3 (behavioral).** In a dispatched `email-ops` session whose
  environment lacks the gmail tools, the subagent reports the unavailability
  and performs no install, configure, or substitute action for any mail
  tooling. Instrument: behavioral run via the tests-v2 harness — an
  email-intent prompt produces the main-agent dispatch to `email-ops`, and
  the recorded subagent session shows a report of gmail-tool unavailability
  with no `tb` install, no package-manager invocation, and no network
  download of mail tooling. This SC is producible in-harness: the isolated
  environment has no gmail MCP by construction, which is exactly the
  condition under test.

## Out of scope

- Any change to the gmail deny/allow permission mechanism (`.opencode#2568`).
- Changes to the email-management card body or its references.
- Re-running or revising `.opencode#2568`'s success criteria.

## Deck governance

Item 1 edits a governed deck surface (`agents/` card content — the
skill-creator admission gate covers the deck's card surfaces); the admission
gate applies at implementation time as a process obligation of the change,
not as a success criterion.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
