# resolve-models — Resolve Cross-Family Auditor Pairs

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Resolve two auditor models from different model families for adversarial cross-validation.

## Invocation

Execute the resolve-models tool:

```bash
bash .opencode/tools/resolve-models
```

The `MODEL_ID` environment variable is set automatically by the session context. No additional arguments are required for standard use.

### Re-Task (When Prior Audit Pair Failed)

If a prior audit iteration produced a failed/unusable result and the orchestrator needs a fresh pair while optionally excluding the previous pair:

```bash
bash .opencode/tools/resolve-models --re-task --excluded-pair <family_1> <family_2>
```

Replace `<family_1>` and `<family_2>` with the family names from the previous iteration's output.

## Output Format

### Success (exit code 0)

```yaml
auditor_1: "auditor-<family>-<variant>"
auditor_2: "auditor-<family>-<variant>"
family_1: "<family>"
family_2: "<family>"
```

### Insufficient Families (exit code 1)

```yaml
error: "INSUFFICIENT_FAMILIES"
reason: "<explanation>"
eligible_count: <number>
```

## Usage

1. Execute `bash .opencode/tools/resolve-models`
2. Parse the YAML output
3. If exit code is 0: dispatch `auditor_1` and `auditor_2` as the two cross-family auditors
4. If exit code is 1 (INSUFFICIENT_FAMILIES): halt the audit pipeline — this is a non-recoverable error per adversarial-audit-017

## Mandatory Rules

- This task is the ONLY authorized entry point for auditor resolution
- Agents MUST NOT read, reason about, or inline model family composition from any source other than this task's YAML output
- Agents MUST NOT hardcode auditor types, inline model names, or substitute cached family mappings
- The orchestrator MUST invoke this task on EVERY audit iteration — initial, re-audit, and all subsequent re-audits
- Historical auditor selections from any prior iteration MUST NOT be cached, reused, or considered — every invocation starts fresh

Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)