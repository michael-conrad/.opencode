<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Plan for .opencode#2650, derived entirely from .opencode/.issues/2650/spec.md. -->

# Plan — Two-SC manifest rewrite: idempotent per-pass recording

Derivation: every item below traces to the spec's SCs (SC-1…SC-5) and
requirements R-1–R-5; no other items. Surfaces live in the `.opencode`
submodule (`michael-conrad/.opencode`), feature branch
`feature/2650-manifest-idempotent-recording`; no parent-repo file changes.

Shared fixture basis (used by Items 1 and 2): a temp artifact dir seeded with
a base manifest carrying the six base-heredoc keys (`scenario_name`, `phase`,
`model`, `timestamp`, `exit_code`, `harness_version`) plus a
`resumed_after_cap_hit: true` marker line (seeding the pass-1 cap-hit append
path, `behaviors/helpers.sh` line 2273).

### Item 1 — Verification probe with legacy-mode RED (SC-1, SC-2)

- **Deliverable:** one non-model probe
  `tests-v2/2650-manifest-recording-probe.sh` under `tests-v2/`, invoked
  directly (`bash <probe>`), registered into no runner's scenario registries
  (R-4's exclusive changed-file set). The probe's per-recording-invocation
  step resolves the recording path at runtime: when
  `behaviors/helpers.sh` defines the two-SC recording helper it sources
  helpers.sh and calls the helper; otherwise it executes the legacy
  concatenate-and-re-echo pattern verbatim as the two-SC scripts carry it
  today (this is what makes the probe RED-able on pre-change code — the
  block appends unconditionally on each invocation, verified by inspection
  of `2639-sc8-…:160–166` and `2557-sc7-…:72–77`). Sequences driven:
  (a) seeded fixture, three annotation-carrying invocations, assert
  `two_turn` and `turn2_resumed_home` each exactly once with the invocation
  values, all six base keys present, `resumed_after_cap_hit: true`
  preserved (SC-1); (b) three annotation-carrying invocations plus one
  without: single per-pass list key (`tail_materialization_passes`) with
  exactly three entries, no `tail_materialization_pass` scalar line (SC-2);
  plus a duplicate-pattern grep over the final manifest for output capture.
- **RED:** run the probe against unchanged code — the legacy branch
  executes and the assertions fail on duplicate scalar keys (captured
  output).
- **GREEN:** reached via Item 2 (the probe file is unchanged between RED
  and GREEN).
- **Instrument:** the probe itself; captured stdout.

### Item 2 — Shared recording helper + both call sites (SC-1, SC-2, SC-3)

- **Deliverable:** one new `behaviors/helpers.sh` function
  `__record_two_turn_manifest` (pass-idempotent recording): reads the
  existing manifest, rewrites `two_turn` and `turn2_resumed_home` to single
  occurrence with the latest invocation's values, appends the pass
  annotation as one entry to the per-pass list key exactly when the
  invocation carries one, and preserves every other key and value
  (R-1, R-2). Both two-SC scripts call it — SC-8's block at
  `2639-sc8-second-directive-rides-open-pr.sh:160–166` (with the
  skip-turn2 annotation, `[ -n "${SC8_SKIP_TURN2:-}" ]` passing the
  annotation text into the helper conditionally) and SC-7's block at
  `2557-sc7-ask-record-commands.sh:71–77` (no annotation); the inline
  `cat`-echo blocks are deleted in the same change (R-3,
  self-containment). All other `helpers.sh` manifest surfaces untouched
  (base heredoc 2176, `resumed_after_cap_hit` append 2273 — R-4).
- **RED:** covered by Item 1's RED (the same failure mechanism this item
  removes).
- **GREEN:** Item 1's probe run against the changed tree passes SC-1's and
  SC-2's assertions (captured output).
- **Instrument:** probe output (SC-1/SC-2); grep of
  `tests-v2/behaviors/*.sh` for the inline concatenate-and-re-echo pattern
  returning zero matches and read-back of both scripts' call sites (SC-3);
  recorded diff review of the change against base tip `7e409e2ab` plus
  grep confirming line 2273's append untouched (SC-4's facts, gathered
  here, recorded at verify).

### Item 3 — Record reconciliation read-back (SC-5)

- **Deliverable:** none beyond verification if parity already holds —
  GitHub #2650 title (`[SPEC] …`), labels (`bug`, `spec-fix`), remote body
  carrying the spec summary + resolvable artifacts pointer, local store
  body mirroring it, `spec.md` store-authoritative,
  `issue-body-original.md` archived (all observed present in the store
  2026-11-02; remote parity confirmed this session's triage before
  branching). Any discovered drift is remediated through the issues card
  before PR creation.
- **RED:** N/A — structural read-back of a record; the instrument decides
  pass/fail, no code change is derived.
- **GREEN:** read-back parity record (captured `gh issue view` output and
  store `issue.yaml` compare).
- **Instrument:** read-back of GitHub #2650 and `.opencode/.issues/2650/`.

### Full-suite and verify gates (post-items)

After Items 1–2: structural checks clean; fresh-context `verify` PASS
against the spec (primary artifacts: spec.md, branch diff, probe output)
before PR creation. Item boundaries carry RED/GREEN evidence captured during
execution; the verify dispatch is the pre-PR gate.

🤖 OpenCode (huggingface/zai-org/GLM-5.3-Flash)