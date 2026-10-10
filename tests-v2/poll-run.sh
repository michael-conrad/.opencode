#!/bin/bash
# poll-run.sh — supervision poll for an active behavioral run (card §9).
# Reads the active run's session DB (SQLite export), prints a digest of what
# the run agent is doing, and ENDS WITH THE REMINDER BLOCK: the orchestrator's
# NEXT TURN MUST BE a text-only in-chat update (semantic analysis of this
# poll's evidence) before any further tool call (#2561: silent 30-minute
# blocking runs are a supervision defect).
#
# Usage: poll-run.sh <path-to-session.yaml> [poll_number]
#   The DB path is the active run's test-home session export — pin it to the
#   run you are supervising (env-passed path, never newest-by-mtime).

set -euo pipefail
DB="${1:?usage: poll-run.sh <session.yaml> [poll_number]}"
POLL="${2:-?}"

python3 - "$DB" "${2:-?}" <<'PYEOF'
import json, sqlite3, sys, time

db_path, poll = sys.argv[1], sys.argv[2]
con = sqlite3.connect(db_path)
cur = con.cursor()
# Live session DB (tests-v2 AGENTS.md §14): the event table's
# message.part.updated events carry the parts — tool calls, text,
# reasoning. Extract from the documented event stream.
tool_calls, texts, reasoning_chars = [], [], 0
for (typ, data) in cur.execute("select type, data from event order by id"):
    if not typ.startswith("message.part.updated"):
        continue
    p = (json.loads(data) or {}).get("part") or {}
    t = p.get("type")
    if t == "tool":
        st = p.get("state") or {}
        tool_calls.append(f"{p.get('tool','?')} [{st.get('status','?')}] {str(st.get('title',''))[:70]}")
    elif t == "text" and (p.get("text") or "").strip():
        texts.append(p["text"].strip())
    elif t == "reasoning":
        reasoning_chars += len(p.get("text") or "")
print(f"POLL {poll} ts={int(time.time())} tools={len(tool_calls)} reasoning_chars={reasoning_chars}")
print(f"latest_tool_call: {tool_calls[-1] if tool_calls else 'none-yet'}")
print("recent_tool_calls (oldest→newest):")
for t in tool_calls[-8:]:
    print(f"  - {t}")
if texts:
    print("latest_agent_text (excerpt):")
    print("  " + texts[-1].replace("\n", "\n  ")[:600])
PYEOF

cat <<'REMINDER'

=== ORCHESTRATOR REMINDER (card §9, .opencode#2561) ===
This poll's evidence now requires YOUR semantic analysis — the next turn
MUST be a text-only in-chat update with NO tool call, stating:
  1. what the run agent is doing right now (from its actual words/work),
  2. what it intends next,
  3. whether that serves the scenario's declared goal condition,
  4. which hard-abort signals (tests-v2 AGENTS.md §14) have fired, if any.
Deliver the update in chat text. Only after that update may polling continue.
Chaining another tool call before the update turn is the supervision defect.
=========================================================
REMINDER
