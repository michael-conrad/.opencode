// SPDX-FileCopyrightText: 2026 Michael Conrad
// SPDX-License-Identifier: MIT
// Provenance: AI-generated

/**
 * Session Enforcement Plugin for OpenCode
 *
 * Injects session context into the LLM system prompt at session start and strips
 * synthetic mode-switch messages from user input. Secret redaction is delegated to
 * the opencode-vibeguard npm plugin (configured in opencode.json "plugin" array).
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
 * Co-authored with AI: OpenCode (ollama-cloud/glm-5)
 * Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
 */

import type { Hooks, PluginInput } from "@opencode-ai/plugin";
import { execSync } from "child_process";

const CACHE_TTL_MS = 5 * 60 * 1000;

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

function isModeSwitchSynthetic(text: string): boolean {
  return text.includes("Your operational mode has changed from")
    || text.includes("# Plan Mode - System Reminder");
}

export const SessionEnforcementPlugin = async (input: PluginInput): Promise<Hooks> => {
  const projectDir = input?.directory || process.cwd();

  // Inject session context into system prompt ONCE at session start
  const systemTransformHook = async (_sysInput: unknown, output: { system?: string[] }) => {
    const scriptOutput = runSessionInit(projectDir);
    if (scriptOutput) {
      output.system ??= [];
      output.system.push(scriptOutput);
    }
  };

  // Per-turn: strip synthetic mode-switch messages from user input, nothing else
  const messagesTransformHook = async (_input: unknown, output: { messages?: Array<{ info?: { role?: string }; parts?: Array<{ type?: string; text?: string; synthetic?: boolean }> }> }) => {
    if (!output.messages?.length) return;

    const userMessages = output.messages.filter(m => m.info?.role === "user");
    if (!userMessages.length) return;

    const currentUser = output.messages.findLast(m => m.info?.role === "user");
    if (!currentUser?.parts?.length) return;

    for (const part of currentUser.parts) {
      if (part.type !== "text") continue;
      if (!part.synthetic) continue;
      if (isModeSwitchSynthetic(part.text || "")) {
        part.text = "";
        part.synthetic = false;
      }
    }
  };

  return {
    "experimental.chat.system.transform": systemTransformHook,
    "experimental.chat.messages.transform": messagesTransformHook,
  };
};