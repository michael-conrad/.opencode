## Phase 2 of #1672 — Create DiMo Role-Differentiated Auditor Card

**Depends on:** Phase 1
**SCs:** SC-4

### Steps
1. Create `.opencode/agents/auditor-role.md` with all 4 DiMo roles:
   - Generator: Produces initial answer/verdict
   - Evaluator: Assesses correctness, identifies gaps
   - Knowledge Supporter: Retrieves and validates evidence
   - Path Provider: Constructs reasoning chains
2. Define both interaction protocols: Divergent mode and Logical mode
3. Define Judger role for cross-validate integration
4. Verify file exists (SC-4)

### Verification
- SC-4: `auditor-role.md` exists at `.opencode/agents/`

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)