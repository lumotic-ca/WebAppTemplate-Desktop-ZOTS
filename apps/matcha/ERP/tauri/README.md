# Matcha ERP — Tauri

Minimal, production-ready **Tauri v2** desktop wrapper for self-hosted [ERPNext](https://erpnext.com/) instances.

## Features

- Single native window that loads your ERPNext URL directly
- First-run setup: enter server URL once, persisted across reboots
- Page zoom via keyboard and mousewheel (`Ctrl + +/-`, `Ctrl + 0`, `Ctrl + scroll`)
- External links open in the system browser (same-origin navigation stays in-app)
- Window size/position restored via `tauri-plugin-window-state`
- Production builds block devtools shortcuts; right-click paste is allowed
- Strict CSP for the local setup/splash UI; minimal Tauri IPC surface

## Quick start

```bash
cd apps/matcha/ERP/tauri
npm install
npm run tauri dev
```

## Build

```bash
npm run tauri build
```

Artifacts: `src-tauri/target/release/bundle/`

## Configuration

| File | Purpose |
|---|---|
| `src-tauri/tauri.conf.json` | Window defaults, CSP, bundle ID |
| `src-tauri/capabilities/main.json` | Minimal IPC permissions |
| `src/main.ts` | Setup form + splash UI |

Server URL is stored at `{app_data_dir}/erp_server_url.txt`.

## Reset server URL

Delete `{app_data_dir}/erp_server_url.txt` and relaunch, or from devtools console (debug builds only):

```js
await window.__TAURI__.core.invoke('reset_server')
```

## App icon

Place your logo source in `branding/` and regenerate icons — see [branding/README.md](branding/README.md).

## Platform notes

- **Windows 10:** requires [WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/)
- **Linux:** WebKitGTK development packages required for build
- **macOS:** codesign for distribution outside local dev

## License

[GPL-3.0-or-later](../../../../LICENSE)
