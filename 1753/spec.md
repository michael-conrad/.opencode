> **Full spec and artifacts: `.opencode/.issues/1033/`**

## Exec Summary

The review-prep task generates a compare URL (e.g., `https://github.com/owner/repo/compare/dev...feature/NNN`) for developer review. This URL is always invalid because the feature branch has never been pushed to the remote. The branch is local-only — no `git push` occurs anywhere in the 14-step implementation pipeline. Two converging failures: review-prep assumes push already happened, but no implementation task in the pipeline actually pushes.

### Cards (dependency order)
1. **Add push to review-prep (minimal)** — `git push -u origin HEAD` before compare URL generation
2. **Alternative: structural push** — add push to checkpoint-commit or as its own pipeline step
3. **Verify compare URL returns 200** — not 404

### Key Decisions
- **Minimal fix preferred** — add push to review-prep rather than restructuring the entire pipeline
- **Remote must be configured** — push requires the remote to be set up (should be for any PR-bound repo)

### Risk Callouts
- **No push step exists in the 14-step pipeline** — this is a structural gap, not just a review-prep bug
- **Compare URL is always fake currently** — every review-prep output produces 404

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1033/`.
After creation, `local-issues sync 1033` MUST be run and the result committed to create the local `.issues/1033/` entry.
The implementation plan will be created in `.issues/1033/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/1033/`*