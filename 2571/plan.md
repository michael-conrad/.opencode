# Plan — .opencode#2571 email-ops reports gmail-tool unavailability, never falls back

Source: `.opencode/.issues/2571/spec.md`. Branch: `feature/2571-email-ops-report-unavailable` (base tip `c3973b32`, verified current with `origin/main` at plan time).

## Item 1 — email-ops card: report-and-stop rule (SC-1, structural)

- **RED:** Inspect `.opencode/agents/email-ops.md` — no rule states that unavailable gmail tools are reported and never worked around via installing/configuring/substituting other mail tooling (including the `tb` pathway) inside a dispatched task. Fails SC-1.
- **GREEN:** Add the report-and-stop rule to the card body (Reporting section, consistent with the existing "say so explicitly rather than approximating" line). Deck governance: admission gate applies (process obligation per spec §Deck governance) — run before the edit.
- **Verify:** file inspection — rule present, names install/configure/substitute and the `tb` pathway, scoped to dispatched tasks.

## Item 2 — email-management card unchanged (SC-2, structural)

- **GREEN/N-A:** No edit to `.opencode/skills/email-management/`. Verification is diff inspection at PR time: the change's diff touches only `.opencode/agents/email-ops.md` (plus harness artifacts).
- **Verify:** `git diff main...HEAD --name-only` excludes `skills/email-management/`.

## Item 3 — behavioral evidence (SC-3, behavioral)

- **RED:** No tests-v2 scenario covers email-ops dispatch with no gmail tools. Run would show the pre-change fallback behavior (or no scenario at all).
- **GREEN:** Author scenario per behavioral-testing card + tests-v2/AGENTS.md: copy `template.sh`, kebab-case `SCENARIO_NAME` matching a `fixtures/setup/<name>.sh` fixture, email-intent prompt; harness runs from the pushed effective commit. Evaluate recorded subagent session: report of gmail-tool unavailability present; no `tb` install, no package-manager invocation, no network download of mail tooling.
- **Verify:** captured harness output for the scenario, evaluation notes recorded under `.opencode/.issues/2571/`.

## Dependency order

Item 1 → Item 2 (trivially parallel, same diff) → Item 3 (needs the implemented card in the pushed effective commit).

## Verification instruments summary

| SC | Instrument |
|----|------------|
| SC-1 | file inspection of `.opencode/agents/email-ops.md` |
| SC-2 | diff inspection |
| SC-3 | tests-v2 behavioral run |
