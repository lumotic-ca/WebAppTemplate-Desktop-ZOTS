# Architecture

This document describes the planned architecture for Flutter web apps built from this template.

## Overview

```
┌─────────────────────────────────────────────────────────┐
│                     Browser (Web)                      │
│  ┌───────────────────────────────────────────────────┐  │
│  │              Flutter Web App (Dart)                │  │
│  │  ┌─────────┐  ┌──────────┐  ┌─────────────────┐  │  │
│  │  │ Router  │  │  State   │  │  UI (Widgets)   │  │  │
│  │  └────┬────┘  └────┬─────┘  └────────┬────────┘  │  │
│  │       │            │                  │           │  │
│  │       └────────────┴──────────────────┘           │  │
│  │                         │                          │  │
│  │                  ┌──────▼──────┐                   │  │
│  │                  │  Services   │                   │  │
│  │                  └──────┬──────┘                   │  │
│  └─────────────────────────┼───────────────────────────┘  │
└────────────────────────────┼──────────────────────────────┘
                             │ HTTP / WebSocket
                    ┌────────▼────────┐
                    │  Backend API    │
                    │  (external)     │
                    └─────────────────┘
```

## Layers

### Presentation (`lib/features/`)

Each feature is a self-contained module:

- **Screens** — route-level widgets
- **Widgets** — reusable UI components scoped to the feature
- **Controllers / Notifiers** — feature-specific state and user actions

Features should not import from each other's internal folders. Shared UI goes in `lib/core/widgets/`.

### Application (`lib/app.dart`, router)

- App-wide theme (light/dark, typography, color scheme)
- Route definitions and navigation guards
- Global error handling and loading overlays

### Core (`lib/core/`)

Cross-cutting concerns used by multiple features:

- Theme tokens and extensions
- Constants and environment configuration
- Shared widgets (buttons, inputs, layout shells)
- Utilities (formatting, validation)

### Services (`lib/services/`)

Platform and network boundaries:

- REST/GraphQL API clients
- Authentication token storage
- Local persistence (shared_preferences, IndexedDB via plugins)

Services expose interfaces; features depend on abstractions, not HTTP details.

## Routing

Use declarative routing with `go_router`:

- Deep links work out of the box on web
- Route guards for authentication
- Nested navigation for shell layouts (sidebar + content)

## State management

State management choice is TBD. Candidates:

| Option | Strengths |
|---|---|
| **Riverpod** | Compile-safe, testable, good for medium/large apps |
| **Bloc** | Explicit event/state flow, strong for complex UIs |
| **Provider** | Simple, built into the ecosystem, good for smaller apps |

The template will pick one and demonstrate patterns for async data, form state, and dependency injection.

## Web-specific considerations

- **URL strategy** — use path-based URLs (`/dashboard`, not `/#/dashboard`) via `flutter_web_plugins` `usePathUrlStrategy()`
- **Responsive design** — breakpoints for mobile, tablet, and desktop widths
- **PWA** — optional service worker and manifest for installable web apps
- **SEO** — server-side rendering is not native to Flutter web; consider prerendering or a landing page if SEO is critical
- **Bundle size** — tree-shake icons, defer heavy features, use `--wasm` when stable for smaller payloads

## Testing strategy

| Level | Tool | Scope |
|---|---|---|
| Unit | `flutter test` | Pure Dart logic, services with mocks |
| Widget | `flutter test` | Individual widgets and screens |
| Integration | `integration_test` | Full user flows in a real browser |

## Deployment pipeline (planned)

1. `flutter analyze` — static analysis, zero warnings policy
2. `flutter test` — unit and widget tests
3. `flutter build web --release` — optimized production build
4. Deploy `build/web/` to hosting target

CI will be added once the Flutter project is scaffolded.

## Multi-platform path (optional)

The same codebase can target additional platforms without changing the architecture:

```bash
flutter run -d chrome    # Web
flutter run -d windows   # Desktop
flutter run -d android   # Mobile
```

Platform-specific code lives behind service abstractions in `lib/services/`, using conditional imports or `kIsWeb` checks only at the boundary.
