# Lessons Learned

Each subdirectory captures a session (or cross-session theme) where systematic defects were observed in AI agent behavior. These are for clean-room agent review and remediation — not for human consumption.

## Structure

```
lessons-learned/
  session-YYYY-MM-DD/
    README.md              — Session summary and correction catalog
    plan-media.yaml        — Tamer/UPA problem files used (if any)
    plans.yaml             — Plans generated (if any)
    artifacts/             — Evidence artifacts (stderr logs, tool outputs)
```

## Purpose

A clean-room agent reads `session-YYYY-MM-DD/README.md` and determines:
1. Which corrections are one-off context issues vs. systemic skill/guideline gaps
2. What bug-fix issues and skill/guideline PRs to produce
3. Whether new behavioral enforcement tests are needed

## Guidelines for Session Artifacts

- Every session lesson file MUST include a "Root Cause" column — was this a training-data gap, a skill/guideline omission, a tooling API issue, or operator error?
- Every systemic lesson MUST include a proposed remediation target (specific skill, guideline, or tool file)
- One-off context issues should be noted but DO NOT get remediation issues — they are session-specific noise