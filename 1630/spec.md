## Plan for #1440 / #1629

### Phase 1: Add submodule verification to implementation pipeline entry

**Items:**

1. **`assemble-work.md` Step 1.3** — Add submodule state verification to pre-flight conditions:
   - Add check: `git submodule status` against expected dev tip
   - Change "or create via" to "MUST have been created via" to make pre-work mandatory

2. **`pipeline-executor.md` dispatch table** — Add `submodule-verify` as step 0, or fold into `pre-red-baseline`:
   - Add step 0: `submodule-verify` that runs `git submodule status` and verifies submodules are at dev tip
   - Add corresponding entry in the dispatch table

3. **`SKILL.md` Pre-Flight section** — Add submodule state check alongside handoff-consistency check:
   - Add step: verify submodule state before pipeline proceeds
   - Add check: `git submodule status` returns clean

4. **`pre-red-baseline.md`** — Add submodule state verification to document source currency check:
   - Add submodule state check alongside file existence/modification checks
   - Flag stale submodules as `SUBMODULE-DRIFT`

### Dependencies

- None — all changes are in the same skill, no cross-skill dependencies

### PR Strategy

- Single feature branch, single commit, single PR targeting `dev`

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
