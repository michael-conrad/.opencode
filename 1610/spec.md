Raise SC-LINT-004 300-char limit to 1024-char in the guideline file.

**Parent plan:** [#1602](https://github.com/michael-conrad/.opencode/issues/1602)
**SC:** SC-2
**Files:** `.opencode/guidelines/` (SC-LINT-004 rule)
**Dependencies:** Phase 0
**Exit:** `grep 'max_length: 1024'` matches, `grep 'max_length: 300'` matches zero
**Note:** Must complete before Phase 2 (farmage descriptions exceed 300-char limit)

🤖 OpenCode (deepseek-v4-flash) created