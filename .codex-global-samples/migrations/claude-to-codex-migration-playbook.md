# Claude Code to Codex Migration Playbook

This playbook captures the reusable method for moving Claude Code customizations into Codex. It is intentionally written as a process, because each Claude Code setup may have different skills, MCP servers, hooks, commands, plugins, and local scripts.

## Goal

Move useful Claude Code extensions into Codex without blindly copying everything.

The target Codex setup should be:

- small enough that Codex does not load unnecessary tools every turn
- explicit about what is native, what is skill-mediated, and what is ignored
- easy to audit from disk
- reversible when something turns out to be noisy or stale

## Core Philosophy

Do not ask "Can this Claude thing be copied into Codex?"

Ask:

1. What job does this thing do?
2. Does Codex already have a native feature for that job?
3. Does it need to be always available, or only used on demand?
4. Does registering it natively cost extra context, startup time, tool noise, or failure risk?
5. Can a skill call the same underlying CLI/MCP/script only when needed?

The usual best answer is:

| Claude item | Codex migration style |
|---|---|
| User behavior rules | Put in `~/.codex/AGENTS.md` |
| Frequently used safety automation | Convert to Codex hooks |
| Heavy or occasional MCP tools | Keep behind skills and mcporter |
| Lightweight must-have MCP tools | Consider native Codex MCP |
| Slash commands | Convert to skills or ignore |
| Claude-only plugins | Ignore unless they contain reusable scripts |
| Claude hooks | Convert by event and payload semantics |
| Claude skills | Normalize into `~/.agents/skills/<name>/SKILL.md` |

## Step 1: Inventory Claude Code

List the real files first.

Useful commands:

```bash
find ~/.claude -maxdepth 3 -type f \( -name 'settings.json' -o -name 'SKILL.md' -o -name '*.json' \) -print | sort
find ~/.claude/commands -maxdepth 1 -type f -print | sort
find ~/.claude/hooks -maxdepth 2 -type f -print | sort
```

Inspect hooks:

```bash
jq '{hooks, statusLine, enabledMcpjsonServers, disabledMcpjsonServers}' ~/.claude/settings.json
```

Classify each item by role:

| Role | Examples |
|---|---|
| Communication / behavior | `CLAUDE.md`, global instructions |
| Tool automation | `PreToolUse`, `PostToolUse`, `SessionStart` hooks |
| Token saving | RTK hook, compact command wrappers |
| Code intelligence | code-review-graph, Graphify, repo packers |
| Browser automation | Playwright, browser MCP, Lightpanda |
| Reasoning workflow | sequential-thinking, planning skills |
| Commands | slash commands |
| UI/plugin-only features | statusline, Claude HUD, context-mode |

## Step 2: Inventory Codex

Check what Codex already has.

```bash
sed -n '1,260p' ~/.codex/config.toml
codex mcp list
find ~/.codex -maxdepth 3 \( -type f -o -type l \) \( -name 'AGENTS.md' -o -name 'hooks.json' -o -name 'SKILL.md' -o -name '*.rules' \) -print | sort
find -L ~/.agents/skills -maxdepth 2 -type f -name 'SKILL.md' -print | sort
```

If you use mcporter:

```bash
sed -n '1,260p' ~/.mcporter/mcporter.json
npx mcporter list --json
```

Key distinction:

| Location | Meaning |
|---|---|
| `~/.codex/config.toml` `[mcp_servers.*]` | Native Codex MCP, always exposed to Codex |
| `~/.mcporter/mcporter.json` | MCPs available through CLI on demand |
| `~/.agents/skills/<name>/SKILL.md` | User skills Codex can discover |
| `~/.codex/skills/.system/*` | System skills |
| `~/.codex/hooks.json` | Codex lifecycle automation |
| `~/.codex/AGENTS.md` | Global operating instructions |

## Step 3: Decide Native MCP vs Skill-Mediated MCP

Use native Codex MCP only when the server should be first-class and available constantly.

Use skill-mediated MCP through mcporter when the tool is useful but should not be loaded all the time.

Decision table:

| Question | If yes | If no |
|---|---|---|
| Is this needed in most coding turns? | Consider native MCP | Use skill/mcporter |
| Does the model need tool schemas every session? | Native MCP may be worth it | Use skill/mcporter |
| Is it heavy, flaky, or rarely used? | Use skill/mcporter | Native MCP is acceptable |
| Is token saving a priority? | Prefer skill/mcporter | Native MCP is simpler |
| Is it just a CLI wrapper? | Prefer skill/CLI | Native MCP not needed |

Example native MCP removal:

```bash
codex mcp list
codex mcp remove sequential-thinking
codex mcp remove knowledge-graph
```

Example mcporter-backed MCP:

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "/home/hung/env/.venv/bin/python",
      "args": ["/home/hung/MCPs/sequential-thinking-mcp-v2/main.py"]
    }
  }
}
```

Example skill that uses mcporter:

```markdown
---
name: sequential-thinking
description: Structure complex reasoning using sequential-thinking through mcporter.
---

