# Claude to Codex Repos

**User:** Anonymous  
**Created:** 4/27/2026 0:45:07  
**Updated:** 4/27/2026 0:53:37  
**Exported:** 4/27/2026 0:56:22  
**Link:** [https://chatgpt.com/g/g-p-69ee4ec9fecc8191be427e80f21ce155/c/69ee4f21-fb98-839a-b5f5-f313ab8b3c44](https://chatgpt.com/g/g-p-69ee4ec9fecc8191be427e80f21ce155/c/69ee4f21-fb98-839a-b5f5-f313ab8b3c44)  

## Prompt:
4/27/2026, 12:45:06 AM

Are there any repositories on GitHub that convert Claude-Code hooks and skills to CodeX hooks and skills (and are currently being used by many people)?

## Response:
4/27/2026, 12:45:07 AM


## Bottom line

**I found popular repos for Claude Code → Codex _skills_, but not a clearly popular repo that converts both Claude-Code _hooks and skills_ into Codex-native hooks/skills.**

The closest matches are:

| Repo | What it does | Adoption signal | Fit for your question |
|---|---:|---:|---|
| **alirezarezvani/claude-skills** | Large Claude Code skills/plugin library that also supports OpenAI Codex, including `npx agent-skills-cli add ... --agent codex`, `scripts/codex-install.sh`, and `scripts/convert.sh --tool all`. | README claims **5,200+ GitHub stars**. | **Best match for skills.** Not primarily a hooks converter. ([GitHub](https://github.com/alirezarezvani/claude-skills)) |
| **troykelly/codex-skills** | “Codex-focused port” of an original `claude-skills` project; includes `skills/`, `hooks/`, and helper CLIs such as `codex-hook-runner`. | Only 17 commits in the GitHub page snapshot; no strong public adoption signal surfaced. | **Relevant port**, but I would not call it “used by many people” based on the evidence found. ([GitHub](https://github.com/troykelly/codex-skills)) |
| **sane-apps/SaneProcess** | Workflow enforcement across Claude Code and Codex, combining Claude-native hooks with Codex-native instructions, skills, MCP, and shared guardrails. | GitHub org page shows **8 stars / 2 forks** for SaneProcess. | **Closest for hooks + skills conceptually**, but **not popular**. ([GitHub](https://github.com/sane-apps/SaneProcess)) |
| **aiskillstore/marketplace** | Marketplace for skills for Claude Code and Codex; includes install paths for Claude Code and Codex. | 2,301 commits, but I did not find a clear “many users” metric in the searched results. | **Skills marketplace**, not a Claude hooks/skills → Codex converter. ([GitHub](https://github.com/aiskillstore/marketplace)) |
| **boshu2/agentops `converter` skill** | Cross-platform skill converter with Codex output options; third-party listings show ~260–271 stars. | Moderate, not “many people” in the same sense as thousands of stars. | **Potentially relevant for skills conversion**, not hooks. ([ExplainX](https://explainx.ai/skills/boshu2/agentops/converter?utm_source=chatgpt.com)) |

## Why I’m separating hooks from skills

Codex now has first-party documentation for **both hooks** and **Agent Skills**. OpenAI’s Codex docs describe hooks as lifecycle scripts injected into the agentic loop, and skills as `SKILL.md`-based reusable workflows that Codex can invoke explicitly or implicitly. ([OpenAI Developers](https://developers.openai.com/codex/hooks?utm_source=chatgpt.com))

However, the ecosystem evidence I found is uneven:

- **Skills conversion/support is real and already public.** The strongest example is `alirezarezvani/claude-skills`, which explicitly says it works with Claude Code and OpenAI Codex and provides Codex installation/conversion commands. ([GitHub](https://github.com/alirezarezvani/claude-skills))
- **Hooks conversion is much less mature.** I found repos that include or bridge hook concepts, but not a widely adopted “Claude Code hooks → Codex hooks” converter with strong usage signals.
- Codex hook/plugin integration still appears to be actively evolving: recent Codex GitHub issues discuss plugin-defined hooks not loading, stable bundle/plugin context for hooks, hot-reload behavior, and skill lifecycle hooks. That suggests the substrate exists, but the migration tooling is not yet settled. ([GitHub](https://github.com/openai/codex/issues/17331?utm_source=chatgpt.com))

## Practical recommendation

Use **`alirezarezvani/claude-skills`** if your main need is **Claude Code skills → Codex skills**. It has the clearest Codex support and the strongest adoption signal I found. ([GitHub](https://github.com/alirezarezvani/claude-skills))

For **hooks**, I would not rely on an off-the-shelf popular converter yet. I’d treat hook migration as a manual mapping exercise from Claude Code hook events and payloads to Codex `hooks.json` behavior, then package the shared logic as scripts so Claude and Codex wrappers can call the same underlying guardrails. **SaneProcess** is directionally similar, but its public adoption is small. ([GitHub](https://github.com/sane-apps/SaneProcess))

---

**Sources:**

- [GitHub - alirezarezvani/claude-skills: 232+ Claude Code skills & agent plugins for Claude Code, Codex, Gemini CLI, Cursor, and 8 more coding agents — engineering, marketing, product, compliance, C-level advisory. · GitHub](https://github.com/alirezarezvani/claude-skills)
- [converter — AI agent skill](https://explainx.ai/skills/boshu2/agentops/converter?utm_source=chatgpt.com)
- [Hooks – Codex](https://developers.openai.com/codex/hooks?utm_source=chatgpt.com)

## Prompt:
4/27/2026, 12:52:56 AM

```markdown
| Claude Code | Codex |
|-------------|-------|
| `.claude/settings.json` hooks[] | `hooks.json` - `[{hooks.EVENT}]` |
| SessionStart | SessionStart |
| PreToolUse | PreToolUse |
| PostToolUse | PostToolUse |
| UserPromptSubmit | UserPromptSubmit |
| Stop | Stop |
| SubagentStop | — no equivalent — |
| Notification · PreCompact | — no equivalent — |

- full match
- partial (Bash-only)
- no Codex equivalent

SubagentStop · Notification · PreCompact have no Codex target → emit warnings

---

## 1. Input parsing

**Read `.claude/settings.json` + SKILL.md files**

Right:
- `settings.json · hooks[] array`
- `SKILL.md frontmatter block`

---

## 2. AST normalisation

**Resolve matchers · strip CC-only fields**

Right:
- Based on: `padmilikhandelwal/convert-claude-to-codex-skill`

---

## 3. Hook event mapping

**SessionStart/UserPromptSubmit/Stop → 1:1**  
**Pre/PostToolUse Write/Edit → wrap in Bash**

Right:
- `alirezarezvani/claude-skills`
- `scripts/convert.sh logic`
- `nyosegawa Bash-only constraint`

---

## 4. Handler + SKILL.md rewrite

**Rewrite tool refs · fix frontmatter**  
**CLAUDE.md refs → AGENTS.md**

Right:
- `ECC DRY adapter pattern`
- `affaan-m/everything-claude-code`

---

## 5. File emit

**Write `.codex/hooks.json` · skill dirs**

Right:
- `codex/hooks.json`
- `~/.codex/skills/<name>/SKILL.md`
```


```
Now I have everything I need to produce the full answer with proper diagrams.---

## Repository landscape (updated)

| Repo | Stars | Hooks support | Skills support | Relevance to conversion |
|---|---|---|---|---|
| **affaan-m/everything-claude-code** | 100K+ | Full Claude Code hooks; Codex support is instruction-only via AGENTS.md — no Codex-native hook execution | Cross-platform (Claude Code, Cursor, Codex, OpenCode) | DRY adapter pattern for reusing hook scripts; best source for hook script logic |
| **alirezarezvani/claude-skills** | 5,200+ | None | Native for 12 tools including Claude Code and Codex; `scripts/convert.sh --tool all` converts across platforms | Best skills converter; convert.sh is the most reusable piece |
| **padmilkhandelwal/convert-claude-to-codex-skill** | Low / new | None | Rewrites incompatible tool references, frontmatter format, and CLAUDE.md → AGENTS.md mapping; one-command install | Only purpose-built skills converter; directly addresses the format incompatibility |
| **sane-apps/SaneProcess** | 8 | Bridges Claude hooks + Codex AGENTS/skills/MCP with shared guardrails | Skills | Conceptually closest for both hooks + skills; low adoption |
| **fcakyon/claude-codex-settings** | Personal/low | Hooks for Claude Code only; Codex does not expose PreCompact | Dual platform (Claude Code + Codex) via plugins | Real-world dual-platform example |

---

## Hook-level gap analysis

| Claude Code event | Codex equivalent | Conversion action |
|---|---|---|
| `SessionStart` | `SessionStart` | 1:1 copy |
| `UserPromptSubmit` | `UserPromptSubmit` | 1:1 copy |
| `Stop` | `Stop` | 1:1 copy |
| `PreToolUse` matcher `Bash` | `PreToolUse` (Bash only) | 1:1 copy |
| `PostToolUse` matcher `Bash` | `PostToolUse` (Bash only) | 1:1 copy |
| `PreToolUse` matcher `Write\|Edit\|Read` | `PreToolUse` (Bash only) | Codex performs file operations via Bash, so file-targeting hooks must be re-expressed as Bash guards; wrap logic in a shell command that reads the path from `$CODEX_TOOL_INPUT` |
| `PostToolUse` matcher `Write\|Edit` | `PostToolUse` (Bash only) | Same Bash-wrapper pattern |
| `SubagentStop` | None | Emit conversion warning; no Codex equivalent |
| `Notification` | None | Drop; no Codex equivalent |
| `PreCompact` | None | Codex does not expose a PreCompact hook; drop with warning |
| Handler `type: "prompt"` | Parsed but skipped | Prompt and agent hook handlers are parsed but skipped in Codex; rewrite as `type: "command"` calling a shell script that invokes the model |
| Handler `type: "agent"` | Parsed but skipped | Same — rewrite as shell-delegated command |
| Handler `type: "http"` | Supported | 1:1 copy |
| Handler `type: "command"` | Supported | 1:1 copy |

---

## SKILL.md conversion delta

| Field / convention | Claude Code | Codex | Converter action |
|---|---|---|---|
| Instruction file | `CLAUDE.md` | `AGENTS.md` | String-replace all `CLAUDE.md` references |
| Skill install path | `~/.claude/skills/<name>/` | `~/.codex/skills/<name>/` or per config | Rewrite install paths |
| Frontmatter strictness | Loose | Strict — unknown keys rejected | Strip non-standard frontmatter keys |
| Tool call syntax | CC-specific (Write, Edit, Bash, Read) | Codex shell-only tool set | Rewrite tool references to `Bash` equivalent |
| Hook config location | `.claude/settings.json` · `hooks[]` | `hooks.json` files or inline `[[hooks]]` in `config.toml` | Generate both formats |
| Feature flag required | No | `codex_hooks = true` under `[features]` in config.toml | Append feature flag block |

---

## Conversion tool design (based on top 3 projects)

Three source repos contribute distinct pieces:

**alirezarezvani/claude-skills** — supplies `scripts/convert.sh`: the mature multi-tool conversion shell that handles path rewriting and platform targeting. Pull this as the CLI skeleton.

**padmilkhandelwal/convert-claude-to-codex-skill** — supplies the skills-specific format normaliser: frontmatter rewriting, tool-reference patching, and CLAUDE.md → AGENTS.md substitution. Pull this as the SKILL.md transform layer.

**affaan-m/everything-claude-code** — supplies hook scripts already written as standalone shell commands with no Claude Code runtime dependency. These are the shared underlying scripts that both Claude Code and Codex wrappers should delegate to, implementing ECC's DRY adapter pattern.

The conversion tool pipeline is shown in the diagram above. The critical design constraint: since Codex's PreToolUse and PostToolUse only target the Bash tool, hooks that match Write/Edit/Read in Claude Code must be rewritten as Bash guards that inspect the incoming path from the tool input — you can get equivalent practical coverage but cannot match file tools directly. Any handler typed `prompt` or `agent` must be demoted to a `command` handler calling a shell script, because Codex currently parses prompt and agent handler types but skips them at execution time.
```
-------------------
So, if we can't reinvent the wheel, what's the quickest way to do it?

[Attachment: f8fa661e-4210-481c-bc04-7286052aac48.png]

## Response:
4/27/2026, 12:52:57 AM


## Quickest path: **compose, don’t build from scratch**

Do **not** write a full universal Claude Code → Codex converter first. The fastest practical route is a **thin migration harness** that reuses existing projects:

1. **Skills:** use `alirezarezvani/claude-skills` as the install/conversion backbone. It already supports OpenAI Codex, has `scripts/convert.sh`, and claims 5,200+ GitHub stars. ([GitHub](https://github.com/alirezarezvani/claude-skills))  
2. **Skill incompatibilities:** use the `padmilkhandelwal/convert-claude-to-codex-skill` approach for the hard deltas: tool references, stricter frontmatter, and `CLAUDE.md → AGENTS.md`. The author explicitly describes those as the breakpoints and provides a one-command converter. ([OpenAI Developer Community](https://community.openai.com/t/claude-to-codex-bring-claude-skills-to-codex-automatically/1378574))  
3. **Hooks:** write a small `settings.json → hooks.json` transpiler yourself. This is the missing wheel. Codex hooks are first-party now, but the shape is simple enough: `hooks.json` or inline `config.toml`, enabled by `[features] codex_hooks = true`. ([OpenAI Developers](https://developers.openai.com/codex/hooks))  
4. **Hook scripts:** vendor or adapt standalone shell/Python hook scripts from `everything-claude-code`, not its Claude runtime wiring. It is a large, active multi-agent-harness repo with skills, hooks, rules, MCP configs, and stated Codex support. ([GitHub](https://github.com/affaan-m/everything-claude-code))  

One important correction to the diagram: **Codex is no longer Bash-only for tool hooks.** Current Codex docs say `PreToolUse`, `PostToolUse`, and `PermissionRequest` support `Bash`, `apply_patch`, and MCP tool names; for file edits through `apply_patch`, matchers can use `Edit` or `Write`. `Read` still does not have the same direct native mapping unless it is routed through MCP or Bash. ([OpenAI Developers](https://developers.openai.com/codex/hooks))

---

## The fastest MVP architecture

```text
claude-to-codex-migrate
├── convert-skills
│   ├── call or vendor alirezarezvani/claude-skills scripts
│   └── apply padmilk-style SKILL.md normalisation
│
├── convert-hooks
│   ├── read ~/.claude/settings.json and repo .claude/settings.json
│   ├── keep SessionStart / UserPromptSubmit / Stop
│   ├── map PreToolUse/PostToolUse Bash directly
│   ├── map Write/Edit to apply_patch or Edit|Write matcher
│   ├── warn/drop Read, Notification, PreCompact, SubagentStop
│   └── emit .codex/hooks.json + config.toml feature flag
│
└── install-runtime
    ├── copy or symlink scripts into .codex/hooks/
    ├── copy skills into .codex/skills/
    └── run validation
```

This gets you to a working tool in **1–2 days**, not weeks.

---

## Concrete implementation plan

### Phase 1 — Skills: avoid doing real work

For skills that are already compatible, symlink or copy them. There is even a small repo that syncs Claude Code skills into Codex via symlinks, including plugin and personal skill directories. It has low adoption, but the idea is useful for a fast local workflow. ([GitHub](https://github.com/ariccb/sync-claude-skills-to-codex))

Use this order:

```bash
# 1. Install known-good multi-platform skills directly
npx agent-skills-cli add alirezarezvani/claude-skills --agent codex

# 2. For arbitrary Claude skills, run a normalizer/converter
# Pattern based on padmilkhandelwal/convert-claude-to-codex-skill:
# - rewrite CLAUDE.md references to AGENTS.md
# - strip unsupported frontmatter
# - rewrite Claude tool references
# - install under ~/.codex/skills/<skill>
```

For your own migration tool, make the skills converter intentionally boring:

```text
SKILL.md transform:
- parse YAML frontmatter
- keep only Codex-safe keys: name, description, maybe allowed metadata
- rewrite CLAUDE.md → AGENTS.md
- rewrite ~/.claude/skills → ~/.codex/skills
- flag Claude-only tool mentions: Write, Edit, Read, TodoWrite, Task
- do not silently “fix” semantic instructions unless rule-based
```

Codex skills only require a directory with `SKILL.md`; optional `scripts/`, `references/`, `assets/`, and `agents/openai.yaml` are supported. ([OpenAI Developers](https://developers.openai.com/codex/skills))

---

### Phase 2 — Hooks: build the missing 20%

The hook transpiler is small because Codex’s hook schema is straightforward: event → matcher group → handlers. The docs show `SessionStart`, `PreToolUse`, `PermissionRequest`, `PostToolUse`, `UserPromptSubmit`, and `Stop` examples in `hooks.json`; commands receive JSON on `stdin`. ([OpenAI Developers](https://developers.openai.com/codex/hooks))

Your first-pass mapping should be:

| Claude Code | Codex | Action |
|---|---|---|
| `SessionStart` | `SessionStart` | Copy |
| `UserPromptSubmit` | `UserPromptSubmit` | Copy, drop matcher because Codex ignores matcher here |
| `Stop` | `Stop` | Copy, drop matcher because Codex ignores matcher here |
| `PreToolUse: Bash` | `PreToolUse: Bash` | Copy |
| `PostToolUse: Bash` | `PostToolUse: Bash` | Copy |
| `PreToolUse: Write/Edit` | `PreToolUse: apply_patch` or `Edit|Write` | Convert |
| `PostToolUse: Write/Edit` | `PostToolUse: apply_patch` or `Edit|Write` | Convert |
| `Read` | none, unless MCP/Bash | Warn |
| `Notification` | none | Warn/drop |
| `PreCompact` | none | Warn/drop |
| `SubagentStop` | none | Warn/drop |

Codex currently says matchers are honored for `PermissionRequest`, `PostToolUse`, `PreToolUse`, and `SessionStart`; matchers are ignored for `UserPromptSubmit` and `Stop`. ([OpenAI Developers](https://developers.openai.com/codex/hooks))

---

## Minimal `hooks.json` emitter

Your generated Codex file should look like this:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$(git rev-parse --show-toplevel)/.codex/hooks/pre_tool_use.py\"",
            "statusMessage": "Checking command"
          }
        ]
      },
      {
        "matcher": "Edit|Write|apply_patch",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$(git rev-parse --show-toplevel)/.codex/hooks/pre_patch_guard.py\"",
            "statusMessage": "Checking file edit"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash|Edit|Write|apply_patch",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$(git rev-parse --show-toplevel)/.codex/hooks/post_tool_use.py\"",
            "statusMessage": "Reviewing tool output"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$(git rev-parse --show-toplevel)/.codex/hooks/user_prompt_submit.py\""
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"$(git rev-parse --show-toplevel)/.codex/hooks/stop.py\"",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

And append this to `.codex/config.toml`:

```toml
[features]
codex_hooks = true
```

Codex searches for hooks in `~/.codex/hooks.json`, `~/.codex/config.toml`, `<repo>/.codex/hooks.json`, and `<repo>/.codex/config.toml`. ([OpenAI Developers](https://developers.openai.com/codex/hooks))

---

## The fastest repo strategy

Create a new repo, but keep it deliberately thin:

```text
claude-codex-bridge/
├── package.json
├── src/
│   ├── cli.ts
│   ├── skills/
│   │   ├── normalize-skill.ts
│   │   └── install-skill.ts
│   ├── hooks/
│   │   ├── read-claude-settings.ts
│   │   ├── convert-hooks.ts
│   │   └── emit-codex-hooks.ts
│   └── validate/
│       ├── validate-skill.ts
│       └── validate-hooks.ts
├── templates/
│   ├── codex-hooks.json
│   └── config.toml.patch
└── README.md
```

Expose just three commands:

```bash
# Convert current repo
claude-codex-bridge migrate .

# Convert global Claude config/skills
claude-codex-bridge migrate --global

# Dry-run with warnings
claude-codex-bridge migrate . --dry-run
```

Do not start with a marketplace, GUI, plugin registry, or universal agent abstraction. The value is the **hook gap** plus a practical skill normalizer.

---

## What I would ship first

### MVP acceptance criteria

```text
Given:
  .claude/settings.json
  .claude/skills/*
  CLAUDE.md

Produce:
  .codex/hooks.json
  .codex/config.toml
  .codex/skills/*
  AGENTS.md

With:
  - warnings for unsupported Claude events
  - warnings for Claude-only handlers
  - no silent lossy conversion
  - dry-run diff
```

### Day-one feature set

- `settings.json` hook parser
- `hooks.json` emitter
- `config.toml` feature flag patcher
- `SKILL.md` frontmatter cleaner
- `CLAUDE.md → AGENTS.md` reference rewrite
- `~/.claude → ~/.codex` path rewrite
- `--dry-run`
- `--warnings-json`

That is the shortest credible path to a useful converter.

---

## Final recommendation

The quickest route is:

> **Use `alirezarezvani/claude-skills` for skills distribution, copy the `padmilkhandelwal` conversion rules for incompatible skills, and build only the missing hook transpiler yourself.**

That gives you something genuinely useful: not another skills marketplace, but the missing **Claude Code settings/hooks → Codex hooks/config** bridge.

---

**Sources:**

- [GitHub - alirezarezvani/claude-skills: 232+ Claude Code skills & agent plugins for Claude Code, Codex, Gemini CLI, Cursor, and 8 more coding agents — engineering, marketing, product, compliance, C-level advisory. · GitHub](https://github.com/alirezarezvani/claude-skills)
- [Claude-to-codex — bring Claude skills to Codex automatically - Codex - OpenAI Developer Community](https://community.openai.com/t/claude-to-codex-bring-claude-skills-to-codex-automatically/1378574)
- [Hooks – Codex | OpenAI Developers](https://developers.openai.com/codex/hooks)