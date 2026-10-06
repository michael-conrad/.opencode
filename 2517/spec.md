# Spec: .opencode#2517 — behavioral verification routes through the tests-v2 harness

Provenance: observed regression 2026-10-05 during #2516 implementation — the
agent ran an ad-hoc, direct `opencode run` (production snap binary, scratch
directory) instead of the `.opencode/tests-v2/` harness, used an
interview-style prose-recall prompt (§11 hard-fail), and probed for alternate
models on a usage-limit error (§10.6 no-outguess mandate). The remote issue
body carries the full observation record.

## Problem

The deck's behavioral test framework documents exhaustive mandates for itself
(isolation, two-SC pattern, prompt construction, default model, remediation
paths) but nothing routes an agent to it. An agent whose intent is "verify a
behavioral SC" has no dispatch surface — the framework is found only by
accident, and the bypass happens before any guard fires.

## Success criteria

### SC-1 (structural) — routing entry for behavioral verification

The routing index (`.opencode/routing.md`) contains an entry dispatching
behavioral verification / behavioral testing intent to the `tests-v2`
framework.

- **Verify:** read `.opencode/routing.md`; an intent-phrased entry names
  `tests-v2` (behavioral runs, harness, behavioral SC evidence).

### SC-2 (structural) — implementation/verification cards carry the harness mandate

The workflow card(s) that own verification during implementation
(`skills/implement/SKILL.md` and/or `skills/verify/SKILL.md`) state that
behavioral SC evidence is produced only through the `tests-v2` harness
(`with-test-home` + `behavior_run()`), and that ad-hoc `opencode run` is
prohibited — lean reference, not a restatement of `tests-v2/AGENTS.md`
content.

- **Verify:** read the edited card(s); the mandate and the reference to
  `tests-v2/AGENTS.md` are present; no duplicated harness detail.

### SC-3 (behavioral) — an agent dispatched to verify a behavioral SC uses the harness

An agent given a task to produce behavioral evidence for an SC runs it
through the tests-v2 harness (session shows `with-test-home`/`behavior_run`
invocation or reading of `tests-v2/AGENTS.md` as its first verification step),
not a direct `opencode run`.

- **Verify:** two-SC pattern per `tests-v2/AGENTS.md` §6a —
  SC-3a: artifact-generating behavioral run via a new scenario script in
  `tests-v2/behaviors/` following `template.sh`, real-domain prompt, fixture
  issue under `fixtures/issues/`;
  SC-3b: clean-room sub-agent reads the exported `session.yaml` and evaluates
  whether the agent's verification path went through the harness.

### SC-4 (structural) — reference integrity

All Read-links added or moved by this change resolve (§6c check).

- **Verify:** `./.opencode/tools/reference-integrity --scan` exits 0 after the
  edits.

## Out of scope

- Changes to `tests-v2/AGENTS.md` isolation mandates or the harness itself
  (working as documented).
- #2516's floor/vocabulary work (separate spec, in progress).

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
