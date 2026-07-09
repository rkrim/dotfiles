/**
 * Team — Multi-agent team framework for Pi
 *
 * Loads teams from ./teams.yaml and agents from ./agents/*.md.
 *
 * Commands:
 *   /teams            — list available teams
 *   /team <name>      — activate a team for the current session
 *   /team leave       — return to generic mode
 *   /agents           — list active team members
 *   /agent <name> <task> — one-shot delegation to a member
 *
 * Tools available in team mode:
 *   query_agents       — parallel research across multiple agents
 *   delegate_to_agent — single focused agent task
 *
 * Usage: pi -e extensions/team.ts
 */

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { Text, truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";
import { readFileSync, existsSync } from "fs";
import { join } from "path";
import { spawn } from "child_process";
import { applyExtensionDefaults } from "../themeMap.ts";

// ── Types ────────────────────────────────────────

interface Agent {
  name: string;
  description: string;
  expertise: string[];
  skills: string[];
  tools: string[];
  systemPrompt: string;
  file: string;
}

interface Team {
  name: string;
  description: string;
  leader: string;
  members: string[];
}

// ── Agent Grid States ───────────────────────────────────

interface AgentState {
  def: Agent;
  status: "idle" | "researching" | "done" | "error";
  question: string;
  elapsed: number;
  lastLine: string;
  queryCount: number;
  timer?: ReturnType<typeof setInterval>;
}

const EXPERT_COLORS: Record<string, { bg: string; br: string }> = {
  "personas":   { bg: "\x1b[48;2;20;30;75m",  br: "\x1b[38;2;70;110;210m"  }, // navy
  "agent":      { bg: "\x1b[48;2;20;30;75m",  br: "\x1b[38;2;70;110;210m"  }, // navy
  "config":     { bg: "\x1b[48;2;18;65;30m",  br: "\x1b[38;2;55;175;90m"   }, // forest
  "extensions": { bg: "\x1b[48;2;80;18;28m",  br: "\x1b[38;2;210;65;85m"   }, // crimson
  "ext":        { bg: "\x1b[48;2;80;18;28m",  br: "\x1b[38;2;210;65;85m"   }, // crimson
  "keybinding": { bg: "\x1b[48;2;50;22;85m",  br: "\x1b[38;2;145;80;220m"  }, // violet
  "prompt":     { bg: "\x1b[48;2;80;55;12m",  br: "\x1b[38;2;215;150;40m"  }, // amber
  "skill":      { bg: "\x1b[48;2;12;65;75m",  br: "\x1b[38;2;40;175;195m"  }, // teal
  "theme":      { bg: "\x1b[48;2;80;18;62m",  br: "\x1b[38;2;210;55;160m"  }, // rose
  "tui":        { bg: "\x1b[48;2;28;42;80m",  br: "\x1b[38;2;85;120;210m"  }, // slate
  "cli":        { bg: "\x1b[48;2;60;80;20m",  br: "\x1b[38;2;160;210;55m"  }, // olive/lime
  "lead":       { bg: "\x1b[48;2;40;40;40m",  br: "\x1b[38;2;180;180;180m" }, // gray
};

const FG_RESET = "\x1b[39m";
const BG_RESET = "\x1b[49m";

function displayName(name: string): string {
  let clean = name.toLowerCase();
  if (clean.startsWith("agent-pi-")) {
    clean = clean.slice("agent-pi-".length);
  } else if (clean.startsWith("agent-")) {
    clean = clean.slice("agent-".length);
  }
  
  if (clean === "extensions" || clean === "ext") return "Extensions Expert";
  if (clean === "personas") return "Personas Expert";
  if (clean === "agent") return "Agent Expert";
  if (clean === "keybinding") return "Keybinding Expert";
  if (clean === "config") return "Config Expert";
  if (clean === "prompt") return "Prompt Expert";
  if (clean === "skill") return "Skill Expert";
  if (clean === "theme") return "Theme Expert";
  if (clean === "tui") return "Tui Expert";
  if (clean === "cli") return "Cli Expert";
  if (clean === "lead") return "Pi Lead";
  
  return clean.split("-").map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(" ") + (clean.endsWith("expert") || clean.endsWith("lead") ? "" : " Expert");
}

function getAgentColors(name: string) {
  let clean = name.toLowerCase();
  if (clean.startsWith("agent-pi-")) {
    clean = clean.slice("agent-pi-".length);
  } else if (clean.startsWith("agent-")) {
    clean = clean.slice("agent-".length);
  }
  return EXPERT_COLORS[clean] || { bg: "", br: "" };
}

// ── Paths ────────────────────────────────────────

function projectAgentsDir(cwd: string): string {
  return join(cwd, "agents");
}

function globalAgentDir(): string {
  const home = process.env.HOME || process.env.USERPROFILE || "~";
  return join(home, ".pi", "agent");
}

function teamsFilePaths(cwd: string): string[] {
  const home = process.env.HOME || process.env.USERPROFILE || "~";
  return [
    join(cwd, "teams.yaml"),
    join(globalAgentDir(), "teams.yaml"),
    join(home, ".pi", "teams.yaml"),
  ];
}

function agentFilePaths(cwd: string, name: string): string[] {
  const file = name.endsWith(".md") ? name : `${name}.md`;
  const home = process.env.HOME || process.env.USERPROFILE || "~";
  return [
    join(projectAgentsDir(cwd), file),
    join(globalAgentDir(), "agents", file),
    join(home, ".pi", "agents", file),
  ];
}

// ── YAML subset parser ───────────────────────────

function parseScalar(value: string): string {
  value = value.trim();
  if (
    (value.startsWith('"') && value.endsWith('"')) ||
    (value.startsWith("'") && value.endsWith("'"))
  ) {
    return value.slice(1, -1);
  }
  return value;
}

function parseTeamsYaml(content: string): Record<string, Team> {
  const teams: Record<string, Team> = {};
  let teamKey: string | null = null;
  let lastKey: string | null = null;

  for (const rawLine of content.split("\n")) {
    const line = rawLine.split("#")[0];
    if (!line.trim()) continue;

    const spaces = line.length - line.trimStart().length;
    const trimmed = line.trim();

    if (spaces === 0 && trimmed === "teams:") {
      teamKey = null;
      lastKey = null;
      continue;
    }

    if (spaces === 2 && trimmed.endsWith(":") && !trimmed.includes(": ")) {
      teamKey = trimmed.slice(0, -1);
      teams[teamKey] = { name: "", description: "", leader: "", members: [] };
      lastKey = null;
      continue;
    }

    if (teamKey && (spaces === 4 || spaces === 6)) {
      if (trimmed.startsWith("- ")) {
        if (lastKey === "members") {
          teams[teamKey].members.push(trimmed.slice(2).trim());
        }
        continue;
      }

      const idx = trimmed.indexOf(":");
      if (idx > 0) {
        const key = trimmed.slice(0, idx).trim() as keyof Team;
        const value = trimmed.slice(idx + 1).trim();
        if (key === "members") {
          lastKey = key;
        } else {
          (teams[teamKey][key] as string) = parseScalar(value);
          lastKey = key;
        }
      }
    }
  }

  return teams;
}

// ── Agent parser ─────────────────────────────────

function parseAgentFrontmatter(text: string): Record<string, any> {
  const result: Record<string, any> = {};
  const lines = text.split("\n");
  let i = 0;

  while (i < lines.length) {
    const line = lines[i].split("#")[0];
    if (!line.trim()) {
      i++;
      continue;
    }

    const idx = line.indexOf(":");
    if (idx <= 0) {
      i++;
      continue;
    }

    const key = line.slice(0, idx).trim();
    const value = line.slice(idx + 1).trim();

    if (value === "") {
      i++;
      const baseIndent = line.length - line.trimStart().length;
      const items: string[] = [];
      while (i < lines.length) {
        const childRaw = lines[i];
        const childLine = childRaw.split("#")[0];
        if (!childLine.trim()) {
          i++;
          continue;
        }
        const childIndent = childLine.length - childLine.trimStart().length;
        if (childIndent <= baseIndent) break;
        const childTrimmed = childLine.trim();
        if (childTrimmed.startsWith("- ")) {
          items.push(childTrimmed.slice(2).trim().replace(/^["']|["']$/g, ""));
          i++;
        } else {
          break;
        }
      }
      result[key] = items;
    } else {
      result[key] = parseScalar(value);
      i++;
    }
  }

  return result;
}

function parseAgentFile(filePath: string): Agent | null {
  try {
    const raw = readFileSync(filePath, "utf-8");
    const match = raw.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
    if (!match) return null;

    const front = parseAgentFrontmatter(match[1]);
    if (!front.name) return null;

    const tools = Array.isArray(front.tools)
      ? (front.tools as string[])
      : (front.tools || "").split(",").map((s: string) => s.trim()).filter(Boolean);

    return {
      name: front.name as string,
      description: (front.description as string) || "",
      expertise: Array.isArray(front.expertise) ? (front.expertise as string[]) : [],
      skills: Array.isArray(front.skills) ? (front.skills as string[]) : [],
      tools,
      systemPrompt: match[2].trim(),
      file: filePath,
    };
  } catch {
    return null;
  }
}

// ── Loaders ──────────────────────────────────────

function loadTeams(cwd: string): Record<string, Team> {
  for (const path of teamsFilePaths(cwd)) {
    if (existsSync(path)) {
      try {
        return parseTeamsYaml(readFileSync(path, "utf-8"));
      } catch (err) {
        console.error(`[team] failed to parse ${path}:`, err);
      }
    }
  }
  return {};
}

function loadAgent(cwd: string, name: string): Agent | null {
  for (const path of agentFilePaths(cwd, name)) {
    if (existsSync(path)) {
      return parseAgentFile(path);
    }
  }
  return null;
}

// ── Agent subprocess runner ──────────────────────

// ── Main extension ───────────────────────────────

export default function (pi: ExtensionAPI, ctx?: ExtensionContext) {
  let activeTeamName: string | null = null;
  const agentStates = new Map<string, AgentState>();
  let gridCols = 3;
  let widgetCtx: ExtensionContext | undefined;

  function renderCard(state: AgentState, colWidth: number, theme: any): string[] {
    const w = colWidth - 2;
    const truncate = (s: string, max: number) => s.length > max ? s.slice(0, max - 3) + "..." : s;

    const statusColor = state.status === "idle" ? "dim"
      : state.status === "researching" ? "accent"
      : state.status === "done" ? "success" : "error";
    const statusIcon = state.status === "idle" ? "○"
      : state.status === "researching" ? "◉"
      : state.status === "done" ? "✓" : "✗";

    const name = displayName(state.def.name);
    
    const statusStr = `${statusIcon} ${state.status}`;
    const timeStr = state.status !== "idle" ? ` ${Math.round(state.elapsed / 1000)}s` : "";
    const queriesStr = state.queryCount > 0 ? ` (${state.queryCount})` : "";
    const statusRight = statusStr + timeStr + queriesStr;
    const statusRightVisible = statusRight.length;

    const innerW = w - 2; // Subtract border paddings
    const maxNameW = Math.max(5, innerW - statusRightVisible - 2);
    const truncatedName = truncate(name, maxNameW);
    const nameVisible = truncatedName.length;

    const nameStr = theme.fg("accent", theme.bold(truncatedName));
    const statusLine = theme.fg(statusColor, statusRight);
    
    const padLen = Math.max(1, innerW - nameVisible - statusRightVisible);
    const topRowContent = nameStr + " ".repeat(padLen) + statusLine;

    const workRaw = state.question || state.def.description;
    const workText = truncate(workRaw, Math.min(50, w - 1));
    const workLine = theme.fg("muted", workText);
    const workVisible = workText.length;

    const lastRaw = state.lastLine || "";
    const lastText = truncate(lastRaw, Math.min(50, w - 1));
    const lastLineRendered = lastText ? theme.fg("dim", lastText) : theme.fg("dim", "—");
    const lastVisible = lastText ? lastText.length : 1;

    const colors = getAgentColors(state.def.name);
    const bg  = colors.bg;
    const br  = colors.br;
    const bgr = bg ? BG_RESET : "";
    const fgr = br ? FG_RESET : "";

    const bord = (s: string) => bg + br + s + bgr + fgr;

    const top = "┌" + "─".repeat(w) + "┐";
    const bot = "└" + "─".repeat(w) + "┘";

    const border = (content: string, visLen: number) => {
      const pad = " ".repeat(Math.max(0, w - visLen));
      return bord("│") + bg + content + bg + pad + bgr + bord("│");
    };

    return [
      bord(top),
      border(" " + topRowContent + " ", w),
      border(" " + workLine, 1 + workVisible),
      border(" " + lastLineRendered, 1 + lastVisible),
      bord(bot),
    ];
  }

  function updateWidget() {
    if (!widgetCtx) return;

    if (!activeTeamName) {
      widgetCtx.ui.setWidget("pi-pi-grid", undefined);
      return;
    }

    widgetCtx.ui.setWidget("pi-pi-grid", (_tui: any, theme: any) => {
      return {
        render(width: number): string[] {
          if (agentStates.size === 0) {
            return ["", theme.fg("dim", "  No agents loaded in the active team.")];
          }

          const cols = Math.min(gridCols, agentStates.size);
          const gap = 1;
          
          // Safety margin of 2 characters total (1 on left, 1 on right)
          const innerWidth = width - 2;
          const colWidth = Math.max(15, Math.floor((innerWidth - gap * (cols - 1)) / cols));
          
          const gridWidth = colWidth * cols + gap * (cols - 1);
          const leftMargin = Math.max(0, Math.floor((width - gridWidth) / 2));
          const marginStr = " ".repeat(leftMargin);

          const allAgents = Array.from(agentStates.values());
          const lines: string[] = [""]; // top margin

          for (let i = 0; i < allAgents.length; i += cols) {
            const rowAgents = allAgents.slice(i, i + cols);
            const cards = rowAgents.map(e => renderCard(e, colWidth, theme));
            const cardHeight = cards[0].length;

            while (cards.length < cols) {
              cards.push(Array(cardHeight).fill(" ".repeat(colWidth)));
            }

            for (let line = 0; line < cardHeight; line++) {
              lines.push(marginStr + cards.map(card => card[line] || "").join(" ".repeat(gap)));
            }
          }

          return lines;
        },
        invalidate() {},
      };
    });
  }

  async function queryAgent(
    cwd: string,
    agentName: string,
    task: string,
    model: string,
    maxOutput = 12000,
  ): Promise<{ output: string; exitCode: number; elapsed: number }> {
    const agent = loadAgent(cwd, agentName);
    if (!agent) {
      return { output: `Agent "${agentName}" not found.`, exitCode: 1, elapsed: 0 };
    }

    const key = agentName.toLowerCase();
    const state = agentStates.get(key);

    if (state) {
      state.status = "researching";
      state.question = task;
      state.elapsed = 0;
      state.lastLine = "";
      state.queryCount++;
      updateWidget();
    }

    const startTime = Date.now();
    let timer: ReturnType<typeof setInterval> | undefined;

    if (state) {
      timer = setInterval(() => {
        state.elapsed = Date.now() - startTime;
        updateWidget();
      }, 1000);
    }

    const textChunks: string[] = [];

    const args = [
      "--mode", "json",
      "-p",
      "--no-session",
      "--no-extensions",
      "--model", model,
      "--tools", agent.tools.join(","),
      "--thinking", "off",
      "--append-system-prompt", agent.systemPrompt,
      task,
    ];

    return new Promise((resolve) => {
      const proc = spawn("pi", args, {
        stdio: ["ignore", "pipe", "pipe"],
        env: { ...process.env },
        cwd,
      });

      let buffer = "";

      proc.stdout!.setEncoding("utf-8");
      proc.stdout!.on("data", (chunk: string) => {
        buffer += chunk;
        const lines = buffer.split("\n");
        buffer = lines.pop() || "";
        for (const line of lines) {
          if (!line.trim()) continue;
          try {
            const event = JSON.parse(line);
            if (event.type === "message_update") {
              const delta = event.assistantMessageEvent;
              if (delta?.type === "text_delta") {
                textChunks.push(delta.delta || "");
                if (state) {
                  const full = textChunks.join("");
                  const last = full.split("\n").filter((l: string) => l.trim()).pop() || "";
                  state.lastLine = last;
                  updateWidget();
                }
              }
            }
          } catch {}
        }
      });

      proc.stderr!.setEncoding("utf-8");
      proc.stderr!.on("data", () => {});

      proc.on("close", (code) => {
        if (buffer.trim()) {
          try {
            const event = JSON.parse(buffer);
            if (event.type === "message_update") {
              const delta = event.assistantMessageEvent;
              if (delta?.type === "text_delta") textChunks.push(delta.delta || "");
            }
          } catch {}
        }

        if (timer) {
          clearInterval(timer);
        }

        if (state) {
          state.elapsed = Date.now() - startTime;
          state.status = code === 0 ? "done" : "error";
          updateWidget();
        }

        const full = textChunks.join("");
        const truncated = full.length > maxOutput
          ? full.slice(0, maxOutput) + "\n\n... [truncated — ask follow-up for more]"
          : full;

        resolve({
          output: truncated,
          exitCode: code ?? 1,
          elapsed: Date.now() - startTime,
        });
      });

      proc.on("error", (err) => {
        if (timer) {
          clearInterval(timer);
        }
        if (state) {
          state.status = "error";
          updateWidget();
        }
        resolve({
          output: `Error spawning agent: ${err.message}`,
          exitCode: 1,
          elapsed: Date.now() - startTime,
        });
      });
    });
  }

  const isTeamMode = () => activeTeamName !== null;

  pi.on("before_agent_start", async (_event, ctx) => {
    if (!activeTeamName) return;
    const teams = loadTeams(ctx.cwd);
    const team = teams[activeTeamName];
    if (!team) return;

    const leader = loadAgent(ctx.cwd, team.leader);
    if (!leader) return;

    const memberCatalog = team.members
      .map((name) => loadAgent(ctx.cwd, name))
      .filter((a): a is Agent => Boolean(a))
      .map((m) => `- ${m.name}: ${m.description}\n  expertise: ${m.expertise.join(", ")}\n  skills: ${m.skills.join(", ")}`)
      .join("\n");

    const systemPrompt = `${leader.systemPrompt}\n\n## Active Team Context\n\nYou are currently leading the **${team.name}**: ${team.description}\n\n## Team Members\n\n${memberCatalog}\n\n## Your Tools\n\n- \`query_agents\`: call multiple agents in parallel for research.\n- \`delegate_to_agent\`: call one agent for a focused task.\n\nYou are the only one who writes files. Agents only return research or focused contributions.`;

    return { systemPrompt };
  });

  const init = (ctx: ExtensionContext) => {
    applyExtensionDefaults(import.meta.url, ctx);
    widgetCtx = ctx;
    if (activeTeamName) {
      const teams = loadTeams(ctx.cwd);
      const team = teams[activeTeamName];
      if (team) {
        agentStates.clear();
        for (const memberName of team.members) {
          const agent = loadAgent(ctx.cwd, memberName);
          if (agent) {
            agentStates.set(agent.name.toLowerCase(), {
              def: agent,
              status: "idle",
              question: "",
              elapsed: 0,
              lastLine: "",
              queryCount: 0,
            });
          }
        }
        ctx.ui.setStatus("team", `Team: ${team.name}`);
        updateWidget();

        ctx.ui.setFooter((_tui, theme, _footerData) => ({
          dispose: () => {},
          invalidate() {},
          render(width: number): string[] {
            if (!activeTeamName) return [];
            const model = ctx.model?.id || "no-model";
            const usage = ctx.getContextUsage();
            const pct = usage ? usage.percent : 0;
            const filled = Math.round(pct / 10);
            const bar = "#".repeat(filled) + "-".repeat(10 - filled);

            const active = Array.from(agentStates.values()).filter(e => e.status === "researching").length;
            const done = Array.from(agentStates.values()).filter(e => e.status === "done").length;

            const left = theme.fg("dim", ` ${model}`) +
              theme.fg("muted", " · ") +
              theme.fg("accent", `Team: ${activeTeamName}`);
            const mid = active > 0
              ? theme.fg("accent", ` ◉ ${active} researching`)
              : done > 0
              ? theme.fg("success", ` ✓ ${done} done`)
              : "";
            const right = theme.fg("dim", `[${bar}] ${Math.round(pct)}% `);
            const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(mid) - visibleWidth(right)));

            return [truncateToWidth(left + mid + pad + right, width)];
          },
        }));
      }
    }

  };

  pi.on("session_start", async (_event, context) => {
    init(context);
  });

  if (ctx) {
    init(ctx);
  }

  // Available to both modes:

  pi.registerCommand("teams", {
    description: "List available teams",
    handler: async (_args, ctx) => {
      const teams = loadTeams(ctx.cwd);
      const teamEntries = Object.entries(teams);
      if (teamEntries.length === 0) {
        await pi.sendMessage({
          customType: "teams",
          content: "No teams found in teams.yaml",
          display: true,
        }, {
          triggerTurn: false,
        });
        return;
      }

      const maxKeyLen = Math.max(...teamEntries.map(([key]) => key.length), 0);
      const lines = teamEntries.map(([key, t]) => {
        const isActive = (key === activeTeamName);
        const paddedKey = key.padEnd(maxKeyLen + 4, " ");
        const status = isActive ? "🟢 (active)  " : "⚪ (inactive)  ";
        return `  ${paddedKey}${status}${t.name} — ${t.description}`;
      }).join("\n");

      await pi.sendMessage({
        customType: "teams",
        content: `Available teams:\n${lines}`,
        display: true,
      }, {
        triggerTurn: false,
      });
    },
  });

  pi.registerCommand("team", {
    description: "Activate a team (or leave): /team <name> | /team leave",
    handler: async (args, ctx) => {
      const arg = args.trim();
      widgetCtx = ctx;

      if (arg === "leave" || arg === "exit" || arg === "reset") {
        activeTeamName = null;
        agentStates.clear();
        if (typeof pi.setActiveTools === "function") {
          pi.setActiveTools([]); // reset to defaults
        }
        ctx.ui.setStatus("team", "");
        ctx.ui.setFooter(undefined);
        updateWidget();
        ctx.ui.notify("Left team mode. Next turn uses the generic prompt.", "info");
        return;
      }

      if (!arg) {
        ctx.ui.notify("Usage: /team <name> or /team leave", "error");
        return;
      }

      const teams = loadTeams(ctx.cwd);
      const team = teams[arg];
      if (!team) {
        ctx.ui.notify(`Team "${arg}" not found. Available: ${Object.keys(teams).join(", ") || "none"}`, "error");
        return;
      }

      const leader = loadAgent(ctx.cwd, team.leader);
      if (!leader) {
        ctx.ui.notify(`Leader agent "${team.leader}" not found.`, "error");
        return;
      }

      activeTeamName = arg;
      const teamTools = [...leader.tools, "query_agents", "delegate_to_agent"];
      if (typeof pi.setActiveTools === "function") {
        pi.setActiveTools(teamTools);
      }

      agentStates.clear();
      for (const memberName of team.members) {
        const agent = loadAgent(ctx.cwd, memberName);
        if (agent) {
          agentStates.set(agent.name.toLowerCase(), {
            def: agent,
            status: "idle",
            question: "",
            elapsed: 0,
            lastLine: "",
            queryCount: 0,
          });
        }
      }

      ctx.ui.setStatus("team", `Team: ${team.name}`);
      updateWidget();

      ctx.ui.setFooter((_tui, theme, _footerData) => ({
        dispose: () => {},
        invalidate() {},
        render(width: number): string[] {
          if (!activeTeamName) return [];
          const model = ctx.model?.id || "no-model";
          const usage = ctx.getContextUsage();
          const pct = usage ? usage.percent : 0;
          const filled = Math.round(pct / 10);
          const bar = "#".repeat(filled) + "-".repeat(10 - filled);

          const active = Array.from(agentStates.values()).filter(e => e.status === "researching").length;
          const done = Array.from(agentStates.values()).filter(e => e.status === "done").length;

          const left = theme.fg("dim", ` ${model}`) +
            theme.fg("muted", " · ") +
            theme.fg("accent", `Team: ${activeTeamName}`);
          const mid = active > 0
            ? theme.fg("accent", ` ◉ ${active} researching`)
            : done > 0
            ? theme.fg("success", ` ✓ ${done} done`)
            : "";
          const right = theme.fg("dim", `[${bar}] ${Math.round(pct)}% `);
          const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(mid) - visibleWidth(right)));

          return [truncateToWidth(left + mid + pad + right, width)];
        },
      }));

      const expertNames = Array.from(agentStates.values()).map(s => displayName(s.def.name)).join(", ");
      ctx.ui.notify(
        `Team activated: ${team.name} — ${agentStates.size} experts loaded: ${expertNames}\n\n` +
        `/agents           List team members and status\n` +
        `/agents-grid N    Set grid columns (1-5)\n\n` +
        `The next message will use the leader's system prompt and tools.`,
        "info",
      );
    },
  });

  pi.registerCommand("experts", {
    description: "List available team members and their status",
    handler: async (_args, ctx) => {
      widgetCtx = ctx;
      if (!activeTeamName) {
        ctx.ui.notify("No active team. Use /team <name> first.", "error");
        return;
      }
      const lines = Array.from(agentStates.values())
        .map(s => `${displayName(s.def.name)} (${s.status}, queries: ${s.queryCount}): ${s.def.description}`)
        .join("\n");
      await pi.sendMessage({
        customType: "experts",
        content: lines || "No active team members",
        display: true,
      }, {
        triggerTurn: false,
      });
    },
  });

  pi.registerCommand("experts-grid", {
    description: "Set agent grid columns: /experts-grid <1-5>",
    handler: async (args, ctx) => {
      widgetCtx = ctx;
      const n = parseInt(args?.trim() || "", 10);
      if (n >= 1 && n <= 5) {
        gridCols = n;
        ctx.ui.notify(`Grid set to ${gridCols} columns`, "info");
        updateWidget();
      } else {
        ctx.ui.notify("Usage: /experts-grid <1-5>", "error");
      }
    },
  });

  pi.registerCommand("agents-grid", {
    description: "Set agent grid columns: /agents-grid <1-5>",
    handler: async (args, ctx) => {
      widgetCtx = ctx;
      const n = parseInt(args?.trim() || "", 10);
      if (n >= 1 && n <= 5) {
        gridCols = n;
        ctx.ui.notify(`Grid set to ${gridCols} columns`, "info");
        updateWidget();
      } else {
        ctx.ui.notify("Usage: /agents-grid <1-5>", "error");
      }
    },
  });

  // Team-mode tools:

  pi.registerTool({
    name: "query_agents",
    label: "Query Agents",
    description:
      "Query multiple agents in parallel. Pass a list of agent names and a single task or question. " +
      "All agents run simultaneously and their results are returned together. " +
      "(Only useful inside an active team session.)",
    parameters: Type.Object({
      agents: Type.Array(Type.String({ description: "Agent names to query" }), {
        description: "List of agent names",
      }),
      task: Type.String({ description: "Task or question to send to all agents" }),
    }),

    async execute(_toolCallId, params, _signal, onUpdate, ctx) {
      if (!activeTeamName) {
        return { content: [{ type: "text", text: "No active team. Use /team <name> first." }] };
      }

      const { agents, task } = params as { agents: string[]; task: string };
      const model = ctx.model
        ? `${ctx.model.provider}/${ctx.model.id}`
        : "openrouter/google/gemini-3-flash-preview";

      if (agents.length === 0) {
        return { content: [{ type: "text", text: "No agents specified." }] };
      }

      if (onUpdate) {
        onUpdate({
          content: [{ type: "text", text: `Querying ${agents.length} agents in parallel...` }],
        });
      }

      const settled = await Promise.allSettled(
        agents.map(async (name) => {
          const result = await queryAgent(ctx.cwd, name, task, model);
          return { name, ...result };
        }),
      );

      const sections = settled.map((s, i) => {
        const name = agents[i];
        if (s.status === "fulfilled") {
          const icon = s.value.exitCode === 0 ? "✓" : "✗";
          return `## [${icon}] ${name} (${Math.round(s.value.elapsed / 1000)}s)\n\n${s.value.output}`;
        }
        return `## [✗] ${name}\n\nError: ${s.reason}`;
      });

      return {
        content: [{ type: "text", text: sections.join("\n\n---\n\n") }],
        details: { agents, task, results: settled },
      };
    },
  });

  pi.registerTool({
    name: "delegate_to_agent",
    label: "Delegate to Agent",
    description: "Delegate a focused, single-agent task. Useful when only one specific skill is needed.",
    parameters: Type.Object({
      agent: Type.String({ description: "Agent name" }),
      task: Type.String({ description: "Task or question" }),
    }),

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (!activeTeamName) {
        return { content: [{ type: "text", text: "No active team. Use /team <name> first." }] };
      }

      const { agent, task } = params as { agent: string; task: string };
      const model = ctx.model
        ? `${ctx.model.provider}/${ctx.model.id}`
        : "openrouter/google/gemini-3-flash-preview";

      const result = await queryAgent(ctx.cwd, agent, task, model);
      const icon = result.exitCode === 0 ? "✓" : "✗";

      return {
        content: [{ type: "text", text: `## [${icon}] ${agent} (${Math.round(result.elapsed / 1000)}s)\n\n${result.output}` }],
        details: { agent, task, result },
      };
    },
  });

  // Team-mode only commands:

  pi.registerCommand("agents", {
    description: "List active team members",
    handler: async (_args, ctx) => {
      if (!activeTeamName) {
        ctx.ui.notify("No active team. Use /team <name> first.", "error");
        return;
      }

      const teams = loadTeams(ctx.cwd);
      const team = teams[activeTeamName];
      if (!team) {
        ctx.ui.notify(`Active team "${activeTeamName}" not found.`, "error");
        return;
      }

      const leader = loadAgent(ctx.cwd, team.leader);
      const members = team.members
        .map((name) => {
          const agent = loadAgent(ctx.cwd, name);
          return agent
            ? `${agent.name}: ${agent.description}`
            : `${name}: (agent file missing)`;
        })
        .join("\n");

      await pi.sendMessage({
        customType: "agents",
        content: `Team: ${team.name}\nLeader: ${leader ? leader.name : team.leader + " (missing)"}\nMembers:\n${members}`,
        display: true,
      }, {
        triggerTurn: false,
      });
    },
  });

  pi.registerCommand("agent", {
    description: "Ask a specific agent: /agent <name> <task>",
    handler: async (args, ctx) => {
      if (!activeTeamName) {
        ctx.ui.notify("No active team. Use /team <name> first.", "error");
        return;
      }

      const trimmed = args.trim();
      const firstSpace = trimmed.indexOf(" ");
      if (firstSpace <= 0) {
        ctx.ui.notify("Usage: /agent <name> <task>", "error");
        return;
      }

      const agentName = trimmed.slice(0, firstSpace).trim();
      const task = trimmed.slice(firstSpace + 1).trim();

      const teams = loadTeams(ctx.cwd);
      const team = teams[activeTeamName];
      if (!team) {
        ctx.ui.notify("Active team configuration not found.", "error");
        return;
      }

      const available = [team.leader, ...team.members];
      if (!available.includes(agentName)) {
        ctx.ui.notify(
          `Agent "${agentName}" is not part of team "${activeTeamName}". Available: ${available.join(", ")}`,
          "error",
        );
        return;
      }

      const model = ctx.model
        ? `${ctx.model.provider}/${ctx.model.id}`
        : "openrouter/google/gemini-3-flash-preview";

      ctx.ui.notify(`Asking ${agentName}...`, "info");
      const result = await queryAgent(ctx.cwd, agentName, task, model);
      ctx.ui.notify(
        `${agentName} ${result.exitCode === 0 ? "done" : "error"} (${Math.round(result.elapsed / 1000)}s)`,
        result.exitCode === 0 ? "success" : "error",
      );

      const preview = result.output.length > 500
        ? result.output.slice(0, 500) + "\n..."
        : result.output;
      ctx.ui.notify(`${agentName}:\n${preview}`, result.exitCode === 0 ? "info" : "error");
    },
  });
}
