// SPDX-FileCopyrightText: 2026 Michael Conrad
// SPDX-License-Identifier: MIT
// Provenance: AI-generated
/**
 * OpenCode SSE Timeout Auto-Retry Plugin
 *
 * Retries SSE/connection timeouts with exponential backoff, partial response
 * cleanup, and configurable error/skip patterns.
 *
 * Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
 */

import type { Plugin } from "@opencode-ai/plugin";
import fs from "fs";
import path from "path";
import os from "os";

// ── Types ─────────────────────────────────────────────────

interface PluginConfig {
  enabled: boolean;
  maxRetries: number;
  baseDelayMs: number;
  maxDelayMs: number;
  errorPatterns: string[];
  skipPatterns: string[];
  debugLogging: boolean;
  toastRetry: string;
  toastSuccess: string;
  toastFailure: string;
}

interface RetryState {
  attempts: number;
  lastActivity: number;
}

// ── Defaults ──────────────────────────────────────────────

const DEFAULT_CONFIG: PluginConfig = {
  enabled: true,
  maxRetries: 3,
  baseDelayMs: 3000,
  maxDelayMs: 30000,
  errorPatterns: [
    "sse read timed out", "timed out", "econnreset",
    "connection reset", "read timeout", "connection refused", "aborted",
  ],
  skipPatterns: [
    "401", "403", "429", "authentication", "unauthorized",
    "invalid api key", "invalid x-api-key", "ProviderAuthError",
  ],
  debugLogging: false,
  toastRetry: "Retrying (attempt {attempt}/{max})…",
  toastSuccess: "Retry successful",
  toastFailure: "Retry failed after {max} attempts",
};

// ── Module-level state ────────────────────────────────────

const retryState = new Map<string, RetryState>();
const retryingSessions = new Set<string>();
const sessionModels = new Map<string, { providerID: string; modelID: string }>();

// ── Helpers ───────────────────────────────────────────────

function loadConfig(projectDir: string): PluginConfig {
  const cfg = { ...DEFAULT_CONFIG };

  const tryLoad = (filePath: string) => {
    try {
      if (!fs.existsSync(filePath)) return;
      const raw = fs.readFileSync(filePath, "utf8");
      const parsed = JSON.parse(raw);
      if (typeof parsed !== "object" || parsed === null) return;
      for (const key of Object.keys(parsed)) {
        if (key in cfg) (cfg as any)[key] = (parsed as any)[key];
      }
    } catch {
      // malformed JSON — fall through to defaults
    }
  };

  // Priority 1: XDG config (~/.config/opencode/opencode-retry-timeout.json)
  tryLoad(path.join(os.homedir(), ".config", "opencode", "opencode-retry-timeout.json"));
  // Priority 2: project-local (.opencode/opencode-retry-timeout.json)
  tryLoad(path.join(projectDir, ".opencode", "opencode-retry-timeout.json"));

  return cfg;
}

function debugAppend(logPath: string, msg: string): void {
  try {
    fs.mkdirSync(path.dirname(logPath), { recursive: true });
    fs.appendFileSync(logPath, `[${new Date().toISOString()}] ${msg}\n`, "utf8");
  } catch {
    // best-effort
  }
}

function calcDelay(attempt: number, base: number, max: number): number {
  let d = Math.min(base * Math.pow(2, attempt - 1), max);
  d *= 1 + Math.random() * 0.25;
  return Math.round(d);
}

function errorText(err: any): string {
  if (err?.data?.message) return err.data.message;
  if (err?.data?.responseBody) return err.data.responseBody;
  if (err?.name) return err.name;
  if (err?.message) return err.message;
  return "unknown";
}

function matches(text: string, patterns: string[]): boolean {
  const lower = text.toLowerCase();
  for (const p of patterns) {
    if (lower.includes(p.toLowerCase())) return true;
  }
  return false;
}

function transformParts(parts: any[]): any[] {
  const out: any[] = [];
  for (const p of parts) {
    switch (p.type) {
      case "text": {
        const t: any = { type: "text", text: p.text };
        if (p.synthetic !== undefined) t.synthetic = p.synthetic;
        if (p.ignored !== undefined) t.ignored = p.ignored;
        if (p.time !== undefined) t.time = p.time;
        if (p.metadata !== undefined) t.metadata = p.metadata;
        out.push(t);
        break;
      }
      case "file": {
        const f: any = { type: "file", mime: p.mime, url: p.url };
        if (p.filename !== undefined) f.filename = p.filename;
        if (p.source !== undefined) f.source = p.source;
        out.push(f);
        break;
      }
      case "agent": {
        const a: any = { type: "agent", name: p.name };
        if (p.source !== undefined) a.source = p.source;
        out.push(a);
        break;
      }
      case "subtask": {
        out.push({ type: "subtask", prompt: p.prompt, description: p.description, agent: p.agent });
        break;
      }
      // ReasoningPart, ToolPart, StepStartPart, StepFinishPart,
      // SnapshotPart, PatchPart, RetryPart, CompactionPart → SKIP
    }
  }
  return out;
}

