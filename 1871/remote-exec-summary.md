> **Full spec and artifacts: [`.opencode/.issues/1871/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1871/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1871/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Exec Summary

Remove a dead body-revision check (Step 1.5b) from the `issue-operations/tasks/comment.md` task file that creates a routing trap. The classification table says "Revising/correcting spec → internal (triggers Phase 3 body update)" but the procedural gate only fires for stakeholder-classified content — the body update never executes. The correct architecture already exists: `spec-creation --task change-control` for spec revisions and `writing-plans --task update` for plan revisions. Add a routing gate to redirect spec/plan corrections to the correct pipeline.

### Cards (dependency order)
1. **Remove Step 1.5b** — delete the dead body-revision check from `comment.md`
2. **Remove dead annotation** — delete "(triggers Phase 3 body update)" from the classification table
3. **Add routing gate** — redirect spec corrections to `spec-creation --task change-control` and plan corrections to `writing-plans --task update`
4. **Behavioral enforcement test** — verify agent routes spec corrections to spec-creation, not comment

### Key Decisions
- **Remove, don't fix**: The body-revision path is architecturally wrong — the comment task should only post comments. Fixing the dead gate would add complexity to the wrong component.
- **Route, don't duplicate**: Spec/plan revision pipelines already exist. The comment task should redirect to them, not reimplement them.

### Risk Callouts
- **Risk A**: Agents that currently dispatch to `issue-operations --task comment` for spec corrections will need to learn the new routing gate. Mitigation: behavioral test verifies the routing behavior.
- **Risk B**: The routing gate must be clear enough that agents don't try to handle corrections inline. Mitigation: explicit dispatch strings in the gate prose.

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1871/`.
After creation, `local-issues sync 1871` MUST be run and the result committed to create the local `.opencode/.issues/1871/` entry.
The implementation plan will be created in `.opencode/.issues/1871/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
