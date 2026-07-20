## Phase 5 of #1672 — Behavioral Tests

**Depends on:** Phase 1, 2, 3, 4
**SCs:** SC-13, SC-14

### Steps
1. Write behavioral enforcement test for SC-13 (DiMo role chain dispatch)
   - Send audit prompt via `opencode-cli run`
   - Verify stderr shows role-differentiated dispatch, not `resolve-models`
2. Write behavioral enforcement test for SC-14 (single-model-family resilience)
   - Run in environment with 1 model family
   - Verify audit completes without `INSUFFICIENT_FAMILIES` error
3. Run both tests RED (before implementation changes)
4. Run both tests GREEN (after all phases implemented)

### Verification
- SC-13: `opencode-cli run` with audit prompt → stderr shows role-differentiated dispatch
- SC-14: `opencode-cli run` in 1-model-family environment → no `INSUFFICIENT_FAMILIES`

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)