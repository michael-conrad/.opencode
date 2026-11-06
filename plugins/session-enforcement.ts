// SPDX-FileCopyrightText: 2026 Michael Conrad
// SPDX-License-Identifier: MIT
// Provenance: AI-generated

/**
 * Session Enforcement Plugin for OpenCode (V2)
 *
 * Injects session context into the model-visible system context per model
 * request. Secret redaction is delegated to the opencode-vibeguard npm
 * plugin (configured in opencode.json "plugin" array).
 *
 * V2 port (per opencode.ai/v2/docs/build/plugins/migrate-v1):
 * - V1 named-export Plugin function returning hooks -> `Plugin.define({ id, setup })` default export
 * - V1 `directory` input -> `ctx.location.directory`
 * - V1 `experimental.chat.system.transform` (`output.system.push(string)`)
 *     -> `ctx.session.hook("context", ...)` pushing a `{ type: "text" }` part into `event.system`
 * - V1 `experimental.chat.messages.transform` (the synthetic mode-switch
 *     strip) — retired per .opencode#2717 R-5: V2 core renders
 *     `agent-switched` syntheses to nothing at the model layer, so the
 *     noise the V1 strip guarded has no generator and no surface to match;
 *     the plugin registers no message-editing hook.
 *
 * Source attribution:
 * - Session init pattern adapted from existing session-init.ts (project-internal)
 * - Skill enforcement injection adapted from obra/superpowers
 *   https://github.com/obra/superpowers/blob/main/.opencode/plugins/superpowers.js
 * - Red-flags rationalization table adapted from obra/superpowers writing-skills
 *   https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md
 * - CSO (Content Search Optimization) principles adapted from obra/superpowers
 *   https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md
 *
 * Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
 */

import { Plugin } from "@opencode/plugin";
import { execSync } from "child_process";

function runSessionInit(projectDir: string): string | null {
  try {
    const scriptPath = `${projectDir}/.opencode/tools/session-init`;
    const result = execSync(scriptPath, {
      cwd: projectDir,
      encoding: "utf8",
      timeout: 10000,
      stdio: ["pipe", "pipe", "pipe"],
    });
    return result.trim() || null;
  } catch {
    return null;
  }
}

export default Plugin.define({
  id: "session-enforcement",
  async setup(ctx) {
    const projectDir = ctx.location.directory || process.cwd();

    await ctx.session.hook("context", (event) => {
      // Inject session context into system context — V1 ran this transform
      // per model request, and the V2 `context` hook preserves that frequency.
      const scriptOutput = runSessionInit(projectDir);
      if (scriptOutput) {
        event.system.push({ type: "text", text: scriptOutput });
      }
    });
  },
});


