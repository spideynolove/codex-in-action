# Multi-Tool Migration: Repos Research

Companion to `multi-tool-migration-playbook.md`. Documents what was found, what's worth using, and what to search for next.

---

## What's already installed / available

### obra/superpowers (via ~/.qwen/superpowers)
**Source**: `https://github.com/obra/superpowers`  
**Version**: 5.0.1  
**What it covers**: Gemini CLI, Codex, OpenCode, Claude Code — multi-platform skills library.  
Contains:
- 14 workflow skills (TDD, debugging, git worktrees, brainstorming, etc.)
- `gemini-extension.json` → installs via `gemini extensions install`
- `.claude-plugin/plugin.json` → installs in Claude Code
- `.codex/INSTALL.md` → Codex bootstrap
- `.opencode/plugins` → OpenCode plugin structure (design in progress)
- `GEMINI.md` → `@./skills/using-superpowers/SKILL.md` (auto-injected)

**Best use**: Install as Gemini extension first (`gemini extensions install <dir>`). All 14 skills immediately available. Then layer personal skills on top.

---

### mksglu/context-mode (via ~/.claude/plugins and ~/.npm/_npx/.../context-mode)
**Source**: `https://github.com/mksglu/context-mode`  
**What it covers**: Claude Code, OpenClaw, Gemini, Qwen (adapters in `build/adapters/`)  
Contains:
- `configs/openclaw/openclaw.json` → ready-to-use OpenClaw plugin config
- `build/adapters/openclaw/` → OpenClaw adapter implementation
- `.openclaw-plugin/openclaw.plugin.json` → OpenClaw plugin manifest
- Gemini + Qwen adapters (check `build/adapters/`)

**Best use**: Copy `configs/openclaw/openclaw.json` to `~/.openclaw/openclaw.json` immediately after installing OpenClaw. Adapter is already implemented.

---

### alirezarezvani/claude-skills
**Source**: `https://github.com/alirezarezvani/claude-skills`  
**What it covers**: 232+ skills, explicitly supports Claude Code, Codex, Gemini CLI, Cursor, and 8 more tools.  
Contains `scripts/convert.sh` — the mature multi-platform conversion shell.

**Best use**: Source of pre-converted skills for Gemini and Qwen. Also use convert.sh as CLI skeleton for batch SKILL.md migration.

---

### ariccb/sync-claude-skills-to-codex
**Source**: `https://github.com/ariccb/sync-claude-skills-to-codex`  
**What it covers**: Symlinks Claude Code skills into Codex (and likely Gemini/Qwen which share `~/.agents/skills/`).

**Best use**: Adapt the symlink approach — instead of Codex-only, target `~/.agents/skills/` which Gemini CLI already reads from.

---

## Tool-specific repos to search

### Gemini CLI

The tool already shares architecture with Claude Code. No dedicated converter needed.  
Search if needed: `gemini CLI skills hooks migration claude`

Key discovery: Gemini reads from `~/.agents/skills/` (confirmed — 7 skills already visible from Codex installation). This is the shared path — no separate Gemini skill dir needed.

---

### Qwen Code

Qwen Code is a fork of Gemini CLI (same command structure: `qwen hooks`, `qwen extensions`, `qwen mcp`).  
The superpowers package already supports it via the same GEMINI.md extension mechanism.

**Open question**: Does Qwen read `GEMINI.md` or `QWEN.md`? Check:
```bash
ls ~/.qwen/superpowers/  # already has GEMINI.md
qwen extensions list     # see what extension files Qwen loads
```

Repos to check for Qwen-specific migration:
- GitHub: `qwen code skills CLAUDE.md GEMINI.md`
- The `~/.qwen/superpowers/docs/plans/2025-11-22-opencode-support-design.md` already has opencode design (from obra/superpowers planning docs)

---

### OpenCode

**Not installed**. Install:
```bash
# Check: https://opencode.ai or https://github.com/sst/opencode
npm install -g opencode  # likely command
```

