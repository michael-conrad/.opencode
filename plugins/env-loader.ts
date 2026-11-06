/**
 * Env-Loader Plugin for OpenCode (V2)
 *
 * Reads project environment data and injects all key-value pairs into
 * every shell session via the shell-domain `create.before` hook. This is
 * the SOLE provider of bash environment variables — session-enforcement.ts
 * owns LLM context.
 *
 * Source (independently gathered, no cross-plugin coupling):
 * - .env file — all parsed key-value pairs including secrets
 *
 * V2 port (per opencode.ai/v2/docs/build/plugins/migrate-v1):
 * - V1 named-export Plugin function returning hooks -> `Plugin.define({ id, setup })` default export
 * - V1 `directory` input -> `ctx.location.directory`
 * - V1 `shell.env` hook (`output.env[key] = value`) -> `ctx.shell.hook("create.before", (event) => event.env[key] = value)`
 * - V1 `worktree` input — no V2 equivalent on the plugin context; the derived
 *   `WORKTREE_PATH` injection was removed with it (issue .opencode#2717, R-3)
 *
 * Hook: shell `create.before` ONLY — no system prompt, no LLM output.
 *
 * Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
 */

import { Plugin } from "@opencode/plugin";
import fs from "fs";
import path from "path";

const ENV_FILE = ".env";

interface ParseResult {
  env: Record<string, string>;
  warnings: string[];
}

function parseEnvFile(content: string): ParseResult {
  const env: Record<string, string> = {};
  const warnings: string[] = [];

  for (const rawLine of content.split("\n")) {
    const line = rawLine.trim();

    if (line === "" || line.startsWith("#")) {
      continue;
    }

    const eqIdx = line.indexOf("=");
    if (eqIdx === -1) {
      continue;
    }

    const key = line.slice(0, eqIdx).trim();
    let value = line.slice(eqIdx + 1).trim();

    if (!key) {
      continue;
    }

    // Strip inline comments before unquoting
    value = stripInlineComments(value);

    // Strip surrounding quotes
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }

    if (key in env) {
      warnings.push(`Duplicate key "${key}" — last value wins`);
    }

    env[key] = value;
  }

  return { env, warnings };
}

function stripInlineComments(value: string): string {
  // If value is quoted, don't strip inline comments — hashes inside quotes are literal
  if (
    (value.startsWith('"') && value.endsWith('"')) ||
    (value.startsWith("'") && value.endsWith("'"))
  ) {
    return value;
  }
  // For unquoted values, strip inline comments: `value # comment`
  const hashIdx = value.indexOf(" #");
  if (hashIdx !== -1) {
    return value.slice(0, hashIdx).trim();
  }
  return value;
}

export default Plugin.define({
  id: "env-loader",
  async setup(ctx) {
    const projectDir = ctx.location.directory || process.cwd();
    const envPath = path.join(projectDir, ENV_FILE);

    await ctx.shell.hook("create.before", (event) => {
      // --- .env file values ---
      if (fs.existsSync(envPath)) {
        const content = fs.readFileSync(envPath, "utf8");
        const { env } = parseEnvFile(content);

        for (const [key, value] of Object.entries(env)) {
          event.env[key] = value;
        }
      }
    });

    // Hook registrations are disposed automatically when the plugin unloads.
  },
});

// Utility functions are intentionally not exported — a V2 plugin's module
// surface is exactly the default definition. Only the plugin definition is
// exported.
