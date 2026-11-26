# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-authored, .opencode#2624 (SC-8 pr-validation retrieval-preserved fixture)

"""SC-8 pr-validation fixture: retrieval preserved under the hardened path.

Tier: pr_validation (runs real processes; PR-check time only).

The TRUE registered command shape (wrapper chain, NO hardening overrides —
the in-repo `.opencode/ragsync-hardening.yaml` defaults apply) is launched
with only its `--config` argument substituted for a workspace fixture config
with two designated sources and seeded content. A real MCP stdio client
connects inside the documented connect envelope, calls `list_sources` (must
return exactly the fixture's two sources) and `search` (must return at least
one hit). This is the silent-regression guard: any hardening defect that
kills retrieval fails here.
"""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

import pytest

from tests.test_ragsync_launch.ragsync_fixture import (
    PROJECT_ROOT,
    kill_pids,
    registered_ragsync_command,
    tree_pids,
    with_fixture_config,
)

CONNECT_ENVELOPE = 300


def _fixture_config_with_two_sources(tmp_path: Path) -> Path:
    base = tmp_path / "corpus-a"
    extra = tmp_path / "corpus-b"
    for d in (base, extra):
        d.mkdir(parents=True, exist_ok=True)
    (base / "alpha.md").write_text(
        "# Alpha source\n\nThe quaternion of the zephyr anchors the sc8 retrieval fixture.\n",
        encoding="utf-8",
    )
    (extra / "beta.md").write_text(
        "# Beta source\n\nA second designated corpus for the list_sources exactness check.\n",
        encoding="utf-8",
    )
    config = tmp_path / "ragsync-sc8-config.yaml"
    config.write_text(
        f"""
sources:
  - name: sc8-alpha
    type: folder
    description: SC-8 fixture corpus alpha
    connection:
      path: {base}
      include: ["*.md"]
    vector_store:
      collection: sc8_alpha
      persist_directory: {tmp_path / "vdb-a"}
    watch:
      enabled: false
  - name: sc8-beta
    type: folder
    description: SC-8 fixture corpus beta
    connection:
      path: {extra}
      include: ["*.md"]
    vector_store:
      collection: sc8_beta
      persist_directory: {tmp_path / "vdb-b"}
    watch:
      enabled: false
""",
        encoding="utf-8",
    )
    return config


@pytest.mark.pr_validation
def test_hardened_path_preserves_retrieval(tmp_path: Path) -> None:
    config_path = _fixture_config_with_two_sources(tmp_path)
    command = with_fixture_config(registered_ragsync_command(), config_path)
    cmd_dir = tmp_path / "spawn"
    cmd_dir.mkdir()
    cmdfile = cmd_dir / "command.json"
    cmdfile.write_text(json.dumps(command), encoding="utf-8")

    marker = ("ragsync-launch.py", str(config_path))
    stderr_log = cmd_dir / "server-stderr.log"
    result_file = cmd_dir / "mcp-stub-result"
    stub = subprocess.Popen(
        [
            "uv",
            "run",
            "--script",
            "--with",
            "mcp<2",
            ".opencode/tests/test_ragsync_launch/mcp_stub_client.py",
            str(cmdfile),
            "0",
            "zephyr quaternion",
        ],
        cwd=PROJECT_ROOT,
        stdout=open(result_file, "wb"),
        stderr=stderr_log.open("wb"),
        stdin=subprocess.DEVNULL,
    )
    try:
        try:
            stub.wait(timeout=CONNECT_ENVELOPE)
        except subprocess.TimeoutExpired:
            stub.kill()
            pytest.fail(f"MCP invocation exceeded the {CONNECT_ENVELOPE}s connect envelope")
        assert stub.returncode == 0, (
            f"hardened MCP invocation failed (exit {stub.returncode}); "
            f"stderr: {stderr_log.read_text(errors='replace')[-400:]!r}"
        )
        result = result_file.read_text(errors="replace")
        assert "LIST_SOURCES_RESULT:" in result and "sc8-alpha" in result and "sc8-beta" in result, (
            f"list_sources did not return exactly the fixture's two sources; "
            f"result: {result[-500:]!r}"
        )
        assert "SEARCH_RESULT:" in result and "zephyr" in result.lower(), (
            f"seeded search returned no hit; result: {result[-500:]!r}"
        )
    finally:
        kill_pids(tree_pids(marker))
