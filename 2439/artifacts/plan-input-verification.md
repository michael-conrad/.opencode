# Plan Input Verification Ledger — .opencode#2439

## Issue State
- Issue: .opencode#2439 — "[SPEC] Shallow temp-copy build/test gate for release verification"
- Status: open
- Labels (local issue.yaml, canonical): `approved-for-for_pr`
- authorization_scope: for_pr; pr_strategy: stacked
- github_url: https://github.com/michael-conrad/.opencode/issues/2439

## Success Criteria (with evidence types — all behavioral)
- SC-1: Shallow temp-copy checkout of root repo at release commit — behavioral
- SC-2: Submodules at gitlink-pinned SHAs via `git submodule update --init --depth 1`; never `--remote`/`--recursive` — behavioral
- SC-3: Resolved submodule SHA == pinned SHA; hard fail on drift — behavioral
- SC-4: Build/test commands discovered from repo AGENTS.md (root first, .opencode/AGENTS.md fallback); hard fail if undiscoverable — behavioral
- SC-5: Execute discovered build+test; zero failures required; non-zero exit = FAIL, blocks promotion — behavioral
- SC-6: Gate runs once per release; any FAIL blocks promotion — behavioral

## Structure Artifact Mappings
- Phase 1 "Shallow temp-copy checkout at release release commit" — SC-1 — files: tasks/operating-protocol.md, SKILL.md
- Phase 2 "Submodule pin resolution + drift assertion" — SC-2, SC-3 — files: tasks/operating-protocol.md
- Phase 3 "Build manifest discovery + build/test execution gate" — SC-4, SC-5 — files: tasks/operating-protocol.md
- Phase 4 "Once-per-release gate placement + promotion blocking" — SC-6 — files: tasks/operating-protocol.md, SKILL.md
- DAG: 1 → 2 → 3 → 4 (linear); triplet_colocation PASS; cross_phase_dependencies PASS
- Dispatch per item: red → test-driven-development; green → test-driven-development; verify → verification-before-completion; commit → orchestrator commit-inline (direct)

## CLI Surface
- Label write: `./.opencode/tools/local-issues update .opencode#2439 --labels <full comma-separated array>` (replaces entire labels array — must include `approved-for-for_pr`)
- Pre-check: run `local-issues update --help` once before first label write to confirm flag syntax

## Affected Files (verified_exists via blast-radius artifact)
- .opencode/skills/release-promoter/SKILL.md
- .opencode/skills/release-promoter/tasks/operating-protocol.md
- .opencode/skills/release-promoter/tasks/tag.md (gate placement context)
- AGENTS.md / .opencode/AGENTS.md — read-only build-manifest dependency (root lacks build section; fallback is canonical)

## Key Findings Carried Forward
- Root AGENTS.md has no build/test section; discovery must fall back to .opencode/AGENTS.md "Build / Lint / Test Commands"
- Gate states: PENDING, CHECKOUT_OK, DRIFT_FAIL, MANIFEST_FAIL, BUILD_FAIL, PASS; any FAIL blocks promotion; no retries per release run
- Blast radius: LOW-MEDIUM; all changes confined to release-promoter skill deck (.opencode submodule)
