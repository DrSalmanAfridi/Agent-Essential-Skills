# API keys (only 2 of 10)

The installer sets up every tool that works offline. Two tools talk to a cloud service and need a key for full use. They are optional — skip them until you need them.

## Context7 — live library docs

**Why:** so the agent stops inventing outdated APIs.

1. Create a free account at [context7.com](https://context7.com)
2. Create an API key
3. Put it where your agent can see it:

```bash
# shell (current session)
export CONTEXT7_API_KEY="your-key-here"

# or add to ~/.zshrc / ~/.bashrc
echo 'export CONTEXT7_API_KEY="your-key-here"' >> ~/.zshrc
```

If you use the Context7 MCP entry from this repo, the same env var is read automatically.

Or run the official setup (handles auth for you):

```bash
npx ctx7 setup
```

## Firecrawl — live web scrape / search

**Why:** so the agent can pull clean page content from the public web.

1. Create an account at [firecrawl.dev](https://www.firecrawl.dev)
2. Copy an API key
3. Export it:

```bash
export FIRECRAWL_API_KEY="fc-your-key-here"
# or
echo 'export FIRECRAWL_API_KEY="fc-your-key-here"' >> ~/.zshrc
```

Restart Cursor / Claude Code after setting keys so MCP servers pick them up.

## Check

```bash
echo "context7: ${CONTEXT7_API_KEY:+set}"
echo "firecrawl: ${FIRECRAWL_API_KEY:+set}"
```
