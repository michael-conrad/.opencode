# [SPEC] Supervision early-abort mandate — conclude a monitored run when the verdict state is confirmed

## Problem Statement (observed failure, 2026-10-13)

During the `.opencode#2589` SC-5 supervised behavioral run, the supervisor's
poll-47 semantic check **confirmed the green state** — the run agent's own
words: "Remote reconciled to CLOSED in the same workflow. Final verification
pass." The complete goal condition (verify → verdict record → local close →
`gb`-route remote close → remote-state confirmation) was observed in-session.
The supervisor nonetheless continued polling through poll 50 (~5 wasted
60-second cycles, ≈5 minutes of continued inference on tail hygiene) before
the developer intervened.

Developer ruling (session 2026-10-13): the agent is not early-aborting on a
confirmed green or red state, causing wasted cycles, project delays, and
divergence into the weeds.

Existing surface and its gap: the Evidence-Sufficiency Early Exit (#2538) in
the `behavioral-testing` card and tests-v2 §14 covers "the SC's evidence
surface is already complete" — but it is framed as a value judgment
("further running adds no value") with no obligation tied to the moment the
verdict state itself becomes known. The supervisor treated post-confirmation
tail hygiene (extra validation reads, closing prose) as evidence-adding and
kept the loop alive. A confirmed verdict state is a **stronger, mandatory**
trigger than sufficiency: once the outcome is known, the run's remaining
cycles cannot change the verdict and are waste by definition.

## Scope

1. `skills/behavioral-testing/SKILL.md` — extend the supervise-every-run rule
   with the **verdict-confirmed conclusion mandate**: when a poll's semantic
   check confirms the SC verdict state (green — the goal condition observed
   met; or red — the goal condition observed failed / a run-fatal defect
   observed), the supervisor MUST conclude the run in that same cycle:
   PID-addressed kill of the run process tree, §10.5 export when the
   artifact set is incomplete, recorded confirmation (which poll confirmed,
   the event citations, the verdict state) in the evidence directory — then
   proceed to evaluation. Polling past the confirming poll is a supervision
   defect. The kill is the supervisor's own abort signal (GNU `timeout`
   remains forbidden); early conclusion is distinct from the §10 remediation
   paths — it is a successful (or honestly-failed) run ending on its own
   evidence.
2. `tests-v2/AGENTS.md` §14 — mirror the mandate in the Evidence-Sufficiency
   Early Exit section: two exits become three-tier — evidence-sufficiency
   (judgment) and **verdict-confirmed (mandatory once the poll's semantic
   check establishes green or red)**. Same kill/export/record mechanics.
3. No changes to `helpers.sh`, `with-test-home`, or the harness monitor
   machinery — the mandate binds the agent supervisor, which is card-owned
   surface (same ownership as the #2557/#2561 supervision rules).

**Out of scope:** harness monitor automation changes (the confirmation
judgment remains intent-decidable — judgment decides, mechanisms verify);
changes to the #2538 sufficiency rule itself (it stands unchanged); the
`.opencode#2589` pipeline (proceeds separately; its conclusion record
documents the observed defect).

## Success Criteria

| ID | Criterion | Type | Instrument |
|----|-----------|------|------------|
| SC-1 | `skills/behavioral-testing/SKILL.md` and `tests-v2/AGENTS.md` §14 both carry the verdict-confirmed conclusion mandate with consistent mechanics (confirm → kill by PID → export → record → evaluate; polling past the confirming poll is a defect), the confirmation trigger is stated as mandatory (not a value judgment), and the red-state case (goal observed failed) is covered alongside green | structural | file read + grep for the mandate anchors in both files; `./.opencode/tools/reference-integrity` passes on both |
| SC-2 | A monitored behavioral run whose verdict state becomes confirmed mid-run is concluded in the confirming poll's cycle: the poll log shows the confirming semantic analysis, then the conclusion actions (PID-addressed kill, export, recorded confirmation), and no further poll cycles after the confirming poll | behavioral | targeted supervised run (`supervision-early-abort-confirmed-green` scenario) + its poll log in the evidence directory |
| SC-3 | Clean-room evaluation of SC-2's poll log confirms: the confirming poll's semantic analysis identified the verdict state, conclusion actions followed within the same cycle, no poll cycles occurred after the confirming poll, and the confirmation record names the event citations | behavioral | clean-room sub-agent reads the SC-2 evidence directory, returns PASS/FAIL with citations |

**Ordering:** SC-1 before SC-2 (the supervisor follows the fixed card);
SC-2 before SC-3 (two-SC pattern; SC-3 is the clean-room evaluation
dispatch).

## Analysis and Risks

- **The confirmation step stays intent-decidable.** Whether a poll's
  evidence confirms the verdict state is a judgment on the run agent's
  actual words and work — never a scripted pattern match. The mandate
  governs what happens *after* confirmation, which is mechanical.
- **Red-state case matters as much as green.** A run whose failure is
  already evident (e.g., the agent halted deferring remote closure — the
  exact behavior 2561-sc1 probes for) must conclude at the confirming poll
  too; waiting out a confirmed-red run burns inference and delays
  remediation.
- **Interaction with §10.7 resumption:** early conclusion is not a timeout
  kill; resumption does not apply. The conclusion record must state the
  verdict state so downstream evaluation treats the run as complete.
- **Cost justification (CM-1):** the observed defect cost ~5 supervision
  cycles in one run and repeats on every future monitored run without the
  mandate; the card text is the minimal fix surface. The SC-2 demonstration
  run uses a small-scoped scenario to bound cost.

## Provenance

- Developer ruling, session 2026-10-13: "the agent is not early aborting on
  confirmed green or red state causing wasted cycles, project delays, and
  divergence into the weeds. add an SC and address this in the appropriate
  skill cards."
- Observed incident: `.opencode#2589` SC-5 supervised run, 2026-10-13 —
  green confirmed at poll 47 (17:41:10Z), polling continued through poll 50;
  conclusion record at
  `tmp/behavioral-evidence-2561-sc1-verified-moot-closes-remote-GREEN-ollama-qwen3.8-27b-256k-gguf4-3/conclusion-record.md`.
- Adjacent standing rules: Evidence-Sufficiency Early Exit (#2538);
  supervision cadence and update discipline (#2557, #2570, #2561).

Predicate classification: the confirmation judgment is intent-decidable
(judgment, never scripted); the post-confirmation conclusion actions are
mechanical and fact-decidable (process gone by PID, export file exists,
record present).