# Sequential Thinking

Use this skill for complex analysis, branching, and synthesis before implementation.

List tools:

```bash
npx mcporter list sequential-thinking --schema
```

Call a tool:

```bash
npx mcporter call sequential-thinking.start_session problem:"..." success_criteria:"..."
```
```

## Step 4: Convert Skills

Claude skills are usually portable, but normalize them.

Skill conversion checklist:

| Claude convention | Codex convention |
|---|---|
| `~/.claude/skills/<name>/SKILL.md` | `~/.agents/skills/<name>/SKILL.md` |
| References to `CLAUDE.md` | Replace with `AGENTS.md` |
| Claude-specific tools | Rewrite to shell, Codex tools, or mcporter calls |
| Native MCP tool assumptions | Rewrite as `npx mcporter call server.tool ...` if using token-saving pattern |
| Unknown frontmatter | Keep minimal `name` and `description` |

Minimal Codex skill shape:

```markdown
---
name: tool-name
description: Use when this workflow is needed. Mention the trigger and the tool access path.
---

# Tool Name

When to use this skill.

Preferred commands:

```bash
tool status
tool run
```

MCP access through mcporter:

```bash
npx mcporter list tool-name --schema
npx mcporter call tool-name.some_tool key=value
```
```

Reasoning:

- A skill is cheaper than native MCP for occasional tools.
- A skill can encode workflow, examples, and warnings.
- A skill can call CLI, mcporter, scripts, or local files without forcing every tool schema into every Codex session.

## Step 5: Convert Hooks by Semantics

Do not copy Claude Code hooks blindly. Convert by event meaning.

Start with the Claude hook table:

```bash
jq '.hooks' ~/.claude/settings.json
```

Map events:

| Claude Code event | Codex target | Notes |
|---|---|---|
| `SessionStart` | `SessionStart` | Usually portable |
| `PreToolUse` | `PreToolUse` | Match Codex tool names and payload shape |
| `PostToolUse` | `PostToolUse` | Good for graph updates or audit |
| `UserPromptSubmit` | `UserPromptSubmit` | Useful for prompt guards |
| `Stop` | `Stop` | Useful for final checks |
| `SubagentStop` | No direct equivalent | Drop or warn |
| `Notification` | No direct equivalent | Drop |
| `PreCompact` | No direct equivalent | Drop |

Codex hook config shape:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|apply_patch|Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "python3 /absolute/path/to/hook.py",
            "timeout": 5,
            "statusMessage": "Checking tool call"
          }
        ]
      }
    ]
  }
}
```

Important method:

1. Preserve the underlying useful script if possible.
2. Rewrite the hook wrapper to Codex event names and matcher names.
3. Test the script with sample stdin.
4. Keep hooks quiet unless they need to block or add context.
5. Prefer fail-open behavior for convenience hooks.

## Step 6: Convert Common Hook Types

### Duplicate Tool Guard

Purpose: prevent repeated identical tool calls in one session.

Best as: `PreToolUse`.

Matcher example:

```json
"matcher": "Bash|apply_patch|Edit|Write|mcp__.*"
```

Reasoning:

- This prevents context waste.
- It can false-positive during repeated verification.
- Keep it easy to disable.

### RTK Token-Saving Hook

Purpose: rewrite noisy shell commands to compact RTK wrappers.

Best as: `PreToolUse` on `Bash`.

Example:

```json
{
  "type": "command",
  "command": "rtk hook claude",
  "timeout": 10,
  "statusMessage": "Checking RTK rewrite"
}
```

Reasoning:

- RTK reduces output size before it reaches context.
- If there is no Codex-specific RTK hook processor, test another compatible processor with Codex-style stdin.
- Verify before trusting it:

```bash
rtk hook claude <<'JSON'
{"session_id":"verify","tool_name":"Bash","tool_input":{"command":"ls -la"}}
JSON
```

### Code Graph Update Hook

Purpose: keep a graph index fresh after edits.

Best as: `PostToolUse`.

Example:

```json
{
  "type": "command",
  "command": "git rev-parse --git-dir >/dev/null 2>&1 && code-review-graph update --skip-flows >/dev/null 2>&1 || true",
  "timeout": 30,
  "statusMessage": "Updating code-review-graph"
}
```

Reasoning:

- Run only inside git repos.
- Suppress normal output.
- Fail open so graph update failure does not block coding.

### Session Context Hook

Purpose: load compact project context at session start.

Best as: `SessionStart`.

Example:

```json
{
  "type": "command",
  "command": "python3 ~/.codex/hooks/crg_session_start.py",
  "timeout": 30,
  "statusMessage": "Loading code-review-graph context"
}
```

Reasoning:

- Useful for repo-aware starts.
- Can slow startup.
- If startup becomes noisy, remove this first before removing graph tooling entirely.

## Step 7: Rewrite AGENTS.md

Move durable policy into `~/.codex/AGENTS.md`.

Keep it focused on:

