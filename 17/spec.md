## Problem

The `dispatch-table.yaml` file was deleted in `b299f53` (issue #210), which also removed the `extractFrontmatter()`, `loadSkillDescriptions()`, `buildFrontmatterWarning()`, and `buildEnforcementContent()` functions from `session-enforcement.ts`. Skill discovery is now driven by SKILL.md frontmatter `Triggers on:` lines, not by plugin injection.

However, 24+ stale references to the deleted file and its mechanics remain across the codebase, creating confusion about how skill invocation actually works:

1. **Deleted file referenced** — `.opencode/dispatch-table.yaml` is still listed in `README.md` directory tree and `fragment-manager/SKILL.md` cross-references
2. **Stale invocation language** — 6 references in `docs/audits/phase0-audit-data.md` say skills are "auto-invoked by dispatch-table.yaml" (they aren't — skills are triggered by frontmatter patterns)
3. **Confusing plugin comment** — `session-enforcement.ts` line 5 still says "enforces skill invocation rules" when it no longer does anything with skills
4. **Cross-reference to non-existent file** — `fragment-manager/SKILL.md` references `.opencode/dispatch-table.yaml` as a related file
5. **Audit data claims dead mechanism** — Phase0 audit data describes the old dispatch-table.yaml mechanism as if it's still active

These stale references cause two concrete problems:
- **Agent confusion**: An LLM reading "auto-invoked by dispatch-table.yaml" will look for a file that doesn't exist, wasting context and producing incorrect reasoning
- **Maintenance confusion**: Developers seeing references to dispatch-table.yaml may believe it needs to be created or maintained

## Scope Classification

**Clearly simple work** — documentation and reference cleanup only. No behavioral changes, no code modifications beyond comments and cross-references. Tier 2 waiver applies (developer authorization IS sufficient process).

## Success Criteria

- [ ] SC-1: `README.md` directory tree no longer lists `dispatch-table.yaml`
- [ ] SC-2: `fragment-manager/SKILL.md` cross-references list no longer includes `dispatch-table.yaml`
- [ ] SC-3: `session-enforcement.ts` comment accurately reflects current functionality (session context + enforcement, not skill invocation)
- [ ] SC-4: `docs/audits/phase0-audit-data.md` references to "auto-invoked by dispatch-table.yaml" are updated to reflect SKILL.md frontmatter self-discovery
- [ ] SC-5: All files referencing `dispatch-table.yaml` or `dispatch-table` as a file path are updated or have references removed
- [ ] SC-6: No grep match for `dispatch-table.yaml` as a file path reference anywhere under `.opencode/`
- [ ] SC-7: `skildeck` dispatcher comment at line 7 of `.opencode/tools/skildeck` description remains accurate (no changes needed — it's correct)

## Fix Approach

**Root cause**: The dispatch-table.yaml deletion in #210 removed the file and the plugin code that read it, but did not clean up references in documentation, cross-references, and audit data.

**Approach**: Mechanical reference cleanup. Every stale reference is either:
1. Removed (cross-reference to deleted file)
2. Replaced with the correct current mechanism (SKILL.md frontmatter `Triggers on:` self-discovery)
3. Corrected to reflect current functionality (session-enforcement.ts comment)

**No behavioral changes. No code logic changes. No new files. No skill/guideline content changes beyond cross-references and comments.**

### Files to Modify

1. **`.opencode/README.md` line 36** — Remove `dispatch-table.yaml` entry from directory tree

2. **`.opencode/skills/fragment-manager/SKILL.md` line 163** — Remove `.opencode/dispatch-table.yaml` from related files list

3. **`.opencode/plugins/session-enforcement.ts` lines 4-6** — Update comment from "enforces skill invocation rules" to accurate description: "Injects session context into the LLM system prompt and enforces runtime guards (git config mutation watchdog, --no-verify detection, protected branch edit warnings, secret redaction). Also detects bare issue references (#N) and injects mandatory audit pipelines."

4. **`.opencode/docs/audits/phase0-audit-data.md` lines 207, 1189, 1309, 3405, 3957, 4159** — Replace "auto-invoked by dispatch-table.yaml when" with "triggered by SKILL.md frontmatter `Triggers on:` patterns when"

### Files NOT Modified (correct as-is)

- **`.opencode/skills/approval-gate/enforcement/auto-dispatch-table.md`** — This file exists and is current. It documents the approval-gate dispatch chain, not the deleted `dispatch-table.yaml`. References to this file are correct.
- **All `approval-gate/tasks/*.md` references to `enforcement/auto-dispatch-table.md`** — These point to the existing auto-dispatch-table.md, not the deleted dispatch-table.yaml. Correct as-is.
- **`.opencode/tools/skildeck`** — Correct as-is; no changes needed.

### Verification

After changes:
```bash
# Verify no stale dispatch-table.yaml file path references remain
grep -r "dispatch-table\.yaml" .opencode/ --include="*.md" --include="*.ts" --include="*.yaml" --include="*.json"
# Expected: 0 matches (the deleted file no longer exists and no references remain)

# Verify session-enforcement.ts comment is accurate
grep "enforces skill invocation" .opencode/plugins/session-enforcement.ts
# Expected: 0 matches (stale comment removed)

# Verify README.md no longer lists dispatch-table.yaml
grep "dispatch-table" .opencode/README.md
# Expected: 0 matches
```

🤖 OpenCode (ollama-cloud/glm-5) ✅ completed
