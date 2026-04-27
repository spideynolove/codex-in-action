# Claude Code → Multi-Tool Migration Playbook

**Scope**: Gemini CLI, Qwen Code, OpenCode, MiniMax, OpenClaw, Hermes-Agent  
**Reference**: See `claude-to-codex-migration-playbook.md` for the Codex baseline this extends.

---

## Current ~/.claude Inventory

### Hooks (3 Python scripts)
| File | Trigger | Role |
|---|---|---|
| `hooks/dedup.py` | PreToolUse: Read\|Glob\|Grep\|WebFetch\|mcp__ | Duplicate tool guard |
| `hooks/crg-preread.py` | PreToolUse: Read | code-review-graph pre-read |
| `hooks/crg-session-start.py` | SessionStart | code-review-graph session init |
| _(inline)_ | PreToolUse: Bash | `rtk hook claude` (token saving) |
| _(inline)_ | PostToolUse: Edit\|Write\|Bash | `code-review-graph update --skip-flows` |

### Skills (10 personal)
`agents-refine`, `graphify`, `handoff`, `lightpanda`, `playwright`, `reddit2md`, `repomix`, `sequential-thinking`, `x2md`, `xia`

### Commands (9)
`check-github-ci`, `commit-message`, `design-patterns`, `e2e`, `explain-code`, `refactor`, `semantic-commit`, `token-efficient`, `xia-group`

### Plugins (marketplace)
`minimax-skills` (PPTX skills), `context-mode`, `openai-codex`, `hamel-review`, `ui-ux-pro-max-skill`

### Shared skills (already cross-tool via ~/.agents/skills/)
`code-review-graph`, `graphify`, `interactive-learning`, `playwright`, `repomix`, `rlm-workflow`, `sequential-thinking`

---

## Tool 1: Gemini CLI (v0.39.1) — NEAR 1:1

**Status**: Installed. Config: `~/.gemini/settings.json`. No hooks or commands configured yet.

### Architecture delta vs Claude Code

| Feature | Claude Code | Gemini CLI | Action |
|---|---|---|---|
| Instruction file | `CLAUDE.md` | `GEMINI.md` (set via `gemini-extension.json` `contextFileName`) | Create `~/.gemini/GEMINI.md` |
| Settings file | `~/.claude/settings.json` | `~/.gemini/settings.json` | **Hooks format is identical** — copy the `hooks` block |
| Skills path | `~/.claude/skills/` or `~/.agents/skills/` | `~/.agents/skills/` | Already shared — 7 skills visible |
| Commands | `~/.claude/commands/*.md` | `~/.gemini/commands/*.md` | Copy or symlink directory |
| MCP servers | `settings.json` `mcpServers` | `settings.json` `mcpServers` | 1:1 copy |
| Extensions | Plugin marketplace | `gemini-extension.json` in any dir | Install superpowers (already has gemini-extension.json in ~/.qwen/superpowers/) |
| StatusLine | claude-hud | Not supported | Drop |

### Hook conversion table (Gemini)

| Claude Code hook | Gemini equivalent | Action |
|---|---|---|
| PreToolUse: Read\|Glob\|Grep\|WebFetch\|mcp__ → dedup.py | PreToolUse: same matchers | 1:1 copy to `~/.gemini/settings.json` |
| PreToolUse: Read → crg-preread.py | PreToolUse: Read | 1:1 copy |
| PreToolUse: Bash → rtk hook claude | PreToolUse: Bash → `rtk hook gemini` | Change rtk target |
| PostToolUse: Edit\|Write\|Bash → crg update | PostToolUse: Edit\|Write\|Bash | 1:1 copy |
| SessionStart → crg-session-start.py | SessionStart | 1:1 copy |

### Skills gap

Personal skills in `~/.claude/skills/` not yet in `~/.agents/skills/`:
- `agents-refine`, `handoff`, `lightpanda`, `reddit2md`, `x2md`, `xia`

**Fix**: Symlink each into `~/.agents/skills/<name>` — Gemini reads from there automatically.

### Steps

```bash
# 1. Install superpowers extension (GEMINI.md + 14 skills)
gemini extensions install ~/Documents/spideynolove/codex-in-action/.codex-global-samples/... # or obra/superpowers

# 2. Create personal GEMINI.md
cat > ~/.gemini/GEMINI.md << 'EOF'
# Global instructions for Gemini CLI
# (mirror of CLAUDE.md — strip Claude-specific tool syntax)
EOF

# 3. Copy hooks block to ~/.gemini/settings.json
# Merge the hooks{} section from ~/.claude/settings.json into ~/.gemini/settings.json

# 4. Copy commands directory
ln -s ~/.claude/commands ~/.gemini/commands  # or cp -r

# 5. Symlink personal skills to shared path
for skill in agents-refine handoff lightpanda reddit2md x2md xia; do
  ln -s ~/.claude/skills/$skill ~/.agents/skills/$skill
done
```