// ── Plugin ────────────────────────────────────────────────

export const OpenCodeRetryTimeout: Plugin = async ({ project, client, $, directory, worktree }) => {
  const projectDir = directory || process.cwd();
  const cfg = loadConfig(projectDir);
  const logPath = path.join(os.homedir(), ".config", "opencode", "opencode-retry-debug.log");
  const STALE_MS = 300000;

  async function toast(msg: string, variant: "info" | "success" | "error") {
    try { await client.tui.showToast({ body: { message: msg, variant } }); } catch { /* best-effort */ }
  }

  return {
    event: async ({ event }: { event: any }) => {

      // ═══════════════════════════════════════════════════
      // session.error — retry trigger
      // ═══════════════════════════════════════════════════
      if (event.type === "session.error") {
        const sessionID: string | undefined = event.properties?.sessionID;
        const err = event.properties?.error;

        // REQ-16: missing sessionID → error toast
        if (!sessionID) {
          const msg = err ? errorText(err) : "unknown error";
          await toast(`Session error: ${msg}`, "error");
          return;
        }

        const text = err ? errorText(err) : "unknown";
        if (cfg.debugLogging) debugAppend(logPath, `session.error: sessionID=${sessionID}, error=${text}`);

        // REQ-6: skip patterns (auth/rate-limit) checked first
        if (matches(text, cfg.skipPatterns)) {
          if (cfg.debugLogging) debugAppend(logPath, `skip: session=${sessionID}, error=${text}`);
          return;
        }

        // REQ-2/3: must match an error pattern
        if (!matches(text, cfg.errorPatterns)) {
          if (cfg.debugLogging) debugAppend(logPath, `no match: session=${sessionID}, error=${text}`);
          return;
        }

        // REQ-10: atomic check-and-add dedup
        if (retryingSessions.has(sessionID)) return;
        retryingSessions.add(sessionID);

        // get-or-create state
        let state = retryState.get(sessionID);
        if (!state) {
          state = { attempts: 0, lastActivity: 0 };
          retryState.set(sessionID, state);
        }

        // staleness reset (>5 min → reset attempts)
        const now = Date.now();
        if (state.lastActivity > 0 && now - state.lastActivity > STALE_MS) {
          state.attempts = 0;
        }
        state.lastActivity = now;

        // enabled check
        if (!cfg.enabled) {
          retryingSessions.delete(sessionID);
          return;
        }

        // ── Retry loop ──
        while (true) {
          // check max attempts
          if (state.attempts >= cfg.maxRetries) {
            const msg = cfg.toastFailure.replace("{max}", String(cfg.maxRetries));
            await toast(msg, "error");
            if (cfg.debugLogging) debugAppend(logPath, `max retries: session=${sessionID}`);
            break;
          }

          const currentAttempt = state.attempts + 1;
          const delay = calcDelay(currentAttempt, cfg.baseDelayMs, cfg.maxDelayMs);
          const retryMsg = cfg.toastRetry
            .replace("{attempt}", String(currentAttempt))
            .replace("{max}", String(cfg.maxRetries));
          await toast(retryMsg, "info");
          if (cfg.debugLogging) debugAppend(logPath, `retry: session=${sessionID}, attempt=${currentAttempt}, delay=${delay}ms`);

          // exponential backoff wait
          await new Promise(r => setTimeout(r, delay));

          // ── D-1.6: partial discard ──
          try {
            const msgs: any[] = await client.session.messages({ path: { id: sessionID } });

            // REQ-18: empty messages
            if (!msgs || msgs.length === 0) {
              await toast("Retry failed: no messages to re-send", "error");
              if (cfg.debugLogging) debugAppend(logPath, `empty messages: session=${sessionID}`);
              break;
            }

            // REQ-19: completed assistant with error field
            const last = msgs[msgs.length - 1];
            if (last?.info?.role === "assistant" && last.info.time?.completed !== undefined && last.info.error) {
              const emsg = errorText(last.info.error);
              await toast(`Retry skipped: ${emsg}`, "error");
              if (cfg.debugLogging) debugAppend(logPath, `completed-with-error: session=${sessionID}: ${emsg}`);
              break;
            }

            // find partial assistant (role=assistant, no time.completed)
            let partial: any = null;
            for (let i = msgs.length - 1; i >= 0; i--) {
              const m = msgs[i];
              if (m?.info?.role === "assistant" && m.info.time?.completed === undefined) {
                partial = m;
                break;
              }
            }

            // revert if partial found
            if (partial) {
              try {
                await client.session.revert({ path: { id: sessionID }, body: { messageID: partial.info.id } });
              } catch (rerr) {
                const rmsg = rerr instanceof Error ? rerr.message : String(rerr);
                await toast("Retry failed: cannot discard partial response", "error");
                if (cfg.debugLogging) debugAppend(logPath, `revert failed: session=${sessionID}: ${rmsg}`);
                break;
              }
            }
          } catch (merr) {
            const mmsg = merr instanceof Error ? merr.message : String(merr);
            await toast("Retry failed: cannot read messages", "error");
            if (cfg.debugLogging) debugAppend(logPath, `messages error: session=${sessionID}: ${mmsg}`);
            break;
          }

          // ── D-1.7: retry prompt ──
          try {
            const msgs: any[] = await client.session.messages({ path: { id: sessionID } });

            // find last user message (scan backwards)
            let userMsg: any = null;
            for (let i = msgs.length - 1; i >= 0; i--) {
              if (msgs[i]?.info?.role === "user") {
                userMsg = msgs[i];
                break;
              }
            }

            if (!userMsg) {
              await toast("Retry failed: no user message found", "error");
              if (cfg.debugLogging) debugAppend(logPath, `no user msg: session=${sessionID}`);
              break;
            }

            // transform parts (strip server-side fields, filter assistant-only types)
            const parts = transformParts(userMsg.parts || []);
            if (parts.length === 0) {
              await toast("Retry failed: no retryable parts", "error");
              if (cfg.debugLogging) debugAppend(logPath, `no parts: session=${sessionID}`);
              break;
            }

            // resolve model from tracked data or state
            const model = sessionModels.get(sessionID) || state.currentModel;
            if (!model) {
              await toast("Retry failed: no model tracked", "error");
              if (cfg.debugLogging) debugAppend(logPath, `no model: session=${sessionID}`);
              break;
            }

            try {
              await client.session.prompt({
                path: { id: sessionID },
                body: { model: { providerID: model.providerID, modelID: model.modelID }, parts },
              });

              // success
              state.attempts = 0;
              await toast(cfg.toastSuccess, "success");
              if (cfg.debugLogging) debugAppend(logPath, `retry success: session=${sessionID}`);
              break;

            } catch (perr: any) {
              const ptext = errorText(perr);

              // non-timeout failure → abort cycle
              if (!matches(ptext, cfg.errorPatterns)) {
                await toast(`Retry failed: ${ptext}`, "error");
                if (cfg.debugLogging) debugAppend(logPath, `non-timeout error: session=${sessionID}: ${ptext}`);
                break;
              }

              // timeout re-entry → increment and retry
              state.attempts = currentAttempt;
              if (cfg.debugLogging) debugAppend(logPath, `timeout re-entry: session=${sessionID}, error=${ptext}`);
              continue;
            }

          } catch (perr) {
            const pmsg = perr instanceof Error ? perr.message : String(perr);
            await toast(`Retry failed: ${pmsg}`, "error");
            if (cfg.debugLogging) debugAppend(logPath, `prompt error: session=${sessionID}: ${pmsg}`);
            break;
          }
        }

        retryingSessions.delete(sessionID);
      }

      // ═══════════════════════════════════════════════════
      // message.updated — model tracking
      // ═══════════════════════════════════════════════════
      else if (event.type === "message.updated") {
        const info = event.properties?.info;
        if (!info?.sessionID) return;

        // D-1.4: role-dependent property access
        if (info.role === "user" && info.model?.providerID && info.model?.modelID) {
          sessionModels.set(info.sessionID, {
            providerID: info.model.providerID,
            modelID: info.model.modelID,
          });
        } else if (info.role === "assistant" && info.providerID && info.modelID) {
          sessionModels.set(info.sessionID, {
            providerID: info.providerID,
            modelID: info.modelID,
          });
        }
      }

      // ═══════════════════════════════════════════════════
      // session.idle — success reset
      // ═══════════════════════════════════════════════════
      else if (event.type === "session.idle") {
        const sid = event.properties?.sessionID;
        if (!sid) return;

        // D-1.12: reset attempts only if no retry in progress
        if (!retryingSessions.has(sid)) {
          const s = retryState.get(sid);
          if (s) s.attempts = 0;
        }
      }
    },
  };
};
