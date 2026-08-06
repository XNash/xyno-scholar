# Xyno Scholar

A private, single-user Flutter Web app that helps a licence-level scholar
discover and refine interdisciplinary research topics (History, Catholic
Theology, Art History by default — the field list is fully user-editable).
Pure client-side app: no backend, no server-held secrets, deployable as
static files.

The app calls the Mistral API (`mistral-large-latest`, via the
`chat/completions` endpoint) using a Mistral API key entered by the user at
runtime. Requests go through a minimal, stateless Cloudflare Worker relay
(see [`worker/`](worker/)) rather than straight to `api.mistral.ai`, because
Mistral's endpoint doesn't reliably answer browser CORS preflight requests —
see [Notes on the Mistral API, CORS, and the relay Worker](#notes-on-the-mistral-api-cors-and-the-relay-worker)
below. Generation calls use Mistral's `response_format: { type:
"json_object" }` for valid-JSON output, with the exact response schema also
spelled out in the system prompt (JSON mode alone only guarantees syntactic
validity, not our schema shape).

> **The API key is entered in-app and is never stored in this repository or
> in the build output.** It lives only in the browser's memory for the
> current session (optionally mirrored to `sessionStorage`, never
> `localStorage`, if the user opts in) — closing the tab clears it.

## Requirements

- Flutter SDK (stable channel, 3.35+) with web support enabled:
  `flutter config --enable-web`
- A Mistral API key from [console.mistral.ai](https://console.mistral.ai/)
  (entered in the app, not configured at build time)

## Running in development

```bash
flutter pub get
flutter run -d chrome
```

This opens the app in Chrome with hot reload. On first run you'll see the
"Enter your Mistral API key" screen — paste your key there to unlock the app.

## Building for release

```bash
flutter build web --release
```

Output is written to `build/web/` as fully static files (HTML/JS/CSS/assets).
No environment variables or secrets are needed at build time — the API key
is supplied by the user at runtime, in their browser.

## Deploying

### Netlify

- **Drag-and-drop**: run `flutter build web --release`, then drag the
  `build/web` folder onto [app.netlify.com/drop](https://app.netlify.com/drop).
- **Git-based deploy**: set the build command to
  `flutter build web --release` and the publish directory to `build/web`
  (requires the Flutter SDK available in the Netlify build image, or use the
  community Flutter Netlify plugin).

### GitHub Pages

1. `flutter build web --release`
2. Publish the contents of `build/web` to a `gh-pages` branch (e.g. via
   `git subtree push --prefix build/web origin gh-pages`, or a GitHub Actions
   workflow that runs the build and deploys `build/web`).
3. If serving from a subpath (`https://<user>.github.io/<repo>/`), pass
   `--base-href /<repo>/` to `flutter build web --release`.

## Notes on the Mistral API, CORS, and the relay Worker

Mistral's `chat/completions` endpoint doesn't reliably answer browser CORS
preflight (`OPTIONS`) requests for POST calls with a JSON `Content-Type` and
an `Authorization` header — a direct `fetch()` from the browser to
`api.mistral.ai` fails with a CORS error before the request ever reaches
Mistral. To work around this without giving up the "no backend, BYOK"
model, requests go through a minimal Cloudflare Worker
(`xyno-scholar-relay`, see [`worker/`](worker/)) that does nothing but add
the missing CORS headers and forward the request and response verbatim.

The Worker is a dumb, stateless relay:

- It reads whatever `Authorization` header and JSON body the client sends.
- It forwards them unchanged to `https://api.mistral.ai/v1/chat/completions`.
- It returns Mistral's response with CORS headers attached.
- **It never stores, logs, or has any state.** The user's Mistral key still
  never touches any server-side storage — it's forwarded on each request and
  forgotten immediately after, exactly the same BYOK guarantee as a direct
  call would have, just with one extra stateless hop.

See [`worker/README.md`](worker/README.md) for how to redeploy the Worker if
it ever needs to change.

## Notes on fonts and offline use

The app loads its webfonts (Fraunces, Inter, JetBrains Mono) via
`google_fonts` at runtime from Google's font CDN, and by default fetches the
CanvasKit web renderer from Google's CDN as well (`flutter build web
--release` bundles a local copy of CanvasKit too; pass
`--no-web-resources-cdn` at build time to serve it locally instead of from
the CDN). A normal internet connection in the visitor's browser is all that's
required — no app-specific configuration is needed for this in a typical
deployment.

## Project structure

```
lib/
  app.dart                 # MaterialApp + unlock/home routing
  main.dart                # entry point (ProviderScope)
  l10n/strings.dart         # lightweight FR/EN UI copy
  models/                  # PreferenceBlock, enums, response schema
  providers/                # Riverpod state (API key, preferences, generation, notebook)
  services/                  # Mistral client, sanitization, field detection, storage, BibTeX
  screens/                   # key entry screen, home screen
  theme/                      # typography + color palette
  widgets/
    sidebar/                  # field/level/scope/tone/mood/free-text panels
    output/                    # broad topics, narrow topic view, tabs
    notebook/                   # notebook drawer
    dialogs/                     # BibTeX export dialog
    common/                        # shared MarkdownText widget
worker/                        # stateless Cloudflare Worker CORS relay (see worker/README.md)
```