- communication rules
- code style rules
- commit rules
- local environment rules
- memory and skill strategy
- hook/token-economy policy

Do not leave stale architecture in AGENTS.md.

Example replacement philosophy:

```markdown
## Memory and Context

Use native Codex memories for cross-session continuity.

Use skills for on-demand workflows instead of keeping local MCP servers registered by default.

Use mcporter when a skill needs MCP-backed tools without exposing that MCP server directly to Codex.
```

Reasoning:

- AGENTS.md is always in the agent's behavior path.
- Stale MCP or memory instructions cause repeated wrong choices.
- Keep project-specific, optional workflows in skills instead.

## Step 8: Handle Plugins and Slash Commands

Claude plugins usually do not cross over directly.

Decision table:

| Claude item | Action |
|---|---|
| UI/statusline plugin | Ignore |
| Context/search plugin | Replace with Codex-native tools, skill, or CLI |
| Plugin with useful scripts | Extract script and call from hook/skill |
| Slash command that launches a workflow | Convert to skill |
| Slash command that is just a shell command | Put command example in a skill or AGENTS.md |

Reasoning:

- Plugins are runtime-specific.
- Scripts and workflow text are portable.
- Slash command names are less important than the repeatable procedure behind them.

## Step 9: Verify the Result

Validate files:

```bash
python3 -m json.tool ~/.codex/hooks.json >/dev/null
python3 -m json.tool ~/.mcporter/mcporter.json >/dev/null
python3 - <<'PY'
import tomllib
with open('/home/hung/.codex/config.toml','rb') as f:
    tomllib.load(f)
print('config-ok')
PY
```

Check native MCP state:

```bash
codex mcp list
```

Check mcporter state:

```bash
npx mcporter list --json
npx mcporter list code-review-graph --json
```

Check active skills:

```bash
find -L ~/.agents/skills -maxdepth 2 -type f -name 'SKILL.md' -print | sort
```

Check hooks manually where possible:

```bash
rtk hook claude <<'JSON'
{"session_id":"verify","tool_name":"Bash","tool_input":{"command":"ls -la"}}
JSON
```

## Step 10: Analyze Overlaps

After migration, list everything by role and remove duplicate jobs.

Common overlap groups:

| Role | Common duplicates | Keep-one rule |
|---|---|---|
| Browser automation | Playwright MCP, browser MCP, Lightpanda | Keep Playwright unless CDP attach is required |
| Code graph | code-review-graph, graphify, knowledge-graph MCP | Keep CRG for live repo context; keep Graphify for export/report graphs |
| Repo packing | repomix, graphify, CRG context | Keep repomix for one-shot context packing |
| Structured reasoning | sequential-thinking, planning skills, workflow skills | Keep sequential-thinking for ad hoc reasoning; keep formal workflow only if used |
| Token saving | RTK, dedup hooks, context-mode-like tools | Keep RTK; keep dedup only if it does not block useful repeated checks |
| Skill creation | skill-creator, plugin-creator, writing-skills | Keep system skills; remove duplicate third-party process skills if noisy |
| Persistent memory | native Codex memories, knowledge-graph MCP, graph tools | Keep native memories; use graph tools for code structure, not user preference memory |

## Example Final Architecture

Lean Codex setup:

| Layer | Keep |
|---|---|
| Instructions | `~/.codex/AGENTS.md` |
| Memory | Native Codex memories |
| Native MCP | None by default |
| On-demand MCP | `~/.mcporter/mcporter.json` |
| Skills | `~/.agents/skills/*/SKILL.md` |
| Hooks | `~/.codex/hooks.json` |
| Token saving | RTK hook |
| Code context | code-review-graph hook + skill |

This gives the agent access to advanced tools without making every tool native and always loaded.

## Practical Cleanup Order

When the setup feels noisy, remove in this order:

1. Stale plugin residue that references Claude-only variables.
2. Broken skill symlinks or skills with missing `SKILL.md`.
3. Duplicate browser MCPs.
4. Native MCP registrations for tools already available through mcporter.
5. SessionStart hooks that slow startup.
6. Duplicate workflow skills that enforce incompatible processes.

Do not remove core instructions, native memories, or baseline safety hooks until there is evidence they are causing problems.

## Reusable Migration Checklist

1. Inventory Claude Code files.
2. Inventory current Codex files.
3. Classify each item by role.
4. Decide native MCP vs skill-mediated MCP.
5. Convert useful Claude skills into `~/.agents/skills`.
6. Convert hooks by event semantics, not by raw JSON copying.
7. Move durable rules into `~/.codex/AGENTS.md`.
8. Ignore Claude-only plugins unless they contain reusable scripts.
9. Validate JSON, TOML, MCP, mcporter, and skill discovery.
10. Review overlaps and keep the smallest set that covers each role.

## Core Rule

Native registration is for things Codex should always know about.

Skills are for things Codex should know how to use.

mcporter is for MCP tools Codex should call only when needed.

Hooks are for automation that should happen without asking.
