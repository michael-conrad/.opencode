#!/usr/bin/env python3
# v2rows.py — OpenCode V2 session-store adapter (.opencode#2717)
#
# OpenCode V2 (>= 2.2) moved the session record: the V1 `event` table is
# empty and all message content lives in `session_v2` + `session_message`
# (rich per-message JSON with content[] parts). The harness's consumers —
# session.yaml doc readers, the live poller, the export writer — all speak
# the V1 event shape (`message.part.updated.1` rows with `part` objects,
# `session.created.1` rows, `message.updated.1` rows with `info`).
#
# This module is the SINGLE adapter definition: it reads a V2 store and
# yields the V1-shaped stream the consumers already parse. V1 stores (the
# `event` table populated) are passed through unchanged, so the harness
# works under both runtimes.
#
# Exposed functions:
#   event_rows(db)          -> [(seq, {"type","data",...}), ...] V1-shaped rows
#   part_rows(db)           -> [{"data","time_created","time_updated"}, ...]
#   last_assistant_infos(db) -> [info dicts, newest first]
#
# Consumed by helpers.sh (export + digest/monitor + resume-tail reads),
# poll-run.sh (live polls), and the exporter (session.yaml writer).

import json
import sqlite3


def _v2(conn):
    """True when the store carries the V2 schema (non-empty session_v2)."""
    try:
        n = conn.execute("SELECT count(*) FROM session_v2").fetchone()[0]
    except sqlite3.Error:
        return False
    return n > 0


def _part_from_item(item, sid):
    """Normalize one V2 assistant content item into the V1 part shape."""
    if not isinstance(item, dict):
        return None
    t = item.get("type", "")
    part = {"type": t, "time": item.get("time", {})}
    if t == "tool":
        part["tool"] = item.get("tool") or item.get("name", "?")
        part["id"] = item.get("id", "")
        part["callID"] = part["id"]
        part["executed"] = item.get("executed", False)
        state = dict(item.get("state") or {})
        part["state"] = state
    elif t in ("text", "reasoning"):
        part["text"] = item.get("text", "")
    part["sessionID"] = sid
    return part


def event_rows(db):
    """V1-shaped ordered rows: (seq, type, id, aggregate_id, data_json)."""
    conn = sqlite3.connect(db)
    try:
        if not _v2(conn):
            out = conn.execute(
                "SELECT seq, type, id, aggregate_id, data FROM event ORDER BY seq"
            ).fetchall()
            return out

        rows = []
        seq = 0

        for (sid, t_created) in conn.execute(
            "SELECT id, time_created FROM session_v2 ORDER BY time_created"
        ):
            seq += 1
            rows.append((seq, "session.created.1", "ev-s-%d" % seq, sid,
                         json.dumps({"sessionID": sid, "timeCreated": t_created})))

        msgs = conn.execute(
            "SELECT id, session_id, type, seq, time_created, data"
            " FROM session_message ORDER BY time_created, seq"
        ).fetchall()

        for (mid, sid, mtype, mseq, t_created, data) in msgs:
            try:
                d = json.loads(data or "{}")
            except json.JSONDecodeError:
                d = {}
            parts = []
            if mtype == "assistant":
                for item in d.get("content", []):
                    p = _part_from_item(item, sid)
                    if p is not None:
                        parts.append(p)
                info = {"id": mid, "role": "assistant", "finish": d.get("finish", "")}
            elif mtype == "user":
                parts.append({"type": "text", "text": d.get("text", ""),
                              "files": d.get("files", []), "sessionID": sid})
                info = {"id": mid, "role": "user"}
            elif mtype == "system":
                parts.append({"type": "text", "text": d.get("text", ""),
                              "metadata": d.get("metadata", {}), "sessionID": sid,
                              "synthetic": True})
                info = {"id": mid, "role": "system"}
            else:
                info = {"id": mid, "role": mtype, "data": d}

            for p in parts:
                seq += 1
                rows.append((seq, "message.part.updated.1", "ev-p-%d" % seq, sid,
                             json.dumps({"sessionID": sid, "info": info, "part": p})))
            seq += 1
            rows.append((seq, "message.updated.1", "ev-m-%d" % seq, sid,
                         json.dumps({"info": info})))
        return rows
    finally:
        conn.close()


def part_rows(db):
    """Per-part rows shaped for the timeline tool:
    [{"id","session_id","time_created","time_updated","data"} ...]."""
    out = []
    for (seq, type_, id_, agg, data) in event_rows(db):
        if type_ != "message.part.updated.1":
            continue
        d = json.loads(data)
        p = d.get("part", {})
        t = p.get("time") or {}
        out.append({
            "id": id_ and ("p%s" % seq) or None,
            "session_id": d.get("sessionID") or agg,
            "time_created": t.get("created", 0),
            "time_updated": t.get("completed", t.get("created", 0)),
            "data": json.dumps(p),
        })
    return out


def last_assistant_infos(db, limit=12):
    """Newest-first assistant info dicts: [{"role","finish"}, ...]."""
    conn = sqlite3.connect(db)
    try:
        if not _v2(conn):
            infos = []
            for (data,) in conn.execute(
                "SELECT data FROM event WHERE type='message.updated.1'"
                " ORDER BY id DESC LIMIT %d" % limit
            ):
                try:
                    info = (json.loads(data) or {}).get("info", {})
                except json.JSONDecodeError:
                    continue
                if info.get("role") == "assistant":
                    infos.append(info)
            return infos
        infos = []
        for (mtype, data) in conn.execute(
            "SELECT type, data FROM session_message WHERE type='assistant'"
            " ORDER BY seq DESC LIMIT %d" % limit
        ):
            try:
                d = json.loads(data or "{}")
            except json.JSONDecodeError:
                continue
            infos.append({"role": "assistant", "finish": d.get("finish", "")})
        return infos
    finally:
        conn.close()
