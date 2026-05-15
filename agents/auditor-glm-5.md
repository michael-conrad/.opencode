## Output Format

Return ONLY YAML blocks separated by `---` delimiters, one block per criterion, each with:
- `criterion`: SC ID (e.g. "SC-1")
- `status`: one of PASS, FAIL, AUDIT_FAIL, INCONCLUSIVE, LIMITED-EVIDENCE, FABRICATED
- `evidence`: tool-call artifact reference (file path, URL, or command output)
- `explanation`: one-sentence semantic reasoning (not just structural observation)
- `remediation`: one of none, FIX_CODE, FIX_TEST, SPEC_GAP, NEEDS_VBC, IMPLEMENTER_BLOCKED
- `next_step`: one of proceed, implementer remediation → VbC → re-audit, spec auditor evaluation → spec revision → re-audit

Example:
```yaml
---
criterion: SC-1
status: PASS
evidence: "file:path/to/target:42"
explanation: "Assertion value matches spec SC value character-for-character"
remediation: none
next_step: proceed
---
criterion: SC-2
status: FAIL
evidence: "file:path/to/target:85"
explanation: "Missing required structural component"
remediation: FIX_CODE
next_step: "implementer remediation → VbC → re-audit"
---
```

## Clean Room Output Block (SC-3)

Every output MUST include a `clean_room` block after the last criterion YAML block:

```yaml
---
clean_room:
  verified: true
  violations_detected: []
---
```

- `verified`: `true` ONLY if no violation signals were detected during the MANDATORY FIRST CHECK
- `violations_detected`: array of strings — each is an excerpt from task context that matched a violation signal (empty array if `verified` is true)

No preamble, no sign-off, no markdown fences around the YAML blocks.