---

## Tool 2: Qwen Code — NEAR 1:1

**Status**: Installed. Config: `~/.qwen/settings.json`. Superpowers already installed (14 skills, commands). No hooks configured.

### Architecture delta vs Claude Code

| Feature | Claude Code | Qwen Code | Action |
|---|---|---|---|
| Instruction file | `CLAUDE.md` | Unknown — check if `QWEN.md` or `GEMINI.md` | Verify via `qwen --help` or docs |
| Settings hooks | `~/.claude/settings.json` hooks | `~/.qwen/settings.json` hooks | **Same JSON format** — copy hooks block |
| Skills | `~/.agents/skills/` | Via extensions / same shared path | Check if Qwen reads `~/.agents/skills/` |
| Commands | `~/.claude/commands/` | `~/.qwen/commands/` | Copy or symlink |
| Extensions | Plugin marketplace | `qwen extensions` | Superpowers already installed |

### Qwen-specific notes

- Qwen already has superpowers: 14 skills (brainstorming, TDD, debugging, etc.)
- Already has commands: `brainstorm`, `execute-plan`, `write-plan`
- Has GEMINI.md in superpowers — likely Qwen reads it too (same codebase fork)
- `output-language.md` in `~/.qwen/` is Qwen-specific — no Claude equivalent

### Steps

```bash
# 1. Add hooks to ~/.qwen/settings.json (merge hooks block from Claude settings)

# 2. Copy personal commands
cp ~/.claude/commands/*.md ~/.qwen/commands/ 2>/dev/null || mkdir -p ~/.qwen/commands && cp ~/.claude/commands/*.md ~/.qwen/commands/

# 3. Verify skill discovery path
qwen skills list  # if this command exists

# 4. Create QWEN.md (or AGENTS.md — verify which Qwen uses)
```

---

## Tool 3: OpenCode — LOW EFFORT (direct converter exists!)

**Status**: Already installed: `~/.opencode/bin/opencode` v1.14.28. Architecture: JavaScript/TypeScript plugin with event hooks and custom tools API.

### NEW: Direct Converter Available

A direct converter exists that handles settings, agents, MCP, and skills:

```bash
# Install and run the converter
bunx oc-convert  # or: npx oc-convert

# Convert specific artifacts:
bunx oc-convert --settings ~/.claude/settings.json
bunx oc-convert --skills ~/.claude/skills
bunx oc-convert --mcp ~/.mcp.json
bunx oc-convert --output ~/.config/opencode/
```

- **Repo**: https://github.com/OpeOginni/oc-convert
- **What it converts**: settings.json → opencode.json, agents → .opencode/agent/, skills → .opencode/skills/, MCP → opencode MCP format

### Alternative: alirezarezvani/claude-skills converter

```bash
git clone https://github.com/alirezarezvani/claude-skills.git
cd claude-skills
./scripts/convert.sh --tool opencode
# Outputs to integrations/opencode/skills/
```

### Architecture delta vs Claude Code

| Feature | Claude Code | OpenCode | Action |
|---|---|---|---|
| Instruction file | `CLAUDE.md` | Read from plugin context injection | JS plugin injects into context |
| Config | `settings.json` (JSON) | `~/.config/opencode/opencode.json` | Different format |
| Skills | SKILL.md files | `~/.config/opencode/skills/<name>/SKILL.md` | SKILL.md format compatible |
| Hooks | Shell commands in settings | JS/TS event hooks in plugin | Rewrite as JS wrappers |
| Agents | Not native | `~/.config/opencode/agent/` custom agents | OpenCode-specific |
| Plugin system | Native marketplace | JS module entry point | Superpowers has `.opencode/plugins` design |

### OpenCode agents
- **Build** (default, full access) — equivalent to Claude's default mode
- **Plan** (read-only) — equivalent to plan mode
- **Subagents** — `@mention` invocation

### Hook conversion (OpenCode)

Shell hooks become JS event handlers in the plugin:

```typescript
// hooks.ts in the plugin
export const hooks = {
  onSessionStart: async () => { /* crg-session-start logic */ },
  onPreToolUse: async (tool, input) => {
    if (tool === 'bash') { /* rtk equivalent */ }
  },
  onPostToolUse: async (tool, output) => {
    if (['edit','write','bash'].includes(tool)) { /* crg update */ }
  }
}
```

### Steps

