#!/usr/bin/env bash
# agent-essential-skills — install the bundle for Cursor + Claude Code
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AGENTS=(cursor claude-code)
NEED_NODE=0
NEED_UV=0
DRY_RUN=0
MCP_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --dry-run)  DRY_RUN=1 ;;
    --mcp-only) MCP_ONLY=1 ;;
    -h|--help)  echo "Usage: bash scripts/install.sh [--dry-run] [--mcp-only]"; exit 0 ;;
    *) echo "Unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done

log()  { printf '\n==> %s\n' "$*"; }
ok()   { printf '    ✓ %s\n' "$*"; }
warn() { printf '    ! %s\n' "$*"; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# Merge the MCP fragment into a JSON config safely:
#  - backs the file up first (timestamped .bak, kept next to it)
#  - refuses to touch a file that is not valid JSON (never replaces it with {})
#  - drops ${ENV} placeholders when the variable is not set, so tools run keyless
#    instead of receiving a literal "${CONTEXT7_API_KEY}" string
merge_mcp() {
  local target="$1" label="$2"
  local fragment="$ROOT/mcp/cursor.mcp.fragment.json"
  have python3 || { warn "python3 missing - add $fragment to $label manually"; return 1; }
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "    [dry-run] would merge MCP servers into $target (backup first)"
    return 0
  fi
  mkdir -p "$(dirname "$target")"
  python3 - "$target" "$fragment" <<'PY'
import json, os, shutil, sys, time
target, fragment = sys.argv[1], sys.argv[2]
incoming = json.load(open(fragment))
data = {}
if os.path.exists(target):
    try:
        data = json.load(open(target))
    except Exception as e:
        sys.stderr.write(f"    ! {target} is not valid JSON ({e}); left untouched. Fix it or add the servers manually.\n")
        sys.exit(3)
    if not isinstance(data, dict):
        sys.stderr.write(f"    ! {target} is not a JSON object; left untouched.\n")
        sys.exit(3)
    bak = f"{target}.bak-{time.strftime('%Y%m%d-%H%M%S')}"
    shutil.copy2(target, bak)
    print(f"    backup: {bak}")
servers = data.setdefault("mcpServers", {})
for name, cfg in incoming.get("mcpServers", {}).items():
    cfg = json.loads(json.dumps(cfg))
    env = cfg.get("env") or {}
    for k, v in list(env.items()):
        if isinstance(v, str) and v.startswith("${") and v.endswith("}"):
            val = os.environ.get(v[2:-1])
            if val:
                env[k] = val
            else:
                del env[k]
    if env:
        cfg["env"] = env
    else:
        cfg.pop("env", None)
    servers[name] = cfg
tmp = target + ".tmp"
with open(tmp, "w") as f:
    json.dump(data, f, indent=2)
os.replace(tmp, target)
print(f"    wrote: {target}")
PY
}

install_skill() {
  local repo="$1"
  log "Skill: $repo"
  [[ $DRY_RUN -eq 1 ]] && { echo "    [dry-run] would run: npx skills add $repo -g"; return 0; }
  npx --yes skills add "$repo" -g -a cursor -a claude-code -y || warn "skill install failed for $repo (continuing)"
}

log "agent-essential-skills installer"
echo "    Targets: Cursor + Claude Code"
echo "    Keys: Context7 + Firecrawl are optional — see docs/KEYS.md"

have node || NEED_NODE=1
have npm  || NEED_NODE=1
have uv   || NEED_UV=1
[[ $NEED_NODE -eq 0 ]] || die "Node.js + npm required (https://nodejs.org)"
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[[ "$NODE_MAJOR" -ge 22 ]] || die "Node.js 22+ required (found $(node -v))"
if [[ $NEED_UV -eq 1 ]]; then
  warn "uv not found — graphify + serena CLI steps will be skipped"
  warn "Install uv: https://docs.astral.sh/uv/  then re-run this script"
fi

if [[ $MCP_ONLY -eq 0 ]]; then
  # --- Skills (global, Cursor + Claude Code) ---
  install_skill "DietrichGebert/ponytail"
  install_skill "JuliusBrussee/caveman"
  install_skill "obra/superpowers"
  install_skill "yamadashy/repomix"
  install_skill "Graphify-Labs/graphify"

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "    [dry-run] would install CLIs: repomix, graphify, serena, claude-mem, ctx7"
  else
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
  fi
fi

# --- MCP wiring ---
log "MCP: merge Playwright, Context7, Firecrawl, Serena into Cursor"
merge_mcp "$HOME/.cursor/mcp.json" "Cursor" && ok "Cursor MCP config" || warn "Cursor MCP merge skipped/failed"

log "MCP: merge same servers into Claude Code user config"
merge_mcp "$HOME/.claude.json" "Claude Code" && ok "Claude Code MCP config" || warn "Claude Code MCP merge skipped/failed"

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
