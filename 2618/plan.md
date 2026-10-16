<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2618 -->

# Implementation Plan — .opencode#2618 Deprecation Encounter Protocol

Derives entirely from `spec.md` §5 (Items 1–6). No plan-only deliverables.
Authorization: `approved for pr: .opencode#2618` (2026-10-16 session).

- Branch: `feature/2618-deprecation-encounter-protocol`
- Base tip: `e86299ef8501818678153262db33eb0751cf785e` (submodule main = origin/main, verified 2026-10-16)
- Baseline: `skildeck lint` exit 0; `reference-integrity --scan` exit 0 (62 files)

## Items (SC-mapped, RED → GREEN → verify → commit each)

1. **SC-1** — Author `guidelines/deprecation-encounter-protocol.md` stating the full protocol (R-1..R-7, R-13). RED: file absent. Verify: static text check per requirement.
2. **SC-2** — Inline domain slices + Read-link to the canonical doc in the seven cards (implement, programming-principles, research, systematic-debugging, spec, plan, work), per R-8 per-card guidance. RED: slice/link absent. Verify: static text check per card.
3. **SC-3** — `reference-integrity --scan` exits 0.
4. **SC-4** — `git diff <base> -- floor.md routing.md` empty; all hunks additive-only.
5. **SC-5** — `skildeck lint` exits 0.
6. **SC-6** — Behavioral pickup: tests-v2 clean-room `opencode run` via `with-test-home`; stderr evidence of directive registration; single pickup scenario. Governed by the `behavioral-testing` card.

DAG: 1 → 2 → (3, 4, 5, 6 independent).

## Gate

All six SCs pass → fresh-context `verify` PASS → PR per `git-workflow-pr` (one PR, one squashed commit, body closes `.opencode#2618`).
