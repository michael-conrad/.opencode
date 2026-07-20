## Bug

The symbolic rule condition `"verification_sub_agent_dispatched_with_file_list == true"` in critical-rules-044 is overbroad. It treats verification sub-agents (which need file lists as operational context to do their job) the same as execution sub-agents (where preloading file paths is harmful). This would incorrectly HALT legitimate VbC dispatch.

## Fix

Remove the `verification_sub_agent_dispatched_with_file_list == true` condition from critical-rules-044's symbolic rule conditions array in `guidelines/000-critical-rules.md`. The prose section already correctly scopes to "execution" — only the symbolic condition needs removal.

## Affected file

`.opencode/guidelines/000-critical-rules.md`

## Related issues

- #274 (closed, not_planned)
- #292 (PR that added the overbroad condition)

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)