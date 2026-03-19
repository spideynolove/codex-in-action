# home-pc Codex profile

This profile snapshots the Codex setup from the source machine:

- `codex/config.toml`
- `agents/skills/`

Apply on another machine:

```bash
cd profiles/home-pc
./apply.sh
```

This copies:

- `codex/config.toml` to `~/.codex/config.toml`
- `agents/skills/*` to `~/.agents/skills/`

Restart Codex after applying.
