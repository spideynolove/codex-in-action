#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.codex" "$HOME/.agents/skills"
cp "$ROOT/codex/config.toml" "$HOME/.codex/config.toml"
rsync -a "$ROOT/agents/skills/" "$HOME/.agents/skills/"

printf 'Applied Codex profile from %s\n' "$ROOT"
