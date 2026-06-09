# WebAppTemplate

A starter template for building **web applications with Flutter**.

This repository is being rebuilt around Flutter as the primary framework. The previous Python + pywebview desktop shell has been removed in favor of a cross-platform web-first approach using Flutter's web target.

## Goals

- **Single codebase** for web (and optionally desktop/mobile) using Flutter and Dart
- **Modern UI** with Material 3, responsive layouts, and accessible components
- **Production-ready patterns** for routing, state management, API integration, and deployment
- **Reusable template** that can be forked and customized for new web app projects

## Planned stack

| Layer | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) (web target) |
| Language | Dart |
| UI | Material 3 / Cupertino (platform-adaptive) |
| Routing | `go_router` |
| State | TBD (e.g. Riverpod, Bloc, or Provider) |
| HTTP | `http` or `dio` |
| Build & deploy | `flutter build web` → static hosting (GitHub Pages, Firebase, Netlify, etc.) |

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, web support enabled)
- A code editor ([VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio))
- Chrome (or another supported browser) for local web development

Verify your setup:

```bash
flutter doctor
flutter config --enable-web
```

## Getting started

The Flutter project scaffold has not been generated yet. Once it is in place, the typical workflow will be:

```bash
# Install dependencies
flutter pub get

# Run in Chrome (hot reload enabled)
flutter run -d chrome

# Build for production
flutter build web --release
```

Output will land in `build/web/` and can be deployed to any static file host.

## Project structure (planned)

```
lib/
  main.dart              # App entry point
  app.dart               # Root widget, theme, router
  core/                  # Shared utilities, constants, theme
  features/              # Feature modules (screens, widgets, logic)
  services/              # API clients, persistence, platform services
web/
  index.html             # Web entry HTML
  manifest.json          # PWA manifest
  icons/                 # App icons
test/                    # Unit and widget tests
integration_test/        # End-to-end tests
```

## Development workflow

1. **Fork** this repository for your app
2. **Scaffold** the Flutter project (or pull in the template once added)
3. **Develop** features under `lib/features/`
4. **Test** with `flutter test` and browser manual QA
5. **Build** with `flutter build web --release`
6. **Deploy** the `build/web/` directory to your hosting provider

## Deployment options

Flutter web builds to static assets. Common hosting targets:

- **GitHub Pages** — push `build/web` to a `gh-pages` branch or use Actions
- **Firebase Hosting** — `firebase deploy` after `flutter build web`
- **Netlify / Vercel** — point the publish directory at `build/web`
- **Self-hosted** — serve `build/web` behind nginx, Caddy, or any static file server

## What changed

This repo previously shipped a **Windows-only Python desktop wrapper** (pywebview + Edge WebView2) with a local control panel, download manager, and tray integration. That approach has been retired. The new direction is **Flutter web apps** that run in the browser and can optionally be compiled for desktop and mobile from the same codebase.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

## Status

**In progress** — documentation and project direction are set. Awaiting further instructions before scaffolding the Flutter application.