```bash
# 1. Install OpenCode
npm install -g opencode  # or check official install method

# 2. Copy/symlink skills (SKILL.md format is compatible)
mkdir -p ~/.config/opencode/skills
for skill in ~/.agents/skills/*/; do
  ln -s "$skill" ~/.config/opencode/skills/$(basename "$skill")
done

# 3. Install superpowers OpenCode plugin (obra/superpowers has .opencode/plugins/)

# 4. Rewrite hook scripts as JS event handlers in a plugin module
```

### Key source repo
**obra/superpowers** — already has `.opencode/plugins` directory in `~/.qwen/superpowers/`. Use as reference for plugin structure.

---

## Tool 4: MiniMax CLI (`mmx-cli`) — SKILL INSTALL

**Status**: Not installed. Official MiniMax AI Platform CLI. Not a coding agent — it is a **media generation tool** (text, image, video, speech, music, vision, web search) that agents call via the `mmx` binary.

**Repo**: `github.com/MiniMax-AI/cli` · npm: `mmx-cli` · binary: `mmx`  
**Config**: `~/.mmx/credentials.json` (OAuth) and `~/.mmx/config.json` (API key)

### What it is

| Capability | Command |
|---|---|
| Text chat | `mmx text chat --message "..."` (default model: MiniMax-M2.7) |
| Image generation | `mmx image "prompt"` |
| Video generation | `mmx video generate --prompt "..."` (async) |
| TTS / speech | `mmx speech synthesize --text "..." --out file.mp3` |
| Music generation | `mmx music generate --prompt "..."` |
| Vision / image understanding | `mmx vision photo.jpg` |
| Web search | `mmx search "query"` |
| Quota | `mmx quota` |

### Architecture delta vs Claude Code

| Feature | Claude Code | MiniMax CLI | Notes |
|---|---|---|---|
| Purpose | Coding agent | Media generation API wrapper | Different role — invoked BY agents |
| Instruction file | `CLAUDE.md` | n/a (not a coding agent) | No global instruction file |
| Hooks | settings.json lifecycle hooks | n/a | No hook system |
| Skills | SKILL.md files | `skill/SKILL.md` in repo (440 lines) | Describes how agents should call `mmx` |
| Config | `~/.claude/settings.json` | `~/.mmx/config.json` | API key storage |
| Agent flags | n/a | `--non-interactive --quiet --output json` | Always use in agent context |

### Migration: install the skill into shared pool

The repo ships a comprehensive `skill/SKILL.md` (14KB) covering all mmx commands. Install it once and every tool that reads `~/.agents/skills/` (Gemini, Codex) picks it up automatically.

```bash
# Install globally for all agents (drops into ~/.agents/skills/mmx-cli/)
npx skills add MiniMax-AI/cli -y -g

# Or manually
npm install -g mmx-cli
mmx auth login --api-key sk-xxxxx
mkdir -p ~/.agents/skills/mmx-cli
curl -o ~/.agents/skills/mmx-cli/SKILL.md \
  https://raw.githubusercontent.com/MiniMax-AI/cli/main/skill/SKILL.md
```

### Note on `minimax-skills` Claude plugin

The `minimax-skills` marketplace plugin in `~/.claude/plugins/marketplaces/minimax-skills/` is a **separate, unrelated package** providing PPTX generation skills (ppt-orchestra-skill, slide-making-skill, etc.). It is not the official MiniMax CLI. Both exist independently.

---

## Tool 5: OpenClaw — NEAR 1:1 (once installed)

**Status**: Not installed locally. Config format is well-defined. context-mode already has OpenClaw adapter and plugin config.

### Config format

```json
// ~/.openclaw/openclaw.json
{
  "$schema": "https://openclaw.ai/config.json",
  "plugins": {
    "entries": {
      "context-mode": { "enabled": true }
    },
    "slots": { "contextEngine": "context-mode" }
  }
}
```

### Skills format

Skills install to `~/.openclaw/skills/<name>/SKILL.md` — identical SKILL.md format.

### Architecture delta vs Claude Code

| Feature | Claude Code | OpenClaw | Action |
|---|---|---|---|
| Instruction file | `CLAUDE.md` | Unknown — check docs | Research |
| Skills | `~/.claude/skills/` or `~/.agents/skills/` | `~/.openclaw/skills/` | Copy SKILL.md (1:1 compatible) |
| Hooks | settings.json hooks | Plugin-based (JSON config) | context-mode plugin already covers context hook |
| Invocation | `claude` | `openclaw agent --local --agent main --message ... --json` | CLI wrapper |
| MCP | settings.json mcpServers | `openclaw.json` plugins | Different format, plugin-based |

### Hook note

