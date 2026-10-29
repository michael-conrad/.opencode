<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored; plan for michael-conrad/.opencode#2685, derived from .opencode/.issues/2685/spec.md -->

# Plan — Default test model is qwen3.8:27b-128k-gguf4 (#2685)

Spec: `.issues/2685/spec.md`. SC-1 and SC-3 evidence is on file (merged
#2684; #2681 GREEN harness manifests). Remaining items below.

## Item 1 — retire the with-test-home fallback literals (SC-2 → R-2)

- **Deliverable:** the two structurally distinct fallback sites lose their
  hardcoded `ollama/qwen3.8:27b-256k-gguf4` literal, keeping each site's own
  flow:
  - line 281: `local default_model="${DEFAULT_TEST_MODEL:-…}"` →
    `local default_model="$DEFAULT_TEST_MODEL"` (the `source
    "$SCRIPT_DIR/default-model.sh"` directly above already exports it; with
    the file absent it falls through unset — no hardcoded pin).
  - line 393: inside the existing `if [ -z "${default_model:-}" ]` guard
    (after the site's own `source` + `default_model="$DEFAULT_TEST_MODEL"`
    assignment), drop the literal fallback branch — the guard reduces to the
    sourced value; no second default source remains.
  No new failure behavior is added (spec: "source the file or fall through
  to its exported value; no hardcoded model string remains").
- **RED:** `grep -n "27b-256k-gguf4" tests-v2/with-test-home` hits lines 281
  and 393.
- **GREEN:** the two edits; `bash -n` passes; a functional check that an
  override still wins (`DEFAULT_TEST_MODEL=ollama/x:1` reaches the config).
- **Instrument:** the grep returns zero `27b-256k-gguf4` hits in
  with-test-home; read-back of both sites.

## Item 2 — AGENTS.md doc currency (SC-4 → R-3)

- **Deliverable:** `tests-v2/AGENTS.md` lines 349, 543, 672, 766: the embedded
  model value becomes `ollama/qwen3.8:27b-128k-gguf4`; rule text unchanged.
- **RED:** `grep -n "27b-256k-gguf4" tests-v2/AGENTS.md` hits four lines.
- **GREEN:** the four targeted value replacements.
- **Instrument:** the grep returns zero hits.

## Item 3 — verification-only closeout (SC-1, SC-3)

- **Instrument:** executed sourcing both ways (SC-1 output captured) and the
  on-file manifests for SC-3; grep of the whole `tests-v2/` for the
  superseded literal showing only the sanctioned 2557-sc17 fixture hit.

## Order

1 → 2 → 3. Structural, one feature branch, one commit per issue at the PR.