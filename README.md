# agent-essential-skills

**One install. Ten open-source tools. Native agents that actually have context.**

ChatGPT, Cursor, and Claude are only as good as the context you give them. Almost nobody gives them any. This repo is a one-command bundle: memory, live docs, a codebase map, lean code habits, a real browser, and the rest — installed for **Cursor** and **Claude Code** in one go.

```bash
git clone https://github.com/DrSalmanAfridi/Agent-Essential-Skills.git
cd Agent-Essential-Skills
bash scripts/install.sh
```

Two tools need a free API key for full use (**Context7**, **Firecrawl**). Everything else works offline. Keys → [docs/KEYS.md](docs/KEYS.md).

---

## What you get

| # | Tool | Kind | Why install it |
|---|------|------|----------------|
| 1 | [claude-mem](https://github.com/thedotmack/claude-mem) | memory / installer | Agents forget between sessions. This keeps a compressed memory and injects it next time. |
| 2 | [context7](https://github.com/upstash/context7) | MCP + skill | Agents guess APIs from stale training data. This feeds **live, version-specific docs**. *(key optional)* |
| 3 | [graphify](https://github.com/Graphify-Labs/graphify) | CLI + skill | Turns your codebase into a **queryable knowledge graph** so the agent searches structure, not noise. |
| 4 | [ponytail](https://github.com/DietrichGebert/ponytail) | skill | Forces the **laziest solution that still works** — less bloat, fewer dependencies. |
| 5 | [playwright-mcp](https://github.com/microsoft/playwright-mcp) | MCP | Gives the agent a **real browser** to open pages and test its own UI. |
| 6 | [superpowers](https://github.com/obra/superpowers) | skill / plugin | Full workflow: brainstorm → plan → TDD → review, instead of coding blind. |
| 7 | [repomix](https://github.com/yamadashy/repomix) | CLI + skill | Packs a whole repo into **one AI-friendly file** when you need a single dump. |
| 8 | [firecrawl](https://github.com/firecrawl/firecrawl) | MCP / API | **Search and scrape the live web** into clean markdown for the agent. *(key optional)* |
| 9 | [serena](https://github.com/oraios/serena) | MCP | **IDE-like** symbol search, references, and renames via language servers. |
| 10 | [caveman](https://github.com/JuliusBrussee/caveman) | skill | Shorter agent prose — less filler, more room for code and tools. |

Machine-readable catalog: [`tools.json`](tools.json).

---

## Why each one (plain English)

### 1. claude-mem — memory between sessions
Without this, every chat starts at zero. Claude-mem records what happened, compresses it, and hands the useful bits back next session.

### 2. context7 — live docs, not guesses
Library APIs change. Context7 pulls current docs and examples into the agent so it stops inventing functions that don’t exist.

### 3. graphify — your codebase as a map
Big repos drown agents in files. Graphify builds a knowledge graph you (and the agent) can `query`, `path`, and `explain`.

### 4. ponytail — no more bloated code
Agents love frameworks and helpers. Ponytail is a skill that pushes YAGNI, stdlib first, and the shortest path that works.

### 5. playwright-mcp — open a browser, test the work
If the agent can’t click through the UI, it can’t verify front-end work. Playwright MCP is that browser.

### 6. superpowers — process, not vibes
Brainstorm, write a plan, do TDD, review. Superpowers is a skills pack that makes the agent follow that loop.

### 7. repomix — one file when you need the whole tree
Sometimes you want the entire repo packed for an LLM in one shot. Repomix does that (with ignores and token counts).

### 8. firecrawl — web data for agents
Need pricing pages, docs sites, or article text? Firecrawl scrapes and searches the web into clean markdown/JSON.

### 9. serena — edit like an IDE
Find symbols, jump to references, rename properly. Serena exposes IDE-grade tools over MCP instead of blind search-and-replace.

### 10. caveman — fewer filler tokens
Makes answers denser. Code, paths, and errors stay exact. Savings are biggest on chatty replies; coding sessions see smaller gains.

---

## Install details

`scripts/install.sh` will:

1. Install **skills** globally for Cursor + Claude Code (`ponytail`, `caveman`, `superpowers`, `repomix`, `graphify`)
2. Install **CLIs** (`repomix`, `graphify`, `serena`, plus interactive `claude-mem` and `ctx7` setup)
3. Merge **MCP servers** into `~/.cursor/mcp.json` and `~/.claude.json` (`playwright`, `context7`, `firecrawl`, `serena`)

Requirements: **Node.js 22+**, and **[uv](https://docs.astral.sh/uv/)** for graphify + serena.

This repo does **not** vendor the ten upstream projects. It wires them. Credit and licenses stay with the original authors.

---

## After install

1. Restart Cursor and Claude Code  
2. Add keys if you want live docs / web scrape → [docs/KEYS.md](docs/KEYS.md)  
3. In a project: `graphify .`  
4. Try `/ponytail` or ask the agent to use Playwright on a local URL  

---

## Honesty

- Not all ten are “skills.” Some are skills, some are MCP servers, some are CLIs. The installer handles the mix.
- Context7 and Firecrawl are optional until you add keys.
- Caveman’s big “% tokens saved” numbers are for chatty answers; treat them as a style win first.

---

## License

MIT for this bundle’s scripts and docs. Upstream tools keep their own licenses — see each GitHub repo.
