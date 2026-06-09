# Contributing

Thank you for contributing to WebAppTemplate. This project is a cross-platform Flutter wrapper template meant to be forked for individual web apps.

## Before you start

1. Read the [README](README.md)
2. Review [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
3. Run `flutter doctor` and ensure your target platform is ready

## Development setup

```bash
git clone https://github.com/lumotic-ca/WebAppTemplate-Desktop-ZOTS.git
cd WebAppTemplate-Desktop-ZOTS/flutter-template
flutter pub get
flutter run -d windows   # or android, macos
```

## Code style

- Follow the [Dart style guide](https://dart.dev/effective-dart/style)
- Run `dart format .` before committing
- Run `flutter analyze` — zero issues policy
- Keep platform WebView logic inside `lib/services/webview/`
- Put fork-specific branding in `lib/core/config/app_config.dart`, not scattered constants

## Branching

- `main` — stable template
- `feature/<description>` — new features
- `fix/<description>` — bug fixes

## Pull requests

1. Branch from `main`
2. Include tests for behavior changes
3. Ensure `flutter analyze` and `flutter test` pass
4. Update docs if architecture or fork workflow changes

## Commit messages

```
Add macOS session screen disconnect shortcut
Fix URL validator for custom schemes
Update FORKING guide with iOS signing steps
```

## Scope guidance

Changes should benefit **all forks** of the template:

- Connection hub UX improvements
- WebView performance on a platform
- Settings extensibility patterns
- CI and documentation

App-specific features belong in forks, not this template.

## License

Contributions are licensed under the [GNU General Public License v3.0](LICENSE).
