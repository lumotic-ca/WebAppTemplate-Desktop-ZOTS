# WebAppTemplate

Templates for wrapping web applications in native desktop and mobile shells.

This repository contains multiple template implementations. Pick the stack that fits your targets, fork the repo, and customize branding for each app you ship.

## Templates

| Template | Stack | Status |
|---|---|---|
| [flutter-template/](flutter-template/) | Flutter + native WebView | Ready |
| [tauri-template/](tauri-template/) | Tauri + Svelte shell | Ready |

### flutter-template

Cross-platform wrapper using Flutter for the connection hub and settings UI, with platform-optimized WebViews for the wrapped web app.

**Targets:** Windows, Android, macOS, iOS (scaffolded)

```bash
cd flutter-template
flutter pub get
flutter run -d windows   # or android, macos, linux
```

Documentation:

- [flutter-template/README.md](flutter-template/README.md)
- [flutter-template/docs/ARCHITECTURE.md](flutter-template/docs/ARCHITECTURE.md)
- [flutter-template/docs/FORKING.md](flutter-template/docs/FORKING.md)

### tauri-template

Desktop-only wrapper using Tauri for the shell and native WebViews, with a Svelte connection hub and a separate wrapped window for the remote web app.

**Targets:** Windows, macOS, Linux

```bash
cd tauri-template
npm install
npm run tauri dev
```

Documentation:

- [tauri-template/README.md](tauri-template/README.md)
- [tauri-template/docs/ARCHITECTURE.md](tauri-template/docs/ARCHITECTURE.md)
- [tauri-template/docs/FORKING.md](tauri-template/docs/FORKING.md)

## Apps

Product-specific wrappers built from the templates above.

| App | Description |
|---|---|
| [apps/matcha/ERP/](apps/matcha/ERP/) | **Matcha ERP** — wrappers for self-hosted [ERPNext](https://erpnext.com/) instances (Flutter + Tauri) |

## License

[GNU General Public License v3.0](LICENSE)
