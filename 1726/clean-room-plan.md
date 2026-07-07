# Clean-Room Plan — Remove yaml+symbolic Blocks

Generated from spec body only, no prior plan context.

## Goal

Remove all `yaml+symbolic` code fence blocks from 30 guideline files in `.opencode/guidelines/`.

## Files

`.opencode/guidelines/000-critical-rules.md`, `010-approval-gate.md`, `015-pre-spec-inspection.md`, `016-srclight-preference.md`, `020-go-prohibitions.md`, `045-open-questions.md`, `050-scope-autonomy.md`, `060-tool-usage.md`, `065-verification-honesty.md`, `067-context-completeness.md`, `070-environment.md`, `075-docs-verification.md`, `080-code-standards.md`, `085-project-local-tools.md`, `086-http-requests.md`, `087-no-backward-compat.md`, `090-data-integrity.md`, `091-incremental-build.md`, `100-persistence.md`, `115-branch-naming.md`, `116-pair-mode.md`, `117-session-trigger-behavior.md`, `130-authority-source.md`, `140-planning-spec-creation.md`, `141-planning-status-tracking.md`, `142-planning-archive-workflow.md`, `143-planning-spec-templates.md`, `144-planning-spec-examples.md`, `200-errors.md`, `210-scripting.md`

## Phases

### Phase 1: Remove Blocks
For each of 30 files, locate the ` ```yaml+symbolic` fence and delete everything from that line through the closing ` ``` ` fence. Verify no prose content removed.

### Phase 2: Verify
Run `grep -r 'yaml+symbolic' guidelines/` — must return zero. Spot-check 5 files to confirm frontmatter and prose intact.

## SCs

- SC-1: No `yaml+symbolic` blocks remain (grep returns zero)
- SC-2: All 30 files have trailing YAML block removed
- SC-3: Prose content unchanged
- SC-4: Frontmatter preserved
