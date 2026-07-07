# Scope Parsing Module

## Verb-Prefix Parsing Table

Authorization phrases carry implicit scope — the pipeline stage the developer expects work to reach. Parse authorization text for scope qualifiers:

| Phrase Pattern | Scope | HALT After | Gap-Fill | PR Strategy |
|----------------|-------|------------|----------|-------------|
| `"approved #N"` (no qualifier) | for_review_prep | review-prep | None | none |
| `"approved #N for spec"` or `"#N approved for spec"` | for_spec | spec_created | None | none |
| `"approved #N for analysis"` or `"#N approved for analysis"` | for_analysis | analysis_complete | auto-create spec | none |
| `"approved #N for plan"` or `"#N approved for plan"` | for_plan | plan_created | auto-create spec | none |
| `"approved #N for implementation"` or `"#N approved for implementation"` | for_implementation | verification_complete | auto-create spec+plan, auto-approve | none |
| `"approved #N to PR"` or `"#N approved to PR"` | for_pr | pr_created | auto-create spec+plan, auto-approve, auto-PR | stacked |
| `"approved for next phase"` or `"approved #N for next phase"` | for_next_phase | next_phase_complete | auto-approve next phase | none |
| `"approved for phase N"` or `"approved #N for phase N"` | for_phase_N | phase_N_complete | auto-approve up to phase N | none |

## "Next Phase" Resolution

When scope resolves to `for_next_phase`, the agent MUST:

1. **Read `{project_root}/tmp/{N}/work.md`** to identify current phase tracking state
2. **Identify completed phases** by checking sub-issue state (`get_sub_issues`) and verifying merged PRs for each
3. **Resolve to the next sequential uncompleted phase number**
4. **Set `halt_at`** to `phase_N_complete` where N is the resolved next phase
5. **Set gap-fill** to `auto-approve` for that specific phase only

Phase resolution does not parse STATUS markers or plan bodies. The `{project_root}/tmp/{N}/work.md` file (populated during pre-work and updated by each pipeline step) is the canonical source for current phase state. Resolution logic:

```python
# Read {project_root}/tmp/{N}/work.md for current phase tracking
# Expected format:
#   current_phase: <phase_number>
#   current_concern: <concern_name>
#   current_step: <step_label>
# If file missing → default to first concern, first step
```

### "Approved for Phase N" Resolution

When scope resolves to `for_phase_N`:

```python
def resolve_phase_n(phase_number, total_phases):
    """
    Resolve 'approved for phase N' to halt_at and gap-fill values.
    """
    is_final = (phase_number == total_phases)

    return {
        "resolved_scope": "for_phase_N",
        "halt_at": f"phase_{phase_number}_complete",
        "phase_number": phase_number,
        "gap_fill": f"auto-approve up to phase {phase_number}",
        "is_final_phase": is_final,
        "pr_strategy": "none" if not is_final else "none",
    }
```

| Phase Context | halt_at | Gap-Fill | PR Strategy |
|---------------|---------|----------|-------------|
| Phase N is intermediate | `phase_N_complete` | Auto-approve phases 1 through N | none |
| Phase N is final | `review_prep` (standard completion) | Auto-approve all phases | none |

**⚠️ CRITICAL: `for_next_phase` and `for_phase_N` scopes do NOT cascade to subsequent phases.** Authorization for "next phase" covers exactly that one phase. Authorization for "phase 2" covers phases 1–2 only. Subsequent phases require separate authorization.

## Scope Derivation Rules

1. **No qualifier in authorization message = `for_review_prep`**: `"approved #1200"` → `for_review_prep` scope, review-prep halt, no gap-fill
2. **Non-authorization message (no "approved"/"go") = `for_analysis`**: Default floor scope when user asks a question, reports a bug, or makes a factual claim without authorization language. Self-assigned by agent.
3. **Qualifier present = parse**: Match phrase against table above; ambiguous phrases default to for_review_prep
3. **Multiple issues**: `"approved #1200 #1201 #1197 for implementation"` → `for_implementation` scope applies to all listed issues
4. **Phase qualifier**: `"approved: Phase 1 only"` → single-phase authorization for the named phase only, then HALT
5. **"Next phase" resolution**: `"approved #N for next phase"` → read `{project_root}/tmp/{N}/work.md` for current phase, identify completed phases (via merged PRs), set halt_at to the next sequential uncompleted phase
6. **"Phase N" resolution**: `"approved #N for phase N"` → resolve via `resolve_phase_n()` which sets halt_at based on whether the phase is intermediate or final

## PR Strategy Map

| Scope | PR Strategy |
|-------|-------------|
| for_review_prep | none |
| for_spec | none |
| for_analysis | none |
| for_plan | none |
| for_implementation | none |
| for_pr | stacked |
| for_next_phase | none |
| for_phase_N | none |