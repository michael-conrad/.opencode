<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored. Revised from the 2026-11-01 defect filing
     (#2650) into this specification under the developer's directive of
     2026-11-01 (triage .opencode#2650 and convert it into a full spec).
     Evidence basis: the filing's observed failure record, verified by code
     inspection this session — triage verdict
     `.opencode/.issues/2650/verdict.md` (2026-11-02 UTC). -->

# [SPEC] Two-SC manifest rewrite — idempotent per-pass recording

## Problem

The two-SC behavioral scenario scripts record the two-turn exchange shape in
their artifact's `manifest.yaml` by a rewrite block that concatenates the
previous manifest with freshly echoed lines:

```bash
{
    cat "$artifact_dir/manifest.yaml" 2>/dev/null || true
    echo "two_turn: true"
    echo "turn2_resumed_home: $test_home"
    [ -n "${SC8_SKIP_TURN2:-}" ] && echo "tail_materialization_pass: true (...)"
} > "$artifact_dir/manifest.yaml.tmp" && mv "$artifact_dir/manifest.yaml.tmp" "$artifact_dir/manifest.yaml"
```

`2639-sc8-second-directive-rides-open-pr.sh` recovery mode
(`SC8_RECOVERY_HOME`) runs turn-1's fresh `behavior_run` only on pass 1 and
then re-discovers the newest existing artifact directory on every recovery
pass — so each recovery pass re-enters this rewrite block against the same
file, appending one more copy of `two_turn`, `turn2_resumed_home`, and (on
skip-turn2 materialization passes) `tail_materialization_pass`
(script lines 45–61, 160–166).

**Observed failure (filing's record, verified by inspection):** 9
repetitions of these keys in the SC-8 artifact manifest after pass 9 of
the recorded sequence (9 passes total — pass 1's fresh run and turn-2
block, then 8 recovery passes). The repetition count follows the mechanism
arithmetically: one copy per recording pass — the pass-1 rewrite block's
first copies, plus one per recovery pass. Today every duplicate carries
an identical value, so YAML last-wins parsing reads a correct manifest —
cosmetic at runtime — but it is a data-hygiene defect in the evidence
artifact the clean-room evaluator reads: consumers reading first occurrences
instead of last, or validating strictly, get inconsistent behavior, and the
free-text `tail_materialization_pass` annotation is the one field whose
future pass-variant wording could silently diverge between first- and
last-wins readings.

**Root causes covered:**

- **RC-1 (→ dup accumulation)** — pass-reuse of one artifact directory
  (recovery re-discovery) against an unguarded concatenate-and-re-echo
  rewrite: N passes → N copies. The block's sibling surface in the same
  recovery path already carries the matching fix for this class — the
  `TEST_HOME=` marker append is guarded with `>>` ("a second recovery pass
  must not clobber the prior pass's recovery evidence",
  `.opencode#2646` docker-resume fix) — the manifest was missed by that fix.
- **RC-2 (→ no per-pass structure)** — the per-pass annotation is echoed as
  a bare scalar line, so per-pass recording has no per-pass key to land on;
  idempotence for it can only mean dropping repeated entries or tolerating
  duplicates.

## Scope

The `.opencode` deck's behavioral-harness scenario surface only:

- `tests-v2/behaviors/2639-sc8-second-directive-rides-open-pr.sh` — the
  manifest rewrite block becomes pass-idempotent recording.
- `tests-v2/behaviors/2557-sc7-ask-record-commands.sh` — its same-pattern
  rewrite block (lines 72–77; `two_turn` / `turn2_resumed_home`, no pass
  annotation) takes the same shape; the issue's title covers the two-SC
  scripts and the block is one shared pattern.
- `tests-v2/behaviors/helpers.sh` — one new manifest-recording helper used
  by both scripts' blocks (the only `helpers.sh` touch).
- One non-model verification probe under `tests-v2/` exercising the
  recording path across a simulated pass sequence (R-1's and R-2's
  instrument; §11/§6a concerns do not apply — this is harness-side
  generation-metadata code, not model-behavior evidence).
- The `.opencode#2650` record — body and labels reconciled on both surfaces
  so the spec filing is consistent with the store (SC-5 decides the end
  state).

## Requirements

- **R-1 — pass-idempotent scalar keys.** The two-SC manifest recording
  SHALL be idempotent across recovery passes: repeated recording
  invocations against one artifact directory never grow `two_turn` or
  `turn2_resumed_home` occurrence counts beyond one each, the recorded
  value is the latest invocation's, and the write preserves every key and
  value the previous manifest carries beyond those two scalars — the base
  heredoc keys (`scenario_name`, `phase`, `model`, `timestamp`,
  `exit_code`, `harness_version`) and everything recorded into the
  manifest between recording passes (e.g. a `resumed_after_cap_hit: true`
  marker appended by `behaviors/helpers.sh` line 2273 in the pass-1 cap-hit
  path, which today's concatenate-first block carries forward).
- **R-2 — per-pass annotation collection.** The tail-materialization pass
  annotation SHALL append exactly one entry to a per-pass list key
  (e.g. `tail_materialization_passes: [...]`) per annotation-carrying
  recording invocation — entries accumulate one per invocation, even when
  entries' text is identical (per-pass identity is the invocation, never
  value uniqueness) — replacing the current re-echoed
  `tail_materialization_pass` scalar; an invocation carrying no annotation
  adds no entry and no list key. Repeated passes never duplicate an entry
  beyond that one-per-invocation rule and never lose an earlier one.
- **R-3 — shared shape, both scripts.** Both two-SC scripts
  (`2557-sc7`, `2639-sc8`) SHALL record the two-turn shape through the one
  idempotent recording path — no script retains the inline
  concatenate-and-re-echo block; SC-7's call carries no pass annotation, so
  its recording output adds only the two scalar keys it records today.
- **R-4 — unchanged harness surfaces.** All other manifest surfaces SHALL
  keep current behavior unchanged: the base heredoc manifest
  (`behaviors/helpers.sh` 2176), the `resumed_after_cap_hit: true`
  append (2273), the `TEST_HOME=` marker append, fixture-written manifests
  (`fixtures/setup/*.sh` heredocs), and `session.yaml`'s own shape — no
  machinery outside the two-SC recording blocks and the probe changes.
- **R-5 — record truth.** The `.opencode#2650` record SHALL read
  consistently across surfaces: title and labels agree between the GitHub
  tracker and `.opencode/.issues/2650/`, renamed to this spec's `[SPEC]`
  title with labels `bug`, `spec-fix`; the remote body
  carries this spec as a structured summary closing with a resolvable
  artifacts pointer; `.opencode/.issues/2650/spec.md` is the single
  authoritative spec; the pre-conversion filing body is archived in the
  store folder (`issue-body-original.md`).

## Success criteria

- **SC-1 (behavioral) (→ R-1).** Three consecutive recording invocations
  against one artifact directory leave `two_turn` and `turn2_resumed_home`
  at exactly one occurrence each, values the invocations supplied, all six
  base-manifest keys present, and the seeded pre-existing marker key
  (`resumed_after_cap_hit: true`, seeding the pass-1 cap-hit append)
  preserved. *Instrument:* executed non-model probe under `tests-v2/` that
  drives the recording path three times over one seeded temp artifact dir;
  a YAML parse plus key-occurrence count of the resulting `manifest.yaml`
  (captured output). A three-invocation sequence observes the accumulation
  mechanism directly: the unguarded rewrite adds ≥2 further copies per key;
  the idempotent rewrite adds none — the probe can in principle fail on the
  current code (verified: the block appends unconditionally on each
  invocation).
- **SC-2 (behavioral) (→ R-2).** Three consecutive invocations carrying the
  pass annotation leave a single per-pass list key whose value holds
  exactly three entries, and no `tail_materialization_pass` scalar line; a
  further no-annotation invocation adds no entry and no list key. *Instrument:* the same
  probe; occurrence count of the list key and absence of the scalar
  (captured output).
- **SC-3 (structural) (→ R-3).** Both two-SC scripts record through the
  shared recording path and retain no inline concatenate-and-re-echo block.
  *Instrument:* grep across `tests-v2/behaviors/*.sh` returns the inline
  pattern at zero call sites it does not belong to; read-back confirms both
  scripts invoke the one recording path.
- **SC-4 (structural) (→ R-4).** Unchanged-surfaces check: no file outside
  the two-SC scripts, `helpers.sh` (the one recording helper), the probe,
  and the #2650 record changes, and `helpers.sh`'s other manifest surfaces
  (base heredoc, `resumed_after_cap_hit` append) are byte-identical.
  *Instrument:* recorded diff review of the change against its base tip;
  grep confirms the appended line at 2273 untouched.
- **SC-5 (structural) (→ R-5).** Record parity. *Instrument:* read-back of
  GitHub #2650 and `.opencode/.issues/2650/` — titles equal, labels equal
  (`bug`, `spec-fix`), the remote body carries this spec's structured
  summary closing with a resolvable artifacts pointer, the local store body
  mirrors the remote body, `spec.md` present and store-authoritative, and
  `issue-body-original.md` present.

## Out of scope

- Full recovery runs with live model inference as the verification
  instrument — a real cap-hit resume is not deterministically reproducible
  on demand; the probe exercises the identical recording code path with
  bounded cost (R-1's instrument basis). Scenario RED/GREEN behavior of the
  model runs is untouched by this change.
- The recovery/re-discovery mechanics themselves (`SC8_RECOVERY_HOME`
  directory selection, `--resume-home`, determination gates,
  `__resume_on_cap_hit` ceilings) — they are working
  `.opencode#2646` machinery; only the recording shape it re-enters
  changes.
- Any manifest consumer change — nothing in the deck reads these keys
  (consumer scan recorded 2026-11-02: only the two write sites and no read
  sites across `tests-v2/` and the deck).
- Fixture-written manifests, other scenario scripts' heredoc manifests, and
  the §12/§13 harness surfaces.
- Closure logistics for #2650 — post-merge cleanup per the issues card is
  not a spec deliverable.

## Approach

1. **Shared recording helper (R-1, R-2, R-3).** Add one
   `behaviors/helpers.sh` function — pass-idempotent manifest recording:
   read the existing manifest, overwrite the two-turn scalars to single
   occurrence, append the pass annotation as one entry to the per-pass list
   key only when the invocation carries one. An annotation-only-when-new
   list (never a re-echoed scalar) directly answers RC-2; single-occurrence
   overwrite answers RC-1.
2. **Call it from both blocks (R-3).** SC-8's block calls the helper with
   its skip-turn2 annotation; SC-7's block calls it with no annotation. The
   inline `cat`-echo blocks are deleted in the same change that lands the
   calls (self-containment).
3. **Probe (SC-1, SC-2's instrument).** One non-model test under `tests-v2/`
   seeds a temp artifact dir with a base manifest plus a
   `resumed_after_cap_hit: true` marker line (the pass-1 cap-hit append
   path), drives the recording path three times with the pass annotation
   (mirroring the observed materialization passes) and once without, and
   parses/asserts the resulting manifest — occurrence counts, list shape,
   and marker preservation, captured output. The probe is invoked directly
   (`bash <probe>`), registered into no runner's scenario registries —
   `tests-v2/test-enforcement.sh`'s in-file scenario registries are
   outside R-4's changed-file set, so runner registration is out of scope
   (R-4's constraint, stated to close the deferral branch). RED on the
   current code (duplicates accumulate), GREEN with the helper.
4. **Record reconciliation (R-5).** Labels gain `spec-fix` alongside `bug`
   on both surfaces; the remote body is re-shaped with this spec's summary
   and the closing artifacts pointer; the local store body mirrors it; the
   pre-conversion body is archived first (this revision's flow, before
   implementation).

**Impact.** Blast radius: two scenario scripts, one `helpers.sh` helper, one
new probe test, the #2650 record/labels — no other harness, deck, tool, or
hook surface. Consumers: the clean-room evaluator reads artifact manifests
as generation metadata — SC-7/SC-8 artifacts' key semantics are unchanged;
the tail annotation's shape moves from repeated scalar to a per-pass list
with no deck reader affected (scan on record). Dependent tests: none assert
these manifest keys; fixture manifests are heredoc-written and unaffected
(R-4). Recovery: text edits on the deck's feature branch — every element
reverses through branch history.

🤖 OpenCode (huggingface/zai-org/GLM-5.3-Flash)