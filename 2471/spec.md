## Observed behavior

Both spec issues created via the spec-creation pipeline on 2026-09-29 (Brothertown-Language/snea-shoebox-editor #36 and #1385) carry a body trailer that documents the approval mechanism **inside the spec body itself**:

```
> **Approval Tracking**: Approvals are tracked via GitHub Issue comments (e.g., `AI: Approved`), NOT in the issue body. Issue body edits destroy history.
```

This is stale on its face (approvals are tracked via `approved-for-*` labels; developer directive 2026-09-28: "approvals are NOT tracked by github issue comments. NOTHING is tracked by github comments"), and — per the developer's bug-classification directive — **the line is a defect of category, not just freshness: whether an approval mechanism exists and where it lives is a deck concern (approval-gate skill + platform labels), not a spec concern.** A spec body must contain zero indicators of the approval mechanism. The same reasoning that bans STATUS fields from specs bans approval-mechanism notes: specs define what is required, not how the pipeline tracks process state.

Neither the body footer mandate (issue-operations-core/tasks/creation.md Step 3: byline footer only), nor the exec-summary body format (creation.md Step 5: Blockquote/Problem/Scope/Approach/Impact - 5 sections), nor spec-creation/tasks/create.md (Step 4 template) states this trailer. The line is not sourced from any grep-locatable template literal in the deck (`rg "Approval Tracking|AI: Approved" .opencode/` returns no matches in task cards — so the emitting source is either a template embedded elsewhere in the issue-operations/local platform creation path (`.opencode/skills/issue-operations/platforms/local/tasks/creation.md` or push-artifacts/comment paths) or sub-agent-remembered convention triggered by the body-assembly step). Location unresolved by search = at least one deck gap: if a literal exists, it is stale; if no literal exists, the deck under-specifies the body footer and allows sub-agents to invent approval-mechanism content.

Repair records for the two spec issues (already applied by orchestrator 2026-09-29):
- GitHub #36 + #1385 bodies: `Approval Tracking` line deleted entirely (0 remaining, verified by live body reads)
- Local `.issues/1385/body-1385.md`: line deleted; `.issues/36/` has no body copy carrying the line
- Audit evidence mirror at `tmp/issue-36/spec-mirror/spec-36.md` retains the original line — historical record of audited-at-state, intentionally preserved

## Expected behavior

Spec issue bodies contain no approval-mechanism language whatsoever. The deck normatively states: approval state lives in `approved-for-*` labels (local `issue.yaml` canonical), and body templates carry only: Spec Reference Blockquote, Problem, (spec body sections), Impact, byline footer. A body-template rule "no process/tracking indicators in the body" would prevent recurrence.

## Steps to reproduce

1. Run spec-creation create for any issue (observed on #36/#1385 via issue-review → brainstorming → spec-creation chain 2026-09-28/29).
2. Read the created remote issue body footer.
3. Observe the `Approval Tracking` blockquote above the byline.

## Component affected

Body-assembly path in the issue-creation chain: `.opencode/skills/spec-creation/tasks/create.md` (remote-body write) and `.opencode/skills/issue-operations-core/tasks/creation.md` Step 5 (exec-summary body format) — whichever carries or fails-to-carry the footer literal. Note this run predates the #2464 blockquote-path fix (same chain).

## Discovered during

Spec creation for Brothertown-Language/snea-shoebox-editor #36 (db/embed revision) + #1385 (semantic search UI follow-up), 2026-09-29. Developer flagged after body review: "approvals are NOT tracked by github issue comments / NOTHING is tracked by github comments" → "this is a bug in the deck and needs a bug report."

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
