> **Full spec and artifacts: [`.issues/1356/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1356)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1356/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Exec Summary

Invert the hard-fail gate from FAIL-is-blocker to DONE-is-only-pass. The current gate treats anything not FAIL as PASS — BLOCKED, DONE_WITH_CONCERNS, and unknown statuses all pass through. This creates a bypass where orchestrators rationalize BLOCKED as "false negative" and proceed without remediation.

### Cards (dependency order)
1. **Gate inversion in `000-critical-rules.md`** — Change the symbolic rule condition from `gate_result == 'FAIL'` to `gate_result != 'DONE' OR concerns != empty`
2. **DONE-with-concerns coercion rule** — Add bright-line rule: DONE with non-empty concerns is coerced to FAIL
3. **Orchestrator routing table update** — Update `pipeline-executor.md` Remediation Routing trigger
4. **Secondary enforcement file updates** — Update `065-verification-honesty.md` and `020-go-prohibitions.md`
5. **Behavioral enforcement tests** — RED/GREEN behavioral tests verifying agent remediates BLOCKED and coerces DONE_WITH_CONCERNS

### Key Decisions
- **Gate inversion is bright-line**: `gate_result != 'DONE' OR concerns != empty → FAIL`. No gray zone.
- **DONE_WITH_CONCERNS preserved in status enum but coerced at gate**: Backward compatible with sub-agent contracts while closing the coercion gap.
- **Behavioral tests use `assert_semantic`**: The coercion decision is an agent action, not a text pattern.

### Risk Callouts
- **Orchestrator rationalizes BLOCKED as "false negative"**: Mitigated by behavioral enforcement test (SC-7) verifying remediation action.
- **DONE_WITH_CONCERNS silently degrades**: Mitigated by behavioral enforcement test (SC-8) verifying coercion to FAIL.
- **Future unknown status enums**: Gate inversion is future-proof — unknown statuses are coerced to FAIL by default.

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1356/`.
After creation, `local-issues sync 1356` MUST be run and the result committed to create the local `.opencode/.issues/1356/` entry.
The implementation plan will be created in `.opencode/.issues/1356/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.
