> **Full spec and artifacts: [`.opencode/.issues/582/`](https://github.com/michael-conrad/.opencode/tree/issues-data/582)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/582/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Why

When an agent directly parses or writes structured data for consumption by another agent, it must default to YAML, not JSON — JSON is error-prone in prompts (brace/quote escaping) and benchmarks ~11–18pp worse for LLM comprehension of nested data. The 2026-05 audit found the pre-replacement deck instructing JSON contract formats throughout (task-card templates, prose JSON-output instructions, "structured JSON verdict" language). The deck reorganization to single-file skill cards absorbed that file migration wholesale — the live deck now contains exactly one ```json fence (CLI-output documentation, excluded) and zero JSON-contract language — but it also left the codified rule homeless: the YAML Standard survives only in the preserved attic copy, and nothing live tells an agent to default to YAML in agent-to-agent structured exchanges.

## Final what

1. **Live-deck conformance verified** — fenced scan, prose-instruction scan, and JSON-verdict scan over live LLM-consumed content confirm zero JSON contract templates outside the excluded categories (chat prose, tool I/O, CLI output, config examples, `--json` flags, fixtures, vendor cards, `attic/`, `.issues/` stores). Any block the sweep finds migrates to YAML with field-for-field semantic equivalence.
2. **`(YAML)` token convention in force** — a bare `(YAML)` token, directly associated with every skill-card and detail-card reference to a structured output an agent creates for another agent or a structured input it ingests from another agent. The token's definition (universe, default, exceptions, prose boundary) lives in the skill cards that govern agent-to-agent exchanges — the cards already in context when structured data crosses an agent boundary. Strictly card-text adjustments: no scripts, no lint rules, no new tests, no tooling; the pointer surfaces (`floor.md`, `routing.md`, `AGENTS.md`, `prompts/default.txt`) gain no rule text.
3. **Verification** — `bash .opencode/tests-v2/test-enforcement.sh` zero failures; targeted behavioral runs only where card text changed (whole-suite behavioral enumeration prohibited per #2433); boundary and pointer-surface read-checks; the `verify` card's single fresh-context reviewer pass over all SCs; binary PASS/FAIL only. Anti-lobotomization SCs are non-waivable.

Former interdependencies #1208, #1222, and #936 are closed/superseded by #2433; no live dependency remains.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
