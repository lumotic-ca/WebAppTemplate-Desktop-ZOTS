# WebAppTemplate

Templates for wrapping web applications in native desktop and mobile shells.

This repository contains multiple template implementations. Pick the stack that fits your targets, fork the repo, and customize branding for each app you ship.

## Templates

| Template | Stack | Status |
|---|---|---|
| [flutter-template/](flutter-template/) | Flutter + native WebView | Ready |
| [tauri-template/](tauri-template/) | Tauri | Awaiting setup |

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

Reserved for a Tauri-based web app wrapper template. Not yet implemented.

## License

[GNU General Public License v3.0](LICENSE)
