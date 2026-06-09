# WebApp Template (Tauri)

A **desktop-only** template for wrapping existing web apps in native Tauri shells on Windows, macOS, and Linux.

Fork this folder, set your branding in `src/lib/app-config.ts` and `src-tauri/src/config.rs`, and ship a small native app with a connection hub, settings UI, and a separate high-performance WebView window for the wrapped site.

## What you get

- **Connection Hub** — add, edit, delete, and connect to saved server URLs
- **Persistence** — connections and last-used server survive restarts
- **Settings** — theme mode, reconnect-on-launch, clear servers; extensible app-specific section
- **Dual-window model** — shell UI stays in the main window; wrapped site opens in a dedicated native WebView window with no IPC access
- **Fork-friendly config** — centralized branding and URL allowlist knobs

## Supported platforms

| Platform | Status | WebView engine |
|---|---|---|
| Windows | Supported | WebView2 |
| macOS | Supported | WKWebView |
| Linux | Supported | WebKitGTK |

For mobile targets, use [flutter-template/](../flutter-template/).

## Prerequisites

- [Node.js](https://nodejs.org/) 20+
- [Rust](https://www.rust-lang.org/tools/install) (stable)
- Platform dependencies for [Tauri](https://v2.tauri.app/start/prerequisites/)

**Windows 10:** install the [WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/).

## Quick start

```bash
cd tauri-template
npm install
npm run tauri dev
```

### Typical flow

1. Launch app → Connection Hub
2. Add a server URL (e.g. `https://myapp.example.com`)
3. Click **Connect** → wrapped site opens in a separate window
4. Main window shows session status; use **Disconnect** or close the wrapped window to return

## Project structure

```
src/                 # SvelteKit shell UI
src-tauri/src/       # Rust backend (commands, storage, WebView manager)
src/lib/app-config.ts
docs/
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/FORKING.md](docs/FORKING.md).

## Build for release

```bash
npm run tauri build
```

Outputs land in `src-tauri/target/release/bundle/` (`.deb`, `.msi`, `.dmg`, etc. depending on platform).

## Development checks

```bash
npm test                 # Vitest (URL validation)
cd src-tauri && cargo test
```

## Customize for a new app

1. Edit [`src/lib/app-config.ts`](src/lib/app-config.ts) and [`src-tauri/src/config.rs`](src-tauri/src/config.rs)
2. Update `productName` / `identifier` in [`src-tauri/tauri.conf.json`](src-tauri/tauri.conf.json)
3. Replace icons in `src-tauri/icons/`
4. Add app-specific settings under the placeholder section in Settings

Full guide: [docs/FORKING.md](docs/FORKING.md)

## License

[GNU General Public License v3.0](../LICENSE)
