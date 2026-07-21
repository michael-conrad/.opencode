# Phase 3: Add Clean-Room Validation to 4 DiMo role files

**SCs:** SC-6
**Files:**
- `.opencode/skills/audit/tasks/verification-audit-investigator.md`
- `.opencode/skills/audit/tasks/verification-audit-validator.md`
- `.opencode/skills/audit/tasks/verification-audit-evaluator.md`
- `.opencode/skills/audit/tasks/verification-audit-arbiter.md`

## Steps

### 3.1-3.4 Add Clean-Room Validation section
To each of the 4 files, add after Frugal Contract:

```
## Clean-Room Validation

This task requires independence from orchestrator bias. The sub-agent MUST:

1. **Reject preloaded context** — return `PRELOADED_CONTEXT_REJECTED` if the orchestrator includes inline reasoning, expected outcomes, file paths, or step sequences
2. **Discover scope independently** — read source files, run analysis tools, and determine the scope without orchestrator hints
3. **Produce evidence independently** — write full evidence artifacts to disk before returning
4. **Render binary judgment** — PASS (100% clean, no caveats) or FAIL (any caveat, any concern, any non-100% clean pass)
```

## Exit Criteria
- [ ] `verification-audit-investigator.md` has Clean-Room Validation section
- [ ] `verification-audit-validator.md` has Clean-Room Validation section
- [ ] `verification-audit-evaluator.md` has Clean-Room Validation section
- [ ] `verification-audit-arbiter.md` has Clean-Room Validation section
