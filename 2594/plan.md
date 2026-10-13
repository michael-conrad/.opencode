# Plan — .opencode#2594 Supervision early-abort mandate (verdict-confirmed conclusion)

Spec: `.opencode/.issues/2594/spec.md`. Ordering: SC-1 → SC-2 → SC-3.

## Item 1 (SC-1) — verdict-confirmed conclusion mandate in both card surfaces

- **Deliverable:** `skills/behavioral-testing/SKILL.md` rule 9 and `tests-v2/AGENTS.md` §14 both carry the verdict-confirmed conclusion mandate.
- **RED:** grep for the mandate anchors (`verdict-confirmed`, "conclude the run in that same cycle" / mandatory phrasing, red-state coverage) in both files finds no mandate — the current text has only the value-judgment sufficiency exit (#2538).
- **GREEN:**
  - SKILL.md rule 9: after the #2538 sufficiency exit sentence, add the verdict-confirmed mandate — when a poll's semantic check confirms the verdict state (green: goal condition observed met; red: goal condition observed failed or a run-fatal defect observed), the supervisor MUST conclude the run in that same cycle: PID-addressed kill of the run process tree, §10.5 export when the artifact set is incomplete, recorded confirmation (which poll confirmed, event citations, verdict state) in the evidence directory, then proceed to evaluation. Polling past the confirming poll is a supervision defect. The kill is the supervisor's own abort signal (GNU `timeout` remains forbidden); early conclusion is distinct from §10 remediation paths; §10.7 resumption does not apply.
  - tests-v2/AGENTS.md §14: retitle the exits as three-tier — evidence-sufficiency (judgment, #2538, stands unchanged) and **verdict-confirmed (mandatory once the poll's semantic check establishes green or red)** — same kill/export/record mechanics; update the PROHIBITED-patterns table row to name polling past the confirming poll; add the red-state case explicitly.
- **Predicate classification:** the confirmation judgment is intent-decidable (never scripted); the post-confirmation actions are mechanical/fact-decidable.
- **Verification instrument:** grep for the anchors in both files; `./.opencode/tools/reference-integrity` passes on both.

## Item 2 (SC-2) — targeted supervised run demonstrating the mandate

- **Deliverable:** a monitored behavioral run (`supervision-early-abort-confirmed-green` scenario) whose verdict state becomes confirmed mid-run and is concluded in the confirming poll's cycle; poll log in the evidence directory shows confirming semantic analysis → conclusion actions (PID kill, export, confirmation record) → no further poll cycles.
- **RED:** no such evidence exists; the card text (pre-change) provides no mandate to conclude on confirmed verdict.
- **GREEN:** author the small-scoped scenario (behavioral-testing card governs harness mechanics; BEHAVIOR_NEEDS_REMOTE not required if the scenario needs no remote), supervise per the updated rule 9, conclude at the confirming poll, record evidence.
- **Verification instrument:** the poll log + evidence directory artifacts.

## Item 3 (SC-3) — clean-room evaluation of SC-2's poll log

- **Deliverable:** clean-room sub-agent reads the SC-2 evidence directory and returns PASS/FAIL with citations on: confirming poll's semantic analysis identified the verdict state; conclusion actions followed within the same cycle; no poll cycles after the confirming poll; confirmation record names the event citations.
- **RED:** no evaluation exists.
- **GREEN:** dispatch one fresh-context evaluator per the verify/behavioral-testing dispatch rules.
- **Verification instrument:** the evaluator's verdict record.

## Dependency order

Item 1 → Item 2 → Item 3 (spec-mandated ordering).
