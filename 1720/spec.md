## Phase 1 of #1672 — Eliminate Cross-Model Infrastructure

**Depends on:** None
**SCs:** SC-1, SC-2, SC-3, SC-12

### Steps
1. Delete `.opencode/agents/auditor-deepseek-flash.md`
2. Delete `.opencode/agents/auditor-gemma4.md`
3. Delete `.opencode/agents/auditor-mistral-large.md`
4. Delete `.opencode/agents/auditor-qwen3.5.md`
5. Delete `.opencode/tools/resolve-models`
6. Delete `.opencode/tests/qualification/qualified-auditor-pool.sh`
7. Remove `INSUFFICIENT_FAMILIES` references from any remaining code
8. Verify all deletions (SC-1, SC-2, SC-3, SC-12)

### Verification
- SC-1: File existence check — 0 auditor card files remain
- SC-2: `resolve-models` tool absent
- SC-3: `qualified-auditor-pool.sh` absent
- SC-12: Zero occurrences of `INSUFFICIENT_FAMILIES` in codebase

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)