OpenClaw has no direct shell lifecycle hooks (no PreToolUse/PostToolUse). The `context-mode` plugin already provides the context engine role. RTK and crg hooks would need to be shimmed via a wrapper script that calls openclaw.

### Steps

```bash
# 1. Install OpenClaw (check https://openclaw.ai for install)

# 2. Copy personal skills
mkdir -p ~/.openclaw/skills
for skill in ~/.agents/skills/*/; do
  cp -r "$skill" ~/.openclaw/skills/$(basename "$skill")
done

# 3. Configure context-mode plugin (config already exists in context-mode npm package)
cp ~/.npm/_npx/.../context-mode/configs/openclaw/openclaw.json ~/.openclaw/openclaw.json

# 4. Symlink MiniMax pptx skills too
```

### Key source
**context-mode** (already installed) has `configs/openclaw/` and `build/adapters/openclaw` — use as the integration layer.

---

## Tool 6: Hermes-Agent — RESEARCH NEEDED

**Status**: Not found locally. No config files, no binary. Likely an OpenRouter-backed agent CLI.

### Research directions

1. Search GitHub for `hermes-agent` CLI — potential matches:
   - NousResearch/hermes (model family, not a CLI)
   - An OpenRouter wrapper that uses Hermes models
   
2. Check if it follows the SKILL.md convention (many newer tools do)

3. Check if context-mode has a hermes-agent adapter:
   ```bash
   ls ~/.npm/_npx/.../context-mode/configs/ | grep hermes
   ls ~/.npm/_npx/.../context-mode/build/adapters/
   ```

4. If it's an OpenRouter API wrapper: the migration is API-level (swap model ID), not skill-level.

### Provisional direction

Until the tool is identified:
- Do not migrate until install is confirmed
- If SKILL.md-based: near 1:1 copy from `~/.agents/skills/`
- If API-only: no skill migration, just configure OpenRouter endpoint + Hermes model ID

---

## Conversion Principles (Cross-Tool Summary)

### Tier 1: Near 1:1 (Gemini, Qwen, OpenClaw)

These tools are Claude Code forks or use identical SKILL.md + settings.json patterns.

| Artifact | Claude Code | Target | Action |
|---|---|---|---|
| Instruction file | `CLAUDE.md` | `GEMINI.md` / `QWEN.md` / unknown | String-replace filename references |
| Hook scripts | `~/.claude/hooks/*.py` | Same scripts, new config reference | Update config path |
| Hook config | `settings.json` hooks block | `settings.json` hooks block (Gemini/Qwen) or JSON plugin (OpenClaw) | Copy or adapt format |
| Skills | `~/.claude/skills/<name>/SKILL.md` | Tool-specific skills dir | Copy SKILL.md (fully compatible) |
| Commands | `~/.claude/commands/*.md` | `~/.gemini/commands/` etc. | Copy (same markdown format) |
| MCP | settings.json mcpServers | settings.json mcpServers | 1:1 copy |

### Tier 2: Medium effort (OpenCode)

- SKILL.md content: compatible, copy directly
- Hooks: rewrite as JS/TS event handlers in plugin module
- Config: different JSON schema
- Best path: install obra/superpowers OpenCode plugin, then add personal hooks manually

### Tier 3: Skill content only (MiniMax)

- Extract SKILL.md files, install as standalone skills in other tools
- No CLI, no hook migration

### Tier 4: Research first (Hermes-Agent)

- Identify tool, check SKILL.md support, then classify into Tier 1/2/3

---

## Priority Order

1. **Gemini CLI** — installed, near 1:1, highest ROI. Blocks: create GEMINI.md, merge hooks to `~/.gemini/settings.json`, copy commands.
2. **Qwen Code** — installed, near 1:1. Already has superpowers. Blocks: merge hooks, copy personal commands.
3. **OpenCode** — not installed. Install first, then use obra/superpowers plugin.
4. **MiniMax** — extract PPTX skills to `~/.agents/skills/` (one-time copy).
5. **OpenClaw** — not installed. Install, then use context-mode adapter.
6. **Hermes-Agent** — research before any migration work.

---

## Reference Repos

| Repo | Use |
|---|---|
| `obra/superpowers` | Multi-tool skills (already in ~/.qwen/superpowers) — Gemini, Codex, OpenCode plugins |
| `alirezarezvani/claude-skills` | 232+ cross-platform skills including Gemini/Qwen converters |
| `padmilkhandelwal/convert-claude-to-codex-skill` | SKILL.md format normaliser (works for all SKILL.md-based tools) |
| `mksglu/context-mode` | OpenClaw adapter + Gemini/Qwen adapters already built |
| `ariccb/sync-claude-skills-to-codex` | Symlink approach — adapt for Gemini/Qwen |
