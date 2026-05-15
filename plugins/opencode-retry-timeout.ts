/**
 * Retry-Timeout Plugin for OpenCode
 *
 * Subscribes to session.error events, matches SSE/connection timeout
 * patterns, and automatically retries with exponential backoff. Discards
 * partial assistant responses via session.revert() before re-sending
 * the original user prompt.
 *
 * Hook: event — filters session.error (retry trigger) and
 *   message.updated (model tracking).
 *
 * Co-authored with AI: OpenCode (deepseek-v4-flash-free)
 */

// SPDX-FileCopyrightText: 2026 Michael Conrad
// SPDX-License-Identifier: MIT
// Provenance: AI-generated

import type { Plugin } from "@opencode-ai/plugin";
import fs from "fs";
import path from "path";
import os from "os";

/* ------------------------------------------------------------------ */
/*  Types                                                             */
/* ------------------------------------------------------------------ */

interface RetryState {
  attempts: number;
  lastActivity: number;
  currentModel?: { providerID: string; modelID: string };
}

interface RetryConfig {
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

interface EventProperties {
  sessionID?: string;
  error?: {
    name: string;
    data?: {
      message?: string;
      responseBody?: string;
      statusCode?: number;
      isRetryable?: boolean;
      [key: string]: unknown;
    };
  };
}

type MessageInfo = {
  id: string;
  sessionID: string;
  role: "user" | "assistant";
  time: { created: number; completed?: number };
  providerID?: string;
  modelID?: string;
  model?: { providerID: string; modelID: string };
  error?: { name: string; data?: Record<string, unknown> };
  [key: string]: unknown;
};

type Part = {
  type: string;
  text?: string;
  mime?: string;
  filename?: string;
  url?: string;
  source?: string;
  name?: string;
  prompt?: string;
  description?: string;
  agent?: string;
  synthetic?: boolean;
  ignored?: boolean;
  time?: { created: number };
  metadata?: Record<string, unknown>;
  id?: string;
  sessionID?: string;
  messageID?: string;
  [key: string]: unknown;
};

type PartInput = {
  type: string;
  text?: string;
  mime?: string;
  filename?: string;
  url?: string;
  source?: string;
  name?: string;
  prompt?: string;
  description?: string;
  agent?: string;
  synthetic?: boolean;
  ignored?: boolean;
  time?: { created: number };
  metadata?: Record<string, unknown>;
};

/* ------------------------------------------------------------------ */
/*  Constants                                                         */
/* ------------------------------------------------------------------ */

const STALE_THRESHOLD_MS = 300_000;
const CONFIG_PROJECT_RELATIVE = ".opencode/opencode-retry-timeout.json";
const CONFIG_XDG_RELATIVE = path.join(".config", "opencode", "opencode-retry-timeout.json");
const DEBUG_LOG_RELATIVE = path.join(".config", "opencode", "opencode-retry-debug.log");

const DEFAULT_CONFIG: RetryConfig = {
  enabled: true,
  maxRetries: 3,
  baseDelayMs: 3_000,
  maxDelayMs: 30_000,
  errorPatterns: [
    "sse read timed out",
    "timed out",
    "econnreset",
    "connection reset",
    "read timeout",
    "connection refused",
    "aborted",
  ],
  skipPatterns: [
    "401",
    "403",
    "429",
    "authentication",
    "unauthorized",
    "invalid api key",
    "invalid x-api-key",
    "ProviderAuthError",
  ],
  debugLogging: false,
  toastRetry: "Retrying (attempt {attempt}/{max})\u2026",
  toastSuccess: "Retry successful",
  toastFailure: "Retry failed after {max} attempts",
};

/* ------------------------------------------------------------------ */
/*  Logging                                                           */
/* ------------------------------------------------------------------ */

function debugLog(config: RetryConfig, logPath: string, entry: Record<string, unknown>): void {
  if (!config.debugLogging) return;
  try {
    const dir = path.dirname(logPath);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    const line = JSON.stringify({ timestamp: new Date().toISOString(), ...entry }) + "\n";
    fs.appendFileSync(logPath, line, "utf8");
  } catch {
    // Silent — debug logging must never throw
  }
}

/* ------------------------------------------------------------------ */
/*  Config Loading                                                    */
/* ------------------------------------------------------------------ */

function loadConfig(directory: string): RetryConfig {
  const config = { ...DEFAULT_CONFIG };

  const xdgHome = process.env.XDG_CONFIG_HOME || path.join(os.homedir(), ".config");
  const xdgPath = path.join(xdgHome, CONFIG_XDG_RELATIVE);
  const projectPath = path.join(directory, CONFIG_PROJECT_RELATIVE);

  const candidates: { path: string; label: string }[] = [
    { path: xdgPath, label: "XDG" },
    { path: projectPath, label: "project-local" },
  ];

  for (const { path: cfgPath, label } of candidates) {
    if (!fs.existsSync(cfgPath)) continue;
    try {
      const raw = fs.readFileSync(cfgPath, "utf8");
      const parsed = JSON.parse(raw) as Partial<RetryConfig>;
      Object.assign(config, parsed);
    } catch {
      console.error(`[opencode-retry-timeout] malformed config at ${cfgPath} — falling back to defaults`);
    }
  }

  return config;
}

/* ------------------------------------------------------------------ */
/*  Error Text Extraction & Matching                                  */
/* ------------------------------------------------------------------ */

function extractErrorText(error: EventProperties["error"]): string {
  if (!error) return "unknown";
  return error.data?.message ?? error.data?.responseBody ?? error.name ?? "unknown";
}

function matchesAny(text: string, patterns: string[]): boolean {
  const lower = text.toLowerCase();
  return patterns.some(p => lower.includes(p.toLowerCase()));
}

/* ------------------------------------------------------------------ */
/*  Exponential Backoff                                               */
/* ------------------------------------------------------------------ */

function calculateDelay(attempt: number, config: RetryConfig): number {
  const delay = Math.min(config.baseDelayMs * 2 ** (attempt - 1), config.maxDelayMs);
  return delay + Math.random() * delay * 0.25;
}

/* ------------------------------------------------------------------ */
/*  Part Transformation                                               */
/* ------------------------------------------------------------------ */

const ASSISTANT_ONLY_TYPES = new Set([
  "reasoning",
  "tool",
  "step_start",
  "step_finish",
  "snapshot",
  "patch",
  "retry",
  "compaction",
]);

const SERVER_FIELDS = new Set(["id", "sessionID", "messageID"]);

function isAssistantOnlyPart(part: Part): boolean {
  return ASSISTANT_ONLY_TYPES.has(part.type);
}

function stripServerFields(part: Part): PartInput {
  const input: PartInput = {};
  for (const [key, value] of Object.entries(part)) {
    if (!SERVER_FIELDS.has(key)) {
      (input as Record<string, unknown>)[key] = value;
    }
  }
  return input;
}

function transformParts(parts: Part[]): PartInput[] {
  return parts
    .filter(p => !isAssistantOnlyPart(p))
    .map(p => stripServerFields(p));
}

/* ------------------------------------------------------------------ */
/*  Plugin State                                                       */
/* ------------------------------------------------------------------ */

const retryState = new Map<string, RetryState>();
const retryingSessions = new Set<string>();
const sessionModels = new Map<string, { providerID: string; modelID: string }>();

/* ------------------------------------------------------------------ */
/*  Plugin Export                                                      */
/* ------------------------------------------------------------------ */

export const OpenCodeRetryTimeout: Plugin = async ({ project, client, $, directory, worktree }) => {
  if (!directory) directory = process.cwd();

  const config = loadConfig(directory);
  const xdgHome = process.env.XDG_CONFIG_HOME || path.join(os.homedir(), ".config");
  const logPath = path.join(xdgHome, DEBUG_LOG_RELATIVE);

  debugLog(config, logPath, { event: "plugin_init", status: "loaded", enabled: config.enabled });

  async function showToast(variant: "info" | "success" | "error", message: string): Promise<void> {
    try {
      await client.tui.showToast({ body: { message, variant } });
    } catch {
      // Toast must never break retry
    }
  }

  function substituteTemplate(template: string, attempt: number, max: number): string {
    return template.replace(/\{attempt\}/g, String(attempt)).replace(/\{max\}/g, String(max));
  }

  function getModelForSession(sessionID: string): { providerID: string; modelID: string } | undefined {
    if (sessionModels.has(sessionID)) return sessionModels.get(sessionID);
    const state = retryState.get(sessionID);
    return state?.currentModel;
  }

  async function handleSessionError(sessionID: string, error: NonNullable<EventProperties["error"]>): Promise<void> {
    const errorText = extractErrorText(error);

    debugLog(config, logPath, {
      event: "session.error",
      sessionID,
      errorText,
      errorName: error.name,
    });

    // Skip patterns (auth/rate-limit)
    if (matchesAny(errorText, config.skipPatterns)) {
      debugLog(config, logPath, { event: "skip_pattern_matched", sessionID, errorText });
      return;
    }

    // Match error patterns (timeout/connection)
    if (!matchesAny(errorText, config.errorPatterns)) {
      debugLog(config, logPath, { event: "no_match", sessionID, errorText });
      return;
    }

    if (!config.enabled) return;

    // Atomic check-and-add
    if (retryingSessions.has(sessionID)) return;
    retryingSessions.add(sessionID);

    let attempt = 0;
    let modelCache: { providerID: string; modelID: string } | undefined;
    let userPartsCache: PartInput[] | undefined;

    while (attempt < config.maxRetries) {
      attempt++;

      const state = retryState.get(sessionID);
      const now = Date.now();
      const isStale = state && now - state.lastActivity > STALE_THRESHOLD_MS;

      // On first entry, track state from original session.error
      if (attempt === 1) {
        const currentAttempt = isStale ? 0 : (state?.attempts ?? 0);
        retryState.set(sessionID, {
          attempts: currentAttempt + 1,
          lastActivity: now,
          currentModel: getModelForSession(sessionID) ?? state?.currentModel,
        });
      }

      const delay = calculateDelay(attempt, config);
      const toastMsg = substituteTemplate(config.toastRetry, attempt, config.maxRetries);
      await showToast("info", toastMsg);

      debugLog(config, logPath, {
        event: "retry_delay",
        sessionID,
        attempt,
        delayMs: Math.round(delay),
      });

      await new Promise(resolve => setTimeout(resolve, delay));

      // Get messages
      let messagesData: Array<{ info: MessageInfo; parts: Part[] }>;
      try {
        const msgResult = await client.session.messages({ path: { id: sessionID } });
        messagesData = msgResult.data ?? [];
      } catch {
        if (attempt >= config.maxRetries) break;
        continue;
      }

      if (messagesData.length === 0) {
        if (attempt >= config.maxRetries) {
          await showToast("error", "Retry failed: no messages to re-send");
        }
        break;
      }

      // Terminal error check
      const lastAssistant = [...messagesData].reverse().find(m => m.info.role === "assistant");
      if (lastAssistant && lastAssistant.info.time.completed && lastAssistant.info.error) {
        const errMsg = extractErrorText(lastAssistant.info.error as unknown as EventProperties["error"]);
        await showToast("error", `Retry skipped: ${errMsg}`);
        debugLog(config, logPath, { event: "terminal_error", sessionID, errorMessage: errMsg });
        break;
      }

      // Revert partial assistant
      const partialAssistant = messagesData.find(m => m.info.role === "assistant" && !m.info.time.completed);
      if (partialAssistant) {
        try {
          await client.session.revert({ path: { id: sessionID }, body: { messageID: partialAssistant.info.id } });
          debugLog(config, logPath, { event: "reverted_partial", sessionID, messageID: partialAssistant.info.id });
        } catch {
          if (attempt >= config.maxRetries) {
            await showToast("error", "Retry failed: could not discard partial response");
          }
          break;
        }
      }

      // Cache last user parts and model on first successful messages() call
      if (!userPartsCache || !modelCache) {
        const lastUser = [...messagesData].reverse().find(m => m.info.role === "user");
        if (!lastUser) {
          if (attempt >= config.maxRetries) {
            await showToast("error", "Retry failed: no user message found");
          }
          break;
        }
        userPartsCache = transformParts(lastUser.parts);

        modelCache = getModelForSession(sessionID);
        if (!modelCache) {
          await showToast("error", "Retry failed: unknown model");
          break;
        }
      }

      // Send retry prompt
      try {
        await client.session.prompt({
          path: { id: sessionID },
          body: { model: { providerID: modelCache.providerID, modelID: modelCache.modelID }, parts: userPartsCache },
        });
      } catch (promptError: unknown) {
        const promptErrorText = extractErrorText(
          (promptError as { data?: { message?: string }; message?: string }) as unknown as EventProperties["error"]
        );
        if (matchesAny(promptErrorText, config.errorPatterns)) {
          // Timeout: re-enter loop with incremented attempt
          debugLog(config, logPath, { event: "prompt_timeout", sessionID, attempt, errorText: promptErrorText });
          continue;
        }
        // Non-timeout: abort
        debugLog(config, logPath, { event: "prompt_failed", sessionID, attempt, errorText: promptErrorText });
        if (attempt >= config.maxRetries) {
          await showToast("error", "Retry failed: unexpected error");
        }
        break;
      }

      // Success
      retryState.set(sessionID, {
        attempts: 0,
        lastActivity: Date.now(),
        currentModel: modelCache,
      });

      await showToast("success", substituteTemplate(config.toastSuccess, 0, config.maxRetries));
      debugLog(config, logPath, { event: "retry_success", sessionID, attempt });
      break;
    }

    if (attempt >= config.maxRetries) {
      const msg = substituteTemplate(config.toastFailure, attempt, config.maxRetries);
      await showToast("error", msg);
      debugLog(config, logPath, { event: "max_retries_reached", sessionID, attempts: attempt });
    }

    retryingSessions.delete(sessionID);
  }

  return {
    event: async ({ event }) => {
      if (!event) return;

      if (event.type === "session.error") {
        const props = event.properties as EventProperties;
        const sessionID = props.sessionID;

        if (!sessionID) {
          await showToast("error", "Session error received without session identifier");
          return;
        }

        if (props.error) {
          await handleSessionError(sessionID, props.error);
        }
      }

      if (event.type === "message.updated") {
        const props = event.properties as { info: MessageInfo };
        const info = props.info;
        if (!info) return;

        let providerID: string | undefined;
        let modelID: string | undefined;

        if (info.role === "user" && info.model) {
          providerID = info.model.providerID;
          modelID = info.model.modelID;
        } else if (info.role === "assistant") {
          providerID = info.providerID;
          modelID = info.modelID;
        }

        if (providerID && modelID && info.sessionID) {
          sessionModels.set(info.sessionID, { providerID, modelID });
        }
      }

      if (event.type === "session.idle") {
        const props = event.properties as { sessionID?: string };
        const sessionID = props.sessionID;
        if (!sessionID) return;

        // Reset success counter if this is a normal completion (no retry in progress)
        if (!retryingSessions.has(sessionID)) {
          const state = retryState.get(sessionID);
          if (state && state.attempts > 0) {
            retryState.set(sessionID, { ...state, attempts: 0 });
            debugLog(config, logPath, { event: "success_reset", sessionID });
          }
        }
      }
    },
  };
};
