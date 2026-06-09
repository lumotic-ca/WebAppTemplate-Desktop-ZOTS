# WebApp Template

A cross-platform **Flutter wrapper template** for turning existing web apps into native-feeling desktop and mobile applications.

Fork this repo, set your branding in `lib/core/config/app_config.dart`, and ship Windows, Android, macOS, and iOS shells that load your web app inside a native WebView with a polished connection hub and settings UI.

## What you get

- **Connection Hub** — users pick or add the server URL to connect to; choices persist across restarts
- **Settings** — theme mode, reconnect-on-launch, clear saved servers; extensible section for app-specific options
- **Platform-optimized WebView**
  - Android / iOS: inline native WebView
  - Windows: high-performance WebView2 via `webview_win_floating`
  - macOS: separate native WKWebView window via `desktop_webview_window`
- **Fork-friendly config** — one file to rebrand each new app

## Supported platforms

| Platform | Status | WebView engine |
|---|---|---|
| Windows | Supported | WebView2 |
| Android | Supported | System WebView |
| macOS | Supported | WKWebView (separate window) |
| iOS | Scaffolded | WKWebView (inline) — see [docs/IOS.md](docs/IOS.md) |
| Linux | Stub | Not yet implemented |

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Platform tooling for your targets (`flutter doctor`)
- **Windows**: [WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/) on Windows 10 machines
- **macOS / iOS**: Xcode 15+
- **Android**: Android SDK

```bash
flutter doctor
```

## Quick start

```bash
git clone https://github.com/lumotic-ca/WebAppTemplate-Desktop-ZOTS.git
cd WebAppTemplate-Desktop-ZOTS/flutter-template
flutter pub get
flutter run -d windows   # or chrome device id, android, macos
```

### Typical flow

1. Launch app → Connection Hub
2. Add a server URL (e.g. `https://myapp.example.com`)
3. Tap **Connect** → wrapped site opens in native WebView
4. Disconnect to return to the hub; last server is remembered

## Project structure

```
lib/
  core/config/app_config.dart     # Fork customization
  features/
    connection/                   # Hub + add/edit servers
    settings/                     # App settings
    shell/                        # Bootstrap / splash
    webview/                      # Inline + session screens
  services/
    persistence/                  # Saved connections
    webview/                      # Platform WebView hosts
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for design details and [docs/FORKING.md](docs/FORKING.md) for creating a new app from this template.

## Build for release

```bash
flutter build windows --release
flutter build apk --release
flutter build appbundle --release
flutter build macos --release
flutter build ios --release   # requires macOS + Xcode signing
```

## Customize for a new app

1. Edit [`lib/core/config/app_config.dart`](lib/core/config/app_config.dart) — app name, bundle id, URL allowlist
2. Replace platform icons in `android/`, `ios/`, `windows/`, `macos/`
3. Update `pubspec.yaml` name and description
4. Add app-specific settings widgets under the "App-specific settings" section

Full guide: [docs/FORKING.md](docs/FORKING.md)

## Development

```bash
flutter analyze
flutter test
```

CI runs analyze, test, and release builds for Windows, Android, and macOS on every push to `main`.

## License

[GNU General Public License v3.0](LICENSE)
