# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-authored, .opencode#2624 (SC-2..SC-4 pr-validation fixture helpers)

"""Shared process-fixture helpers for the 2624 ragsync hardening tests.

All helpers run real registered/command-line process trees and sample /proc —
tier pr_validation, PR-check time only.
"""

from __future__ import annotations

import json
import os
import signal
import subprocess
import time
from pathlib import Path

DECK_ROOT = Path(__file__).resolve().parents[2]
PROJECT_ROOT = DECK_ROOT.parent
REGISTRATION_PATH = DECK_ROOT / "opencode.jsonc"

REAP_DEADLINE_SECONDS = 30
STARTUP_TIMEOUT_SECONDS = 240


def _strip_jsonc_comments(text: str) -> str:
    out: list[str] = []
    in_string = False
    escaped = False
    i = 0
    n = len(text)
    while i < n:
        ch = text[i]
        if in_string:
            out.append(ch)
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                in_string = False
            i += 1
        elif ch == '"':
            in_string = True
            out.append(ch)
            i += 1
        elif ch == "/" and i + 1 < n and text[i + 1] == "/":
            while i < n and text[i] != "\n":
                i += 1
        elif ch == "/" and i + 1 < n and text[i + 1] == "*":
            i += 2
            while i + 1 < n and not (text[i] == "*" and text[i + 1] == "/"):
                i += 1
            i = min(i + 2, n)
        else:
            out.append(ch)
            i += 1
    return "".join(out)


def registered_ragsync_command() -> list[str]:
    raw = json.loads(_strip_jsonc_comments(REGISTRATION_PATH.read_text(encoding="utf-8")))
    command = raw["mcp"]["servers"]["ragsync"]["command"]
    assert isinstance(command, list) and len(command) >= 2
    return [str(a) for a in command]


def with_fixture_config(command: list[str], config_path: Path) -> list[str]:
    """Swap the registered `--config <path>` argument for the fixture path."""
    fixed = list(command)
    for i, arg in enumerate(fixed):
        if arg == "--config" and i + 1 < len(fixed):
            fixed[i + 1] = str(config_path)
            return fixed
    raise AssertionError(f"registered command does not name a --config argument: {command}")


def with_hardening_config(command: list[str], hardening_path: Path) -> list[str]:
    """Insert the wrapper's --hardening-config override after the wrapper element."""
    fixed = list(command)
    for i, arg in enumerate(fixed):
        if arg.endswith("ragsync-launch.py"):
            return [*fixed[: i + 1], "--hardening-config", str(hardening_path), *fixed[i + 1 :]]
    raise AssertionError(f"no wrapper element in command to attach hardening override: {command}")


def fixture_ragsync_config(tmp_path: Path, sources: str = "sc1") -> Path:
    corpus = tmp_path / "corpus"
    corpus.mkdir(parents=True, exist_ok=True)
    (corpus / "doc.md").write_text(
        "# Fixture corpus\n\nA single document so the fixture reindex is seconds-fast.\n",
        encoding="utf-8",
    )
    if sources != "sc1":
        raise ValueError(f"unknown fixture source set: {sources}")
    config = tmp_path / "ragsync-fixture-config.yaml"
    config.write_text(
        f"""
sources:
  - name: sc1-fixture
    type: folder
    description: 2624 fixture corpus
    connection:
      path: {corpus}
      include: ["*.md"]
    vector_store:
      collection: sc1_fixture
      persist_directory: {tmp_path / "vector_db"}
    watch:
      enabled: false
""",
        encoding="utf-8",
    )
    return config


def tree_pids(markers: tuple[str, ...]) -> list[int]:
    pids: list[int] = []
    me = Path("/proc/self").resolve().name
    for entry in Path("/proc").iterdir():
        if not entry.name.isdigit() or entry.name == me:
            continue
        try:
            cmdline = (entry / "cmdline").read_bytes()
        except OSError:
            continue
        if any(m.encode() in cmdline for m in markers):
            pids.append(int(entry.name))
    return pids


