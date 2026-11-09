# Optional API keys

Only **2 of 10** tools need a cloud key. The installer sets up everything that works offline. Add these when you want live docs or web scrape.

## Context7 — live library docs

Stops the agent inventing outdated APIs.

1. Create a free account at [context7.com](https://context7.com)
2. Create an API key
3. Export it:

```bash
export CONTEXT7_API_KEY="your-key-here"
# optional: persist
echo 'export CONTEXT7_API_KEY="your-key-here"' >> ~/.zshrc
```

Or run the official setup (handles auth for you):

```bash
npx ctx7 setup
```

## Firecrawl — live web scrape / search

Lets the agent pull clean page content from the public web.

1. Create an account at [firecrawl.dev](https://www.firecrawl.dev)
2. Copy an API key
3. Export it:

```bash
export FIRECRAWL_API_KEY="fc-your-key-here"
echo 'export FIRECRAWL_API_KEY="fc-your-key-here"' >> ~/.zshrc
```

Restart Cursor / Claude Code after setting keys so MCP servers pick them up.

## Check

```bash
echo "context7: ${CONTEXT7_API_KEY:+set}"
echo "firecrawl: ${FIRECRAWL_API_KEY:+set}"
```
