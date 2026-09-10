# Codex Plugin Practice Workflow

Use this folder as learning material for Claude Code + Codex plugin workflows. Do not treat this repo as the target codebase for plugin work.

Claude keeps the main thread and decides scope. Codex gives a second pass, reviews code changes, or takes one bounded delegated task.

## Commands

| Command | When |
|---------|------|
| `/codex:setup` | First session or after auth changes |
| `/codex:review --background` | Review current uncommitted code changes |
| `/codex:review --base main --background` | Review branch changes against a base branch |
| `/codex:adversarial-review --background <focus>` | Challenge a specific design, file, risk, or assumption |
| `/codex:rescue --background read-only: <task>` | Fact-check Claude prose, inspect materials, or research without edits |
| `/codex:rescue --background <task>` | Delegate a bounded fix or investigation |
| `/codex:rescue --resume <task>` | Continue the latest Codex task for this repo |
| `/codex:status` | Check background jobs |
| `/codex:result` | Read a completed job result |
| `/codex:cancel` | Stop a running background job |

## Decision Table

| Need | Use |
|------|-----|
| Claude changed code and you want a normal review | `/codex:review --background` |
| You want Codex to question the approach or inspect a few named risks | `/codex:adversarial-review --background <focus>` |
| You want Codex to fact-check Claude's answer or add missing points | `/codex:rescue --background read-only: <fact-check task>` |
| Claude is stuck on a bug or implementation | `/codex:rescue --background <bounded task>` |
| You want the answer later | `/codex:status`, then `/codex:result` |

## Prompt Shapes

Immediate code review:

```text
/codex:review --background
```

Focused review:

```text
/codex:adversarial-review --background focus only on command choice, setup assumptions, and whether the workflow over-verifies Claude output
```

Claude prose fact-check:

```text
/codex:rescue --background read-only: fact-check Claude's last answer against codex-cc-practice/codex-workflow.md and the Claude session e8210014-e739-4425-9b70-28edf7282b14. Output only wrong claims, missing caveats, and concrete additions.
```

Later follow-up:

```text
/codex:status
/codex:result
```

## Rules

- Use `/codex:review` only for git-backed code review.
- Use `/codex:adversarial-review` when the review needs focus text.
- Use read-only `/codex:rescue` for prose, transcript, material, or fact-check work.
- Use `--background` for anything multi-file, runtime-dependent, or not tiny.
- Evaluate `/codex:result` against the actual repo or materials before acting.
- Keep each Codex request bounded to one repo, one session, or one material folder.

## Optional Gate

`/codex:setup --enable-review-gate` enables automatic stop-time review after Claude makes code changes. Leave it off for normal learning, prose checks, or exploratory sessions because it can create long Claude/Codex loops.