def tree_rss_bytes(pids: list[int]) -> int:
    total = 0
    for pid in pids:
        try:
            for line in Path(f"/proc/{pid}/status").read_text().splitlines():
                if line.startswith("VmRSS:"):
                    total += int(line.split()[1]) * 1024
                    break
        except (OSError, ValueError, IndexError):
            continue
    return total


def kill_pids(pids: list[int], sig: int = signal.SIGKILL) -> None:
    for pid in pids:
        try:
            os.kill(pid, sig)
        except (ProcessLookupError, PermissionError):
            pass


STUB_CLIENT = """import json, subprocess, sys
cmd = json.loads(open(sys.argv[1]).read())
raise SystemExit(subprocess.run(cmd).returncode)
"""


def spawn_fixture_tree(
    tmp_path: Path,
    config_path: Path,
    hardening_config: Path | None = None,
    command: list[str] | None = None,
) -> tuple[subprocess.Popen[bytes], Path, Path]:
    """Spawn the registered command under a stub client; returns (client, stderr_log, cmdfile)."""
    if command is None:
        command = registered_ragsync_command()
    command = with_fixture_config(command, config_path)
    if hardening_config is not None:
        command = with_hardening_config(command, hardening_config)
    cmd_dir = tmp_path / f"spawn-{config_path.parent.name}"
    cmd_dir.mkdir(parents=True, exist_ok=True)
    command_file = cmd_dir / "registered-command.json"
    command_file.write_text(json.dumps(command), encoding="utf-8")
    stderr_log = cmd_dir / "server-stderr.log"
    client = subprocess.Popen(
        ["python3", "-c", STUB_CLIENT, str(command_file)],
        cwd=PROJECT_ROOT,
        stdin=subprocess.PIPE,
        stdout=subprocess.DEVNULL,
        stderr=stderr_log.open("wb"),
    )
    return client, stderr_log, command_file


def wait_for(condition, timeout: float, poll: float = 1.0) -> bool:
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if condition():
            return True
        time.sleep(poll)
    return False


def sample_run(
    tmp_path: Path,
    config_path: Path,
    hardening_config: Path | None = None,
    settle_after_ready: float = 30.0,
    max_duration: float = 180.0,
    command: list[str] | None = None,
) -> tuple[int, bool, bool]:
    """Run the tree while sampling summed tree RSS every second.

    The run window is: spawn -> (ready marker observed on stderr OR
    STARTUP_TIMEOUT) -> settle_after_ready more seconds (bounded by
    max_duration total). Returns (peak_tree_rss_bytes, still_running_at_end,
    ready_marker_seen). Cleans up its own tree by PID.
    """
    client, stderr_log, _cmdfile = spawn_fixture_tree(
        tmp_path, config_path, hardening_config=hardening_config, command=command
    )
    try:
        marker = str(config_path)

        def started() -> bool:
            return bool(tree_pids((marker, "ragsync-launch.py")))

        assert wait_for(started, STARTUP_TIMEOUT_SECONDS), "registered tree never started"

        deadline = time.monotonic() + max_duration
        ready_seen = False
        peak = 0
        while time.monotonic() < deadline:
            pids = tree_pids((marker, "ragsync-launch.py"))
            peak = max(peak, tree_rss_bytes(pids))
            if not ready_seen:
                try:
                    text = stderr_log.read_text(errors="replace")
                except OSError:
                    text = ""
                if "ready:" in text:
                    ready_seen = True
                    deadline = min(deadline, time.monotonic() + settle_after_ready)
            if not pids:
                break
            time.sleep(1.0)
        alive = bool(tree_pids((marker, "ragsync-launch.py")))
        return peak, alive, ready_seen
    finally:
        if client.poll() is None:
            client.kill()
        kill_pids(tree_pids((str(config_path), "ragsync-launch.py")))
