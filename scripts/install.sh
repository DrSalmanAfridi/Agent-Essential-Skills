#!/usr/bin/env bash
# agent-essential-skills — install the bundle for Cursor + Claude Code
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AGENTS=(cursor claude-code)
NEED_NODE=0
NEED_UV=0

log()  { printf '\n==> %s\n' "$*"; }
ok()   { printf '    ✓ %s\n' "$*"; }
warn() { printf '    ! %s\n' "$*"; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

merge_mcp_cursor() {
  local target="$HOME/.cursor/mcp.json"
  local fragment="$ROOT/mcp/cursor.mcp.fragment.json"
  mkdir -p "$HOME/.cursor"
  if ! have python3; then
    warn "python3 missing — copy $fragment into Cursor MCP settings manually"
    return
  fi
  python3 - "$target" "$fragment" <<'PY'
import json, os, sys
target, fragment = sys.argv[1], sys.argv[2]
incoming = json.load(open(fragment))
data = {"mcpServers": {}}
if os.path.exists(target):
    try:
        data = json.load(open(target))
    except Exception:
        data = {"mcpServers": {}}
data.setdefault("mcpServers", {})
for name, cfg in incoming.get("mcpServers", {}).items():
    data["mcpServers"][name] = cfg
# Expand ${ENV} placeholders with real env values when present
for cfg in data["mcpServers"].values():
    env = cfg.get("env") or {}
    for k, v in list(env.items()):
        if isinstance(v, str) and v.startswith("${") and v.endswith("}"):
            key = v[2:-1]
            if os.environ.get(key):
                env[k] = os.environ[key]
    if env:
        cfg["env"] = env
tmp = target + ".tmp"
json.dump(data, open(tmp, "w"), indent=2)
os.replace(tmp, target)
print(target)
PY
}

merge_mcp_claude() {
  # Claude Code project/user MCP often lives in ~/.claude.json under mcpServers
  local target="$HOME/.claude.json"
  local fragment="$ROOT/mcp/cursor.mcp.fragment.json"
  if ! have python3; then
    warn "python3 missing — add MCP servers to Claude Code manually"
    return
  fi
  python3 - "$target" "$fragment" <<'PY'
import json, os, sys
target, fragment = sys.argv[1], sys.argv[2]
incoming = json.load(open(fragment))
data = {}
if os.path.exists(target):
    try:
        data = json.load(open(target))
    except Exception:
        data = {}
data.setdefault("mcpServers", {})
for name, cfg in incoming.get("mcpServers", {}).items():
    data["mcpServers"][name] = cfg
for cfg in data["mcpServers"].values():
    env = cfg.get("env") or {}
    for k, v in list(env.items()):
        if isinstance(v, str) and v.startswith("${") and v.endswith("}"):
            key = v[2:-1]
            if os.environ.get(key):
                env[k] = os.environ[key]
    if env:
        cfg["env"] = env
tmp = target + ".tmp"
json.dump(data, open(tmp, "w"), indent=2)
os.replace(tmp, target)
print(target)
PY
}

install_skill() {
  local repo="$1"
  log "Skill: $repo"
  npx --yes skills add "$repo" -g -a cursor -a claude-code -y || warn "skill install failed for $repo (continuing)"
}

log "agent-essential-skills installer"
echo "    Targets: Cursor + Claude Code"
echo "    Keys: Context7 + Firecrawl are optional — see docs/KEYS.md"

have node || NEED_NODE=1
have npm  || NEED_NODE=1
have uv   || NEED_UV=1
[[ $NEED_NODE -eq 0 ]] || die "Node.js + npm required (https://nodejs.org)"
if [[ $NEED_UV -eq 1 ]]; then
  warn "uv not found — graphify + serena CLI steps will be skipped"
  warn "Install uv: https://docs.astral.sh/uv/  then re-run this script"
fi

# --- Skills (global, Cursor + Claude Code) ---
install_skill "DietrichGebert/ponytail"
install_skill "JuliusBrussee/caveman"
install_skill "obra/superpowers"
install_skill "yamadashy/repomix"
install_skill "Graphify-Labs/graphify"

# --- CLIs ---
log "CLI: repomix"
npm install -g repomix >/dev/null && ok "repomix" || warn "repomix global install failed — use npx repomix@latest"

if [[ $NEED_UV -eq 0 ]]; then
  log "CLI: graphify"
  uv tool install graphifyy >/dev/null && ok "graphify" || warn "graphify install failed"
  log "CLI: serena"
  uv tool install -p 3.13 serena-agent >/dev/null && ok "serena" || warn "serena install failed"
fi

log "CLI: claude-mem"
echo "    Running interactive installer (pick your agents when asked)..."
npx --yes claude-mem install || warn "claude-mem install exited non-zero — run: npx claude-mem install"

log "CLI: context7 setup (optional auth)"
echo "    You can skip auth and add a key later (docs/KEYS.md)."
npx --yes ctx7 setup || warn "ctx7 setup skipped/failed — run later: npx ctx7 setup"

# --- MCP wiring ---
log "MCP: merge Playwright, Context7, Firecrawl, Serena into Cursor"
merge_mcp_cursor && ok "updated ~/.cursor/mcp.json" || warn "Cursor MCP merge failed"

log "MCP: merge same servers into Claude Code user config"
merge_mcp_claude && ok "updated ~/.claude.json" || warn "Claude MCP merge failed"

# --- Summary ---
log "Done"
cat <<EOF

Installed / wired for Cursor + Claude Code:
  Skills:  ponytail, caveman, superpowers, repomix, graphify
  CLIs:    repomix, graphify, serena, claude-mem (interactive), ctx7
  MCP:     playwright, context7, firecrawl, serena

Still need keys for full use (optional):
  CONTEXT7_API_KEY   → docs/KEYS.md
  FIRECRAWL_API_KEY  → docs/KEYS.md

Restart Cursor and Claude Code, then try:
  /ponytail
  graphify .
  "use context7" in a prompt (after key)
  ask the agent to open a page with Playwright

EOF
