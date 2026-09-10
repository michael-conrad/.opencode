## Problem

The behavioral-test orchestrator launches an `opencode run` and does not act on it while it executes. The §14 semantic monitor (`tests-v2/AGENTS.md`, `behaviors/helpers.sh __semantic_monitor()`) polls the live session DB and aborts on stall signals, but it has two gaps:

1. It does NOT check on-disk output artifacts in the test home (e.g., the plan.md the scenario expects to be produced).
2. It never terminates early when the evidence needed for a verdict has already landed — GREEN-capable runs and hopeless runs both burn the full 600-900s timeout as wasted ceremony.

## Scope

- Extend `.opencode/tests-v2/AGENTS.md` §14 with an early-termination mandate.
- Extend `__semantic_monitor()` in `.opencode/tests-v2/behaviors/helpers.sh` with three-signal polling (tool calls, text/reasoning content, on-disk artifacts).
- GREEN-signal and HOPELESS-signal early termination, with poll-log evidence records.
- Behavioral SCs: RED (no early termination today) / GREEN (termination fires) per the two-SC pattern.
- One-line pointer in the root repo `AGENTS.md` (parent-repo change only).

**Out of scope:** changes to `opencode` itself, test-framework harness behavior outside the monitor, verdict-evaluation logic beyond early-termination evidence capture, and artifact-only-generator exit-0 semantics (unchanged).

## Approach

Each monitor poll performs a three-signal semantic read: (a) latest tool calls from the session DB, (b) latest text/reasoning content, and (c) on-disk output artifacts in the test home (scenario-declared expected artifact, e.g., `BEHAVIOR_EXPECTED_ARTIFACT`). GREEN-signal termination fires when the expected artifact exists on disk AND the session event stream shows goal-relevant actions — the run is killed, session.yaml exported, and the verdict evaluated from captured evidence. HOPELESS-signal termination fires on a semantic judgment that the run can never accomplish the scenario goal — the run is killed, exported, and the diagnosis recorded as a valid FAIL/behavior-diagnosis verdict. Early-terminated runs are valid evidence: session.yaml + poll log + termination judgment recorded together.

## Impact

- **Risk: false-positive GREEN termination** (artifact exists but session evidence is not goal-relevant) — mitigation: require BOTH the artifact check AND goal-relevant session actions before firing.
- **Risk: false-positive HOPELESS termination** cutting off a slow-but-viable run — mitigation: semantic judgment must cite concrete evidence, recorded in the poll log for audit.
- **Dependency:** §14 monitor infrastructure already exists; the change extends rather than replaces it.

**Call to action:** Review and approve this spec; implementation follows the two-SC RED/GREEN behavioral pattern.

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2441/

🤖 OpenCode (huggingface/zai-org/GLM-5.3-Flash) created
