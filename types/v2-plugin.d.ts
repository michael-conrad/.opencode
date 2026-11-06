// Ambient declaration for the V2 plugin surface these plugins consume.
//
// The `@opencode/plugin` module is provided at runtime by the opencode V2
// binary (verified embedded in the v2.2.0 release). The locally installed
// `@opencode-ai/plugin` typings (1.18.3) predate the V2 context domains, so
// the V2 surface is declared here at the resolution-alias below. Types match
// the migration guide (opencode.ai/v2/docs/build/plugins/migrate-v1) and the
// verified live port in ~/.config/opencode/plugins/vacuum-retention/.

declare module "@opencode/plugin" {
  export interface PluginContext {
    readonly options: Record<string, unknown>;
    readonly location: {
      readonly directory: string;
      readonly project?: unknown;
    };
    readonly shell: {
      hook(
        name: "create.before",
        callback: (event: { env: Record<string, string> }) => void | Promise<void>,
      ): Promise<unknown>;
    };
    readonly session: {
      hook(
        name: "context",
        callback: (event: {
          system: Array<{ type: string; text?: string }>;
          messages: Array<{
            info?: { role?: string };
            parts?: Array<{
              type?: string;
              text?: string;
              synthetic?: boolean;
            }>;
          }>;
        }) => void | Promise<void>,
      ): Promise<unknown>;
    };
  }

  export interface PluginDefinition {
    readonly id: string;
    readonly setup: (context: PluginContext) => Promise<void> | void;
  }

  export const Plugin: {
    define(plugin: {
      id: string;
      setup(
        context: PluginContext,
      ): Promise<void> | void | (() => void);
    }): PluginDefinition;
  };
}
