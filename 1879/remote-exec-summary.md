> **Full spec and artifacts: [`.opencode/.issues/1879/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1879/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1879/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Exec Summary

Agents skip behavioral success criteria during implementation with rationalizations like "skipped due to real-domain prompt constraint." The rules exist, the pipeline gates exist, and the behavioral test infrastructure exists — but agents still skip SCs because "skipped" is not explicitly named in the SC lobotomy prohibition, no structural gate counts SCs vs verified SCs, and no behavioral test verifies agents don't skip SCs. This spec adds a four-pronged fix: explicit "skipped" prohibition, behavioral enforcement test, structural SC-count gate, and holistic-self-check coverage.

### Cards (dependency order)
1. **Add "skipped" to SC lobotomy prohibition** — Extend `critical-rules-sc-lobotomy` in `000-critical-rules.md` to explicitly name "skipped" as a CRITICAL VIOLATION alongside removal, weakening, deferral, and reclassification.
2. **Mirror prohibition in code standards** — Add "skipped" to the Test Integrity Mandate §Rule 1 in `080-code-standards.md`.
3. **Add SC-count gate to pipeline** — Add a structural gate in `implementation-pipeline/SKILL.md` that reads `sc-summary.yaml` total, counts verified SCs, and BLOCKs on mismatch.
4. **Add behavioral enforcement test** — Create `tests/behaviors/1879-sc-skip-prohibition.sh` that verifies agents do NOT skip behavioral SCs and report BLOCKED when unable to implement.
5. **Extend holistic-self-check** — Add "skipped" to the escape-hatch dimension in `holistic-self-check.md`.

### Key Decisions
- **DEC-1**: "skipped" is classified as a distinct evasion pattern from "deferred" and "removed" — it requires its own explicit prohibition text.
- **DEC-2**: The SC-count gate fires at the pre-completion gate (before VbC), not at PR creation — catching the skip at the earliest possible pipeline stage minimizes defect-discovery-latency.
- **DEC-3**: The behavioral test uses a real-domain prompt (not prose-recall) per `tests/AGENTS.md` §9 Prompt Construction Mandate.

### Risk Callouts
- **RISK-1**: Behavioral test is probabilistic — mitigated by `behavior_run_pool` with multiple models and clean-room semantic inspector evaluation.
- **RISK-2**: SC-count gate may produce false BLOCKED if `sc-summary.yaml` is stale — mitigated by reading at execution time, not from cache.
- **RISK-3**: Agent may rationalize "skipped" as "deferred to follow-up issue" — mitigated by explicitly listing "will be handled separately" as a prohibited pattern.

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1879/`.
After creation, `local-issues sync` MUST be run and the result committed to create the local `.opencode/.issues/1879/` entry.
The implementation plan will be created in `.opencode/.issues/1879/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

## Related

- [opencode-config#1877](https://github.com/michael-conrad/opencode-config/issues/1877) — The issue where SC-4 was skipped
- [opencode-config#1873](https://github.com/michael-conrad/opencode-config/issues/1873) — Previous defective implementation
- [opencode-config#1878](https://github.com/michael-conrad/opencode-config/issues/1878) — PR rejected with "skipped SC => trash => rejected"

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
