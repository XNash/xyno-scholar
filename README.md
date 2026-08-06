# Xyno Scholar

A private, single-user Flutter Web app that helps a licence-level scholar
discover and refine interdisciplinary research topics (History, Catholic
Theology, Art History by default — the field list is fully user-editable).
Pure client-side app: no backend, no server-held secrets, deployable as
static files.

The app calls the Google Gemini API (`gemini-3.6-flash`, via the
`generateContent` REST endpoint) directly from the browser using a Gemini
API key entered by the user at runtime. Generation calls use Gemini's native
structured output (`responseSchema` + `responseMimeType: "application/json"`)
so responses are schema-conformant JSON rather than prompted-for JSON.

> **The API key is entered in-app and is never stored in this repository or
> in the build output.** It lives only in the browser's memory for the
> current session (optionally mirrored to `sessionStorage`, never
> `localStorage`, if the user opts in) — closing the tab clears it.

## Requirements

- Flutter SDK (stable channel, 3.35+) with web support enabled:
  `flutter config --enable-web`
- A Gemini API key from [Google AI Studio](https://aistudio.google.com/apikey)
  (entered in the app, not configured at build time)

## Running in development

```bash
flutter pub get
flutter run -d chrome
```

This opens the app in Chrome with hot reload. On first run you'll see the
"Enter your Gemini API key" screen — paste your key there to unlock the app.

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

## Notes on the Gemini API and CORS

This app calls Gemini directly from the browser with no proxy, using the
standard `models/{model}:generateContent` REST endpoint (not the newer
streaming/Interactions-style endpoints, which currently fail CORS preflight
in browsers). If Google ever changes the CORS policy for this endpoint,
direct calls from a deployed static site could start failing with a CORS
error in the browser console — in that case, a minimal CORS-passthrough
function (which does not need to hold any secret; the user's key still
travels from the client on every request) would need to sit in front of the
API endpoint.

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
  services/                  # Gemini client, sanitization, field detection, storage, BibTeX
  screens/                   # key entry screen, home screen
  theme/                      # typography + color palette
  widgets/
    sidebar/                  # field/level/scope/tone/mood/free-text panels
    output/                    # broad topics, narrow topic view, tabs
    notebook/                   # notebook drawer
    dialogs/                     # BibTeX export dialog
    common/                        # shared MarkdownText widget
```
