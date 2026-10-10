# Behavioral-evidence environment analysis — .opencode#2569 (2026-10-10)

Findings from implementing the plan's behavioral items under the tests-v2
harness. Structure mirrors the #2568 analysis: what each behavioral SC can and
cannot evidence pre-merge, with the mechanism verification that closes the gap.

## Harness environment constraint (same root cause as #2568)

`with-test-home` seeds a minimal global config (`seed_model_config` — model +
models only). The math MCP server (`mcp-mathematics`) is defined ONLY in the
developer's global config (`~/.config/opencode/opencode.jsonc`), not in the
deck config. Therefore no harness session ever has a math MCP server, and
injecting one is a forbidden isolation bypass (observed regression #2538).

## Per-SC evidence status

### SC-3 — PASS (clean-room verdict recorded)

Fully producible in-harness. Artifact directory:
`tmp/behavioral-evidence-2569-sc3-math-intent-dispatch-GREEN-ollama-qwen3.8-27b-256k-gguf4-1/`
(preserved under `tmp/2569/artifacts/`) — `session.yaml` (27 timeline entries),
`monitor.log` (10-poll supervision log), clean-room verdict
`evaluation-1791607643.yaml`: PASS, test_type live DB. The main agent, given
"Use the math MCP to calculate the standard deviation of 4, 8, 6, 5, 3, 9 and
report the result.", issued a `task` dispatch with
`subagent_type: "math-ops"` (part `evt_1241851db001nxkD4co6I3GsFc`, main
session `ses_edbe96782ffeiRrehPJIHhlXz5`), spawning child session
`ses_edbe7ae28ffecQ61fJyRc5wbdT` titled "Std dev via math MCP (@math-ops
subagent)". The child verified the math MCP's absence two ways (empty
`list_mcp_resources`; no math server in the `mcp` block) and halted with an
explicit unavailability report instead of approximating — the #2571-lesson
behavior the card body mandates.

**Run 1 of this scenario was a FAIL and drove a deck fix (R-18 wording
class).** With the original card description ("…Dispatch explicit math-tool
work here; everyday arithmetic stays native (bash/python)."), the main agent
never dispatched: it found no math MCP in the env and computed natively with
python3, licensed by the description's own native-licensing clause sitting on
the routing surface. Remediation (commit `9e5ee6aa`): the description now
carries the email-ops-style routing directive and the boundary clause lives
only in the card body (where SC-6 verifies it). Run 1's artifacts are
preserved at `tmp/2569/artifacts/run1-fail-evidence-description-licensed-native-fallback/`.
Run 2 left no artifacts: it was killed pre-inference by a supervisor
launch-method defect (bash tool default 120 s timeout killed the process
group — §10.2); recorded for the record, remediated by the detached relaunch.

### SC-1 — mechanism resolved at the installed binary in the run environment; harness evidence vacuous; production confirmation post-merge

The generic mechanism was source-verified in #2568 (flat deny rules remove
matched tools from the model toolset — `Permission.disabled` → `resolveTools`
filters the toolset before the provider request; the rule-matching code is
tool-family-generic). Additionally resolved in THIS issue's run environment
(test home `tmp/test-home-20261010-003338`, binary 1.18.3): `opencode debug
agent build` shows the ruleset carries `{permission: "math_*", action: "deny",
pattern: "*"}` (alongside `gmail_*: deny`), and `opencode debug agent
math-ops` shows the subagent ruleset carries both `math_*: deny` (config) and
`math_*: allow` (frontmatter) with the allow appended after the deny — the
findLast-resolution shape that lets the subagent allow win.

Harness evidence for SC-1's literal criterion (no `math_*` tools in a fresh
main-agent session) is **vacuous in isolation**: the math MCP does not exist
in the test env at all, so absence is attributable to the missing server, not
the deny rule. Run 1's transcript incidentally shows the toolset reality: the
main agent enumerated its functions and found no math tools (in the test env,
from the missing server). Definitive production confirmation: post-merge, a
fresh main-agent session in this project under the merged deck shows no
`math_*` tools in the toolset.

### SC-2 — not producible in-harness; production post-merge

The criterion needs a session WITH the math MCP present where the math-ops
allow rule overrides the deck deny. The isolated env cannot contain the math
MCP (injection forbidden, no math container). Structural half (allow entry
present in the card) is SC-5-verified; the ruleset-resolution half
(allow-as-last-matching-rule) is evidenced by `debug agent math-ops` above.
Behavioral half (tools available, calculation completes with no ask stall)
requires a production environment with the math MCP — post-merge, next time
math work is dispatched in a live session.

### SC-7 — baseline reproduced; spec-literal threshold weak post-#2572; marginal-delta A/B control is the honest instrument

Protocol resolution: first assistant message of a main-agent (parentless)
session, providerID `huggingface`, modelID `zai-org/GLM-5.3-Flash`,
`tokens.input` from the message JSON, median. Reproduced against the live db
on 2026-10-10: n=128 first-turn records since 2026-03, median **21,937** —
the spec's ~22.0K baseline; spec threshold ≤ 21,000.

Intervening change: #2572 (gmail deny, merged 2026-10-10 03:57 UTC) already
removed ~3.3K tokens — post-gmail fresh sessions on the trunk measure 18,694
/ 18,703 (n=2, median 18,698). The spec-literal ≤ 21,000 check would pass
even without this change. The honest attribution instrument (per the #2568
review convention): like-for-like fresh minimal-prompt sessions with the math
deny active vs overridden to allow (A/B control), delta ≥ 1,000 tokens
attributable to the math rule itself; expected ~2.0K (the math MCP's schema
weight per the spec's problem statement). Executed by the verify reviewer
pre-merge at the installed binary, with production confirmation post-merge.
