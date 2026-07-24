---
number: 1277
title: "[SPEC-FIX] Verification Command Integrity — Prohibit error-suppression patterns in verification commands"
state: OPEN
---

## Problem

The verification framework in `065-verification-honesty.md` regulates *process* (did you call a tool? did you show output?) but not *sufficiency* (is the command structurally capable of proving the claim?). This allows:

1. **Suppressed verification failures**: Commands with `2>/dev/null` and `|| echo "fallback"` suppress errors. The agent runs a tool, shows output, and claims "confirmed" — while the command was designed to never report failure.

2. **Structurally insufficient source analysis**: Web-fetching partial code (GitHub single-file views) counts as "research" but cannot answer cross-file queries like "does this codebase contain a CREATE mailbox call?" — only a cloned repo + `grep` can.

3. **Silent command failure**: When a bash command fails (e.g., directory doesn't exist), `2>/dev/null` hides the error and a `|| echo "fallback"` substitutes a string the agent misinterprets as a valid result.

### Root Cause

The guidelines define verification by *evidence type* (behavioral > semantic > string > structural) and *provenance* (tool call visible, output shown), but never require that the verification command be *designed to detect failure*.

### Evidence (Live Defect)

In session `2026-06-17`, the agent ran:
```bash
rg -n "CREATE" /nonexistent/path 2>/dev/null || echo "not cloned yet"
```
The directory didn't exist. `2>/dev/null` suppressed the error. The fallback produced "not cloned yet." The agent then web-fetched partial GitHub source files (truncated single-file views covering ~75% of the codebase at most) and concluded the feature didn't exist. All three guideline gates checked:
- `065` ✅ tool call visible, output shown
- `080` ✅ string-level evidence
- `060` ✅ (no specific prohibition against the pattern)

...but the verification was structurally incapable of proving the claim.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `065-verification-honesty.md` adds a "Verification Command Integrity" section prohibiting `2>/dev/null`, `|| echo "fallback"`, and any pattern that masks stderr or substitutes fallback text for verification results | `behavioral` | Behavioral test: agent sent prompt to verify a claim about code existence; agent's bash commands must not contain `2>/dev/null` or `||` fallback patterns for verification commands |
| SC-2 | `060-tool-usage.md` adds a prohibition in §4 (Command Restrictions) against using `2>/dev/null` or `|| fallback` patterns for verification commands | `behavioral` | Behavioral test: same prompt, stderr assertions for tool dispatch |
| SC-3 | New rule requires verification commands to "fail loudly" — the agent must see the actual error when a command fails, not a sanitized fallback | `string` | `grep` for "fail loudly" phrase in 065 |
| SC-4 | New rule requires structural source analysis (clone + grep) rather than web-fetch partial views when the verification question spans multiple files | `semantic` | Sub-agent read of guideline text |
| SC-5 | The Anti-Evasion section (patterns a/b/c) gets a new pattern (d): suppressing failure signals in verification commands | `behavioral` | Behavioral test: agent presented with verification scenario that triggers the anti-evasion rule |
| SC-6 | Existing behavioral enforcement tests updated or new ones created for SC-1, SC-2, SC-5 | `behavioral` | Behavioral test execution via `with-test-home opencode-cli run` |

## Deficiencies Addressed

| # | Deficiency | Current Gap | Fix |
|---|-----------|-------------|-----|
| 1 | No rule against suppressed verification failures | `065` checks process, not command integrity | Add "Verification Command Integrity" section |
| 2 | No rule against `2>/dev/null` + fallback patterns | `060` lists specific prohibited patterns but misses this | Add to `060` §4 Command Restrictions |
| 3 | No rule requiring structural source analysis | Web-fetch partial views count as "research" | Add source-sufficiency requirement |
| 4 | No rule for "fail loud" verification design | All guidelines assume intent, not structural capability | Add fail-loud requirement |

## Affected Files

| File | Change |
|------|--------|
| `.opencode/guidelines/065-verification-honesty.md` | Add "Verification Command Integrity" section + new Anti-Evasion pattern (d) |
| `.opencode/guidelines/060-tool-usage.md` | Add `2>/dev/null` + `|| fallback` to §4 Command Restrictions |
| `.opencode/guidelines/080-code-standards.md` | Add note that evidence type hierarchy now implicitly considers command integrity (structural evidence from a structurally broken command is not valid) |
| `.opencode/tests/behaviors/` | New behavioral test(s) for SC-1, SC-2, SC-5 |

## Anti-Patterns

- Adding a blanket "don't use `2>/dev/null` ever" — the prohibition is scoped to verification commands, not all uses (cleanup, install, etc. may need it)
- Adding verbiage that rephrases existing rules without adding enforcement — every change must gate on a behavioral test
- Silently defining this as a "Tier 2" rule without enforcement — the behavioral tests ARE the enforcement

## Risk Analysis

- **False positives**: Prohibiting `2>/dev/null` for verification may make some legitimate verification commands noisier. Mitigation: the rule is scoped to verification-only, not all commands.
- **Training data conflict**: Some training examples teach `2>/dev/null` as a "good practice." The fix must be explicit enough to override training defaults.
- **Enforcement test flakiness**: Behavioral tests for "agent does NOT use a pattern" can be flaky. Use `assert_stderr_pattern_absent` with specific tool-call patterns.

---
Spec created: 2026-06-17
🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
