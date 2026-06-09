# Contributing

Thank you for your interest in contributing to WebAppTemplate. This project is a Flutter web app template intended to be forked and extended.

## Before you start

1. Read the [README](README.md) for project goals and status
2. Review [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for structural conventions
3. Ensure Flutter is installed and `flutter doctor` passes

## Development setup

Once the Flutter project is scaffolded:

```bash
git clone https://github.com/lumotic-ca/WebAppTemplate-Desktop-ZOTS.git
cd WebAppTemplate-Desktop-ZOTS
flutter pub get
flutter run -d chrome
```

## Code style

- Follow the [Dart style guide](https://dart.dev/effective-dart/style)
- Run `dart format .` before committing
- Run `flutter analyze` and fix all issues
- Keep widgets small and composable; extract when a build method exceeds ~80 lines
- Prefer `const` constructors where possible

## Branching

- `main` — stable template code
- Feature branches — `feature/<short-description>`
- Bug fixes — `fix/<short-description>`

## Pull requests

1. Fork the repository and create a branch from `main`
2. Make focused changes with clear commit messages
3. Add or update tests for behavior changes
4. Ensure `flutter analyze` and `flutter test` pass
5. Open a PR with a description of what changed and why

## Commit messages

Use concise, imperative messages:

```
Add settings screen with theme toggle
Fix router redirect loop on logout
Update README deployment section
```

## What we're building toward

This template aims to provide:

- A clean Flutter web project structure
- Routing, theming, and state management patterns
- API service layer with error handling
- Responsive layouts for web viewports
- CI for analyze, test, and web build
- Deployment documentation for common hosts

If you have ideas that align with these goals, open an issue or PR to discuss before large changes.

## License

By contributing, you agree that your contributions will be licensed under the [GNU General Public License v3.0](LICENSE).
