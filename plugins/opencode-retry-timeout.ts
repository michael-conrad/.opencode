// SPDX-FileCopyrightText: 2026 Michael Conrad
// SPDX-License-Identifier: MIT
// Provenance: AI-generated
//
// Co-authored with AI: OpenCode (deepseek-v4-flash-free)

import type { Plugin } from '@opencode-ai/plugin';
import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';

interface PluginContext {
  project?: any;
  client: any;
  $?: any;
  directory?: string;
  worktree?: string;
}

interface RetryState {
  sessionID: string;
  model: { providerID: string; modelID: string } | undefined;
  originalModel: { providerID: string; modelID: string } | undefined;
  originalPrompt: string;
  attempt: number;
  exhausted: boolean;
  lastActivity: number;
  lastNonTimeoutError: boolean;
}

interface Config {
  baseDelayMs: number;
  maxDelayMs: number;
  maxRetries: number;
  enabled: boolean;
  errorPatterns: string[];
  skipPatterns: string[];
  debugLogging: boolean;
  toastRetry: string;
  toastSuccess: string;
  toastFailure: string;
}

const DEFAULT_CONFIG: Config = {
  baseDelayMs: 3000,
  maxDelayMs: 30000,
  maxRetries: 3,
  enabled: true,
  errorPatterns: [
    'sse read timed out', 'timed out', 'econnreset', 'connection reset',
    'read timeout', 'connection refused', 'aborted',
    'timeout', 'network', 'gateway', 'dns', 'ssl',
    'connection error', 'enotfound', 'econnrefused', 'socket hang up',
  ],
  skipPatterns: [
    'partial_output', 'model_rejected', 'rejected', 'cancelled_by_user',
    'ProviderAuthError', '401', '403', '429',
    'authentication', 'unauthorized', 'invalid api key', 'invalid x-api-key',
  ],
  debugLogging: false,
  toastRetry: 'Retrying (attempt {attempt}/{max})…',
  toastSuccess: 'Retry successful',
  toastFailure: 'Retry failed after {max} attempts',
};

const logFilePath = path.join(os.homedir(), '.config', 'opencode', 'opencode-retry-debug.log');

const logDebug = (client: any, message: string, config: Config): void => {
  if (config.debugLogging) {
    client.app.log({ body: { message: `[opencode-retry-timeout] ${message}` } });
  }
  const entry = JSON.stringify({ timestamp: new Date().toISOString(), message }) + '\n';
  try {
    fs.appendFileSync(logFilePath, entry, 'utf-8');
  } catch {
    // silently ignore
  }
};

const showToast = (client: any, message: string, variant: string): void => {
  client.tui.showToast({ body: { message, variant } });
};

const extractError = (error: any): string => {
  if (typeof error === 'string') return error;
  // note: error?.message is an additional fallback beyond the canonical spec order
  return error?.data?.message ?? error?.data?.responseBody ?? error?.name ?? error?.message ?? 'unknown';
};

const calculateBackoff = (attempt: number, baseDelayMs: number, maxDelayMs: number): number => {
  const delay = Math.min(baseDelayMs * Math.pow(2, attempt), maxDelayMs);
  return Math.round(delay * (1 + Math.random() * 0.25));
};

const classifyError = (errorMsg: string, config: Config): { retryable: boolean; reason: string } => {
  const m = errorMsg.toLowerCase();
  for (const skip of config.skipPatterns) {
    if (m.includes(skip.toLowerCase())) {
      return { retryable: false, reason: `Skip: ${skip}` };
    }
  }
  for (const pat of config.errorPatterns) {
    if (m.includes(pat.toLowerCase())) {
      return { retryable: true, reason: `Match: ${pat}` };
    }
  }
  return { retryable: false, reason: 'No match' };
};

function transformUserPartToPartInput(part: any): any {
  const keepTypes = new Set(['text', 'file', 'agent', 'subtask']);
  if (part.type && !keepTypes.has(part.type)) return null;

  const serverFields = new Set(['id', 'sessionID', 'messageID']);
  const result: any = {};
  for (const [key, value] of Object.entries(part)) {
    if (!serverFields.has(key)) {
      result[key] = value;
    }
  }
  return result;
}

