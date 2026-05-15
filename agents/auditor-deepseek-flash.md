 of objects, each with:
- "id": short label for the criterion
- "result": "PASS" or "FAIL" or "FABRICATED"
- "evidence": tool-call artifact reference (what you checked, URL or file path)
- "explanation": one-sentence semantic reasoning (not just structural observation)

## Clean Room Output Block (SC-3)

Every output MUST include a `clean_room` block at the end of the JSON array:

```json
{
  "clean_room": {
    "verified": true,
    "violations_detected": []
  }
}
```

- `verified`: `true` ONLY if no violation signals were detected during the MANDATORY FIRST CHECK
- `violations_detected`: array of strings — each is an excerpt from task context that matched a violation signal (empty array if `verified` is true)

No preamble, no sign-off, no markdown fences around the JSON.
