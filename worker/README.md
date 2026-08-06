# xyno-scholar-relay

A minimal, stateless Cloudflare Worker that relays `chat/completions`
requests from the Xyno Scholar browser app to Mistral's API.

## Why this exists

Mistral's `chat/completions` endpoint doesn't reliably respond to browser
CORS preflight (`OPTIONS`) requests for POST calls with a JSON
`Content-Type` and an `Authorization` header — a direct `fetch()` from the
browser to `api.mistral.ai` fails with a CORS error before the request ever
reaches Mistral. This Worker sits in between purely to add the CORS headers
Mistral doesn't return, nothing else.

## What it does — and does not — do

- Reads whatever `Authorization` header and JSON body the client sends.
- Forwards them verbatim to `https://api.mistral.ai/v1/chat/completions`.
- Returns Mistral's response, with CORS headers (`Access-Control-Allow-*`)
  attached.
- **Holds no state.** No API key is ever stored, logged, or persisted by
  the Worker — it passes the `Authorization` header straight through on
  every request and forgets it immediately after. The BYOK model is
  unchanged: the user's Mistral key still lives only in their browser.

## Endpoints / behavior

| Method  | Response |
|---------|----------|
| `OPTIONS` | `204` with CORS headers (preflight) |
| `POST`    | Forwarded to Mistral; returns Mistral's real status + body + CORS headers |
| anything else | `405 Method not allowed` with CORS headers |

## Local development

```bash
cd worker
npx wrangler dev
```

Then verify:

```bash
# Preflight
curl -i -X OPTIONS http://localhost:8787 \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type, Authorization"

# POST (with a throwaway/invalid key — should return Mistral's real 401, with CORS headers)
curl -i -X POST http://localhost:8787 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer invalid-key" \
  -d '{"model":"mistral-large-latest","messages":[{"role":"user","content":"hi"}]}'

# GET (should 405)
curl -i http://localhost:8787
```

## Deploying / redeploying

Requires a Cloudflare API token scoped to **Workers Scripts: Edit** (no
broader account access needed):

```bash
cd worker
CLOUDFLARE_API_TOKEN=<token> npx wrangler deploy
```

The deploy output prints the live `*.workers.dev` URL. If the Worker's
logic ever needs to change (e.g. a different upstream URL), edit
`src/index.js` and redeploy the same way — there's no build step and no
other state to migrate.
