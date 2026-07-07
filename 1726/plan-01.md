# Phase 1 — Remove yaml+symbolic blocks

- **Concern:** Delete trailing `yaml+symbolic` code fence blocks from 30 guideline files
- **Files:** `.opencode/guidelines/000-critical-rules.md`, `.opencode/guidelines/010-approval-gate.md`, `.opencode/guidelines/015-pre-spec-inspection.md`, `.opencode/guidelines/016-srclight-preference.md`, `.opencode/guidelines/020-go-prohibitions.md`, `.opencode/guidelines/045-open-questions.md`, `.opencode/guidelines/050-scope-autonomy.md`, `.opencode/guidelines/060-tool-usage.md`, `.opencode/guidelines/065-verification-honesty.md`, `.opencode/guidelines/067-context-completeness.md`, `.opencode/guidelines/070-environment.md`, `.opencode/guidelines/075-docs-verification.md`, `.opencode/guidelines/080-code-standards.md`, `.opencode/guidelines/085-project-local-tools.md`, `.opencode/guidelines/086-http-requests.md`, `.opencode/guidelines/087-no-backward-compat.md`, `.opencode/guidelines/090-data-integrity.md`, `.opencode/guidelines/091-incremental-build.md`, `.opencode/guidelines/100-persistence.md`, `.opencode/guidelines/115-branch-naming.md`, `.opencode/guidelines/116-pair-mode.md`, `.opencode/guidelines/117-session-trigger-behavior.md`, `.opencode/guidelines/130-authority-source.md`, `.opencode/guidelines/140-planning-spec-creation.md`, `.opencode/guidelines/141-planning-status-tracking.md`, `.opencode/guidelines/142-planning-archive-workflow.md`, `.opencode/guidelines/143-planning-spec-templates.md`, `.opencode/guidelines/144-planning-spec-examples.md`, `.opencode/guidelines/200-errors.md`, `.opencode/guidelines/210-scripting.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4
- **Dependencies:** None
- **Entry:** Plan approved, feature branch exists
- **Exit:** All 30 files have their `yaml+symbolic` blocks removed

## Step-by-Step

- [ ] 1. (**sub-agent**) Remove `yaml+symbolic` block from `000-critical-rules.md` — locate ```` ```yaml+symbolic ```` fence and delete through closing ```` ``` ````. Verify prose above the block is untouched.
- [ ] 2. (**sub-agent**) Remove `yaml+symbolic` block from `010-approval-gate.md`
- [ ] 3. (**sub-agent**) Remove `yaml+symbolic` block from `015-pre-spec-inspection.md`
- [ ] 4. (**sub-agent**) Remove `yaml+symbolic` block from `016-srclight-preference.md`
- [ ] 5. (**sub-agent**) Remove `yaml+symbolic` block from `020-go-prohibitions.md`
- [ ] 6. (**sub-agent**) Remove `yaml+symbolic` block from `045-open-questions.md`
- [ ] 7. (**sub-agent**) Remove `yaml+symbolic` block from `050-scope-autonomy.md`
- [ ] 8. (**sub-agent**) Remove `yaml+symbolic` block from `060-tool-usage.md`
- [ ] 9. (**sub-agent**) Remove `yaml+symbolic` block from `065-verification-honesty.md`
- [ ] 10. (**sub-agent**) Remove `yaml+symbolic` block from `067-context-completeness.md`
- [ ] 11. (**sub-agent**) Remove `yaml+symbolic` block from `070-environment.md`
- [ ] 12. (**sub-agent**) Remove `yaml+symbolic` block from `075-docs-verification.md`
- [ ] 13. (**sub-agent**) Remove `yaml+symbolic` block from `080-code-standards.md`
- [ ] 14. (**sub-agent**) Remove `yaml+symbolic` block from `085-project-local-tools.md`
- [ ] 15. (**sub-agent**) Remove `yaml+symbolic` block from `086-http-requests.md`
- [ ] 16. (**sub-agent**) Remove `yaml+symbolic` block from `087-no-backward-compat.md`
- [ ] 17. (**sub-agent**) Remove `yaml+symbolic` block from `090-data-integrity.md`
- [ ] 18. (**sub-agent**) Remove `yaml+symbolic` block from `091-incremental-build.md`
- [ ] 19. (**sub-agent**) Remove `yaml+symbolic` block from `100-persistence.md`
- [ ] 20. (**sub-agent**) Remove `yaml+symbolic` block from `115-branch-naming.md`
- [ ] 21. (**sub-agent**) Remove `yaml+symbolic` block from `116-pair-mode.md`
- [ ] 22. (**sub-agent**) Remove `yaml+symbolic` block from `117-session-trigger-behavior.md`
- [ ] 23. (**sub-agent**) Remove `yaml+symbolic` block from `130-authority-source.md`
- [ ] 24. (**sub-agent**) Remove `yaml+symbolic` block from `140-planning-spec-creation.md`
- [ ] 25. (**sub-agent**) Remove `yaml+symbolic` block from `141-planning-status-tracking.md`
- [ ] 26. (**sub-agent**) Remove `yaml+symbolic` block from `142-planning-archive-workflow.md`
- [ ] 27. (**sub-agent**) Remove `yaml+symbolic` block from `143-planning-spec-templates.md`
- [ ] 28. (**sub-agent**) Remove `yaml+symbolic` block from `144-planning-spec-examples.md`
- [ ] 29. (**sub-agent**) Remove `yaml+symbolic` block from `200-errors.md`
- [ ] 30. (**sub-agent**) Remove `yaml+symbolic` block from `210-scripting.md`

## Phase Completion

- [ ] Verify: `grep -r 'yaml+symbolic' .opencode/guidelines/` returns 0 matches (all blocks removed)
- [ ] Commit all 30 file changes to feature branch
- [ ] Transition to Phase 2
