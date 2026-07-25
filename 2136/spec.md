---
remote_issue: 2136
remote_url: https://github.com/michael-conrad/.opencode/issues/2136
labels: []
---

## Summary

Refactor `.opencode/guidelines/000-critical-rules.md` by moving 123 skill-specific rules to 30 target files, keeping 18 universal rules.

## Changes

- **Phase 1**: Embed 123 moved rules into 30 target files with per-rule change reports
- **Phase 2**: Delete intro cross-references and replace/remove Read[] cross-refs to preloaded guidelines
- **Phase 3**: Remove 123 moved rule blocks from 000-critical-rules.md (now 18 headers)
- **Phase 4**: Remove Why This Matters tables, restore Channel-Routing Table heading

## Verification

All 10 SCs verified PASS:
- SC-1: No intro cross-refs (0 matches)
- SC-2: No preloaded guideline cross-refs (0 matches)
- SC-3: All 123 rules embedded in target files (123/123 confirmed)
- SC-4: Dark prose count < 3 (0 matches)
- SC-5: Why This Matters tables absent (0 matches)
- SC-6: Mandate Tiering, Interaction Rule, Channel-Routing Table preserved
- SC-7: All 18 universal rule headers present
- SC-8: No title-restating paragraphs (token-superset diff clean)
- SC-9: No duplicate headers (0 duplicates)
- SC-10: Exactly 18 rule headers

Closes #2121

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
