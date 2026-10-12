<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated; derives entirely from .opencode/.issues/2579/spec.md (validated PASS, zero findings, 2026-10-11) -->

# Implementation Plan — #2579 test-home `external_directory` containment policy

Spec source: `.opencode/.issues/2579/spec.md` (validation verdict: PASS, zero findings, 2026-10-11). Branch: `feature/2579-test-home-external-deny`. Every item traces to exactly one SC; untraceable work is excluded.

## Item 1 — SC-1: Seeder policy flip

- **Deliverable:** the `permission.external_directory` block emitted by both test-home config seeders — `seed_model_config()` in `.opencode/tests-v2/with-test-home` and the classifier-home seeder in `.opencode/tests-v2/behaviors/helpers.sh` — replaced by the seven-rule policy: `"**": "deny"` first, then `"~": "allow"`, `"~/**": "allow"`, `"/tmp": "allow"`, `"/tmp/**": "allow"`, `"/var/tmp": "allow"`, `"/var/tmp/**": "allow"`.
- **RED:** both seeders emit `"external_directory": {"**": "allow"}` — the deny assertion ("a host-repo-path read from a test home is permission-denied") fails against current behavior; the `#2579` breach demonstrates it at runtime.
- **GREEN:** edit the two heredoc blocks to the seven-rule policy; commit on the feature branch.
- **Verification instrument:** inspect the two heredoc blocks in the sources; run `bash .opencode/tests-v2/with-test-home --setup` and inspect the seeded `.config/opencode/opencode.jsonc` for the identical rule set (structural, fact-decidable).

## Item 2 — SC-2: Containment probe

- **Deliverable:** a monitored `with-test-home` probe whose recorded session evidence shows all four containment outcomes through the `read` tool: host-repo path denied; `/tmp` and `/var/tmp` marker reads returning contents; in-home external path read returning contents.
- **RED:** the same four-case probe pre-change shows host-path reads completing (the breach vector) — the deny assertion fails.
- **GREEN:** provision a fresh test home on the changed seeders, execute the five-step probe prompt (read-tool-constrained for the policy cases), monitor per tests-v2 §14 (60s poll cycle, bash-tool timeout ≥ 600000 ms), export `session.yaml`, evaluate the event stream against the four outcomes.
- **Verification instrument:** `session.yaml` event inspection (primary source per tests-v2 §2) + the run agent's report in `stdout.log` (behavioral, runtime effect through the harness).

## Item 3 — SC-3: Harness-spec documentation

- **Deliverable:** a documentation block in `tests-v2/AGENTS.md` §5 (the model-config-generation surface) stating: the seeded `external_directory` policy and its allow set (test home, `/tmp`, `/var/tmp`, plus the harness's auto-allowed tool-output directory); the deny catch-all; the known bash-command residual (path-checking is command-selective — `cat` caught, `ls`/`grep`/`head`/`sed` bypassed, observed 2026-10-11); the cross-reference that structural containment is the `.opencode#2582` layer.
- **RED:** §5 documents the seeded config's `model`/`models` fields only — no permission policy exists in the harness spec (verified against the live tree 2026-10-11).
- **GREEN:** add the documentation block to §5's Model Config Generation section.
- **Verification instrument:** section inspection for all four elements (policy, allow set, residual, cross-ref) + `./.opencode/tools/reference-integrity --scan` exit 0 on the edited file.

## Dependency order

Item 1 → Item 2 (the probe exercises the seeded policy; no probe before the flip) → Item 3 (documents the verified policy and its measured residual). No padding items; each SC yields exactly one item.

## Verification instruments summary

| Item | Instrument | Type |
|------|-----------|------|
| 1 | heredoc + seeded-config inspection | structural |
| 2 | monitored probe → session.yaml event evaluation | behavioral |
| 3 | section inspection + `reference-integrity --scan` | structural |
