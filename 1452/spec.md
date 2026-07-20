## Bug: Clean-Room Plan Generator Overwrites the Plan Being Audited

### Problem

In the `writing-plans` 21-step pipeline, Step 11 (Clean-room plan generation) dispatches the **wrong task**. Both `create.md` and `SKILL.md` call `"execute write task from writing-plans"` for clean-room generation — the same task as Step 10 (Write). The `write` task writes to `.issues/{N}/plan.md`, so the clean-room plan **overwrites** the actual plan that Step 10 just wrote.

The plan-fidelity auditor in Step 17 then compares the clean-room plan against... the clean-room plan that overwrote it. The comparison trivially passes because both sides are identical. The original plan is destroyed.

### Root Cause

| File | Line | Current (Buggy) | Correct |
|------|------|-----------------|---------|
| `writing-plans/tasks/create.md` | 70 | `"execute write task from writing-plans"` | `"execute clean-room task from writing-plans"` |
| `writing-plans/SKILL.md` | 77 | `"execute write task from writing-plans"` | `"execute clean-room task from writing-plans"` |

The `clean-room.md` task file already exists and is designed for exactly this purpose. Its exit criteria state: *"No issue created (clean-room plans are comparison artifacts, not tracked in GitHub)"* — it returns the plan as in-memory markdown, never writing to `.issues/{N}/plan.md`.

### Fix

Two one-line changes — replace the dispatch string in both files:

1. **`writing-plans/tasks/create.md` line 70**: Change `"execute write task from writing-plans"` to `"execute clean-room task from writing-plans"`
2. **`writing-plans/SKILL.md` line 77**: Same change

### Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Step 11 dispatches `clean-room` task, not `write` task | `string` — grep for dispatch string in both files |
| SC-2 | Clean-room plan does not write to `.issues/{N}/plan.md` | `behavioral` — run pipeline, verify plan file is not overwritten |
| SC-3 | Plan-fidelity audit compares against independently generated clean-room plan | `behavioral` — run pipeline, verify audit compares two distinct plans |

### Affected Files

- `.opencode/skills/writing-plans/tasks/create.md` (line 70)
- `.opencode/skills/writing-plans/SKILL.md` (line 77)

## Interdependencies

### Prerequisite for: #1660 (clean-room plan completeness)

| Aspect | Detail |
|--------|--------|
| **Relationship** | `prerequisite-for` |
| **Issue** | #1660 — Clean-room plan generation must produce complete plan, not minimal |
| **Why** | #1660's Component A updates the Step 11 prompt. But the prompt currently dispatches `write` task, which overwrites the plan. This issue (#1452) must fix the dispatch target to `clean-room` task first. Then #1660's prompt update is applied to the corrected dispatch string. |
| **Direction** | #1452 → #1660 (this issue is implemented first, #1660 follows) |
| **Conflict risk** | If #1660 is implemented first, its prompt update would be applied to the wrong dispatch target (`write` instead of `clean-room`), requiring rework. |

### Cross-Cutting: #1374 (Plan Format Requirements) — same file, different section

| Aspect | Detail |
|--------|--------|
| **Relationship** | `cross-cutting` |
| **Issue** | #1374 — writing-plans create.md Plan Format Requirements hardcodes step sequence |
| **Why** | Both #1452 and #1374 modify `create.md`. #1452 modifies Step 11's dispatch string. #1374 rewrites the `## Plan Format Requirements` section (different section). No semantic conflict. |
| **Ordering** | Independent — can be implemented in any order |

### Independent: #1666, #1415

| Aspect | Detail |
|--------|--------|
| **Relationship** | `independent` |
| **Issues** | #1666 (SC-to-plan coverage gate), #1415 (verify-already-implemented gate) |
| **Why** | Different skills, different files, different concerns. No shared files with #1452. |

## Cross-References

- #1660 — **[FOLLOWS]** Clean-room plan completeness fix (depends on this issue being implemented first)
- #1374 — **[CROSS-CUTTING]** Plan Format Requirements hardcodes step sequence (same file, different section)
- #1413 — Introduced Step 11 (clean-room plan generation) into the pipeline

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)