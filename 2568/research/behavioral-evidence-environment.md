# Behavioral-evidence environment analysis — .opencode#2568 (2026-10-09)

Findings from implementing the plan's behavioral items under the tests-v2
harness. Structure: what each behavioral SC can and cannot evidence pre-merge,
with the mechanism verification that closes the gap.

## Harness environment constraint (root cause)

`with-test-home` seeds a minimal global config (`seed_model_config` — model +
models only; the production global config is never copied because it carries
secrets). The gmail MCP server (`mcp-email-server`) is defined ONLY in the
developer's global config (`~/.config/opencode/opencode.jsonc`), not in the
deck config. Therefore no harness session ever has a gmail MCP server, and
injecting one — via fixtures or otherwise — is a forbidden isolation bypass
(observed regression #2538: "a fixture was authored to inject an MCP entry
into the seeded test config... ruled a bypass of the isolation the harness
exists to enforce"). The harness's remote-API provision (§12) is GitBucket
only; there is no mail-server container.

## Per-SC evidence status

### SC-3 — PASS (clean-room verdict recorded)

Fully producible in-harness. Artifact directory:
`tmp/behavioral-evidence-2568-sc3-email-intent-dispatch-GREEN-qwen3.8-27b-256k-gguf4/`
— `session.yaml` (143 events exported), `sufficiency-judgment.md` (poll log +
early-exit judgment), `evaluation-1791603526.yaml` (clean-room verdict, PASS,
test_type live DB). The main agent, given "Check my gmail inbox for unread
messages and tell me what needs my attention.", loaded `email-management` and
issued a `task` dispatch with `subagent_type: "email-ops"` (part
`prt_123dd2e6f001nip89bTnbzCxeu`, main session
`ses_edc25ade2ffesKjtA4PqXwe3nY`), spawning child session
`ses_edc22d189ffevqlCGtKJnT3O79` with `agent="email-ops"`.

### SC-1 — mechanism source-verified; harness evidence vacuous; production confirmation post-merge

Source verification (opencode repo, packages/opencode/src):
- `permission/index.ts` — `evaluate()` matches the tool NAME against the
  rule's permission key via `Wildcard.match(permission, rule.permission)`;
  `fromConfig()` turns the flat string `"gmail_*": "deny"` into
  `{permission: "gmail_*", action: "deny", pattern: "*"}`.
- `permission/index.ts` — `disabled()` hides a tool when the last matching
  rule has `pattern === "*"` and `action === "deny"`;
  `visibleTools()` filters on it.
- `session/llm/request.ts` — `resolveTools()` calls `Permission.disabled()`
  over `merge(input.agent.permission, input.permission)` and filters the
  toolset BEFORE the provider request — denied tools' schemas are never sent
  to the model (this is what removes the ~2.5K tokens).
- `agent/agent.ts` — agent rulesets are built as
  `[defaults, user-config rules, agent-frontmatter rules]` (line ~267 + ~293),
  so the email-ops frontmatter `"gmail_*": "allow"` is the last matching rule
  for that agent and wins over the deck-config deny via `findLast`.
- `session/tools.ts` — MCP tool execution asks with
  `permission: key` where key is the full tool name
  (`McpCatalog.toolName(server, tool)` → `gmail_list_mailboxes`), so the
  `gmail_*` allow matches at execution time with no prompt.

Caveat: the source read is the repo's current default branch; the installed
binary is 1.18.32 — minor drift risk. The production post-merge observation
closes it.

Harness evidence for SC-1's literal criterion (no `gmail_*` tools in a fresh
main-agent session) is **vacuous in isolation**: the gmail MCP does not exist
in the test env at all, so absence is attributable to the missing server, not
the deny rule — the deny rule matches nothing there. The run's session.yaml
does record the main agent making no gmail tool calls and dispatching instead,
but that proves routing, not toolset filtering.

Definitive production confirmation (post-merge): a fresh main-agent session in
this project under the merged deck shows no `gmail_*` tools in the toolset.

### SC-2 — not producible in-harness; production post-merge

The criterion needs a session WITH the gmail MCP present where the email-ops
allow rule overrides the deck deny. The isolated env cannot contain the gmail
MCP (injection forbidden, no mail container). Structural half (allow entry
present in the card) is SC-5-verified. Behavioral half (tools available, no
ask stall) requires a production environment with the gmail MCP — i.e.
post-merge, next time email work is dispatched in a live session.

### SC-7 — production post-merge measurement

The baseline is a production-database measurement
(`~/.local/share/opencode/opencode.db`); the harness env lacks both the gmail
MCP (whose schema removal IS the measured delta) and the baseline model
profile (DEFAULT_TEST_MODEL is `ollama/qwen3.8:27b-256k-gguf4`; R-20 forbids
substitution without direction).

Documented query protocol (reproduced 2026-10-09 against the live db):

```sql
-- first assistant message per main-agent (parentless) session,
-- per-model median of tokens.input (message JSON field)
WITH firsts AS (
  SELECT json_extract(m.data,'$.tokens.input') AS tin,
         json_extract(m.data,'$.providerID') || '/' || json_extract(m.data,'$.modelID') AS model,
         row_number() OVER (PARTITION BY m.session_id ORDER BY m.time_created ASC, m.id ASC) AS rn
  FROM message m JOIN session s ON s.id = m.session_id
  WHERE json_extract(m.data,'$.role') = 'assistant'
    AND s.parent_id IS NULL
    AND s.time_created >= strftime('%s','2026-03-01') * 1000
)
SELECT model, tin FROM firsts WHERE rn = 1 AND tin > 0;
```

Baseline measured 2026-10-09: `huggingface/zai-org/GLM-5.3-Flash` n=115,
median **21,946** (the spec's ~22.0K). Threshold: post-change fresh
minimal-prompt main-agent session on the same model must measure
**≤ 20,446** (≥ 1,500 below baseline). Note: `sqlite3` CLI here lacks
`json_extract`; use Python's sqlite3 module.

## Deck defect observed by the SC-3 run (R-18 class, out of criterion scope)

The dispatched email-ops subagent, finding no gmail tools in the isolated
environment, loaded `email-management`, followed its `tb` install-on-need
pathway, and launched a live internet download of thunderbird-cli — instead of
reporting gmail-tool unavailability per the email-ops card's own reporting
rule ("If the dispatched task needs something the Gmail tools cannot do, say
so explicitly rather than approximating with another tool").

Root cause (card wording): the email-ops card binds gmail tools as its
mechanism but does not explicitly forbid falling back to other mail pathways
when they are absent; the email-management card body's setup-on-need install
path is reachable and actionable inside an email-ops dispatch. A remediation
line in the email-ops card (unavailable gmail tools are reported, never
worked around via other mail pathways inside a dispatch) would close it — a
governed deck edit requiring its own authorization decision.

## Run-infrastructure incidents (resolved, recorded per §10.1)

- Attempt 1: `HARNESS_FAILURE: lock contention` — orphaned GitBucket process
  (PID 4004898, PPID 1, ~5h18m old) from a prior session's remote-API run
  held the `flock` descriptor at `tmp/.behavior-run.lock`. Killed the orphan;
  removed the stale lock.
- Attempt 2 launcher: killed by the supervising bash tool's 30s timeout
  (process-group kill). Remediation: `setsid` full detachment for the run
  that produced the evidence.
