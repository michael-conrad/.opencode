# Plan Input Verification Ledger — issue 2446

- **Issue state:** open; labels: `approved-for-pr` (from local `issue.yaml`, read 2026-09-17). Remote: https://github.com/michael-conrad/.opencode/issues/2446
- **Spec:** `.opencode/.issues/2446/spec.md` — SPEC-FIX for `local-issues --labels` parsing/rejection/help text.
- **SCs with evidence types:**
  - SC-1 — behavioral — `_normalize_labels(['a, b']) == ['a', 'b']`; `['needs-approval']` unchanged; wired into cmd_update/cmd_create before `_ensure_needs_approval`.
  - SC-2a — behavioral — `cmd_update` fails fast on malformed remainder pre-write/pre-auto-commit; issue.yaml byte-identical.
  - SC-2b — behavioral — `cmd_create` fails fast on malformed remainder; no issue.yaml created.
  - SC-3a — string — `update --help` documents accepted `--labels` formats + rejection.
  - SC-3b — string — `create --help` documents accepted `--labels` formats + rejection.
- **Structure artifact phases:** single phase-1 ("Label normalization helper + fail-fast rejection + help text") covering all 5 SCs, DAG has one node, no edges, item order SC-1 → SC-2a → SC-2b → SC-3a → SC-3b. Triplet co-location and no-cross-phase-dependency verified in artifact.
- **Affected file:** `.opencode/tools/local-issues` (single file) + its test file under `.opencode/tests/`.
- **CLI surface needed:** `./.opencode/tools/local-issues update <repo>#<N> --labels <l1> <l2>` — note: update REPLACES the whole labels array, so every label write must include all existing labels plus any new one. For label write: `update .opencode#2446 --labels approved-for-pr spec-cleared`.
- **Per-task cycle steps (from implementation-workflow reference card):** pre-regression, pre-regression-verify (pre-implementation); red, green, post-regression, verify, commit-inline (per item); audit, z3-check, structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary (post-implementation). Pre-cleanup table applies per step label.