const getSessionMessages = async (client: any, sessionID: string): Promise<{ messages: any[]; errored: boolean }> => {
  try {
    const raw = await client.session.messages({ path: { id: sessionID } });
    const messages = Array.isArray(raw) ? raw : (raw?.data ?? []);
    return { messages, errored: false };
  } catch {
    return { messages: [], errored: true };
  }
};

const findLastUserParts = (messages: any[]): any[] | null => {
  for (let i = messages.length - 1; i >= 0; i--) {
    if (messages[i]?.info?.role === 'user') {
      const parts = messages[i].parts ?? [];
      const transformed = parts
        .map((p: any) => transformUserPartToPartInput(p))
        .filter((p: any) => p !== null);
      return transformed.length > 0 ? transformed : null;
    }
  }
  return null;
};

const loadConfigFile = async (configPath: string): Promise<Partial<Config> | { error: string } | null> => {
  try {
    const raw = await fs.promises.readFile(configPath, 'utf-8');
    return JSON.parse(raw) as Partial<Config>;
  } catch (err) {
    if (err instanceof SyntaxError) {
      return { error: 'Malformed JSON' };
    }
    return null;
  }
};

const resolveProjectConfigPath = (ctx: PluginContext): string => {
  if (ctx.$?.resolve) {
    return ctx.$.resolve('.opencode/opencode-retry-timeout.json');
  }
  if (ctx.directory) {
    return path.join(ctx.directory, '.opencode', 'opencode-retry-timeout.json');
  }
  return path.join(process.cwd(), '.opencode', 'opencode-retry-timeout.json');
};

const loadConfig = async (ctx: PluginContext): Promise<Config | null> => {
  const config: Config = { ...DEFAULT_CONFIG };
  const homePath = path.join(os.homedir(), '.config', 'opencode', 'opencode-retry-timeout.json');
  const projectPath = resolveProjectConfigPath(ctx);

  for (const cfgPath of [homePath, projectPath]) {
    const partial = await loadConfigFile(cfgPath);
    if (partial) {
      if ('error' in partial) {
        showToast(ctx.client, 'opencode-retry-timeout: malformed config ' + cfgPath, 'error');
        logDebug(ctx.client, 'Malformed config at ' + cfgPath + ': ' + partial.error, config);
        continue;
      }
      Object.assign(config, partial);
    }
  }

  return config;
};

export const OpenCodeRetryTimeout: Plugin = async (
  ctx: PluginContext,
): Promise<{ event: (params: { event: any }) => Promise<void> }> => {
  let config: Config;

  try {
    const loaded = await loadConfig(ctx);
    config = loaded ?? { ...DEFAULT_CONFIG };
  } catch (err) {
    config = { ...DEFAULT_CONFIG };
    logDebug(ctx.client, `Config load error, using defaults: ${String(err)}`, config);
    showToast(ctx.client, 'opencode-retry-timeout: config load failed, using defaults', 'error');
  }

  if (!config.enabled) {
    logDebug(ctx.client, 'Plugin disabled by config', config);
  }

  const retryStates = new Map<string, RetryState>();
  const sessionModels = new Map<string, { providerID: string; modelID: string }>();
  const retryingSessions = new Set<string>();

  return {
    event: async ({ event }: { event: any }): Promise<void> => {
      if (!event?.type) return;
      if (!config.enabled) return;

      if (event.type === 'message.updated') {
        const { sessionID, info: message } = event.properties ?? {};
        if (sessionID && message) {
          const modelObj =
            message.role === 'assistant'
              ? { providerID: message.providerID, modelID: message.modelID }
              : { providerID: message.model?.providerID, modelID: message.model?.modelID };
          if (modelObj.providerID && modelObj.modelID) {
            sessionModels.set(sessionID, modelObj);
          }
        }
        return;
      }

      if (event.type === 'session.idle') {
        const { sessionID } = event.properties ?? {};
        if (!sessionID) return;

        const state = retryStates.get(sessionID);
        if (!state) return;

        const idleTime = Date.now() - state.lastActivity;
        if (!state.exhausted && !state.lastNonTimeoutError) {
          state.attempt = 0;
        }
        if (idleTime > 300000) {
          state.attempt = 0;
          state.exhausted = false;
        }
        return;
      }

      if (event.type === 'session.error') {
        await handleSessionError(ctx, event, config, retryStates, sessionModels, retryingSessions);
        return;
      }
    },
  };
};