Key architecture points (from obra/superpowers design docs):
- Primary agents: Build (full access), Plan (read-only)
- Subagents via `@mention`
- JS/TS plugin with event hooks + custom tools API
- Config: `~/.config/opencode/opencode.json` or `~/.config/opencode/agent/`
- Skills: `~/.config/opencode/skills/superpowers/` (symlink to plugin dir)

**Top repo**: obra/superpowers — already has `.opencode/plugins` directory designed. Follow their OpenCode plugin structure.

---

### MiniMax CLI

**Source**: `https://github.com/MiniMax-AI/cli` · npm: `mmx-cli`  
**What it is**: Official MiniMax AI Platform CLI — media generation (text, image, video, speech, music, vision, web search). Not a coding agent; invoked BY agents via the `mmx` binary.  
**Config**: `~/.mmx/credentials.json` and `~/.mmx/config.json`

The repo ships `skill/SKILL.md` (440 lines, 14.3KB) — a comprehensive agent skill guide describing every `mmx` command, flags, and agent-safe patterns (`--non-interactive --quiet --output json`).

**Migration**: One command installs the skill into the shared agent pool:
```bash
npx skills add MiniMax-AI/cli -y -g  # → ~/.agents/skills/mmx-cli/SKILL.md
```
Gemini CLI and Codex both read `~/.agents/skills/` — no further steps needed.

**Note**: The `minimax-skills` Claude marketplace plugin (`~/.claude/plugins/marketplaces/minimax-skills/`) is a separate PPTX-focused package, unrelated to the official CLI. The PPTX skills (ppt-orchestra-skill, slide-making-skill, etc.) can still be extracted and installed independently if needed.

---

### OpenClaw

**Not installed**. Research findings:
- Website: `https://openclaw.ai` (referenced in `$schema`)
- CLI: `openclaw agent --local --agent main --message ... --json`
- Skills dir: `~/.openclaw/skills/`
- Plugin system: JSON-based (`openclaw.json`), not shell hooks

context-mode already has a complete OpenClaw integration:
- Plugin manifest: `.openclaw-plugin/openclaw.plugin.json`
- Adapter: `build/adapters/openclaw`
- Config: `configs/openclaw/openclaw.json`

**Top source for installing**: Check `https://openclaw.ai` for binary.  
**Top source for integration**: context-mode (already local in `~/.npm/_npx/`)

---

### Hermes-Agent

**Not found anywhere locally**. No config files, no binary, no local references.

Research directions:
1. Search GitHub: `hermes-agent cli OpenRouter` — likely an OpenRouter-backed wrapper using NousResearch Hermes models
2. Check if context-mode has an adapter: `ls ~/.npm/_npx/.../context-mode/build/adapters/`
3. Check cc-in-action-repo platform scripts: `ls ~/Documents/spideynolove/cc-in-action-repo/claude-code-settings/skills/skill-creator/scripts/platforms/`

**If Hermes-Agent = OpenRouter CLI with Hermes model**:
- Migration = API config only (set OpenRouter base URL + model ID)
- Skills: if it reads SKILL.md (common pattern), near 1:1 from `~/.agents/skills/`
- Hooks: check if it has a hook system or is stateless

**Provisional**: Do not start migration until the binary/repo is identified.

---

## Bottom Line

| Tool | Repos needed | Effort |
|---|---|---|
| Gemini CLI | obra/superpowers (already local), alirezarezvani/claude-skills | Low — mostly copy/symlink |
| Qwen Code | obra/superpowers (already local) | Low — hooks only gap |
| OpenCode | obra/superpowers (.opencode/ dir), sst/opencode | Medium — install + JS hooks |
| MiniMax | MiniMax-AI/skills (marketplace, already installed) | Minimal — extract skills |
| OpenClaw | context-mode (already local) | Low once installed |
| Hermes-Agent | Unknown | Blocked — identify tool first |

**Shared shortcut**: Everything that reads `~/.agents/skills/` (Gemini confirmed, Codex confirmed) gets the shared skills pool for free. Focus personal skill migration there first.
