<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored; developer directive 2026-10-29: "create a spec to switch
     to the model just used as the default model". Change already merged via #2684
     (2-line default-model.sh edit applied in-session under the developer's directive);
     this specification is the formal record that change lacked (the #2681 pattern). -->

# [SPEC] Default test model is qwen3.8:27b-128k-gguf4

## Problem

On 2026-10-28 the behavioral runs for #2681 exhausted the bounded-generation
ceiling on `ollama/qwen3.8:27b-256k-gguf4`: the model's reasoning turns
repeatedly truncated at the output cap (`finish: length`, 3+ cap-resumes per
attempt, one attempt ending capped-exit), burning ~1h per attempted scenario.
Smoke measurement showed the deployment's `qwen3.8:27b-128k-gguf4` tag fits
100% in VRAM (21 GB vs a 24 GB card, no PCIe spill) and ran ~1.6×–5× faster on
the same generations. The developer directed the switch ("switch the model to
128k-gguf4") in session on 2026-10-29 and the 2-line `tests-v2/
default-model.sh` change merged via #2684 — but it rode that PR unenumerated:
no spec named it, so the change's record sources from the commit message
alone. This specification is that missing record (the #2681-record pattern:
the change is already merged; the spec formalizes and verifies it).

The observed facts backing the switch (recorded 2026-10-29, single RTX 3090
24 GB):

- `qwen3.8:27b-256k-gguf4`: 28 GB loaded (21% CPU / 79% GPU — spills), ~4–8 tok/s in
  agent sessions; repeated `finish: length` truncations under agent reasoning loads.
- `qwen3.8:27b-128k-gguf4`: 21 GB loaded (100% GPU), ~36 tok/s standalone,
  ~6.5+ tok/s sustained through full behavioral scenarios; #2681's two
  behavioral scenarios completed end-to-end on it after failing on 256k.

## Scope

- `tests-v2/default-model.sh` — the single-source `DEFAULT_TEST_MODEL`
  default is `ollama/qwen3.8:27b-128k-gguf4` (merged in #2684; this spec
  defines its acceptance).
- `tests-v2/with-test-home` — the two inline fallback literals naming
  `qwen3.8:27b-256k-gguf4` (line 281 `local default_model="${DEFAULT_TEST_MODEL:-…}"`,
  line 393 classifier/warmup `default_model=` fallback) retire: they are a
  second single-source definition shadowing `default-model.sh` and now carry
  the superseded default. They align to the `default-model.sh` source (source
  the file or fall through to its exported value; no hardcoded model string
  remains in `with-test-home`).
- `tests-v2/AGENTS.md` — the four doc references carrying the superseded
  default update to `ollama/qwen3.8:27b-128k-gguf4`: line 349 (§5
  seed_model_config fallback description), line 543 (Invocation Examples
  command hardcoding `--model ollama/qwen3.8:27b-256k-gguf4` — updated to
  the new default), line 672 (§9 R-20 clause), line 766 (§10.4 evidence
  claim) — docs-currentness for the surfaces this change made stale. §9's
  standing rule text ("DO NOT CHANGE the default model unless explicitly
  directed … by an approved spec") itself stays; only the embedded model
  values are current.

Out of scope:

- Model-selection policy itself — R-20 (`tests-v2/AGENTS.md` §9) and the
  card header stand unchanged: failures remediate through the R-18 defect
  classes or re-scope at a spec, never by model substitution. This spec's
  basis is the developer's directive, not agent-side model-shopping.
- The pre-existing literal `qwen3.8:27b-256k-gguf4` inside
  `behaviors/2557-sc17-supervised-polling.sh`'s SCENARIO_PROMPT — that
  scenario is a self-contained historical fixture, not a default-model
  consumer; touching it is its own scope.
- Scenario-scoped overrides (`BEHAVIOR_SUBMODULE_COMMIT`-style pins,
  per-run `DEFAULT_TEST_MODEL` env overrides) — unaffected.
- Changing harness behavior, tiers, or fixtures beyond the fallback-source
  alignment above.

## Requirements

- **R-1 — single-source default.** `tests-v2/default-model.sh` SHALL define
  `DEFAULT_TEST_MODEL` with default value `ollama/qwen3.8:27b-128k-gguf4`
  and preserve the documented override precedence (`${DEFAULT_TEST_MODEL:-…}`
  — an explicitly set caller value wins).
- **R-2 — single source of truth.** No other deck file SHALL define or
  default the shared test-model string: the two inline fallbacks in
  `tests-v2/with-test-home` (line 281 environment fallback, line 393
  classifier/warmup fallback) route through `default-model.sh` instead of
  hardcoding a model; the file header's "single source of truth — do not
  embed model strings elsewhere" rule stays in force across `tests-v2`.
- **R-3 — doc currency.** `tests-v2/AGENTS.md` carries no stale statement of
  the default model value: the line-349 §5 fallback description, line-543
  Invocation Examples command, line-672 §9 R-20 clause, and line-766 §10.4
  evidence claim name `ollama/qwen3.8:27b-128k-gguf4` (rule text unchanged,
  embedded values current).

## Success criteria

- **SC-1 (structural) (→ R-1).** With `DEFAULT_TEST_MODEL` unset, sourcing
  `tests-v2/default-model.sh` yields exactly `ollama/qwen3.8:27b-128k-gguf4`;
  with it set to any other value, sourcing yields that caller value.
  *Instrument:* executed `bash -c` sourcing both ways; captured output.
- **SC-2 (structural) (→ R-2).** The superseded literal
  `qwen3.8:27b-256k-gguf4` no longer appears anywhere in `tests-v2/` except
  the two sanctioned sites: `tests-v2/default-model.sh`'s
  ${DEFAULT_TEST_MODEL:-…} expansion text is exempt only insofar as it no
  longer contains the literal at all (it was changed in #2684), and the
  self-contained PROMPT fixture `behaviors/2557-sc17-supervised-polling.sh`.
  `with-test-home`'s former fallback sites (lines 281, 393) resolve the model
  through `default-model.sh`'s value. *Instrument:* `grep -rn
  qwen3.8:27b-256k-gguf4 tests-v2/` — every hit outside the 2557-sc17
  SCENARIO_PROMPT is a violation; plus read-back of the two remediated
  `with-test-home` sites.
- **SC-3 (behavioral-provenance, already-executed) (→ R-1 as the operative
  effect).** Harness runs on the merged trunk select the new default.
  *Evidence (already on file):* the #2681 GREEN harness manifests record
  `model: ollama/qwen3.8:27b-128k-gguf4` with clean behavioral runs
  (`tmp/issue-2681/artifacts/behavioral-evidence-2681-sc-a-store-hygiene-repair-GREEN-ollama-qwen3.8-27b-128k-gguf4/manifest.yaml`
  and the matching `...-sc-b-remedy-class-boundary-...` manifest) — executed
  through `behavior_run` on the switched default, model recorded by the
  harness itself, not asserted.
- **SC-4 (structural) (→ R-3).** `tests-v2/AGENTS.md` states the current
  default wherever it carries a model value (lines 349, 543, 672, 766 — the
  four surfaces). *Instrument:* `grep -n "27b-256k-gguf4"
  tests-v2/AGENTS.md` returns zero hits; read-back confirms
  `qwen3.8:27b-128k-gguf4` at all four.

## Approach

The default switch itself is merged (#2684) and verified by SC-1/SC-3
evidence on file. The remaining work is the fallback/doc alignment: source
`default-model.sh` from `with-test-home`'s two fallback sites and update the
four `AGENTS.md` references, all verified by the grep instruments above.

## Impact

- **Consumers:** every `behavior_run` invocation, `with-test-home`'s
  classifier/warmup fallback, and any deck process that sources
  `default-model.sh` — all future behavioral runs select
  `qwen3.8:27b-128k-gguf4` unless a caller overrides.
- **Risk:** the 131072-token runtime `num_ctx` is half the 256k tag's — a
  scenario that legitimately needs 262k context re-scopes at its own spec.
- **Blast radius:** `tests-v2/default-model.sh` (already merged in #2684),
  two fallback sites in `tests-v2/with-test-home`, four model-value
  references in `tests-v2/AGENTS.md` (349, 543, 672, 766). No behavioral
  logic changes.
- **Recovery:** the same 2-line file edit reverses the default; behavioral
  evidence on file remains valid (manifests record the model actually used).

> Full spec and artifacts: resolved pointer in the remote issue body after filing.
## Success-criteria table

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | default-model.sh default = 128k-gguf4, override honored | structural | executed `bash -c` sourcing, both ways |
| SC-2 | superseded literal only at the sanctioned fixture; fallbacks sourced | structural | grep `qwen3.8:27b-256k-gguf4` + read-back |
| SC-3 | harness runs select the new default | behavioral (provenance on file) | #2681 GREEN manifests (model recorded by harness) |
| SC-4 | AGENTS.md model values current at lines 349/543/672/766 | structural | grep zero-hit + read-back |
