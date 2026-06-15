> **Full spec and plan artifacts: `.opencode/.issues/1229/`**

## Problem

When a spec writer creates success criteria in `write.md`, the Evidence Type Classification Gate already instructs correct classification at authorship time. However, there is no post-creation step that systematically re-examines ALL SCs for missed runtime-behavioral misclassification, applies automatic uplift, provides structured remediation, and re-checks before the spec is considered complete.

## Scope

**In scope:** Add a post-SC uplift check step to `write.md` between Step 6 (self-review) and Step 6.5 (evidence artifact verification). Update `completion.md` to verify this step ran. Update `write.md` Operating Protocol checklist.

**Out of scope:** Changes to pipeline-readiness gate, VbC pre-flight classification, or BEH-EV rules in critical-rules.md or code-standards.md.

## Approach

Add a substep under `write.md` Step 6 that: (1) re-checks each SC's evidence type against the substrate BEH-EV question, (2) auto-uplifts misclassified SCs to `behavioral`, (3) provides remediation guidance for verification method updates, (4) re-checks after remediation, (5) writes findings to `.issues/{N}/post-sc-uplift-check.yaml`.

## Impact

| Risk | Mitigation |
|------|------------|
| False positives (uplifting SCs that don't need behavioral tests) | Downgrade-flag path catches → flagged-for-review, no auto-change |
| Adding more behavioral SCs increases verification burden | Intentional — per BEH-EV rule, behavioral is the only valid evidence for runtime-behavioral changes |
| Existing specs not retroactively checked | Out of scope — applies to spec creation time only |

## Key Decisions

- Positioned after Step 6, before Step 6.5
- Auto-uplift only for `structural`/`string` → `behavioral`; downgrade is always flag-for-review
- Substeps within existing Step 6, not a separate task file

## Cards (dependency order)

1. **Add post-SC uplift check substep in write.md** — New step between Step 6 and Step 6.5
2. **Update completion.md** — Verify post-SC uplift check step ran before spec completion
3. **Update write.md Operating Protocol checklist** — Add the new step to the procedure checklist

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)