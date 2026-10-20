# Plan — .opencode#2646: bound per-turn generation in behavioral runs

Spec: `.opencode/.issues/2646/spec.md` (validated PASS after the attempt-7
falsification of finish-then-continue; cap + resume composition). Branch:
stacked on `feature/2639-scope-boundary-stacked-pr`, same PR as
#2639/#2645. Note: Items 1–2 of the first pass are already committed (cap
lines as literal 4000; AGENTS.md doc block). This plan revises those
in place per the revised spec — test-contract currency applies to the
committed doc text.

## Item 1 — Cap surfaces to the env-default form (SC-1, SC-3)

- Deliverable: the two `with-test-home` surfaces (env -i allowlist line and
  set-env.sh export line) change from literal `4000` to
  `${OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX:-4000}`; `docker-harness.sh` and
  the `helpers.sh` classifier seeder keep literal `4000`. Every ordinary run
  executes with 4000; a probe may override via the parent env.
- RED: grep shows the two with-test-home surfaces in literal form (0 hits
  for the `:-4000` form) — captured pre-change output.
- GREEN: apply the two-line change.
- Verify: surface-scoped asserts 2 (`:-4000` in with-test-home) + 1 + 1
  (literal); no other env-surface additions; `default-model.sh` untouched.
- Dependency: none.

## Item 2 — Correct the committed AGENTS.md doc block (SC-2)

- Deliverable: the §5 "Bounded Per-Turn Generation" block revised to match
  the revised spec: cap-hit behavior is a clean length finish that ENDS an
  agentic session (truncation mid-reasoning issues no tool call — attempt-7
  evidence), the resume-on-cap-hit composition (R-4: monitored runs,
  `--resume-home` + `--continue`, ceiling-bounded) continues the work, the
  env-default override form (probe-only), and the supervision relationship
  (cap hit = normal cadence, never an abort signal).
- RED: the committed block carries the falsified "the session continues
  next turn (verified empirically…)" sentence — grep for it (1 hit
  pre-change).
- GREEN: rewrite the block.
- Verify: read-back asserts all R-2 elements; the falsified sentence is
  gone; reference-integrity passes.
- Dependency: none.

## Item 3 — `behavior_run()` resume-on-cap-hit, both tiers (SC-5 structural)

- Deliverable: in `tests-v2/behaviors/helpers.sh`, after the model run
  exits, a fact-decidable probe of the session store's last assistant
  message: `finish: length` → resume that session, monitored runs only,
  ceiling-bounded (default 3 resumed runs per attempt, counter persisted
  next to the attempt's evidence); ceiling exhaustion ends the attempt and
  exports evidence. The exported `session.yaml` covers the full exchange
  (the shared session store already merges both runs' events).
  Tier mechanics (the motivating attempt 7 was tier-2, so both tiers must
  resume):
  - host tier: `with-test-home --resume-home <home> opencode run
    --continue` (the §10.7 form; the home carries the binary).
  - docker tier: a second container run of the same harness invocation
    shape with `--resume-home <staged-home> opencode run --continue` —
    `docker-harness.sh` (inside the spec's blast radius) grows the resume
    launch; the staged home persists under the mounted `tmp/` at the same
    absolute path, so the in-container determination gate and session store
    resolve unchanged. **Binary-gate amendment (required, same item):**
    `with-test-home`'s `--resume-home` path FATALs when
    `$TEST_HOME/bin/opencode` is absent, and docker-tier homes are bare by
    contract (the image's `/usr/local/bin/opencode` is the instrument) — so
    `with-test-home` gains a `TEST_ENV=docker`-aware branch in the resume
    binary check (docker: resolve the image binary; host: unchanged). This
    touches `with-test-home` after Item 1; the item re-asserts SC-3 over
    that file's final state (the binary-gate change is not an env-surface
    addition).
  The §10.7 SC-8 determination gate governs permissibility on both tiers
  (monitored runs write their determination record on natural completion;
  non-undetermined records permit the resume; the persistent
  undetermined-ceiling block composes with the R-4 ceiling).
- RED: grep helpers.sh and docker-harness.sh for the resume anchors
  (`finish: length` probe / `--resume-home` in the post-run path) — zero
  hits pre-change.
- GREEN: implement both tier paths.
- Verify: read-back asserts the structural elements on each tier (probe,
  resume form, monitored scoping, ceiling) plus the docker-aware binary
  gate; bash -n syntax check passes on all touched files; SC-3 re-asserted
  over `with-test-home`'s final state.
- Dependency: Item 1 (the override form is what the probe needs).

## Item 4 — Probe scenario `2646-sc-cap-resume-probe.sh` (SC-5 behavioral)

- Deliverable: `tests-v2/behaviors/2646-sc-cap-resume-probe.sh` —
  artifact-only generator per tests-v2 AGENTS.md. Tier: **3 (host)** — the
  R-1 parent-env override only reaches `with-test-home` on the host path
  (the tier-2 docker_env passes the literal 4000 by spec). The script
  launches `OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX=150
  BEHAVIOR_SEMANTIC_MONITOR=1 behavior_run ...` (the monitored-run flag
  gates the very behavior the probe exercises; the in-repo monitored
  pattern is `BEHAVIOR_SEMANTIC_MONITOR=1 behavior_run`), with a
  real-domain task (a small file edit), and exits 0; the resumed exchange
  lands in the same session store. Cross-reference header, tier
  designation, no assertion helpers. Clean-room evaluation (separate
  dispatch per §6a) asserts from `session.yaml` that the capped turn is
  followed by a resumed exchange in the same session store.
- RED: the file does not exist pre-change (ls check).
- GREEN: author the script.
- Verify: harness smoke — the probe run produces artifacts with
  `manifest.yaml` + `session.yaml` and exit 0, and the session evidence
  shows the cap hit plus the resumed exchange.
- Dependency: Items 1–3 committed and pushed (pre-flight git-state gate).

## Item 5 — SC-4 + #2639 SC-7 re-run (attempt 8) and probe evaluation

- Deliverable: run `2639-sc7-one-branch-one-pr.sh` (tier-2) under the
  composed cap+resume environment (attempt 8) — a cap hit in this run now
  resumes in-container per Item 3 instead of ending the session. The probe
  is NOT re-run: Item 4's verify already executed it under the final
  composed state, and its artifacts are the deterministic SC-5 evidence.
  Item 5 dispatches the clean-room evaluations against the existing
  artifacts: SC-4 (no turn exceeds the cap) and #2639 SC-7 (one branch,
  one PR, one commit per issue) from the attempt-8 run; SC-5 (resume
  observed) from the Item-4 probe artifacts. One run per SC-GREEN need
  (tests-v2 §15 budget).
- Verify: executed runs with artifacts; evaluation verdicts recorded.
- Dependency: Items 1–4.