const handleSessionError = async (
  ctx: PluginContext,
  event: any,
  config: Config,
  retryStates: Map<string, RetryState>,
  sessionModels: Map<string, { providerID: string; modelID: string }>,
  retryingSessions: Set<string>,
): Promise<void> => {
  const { sessionID, error } = event.properties ?? {};

  if (!sessionID) {
    showToast(ctx.client, 'opencode-retry-timeout: missing sessionID', 'error');
    logDebug(ctx.client, 'Missing sessionID in session.error', config);
    return;
  }

  // Atomic dedup check — per spec Retry Flow Step 4
  if (retryingSessions.has(sessionID)) return;
  retryingSessions.add(sessionID);

  try {
    const errorMsg = extractError(error);
    logDebug(ctx.client, `Error: ${sessionID} — ${errorMsg}`, config);

    const decision = classifyError(errorMsg, config);
    logDebug(ctx.client, `Classify: ${sessionID} retryable=${decision.retryable} reason=${decision.reason}`, config);

    if (!decision.retryable) {
      const state = retryStates.get(sessionID);
      if (state) {
        state.lastNonTimeoutError = true;
      }
      showToast(ctx.client, `opencode-retry-timeout: ${decision.reason}`, 'error');
      return;
    }

    const state = retryStates.get(sessionID);

    if (state && Date.now() - state.lastActivity > 300000) {
      logDebug(ctx.client, `Stale session ${sessionID}: reset attempts`, config);
      state.attempt = 0;
      state.exhausted = false;
    }

    if (state?.exhausted) {
      logDebug(ctx.client, `Already exhausted ${sessionID}, skipping`, config);
      return;
    }

    await executeRetry(ctx, sessionID, config, retryStates, sessionModels);
  } finally {
    retryingSessions.delete(sessionID);
  }
};

