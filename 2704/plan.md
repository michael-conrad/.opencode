# Plan — .opencode#2704

Spec: `.opencode/.issues/2704/spec.md` (triage-converted governing spec).
Branch: `feature/2704-stale-issue-review-enforcement`.

## Item 1 — Remove retired-family enforcement entries (SC-1 → R-1)

- **Deliverable:** `tests-v2/test-enforcement.sh` carries zero `issue-review`-family references.
- **RED:** `grep -n "symptom-patch" tests-v2/test-enforcement.sh` currently returns the `SCENARIOS["symptom-patch"]` registration and the `SCENARIO_TAGS["symptom-patch"]` entry; `grep -n "issue-review" tests-v2/test-enforcement.sh` returns those plus `FILE_SCENARIO_MAP[".opencode/skills/issue-review/"]`.
- **GREEN:** delete the three lines/entries by content (line numbers as filed — 89, 116, 143 — are stale; re-locate by content).
- **Instrument:** `grep -n "issue-review" .opencode/tests-v2/test-enforcement.sh` and `grep -n "symptom-patch" .opencode/tests-v2/test-enforcement.sh` each return zero hits.

## Item 2 — Remove orphan legacy fixtures (SC-2 → R-2)

- **Deliverable:** the legacy analyze-and-spec fixtures are absent.
- **RED:** `tests-v2/behaviors/fixtures/setup/2241-sc7-analyze-and-spec-local-first.sh` and `tests-v2/behaviors/fixtures/issues/2249/` exist; `grep -rn "analyze-and-spec" tests-v2/` returns hits.
- **GREEN:** delete the fixture file and the `fixtures/issues/2249/` directory; remove any remaining harness reference to them found by the RED grep.
- **Instrument:** `grep -rn "analyze-and-spec" .opencode/tests-v2/` and `grep -rn "2241-sc7-analyze-and-spec\|fixtures/issues/2249" .opencode/tests-v2/` each return zero hits; both paths no longer exist.

## Item 3 — Harness integrity verification (SC-3 → R-3)

- **Deliverable:** the enforcement harness still functions with the removals applied.
- **GREEN (no code change):** run the integrity instruments on the post-removal tree.
- **Instrument:** executed `bash .opencode/tests-v2/test-enforcement.sh --list` and `--list-tags` (map/array integrity, captured output); executed `2707-sc1` through the behavioral harness (`bash .opencode/tests-v2/with-test-home opencode run`, per the `behavioral-testing` card), passing.

Dependency order: Item 1 → Item 2 (independent deletions, either order) → Item 3 (depends on both). Every item traces to a spec SC; no untraceable items.
