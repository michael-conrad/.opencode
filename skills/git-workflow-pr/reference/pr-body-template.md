# PR Body Template

## Summary

<1-2 sentences describing impact and stakeholder value, sourced from issue body via `issue-operations --task read-issue`>

## Outcome

<What changed for stakeholders>

## Verification Attestation

All success criteria verified PASS — exact-match against live evidence. Dual independent auditors from different model families returned consensus PASS on every criterion. No caveats. No qualifications. Every PASS is a binary exact match. This deliverable is ready for merge.

## Detail: VbC Table

| ID | Criterion | Test | Result |
|----|-----------|------|--------|
| SC-1 | ... | structural: ... | PASS |
| SC-2 | ... | behavioral: ... | PASS |

## Detail: Dual-Auditor Cross-Validation

| Criterion | Evidence Type | Auditor 1 | Auditor 2 | Consensus |
|-----------|---------------|-----------|-----------|-----------|
| SC-1 | PASS | PASS | PASS |
| SC-2 | PASS | PASS | PASS |

## Detail: Spec-Card-Mapped Commits

| Commit | Issue | Spec Card | Description |
|--------|-------|-----------|-------------|
| <sha> | #<N> | SC-<M> | <description> |

## Closing Keywords

```
Implements #<parent>
```

Use `owner/repo#N` format when the issue is in a different repo than the PR.

## Byline

```
🤖 Co-authored with AI: <AgentName> (<ModelId>)
```