const executeRetry = async (
  ctx: PluginContext,
  sessionID: string,
  config: Config,
  retryStates: Map<string, RetryState>,
  sessionModels: Map<string, { providerID: string; modelID: string }>,
): Promise<void> => {
  let state = retryStates.get(sessionID);

  if (state?.exhausted) {
    logDebug(ctx.client, `Already exhausted ${sessionID}, skipping`, config);
    return;
  }

  const { messages: messagesData, errored } = await getSessionMessages(ctx.client, sessionID);

  if (errored) {
    logDebug(ctx.client, `Failed to fetch session messages for ${sessionID}`, config);
    showToast(ctx.client, 'opencode-retry-timeout: failed to fetch session messages', 'error');
    return;
  }

  if (!messagesData || messagesData.length === 0) {
    logDebug(ctx.client, `Empty messages for ${sessionID}`, config);
    showToast(ctx.client, 'Retry failed: no messages to re-send', 'error');
    return;
  }

  // Guard: ensure last assistant is not a terminal non-retryable error
  for (let i = messagesData.length - 1; i >= 0; i--) {
    if (messagesData[i].info?.role === 'assistant') {
      const errorMsg = extractError(messagesData[i].info.error);
      if (messagesData[i].info?.time?.completed && messagesData[i].info?.error) {
        const decision = classifyError(errorMsg, config);
        if (decision.retryable) {
          logDebug(
            ctx.client,
            `Completed-with-error but retryable ${sessionID}: ${errorMsg}`,
            config,
          );
          // Fall through to retry logic below
        } else {
          showToast(
            ctx.client,
            `opencode-retry-timeout: non-retryable — ${errorMsg}`,
            'error',
          );
          logDebug(ctx.client, `Non-retryable completed-with-error ${sessionID}: ${errorMsg}`, config);
          return;
        }
      }
      break;
    }
  }

  const lastUserParts = findLastUserParts(messagesData);
  if (!lastUserParts) {
    logDebug(ctx.client, `No user message found in ${sessionID}`, config);
    showToast(ctx.client, 'opencode-retry-timeout: no user message found', 'error');
    return;
  }

  const model = sessionModels.get(sessionID);

  if (!state) {
    state = {
      sessionID,
      model,
      originalModel: model,
      originalPrompt: JSON.stringify(lastUserParts),
      attempt: 0,
      exhausted: false,
      lastActivity: Date.now(),
      lastNonTimeoutError: false,
    };
    retryStates.set(sessionID, state);
  } else {
    state.lastActivity = Date.now();
  }

  let attempt = state.attempt;
  let success = false;

  while (attempt < config.maxRetries && !success) {
    // Apply backoff delay before retry (first retry has no delay to prevent CLI exit race)
    if (attempt > 0) {
      const delay = calculateBackoff(attempt - 1, config.baseDelayMs, config.maxDelayMs);
      await new Promise<void>((r) => setTimeout(r, delay));
    }

    state.model = model;
    state.attempt = attempt;
    state.lastActivity = Date.now();

    const retryToast = config.toastRetry
      .replace(/\{attempt\}/g, String(attempt + 1))
      .replace(/\{max\}/g, String(config.maxRetries));
    showToast(ctx.client, retryToast, 'info');

    logDebug(
      ctx.client,
      `Retry ${attempt + 1}/${config.maxRetries} ${sessionID} model=${model ? `${model.providerID}/${model.modelID}` : 'default'}`,
      config,
    );

    try {
      let partialIdx = -1;
      for (let i = messagesData.length - 1; i >= 0; i--) {
        if (messagesData[i].info?.role === 'assistant') {
          // Revert any assistant message (partial OR completed-with-error) before re-prompt
          partialIdx = i;
          break;
        }
      }

      if (partialIdx >= 0) {
        const partialMsg = messagesData[partialIdx];
        await ctx.client.session.revert({ path: { id: sessionID }, body: { messageID: partialMsg.info.id } });
        logDebug(ctx.client, `Revert OK ${sessionID} (messageID: ${partialMsg.info.id})`, config);
      } else {
        logDebug(ctx.client, `No partial assistant found for ${sessionID}, skipping revert`, config);
      }
    } catch (revertErr) {
      const msg = extractError(revertErr);
      logDebug(ctx.client, `Revert failed ${sessionID}: ${msg}`, config);
      showToast(ctx.client, 'opencode-retry-timeout: revert failed', 'error');
      state.exhausted = true;
      state.lastActivity = Date.now();
      return;
    }

    try {
      const body: any = { parts: lastUserParts };
      if (model) body.model = model;
      await ctx.client.session.prompt({
        path: { id: sessionID },
        body,
      });

      success = true;
      const successToast = config.toastSuccess.replace(/\{attempt\}/g, String(attempt + 1));
      showToast(ctx.client, successToast, 'success');

      logDebug(ctx.client, `Success ${sessionID} on attempt ${attempt + 1}`, config);
      retryStates.delete(sessionID);
    } catch (promptErr) {
      const promptErrorMsg = extractError(promptErr);
      const promptDecision = classifyError(promptErrorMsg, config);

      attempt++;
      state.attempt = attempt;
      state.lastActivity = Date.now();

      if (!promptDecision.retryable) {
        logDebug(ctx.client, `Non-retryable error during retry ${sessionID}: ${promptErrorMsg}`, config);
        showToast(ctx.client, 'opencode-retry-timeout: non-retryable error during retry', 'error');
        state.exhausted = true;
        state.lastNonTimeoutError = true;
        return;
      }

      if (attempt >= config.maxRetries) {
        const failToast = config.toastFailure.replace(/\{max\}/g, String(config.maxRetries));
        showToast(ctx.client, failToast, 'error');
        state.exhausted = true;
        state.lastActivity = Date.now();
        logDebug(ctx.client, `Exhausted ${sessionID} after ${config.maxRetries} attempts`, config);
        return;
      }

      logDebug(ctx.client, `Retry ${attempt}/${config.maxRetries} ${sessionID}: ${promptErrorMsg}`, config);
    }
  }
};
