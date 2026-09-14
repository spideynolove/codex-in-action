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

## Recommended Verification Workflow

Use Codex on demand, not after every Claude response.

Claude Code should remain the main worker. Codex is an independent checkpoint reviewer for important claims, workflow decisions, and bounded code changes.

### Start Of Session

Run setup only when starting a new environment, after auth changes, or when Codex commands fail:

```text
/codex:setup
```

Leave review gate off by default. Enable it only for a short, high-scrutiny session where latency and usage cost are acceptable.

### Claude Answer Verification

Use this when Claude gives an answer that affects setup, architecture, workflow, or project understanding:

```text
/codex:rescue --background --fresh read-only:
Verify Claude's previous answer.

Evidence:
- README.md
- AGENTS.md
- CLAUDE.md
- codex-cc-practice/codex-workflow.md
- any named Claude session/output

Check only:
- incorrect claims
- unsupported assumptions
- missing caveats
- better command choice

Do not edit files.
Output concise actionable findings only.
```

### Specific Folder Review

Use this when Claude changed or analyzed one active project folder, such as `practice-lhe`, and other folders are templates or reference material:

```text
/codex:rescue --background --fresh read-only:
Review only changes under practice-lhe.

Use:
- git status --short -- practice-lhe
- git diff -- practice-lhe
- direct reads inside practice-lhe only when needed

Exclude:
- .claude
- .agents
- docs
- guide
- materials
- output
- data
- templates
- unrelated files

Check:
- correctness
- missed edge cases
- bad assumptions
- missing verification

Do not edit files.
Output only material findings.
```

### Clean Git Diff Review

Use adversarial review when the git state is already clean and bounded to the real active work:

```text
/codex:adversarial-review --background --scope working-tree
focus only on practice-lhe implementation decisions, root-cause correctness, edge cases, and verification gaps
```

If unrelated files are dirty, use read-only rescue with explicit paths instead.

### Larger Checkpoint

Use this before trusting a larger result, not after every small response:

```text
/codex:rescue --background --fresh read-only:
Audit Claude's completed work for this checkpoint.

Scope:
- practice-lhe only

Evidence:
- git diff -- practice-lhe
- relevant tests or command outputs
- Claude's final summary

Output:
- blocking findings
- questionable assumptions
- missing checks
```

## Command Choice

| Scenario | Use |
|----------|-----|
| Routine Claude answer | No Codex |
| Claim-heavy Claude answer | `/codex:rescue --background --fresh read-only: ...` |
| One folder review without committing | `/codex:rescue --background --fresh read-only: git diff -- <folder>` |
| Clean bounded working-tree diff | `/codex:adversarial-review --background --scope working-tree <focus>` |
| Branch checkpoint | `/codex:adversarial-review --background --base main <focus>` |
| Codex should fix something | `/codex:rescue --background <task>` |

## Reasoning

`/codex:review` and `/codex:adversarial-review` are git-state review commands. They are useful when the git diff is already the intended review target.

`/codex:adversarial-review` focus text steers the review, but it does not make unrelated dirty files disappear from git-derived context.

`/codex:rescue` is better for narrow independent verification because the prompt can name exact paths, exact commands, and read-only behavior.

The stable default is checkpoint-based verification: Claude works, Codex checks the exact evidence you name, and the user decides whether a second opinion is worth the cost.

## Debate Summary

- Do not run Codex after every Claude response.
- Do not enable review gate for normal learning sessions.
- Do not ask Codex to review copied templates or whole mixed workspaces.
- Do not rely on `focus` text to shrink git context; it only steers attention.
- Use Codex when the answer matters, the code changed, or a checkpoint needs independent review.
- Use `/codex:rescue --background --fresh read-only:` for Claude answer checks, exact-path review, and workflow validation.
- Use `/codex:adversarial-review` only when the git diff is already clean, bounded, and represents the target work.
- No commit is required before every review; use `git diff -- <folder>` inside a read-only rescue prompt for folder-scoped checks.
- Keep `practice-lhe` as the active project folder and treat sibling folders as learning material unless named.
- Claude Code stays the main worker; Codex is the second opinion.

Default habit:

```text
Claude works first.
Codex verifies only named evidence.
User decides whether findings matter.
```
