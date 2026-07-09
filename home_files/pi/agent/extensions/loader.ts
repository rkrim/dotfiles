/**
 * Loader — Extension manager for Pi
 * 
 * Auto-discovered globally at ~/.pi/agent/extensions/loader.ts.
 * Exposes commands to list, load, and unload local extensions by modifying settings.json.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { existsSync, readFileSync, writeFileSync, readdirSync } from "fs";
import { join } from "path";

export default function (pi: ExtensionAPI) {
  const getExtensionsDir = () => {
    const home = process.env.HOME || process.env.USERPROFILE || "~";
    return join(home, ".pi", "extensions");
  };

  const getSettingsPath = () => {
    const home = process.env.HOME || process.env.USERPROFILE || "~";
    return join(home, ".pi", "agent", "settings.json");
  };

  // Helper to read settings.json safely (handles JSONC comments)
  const readSettings = (): any => {
    const path = getSettingsPath();
    if (!existsSync(path)) return {};
    try {
      const content = readFileSync(path, "utf-8");
      // Strip comments (both single-line and multi-line) to parse safely
      const cleanContent = content
        .replace(/\/\*[\s\S]*?\*\/|([^\\:]|^)\/\/.*$/gm, "$1")
        .trim();
      return JSON.parse(cleanContent || "{}");
    } catch {
      return {};
    }
  };

  const writeSettings = (settings: any) => {
    const path = getSettingsPath();
    writeFileSync(path, JSON.stringify(settings, null, 2), "utf-8");
  };

  // --- Command: /extensions ---
  pi.registerCommand("extensions", {
    description: "List available and active extensions",
    handler: async (_args, ctx) => {
      const dir = getExtensionsDir();
      if (!existsSync(dir)) {
        ctx.ui.notify(`Directory not found: ${dir}`, "error");
        return;
      }

      try {
        const files = readdirSync(dir).filter(f => f.endsWith(".ts"));
        const settings = readSettings();
        const activeList = Array.isArray(settings.extensions) ? settings.extensions : [];
        
        const nameList = files.map(f => f.replace(/\.ts$/, ""));
        const maxLen = Math.max(...nameList.map(n => n.length), 0);
        
        const lines = files.map((f, i) => {
          const name = nameList[i];
          const isActive = activeList.some((p: string) => p.endsWith(f));
          const paddedName = name.padEnd(maxLen + 4, " ");
          return `  ${paddedName}${isActive ? "🟢 (active)" : "⚪ (inactive)"}`;
        }).join("\n");

        await pi.sendMessage({
          customType: "extensions",
          content: `Available extensions:\n${lines}`,
          display: true,
        }, {
          triggerTurn: false,
        });
      } catch (err: any) {
        ctx.ui.notify(`Failed to list extensions: ${err.message}`, "error");
      }
    }
  });

  // --- Command: /load <name> ---
  pi.registerCommand("load", {
    description: "Load a local extension: /load <name>",
    getArgumentCompletions: (prefix: string) => {
      const dir = getExtensionsDir();
      if (!existsSync(dir)) return null;
      try {
        const files = readdirSync(dir)
          .filter(f => f.endsWith(".ts"))
          .map(f => f.replace(/\.ts$/, ""));
        const items = files.map(f => ({ value: f, label: f }));
        const filtered = items.filter(i => i.value.toLowerCase().startsWith(prefix.toLowerCase()));
        return filtered.length > 0 ? filtered : null;
      } catch {
        return null;
      }
    },
    handler: async (args, ctx) => {
      const name = args.trim();
      if (!name) {
        ctx.ui.notify("Usage: /load <extension-name>", "error");
        return;
      }

      const fileName = name.endsWith(".ts") ? name : `${name}.ts`;
      const fullPath = join(getExtensionsDir(), fileName);
      if (!existsSync(fullPath)) {
        ctx.ui.notify(`Extension not found: ${fileName} in ~/.pi/extensions`, "error");
        return;
      }

      try {
        const settings = readSettings();
        if (!Array.isArray(settings.extensions)) {
          settings.extensions = [];
        }

        const extensionPath = `~/.pi/extensions/${fileName}`;
        if (!settings.extensions.includes(extensionPath)) {
          settings.extensions.push(extensionPath);
          writeSettings(settings);
          ctx.ui.notify(`Enabling ${name} in settings.json...`, "info");
        }

        // Trigger native hot-reload
        await ctx.reload();
        ctx.ui.notify(`Loaded extension: ${name}`, "success");
      } catch (err: any) {
        ctx.ui.notify(`Failed to load "${name}": ${err.message}`, "error");
      }
    }
  });

  // --- Command: /unload <name> ---
  pi.registerCommand("unload", {
    description: "Unload a local extension: /unload <name>",
    getArgumentCompletions: (prefix: string) => {
      const settings = readSettings();
      const activeList: string[] = Array.isArray(settings.extensions) ? settings.extensions : [];
      const items = activeList.map(p => {
        const name = p.split("/").pop()?.replace(/\.ts$/, "") || p;
        return { value: name, label: name };
      });
      const filtered = items.filter(i => i.value.toLowerCase().startsWith(prefix.toLowerCase()));
      return filtered.length > 0 ? filtered : null;
    },
    handler: async (args, ctx) => {
      const name = args.trim();
      if (!name) {
        ctx.ui.notify("Usage: /unload <extension-name>", "error");
        return;
      }

      const fileName = name.endsWith(".ts") ? name : `${name}.ts`;
      const extensionPath = `~/.pi/extensions/${fileName}`;

      try {
        const settings = readSettings();
        if (Array.isArray(settings.extensions) && settings.extensions.includes(extensionPath)) {
          settings.extensions = settings.extensions.filter((p: string) => p !== extensionPath);
          writeSettings(settings);
          ctx.ui.notify(`Disabling ${name} in settings.json...`, "info");
        } else {
          ctx.ui.notify(`Extension ${name} is not active.`, "error");
          return;
        }

        // Trigger native hot-reload
        await ctx.reload();
        ctx.ui.notify(`Unloaded extension: ${name}`, "success");
      } catch (err: any) {
        ctx.ui.notify(`Failed to unload "${name}": ${err.message}`, "error");
      }
    }
  });
}
