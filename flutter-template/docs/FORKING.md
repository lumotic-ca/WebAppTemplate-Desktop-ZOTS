# Forking this template

Use this guide to create a new branded web app wrapper from WebAppTemplate in about 15 minutes.

## 1. Fork or clone

```bash
git clone https://github.com/lumotic-ca/WebAppTemplate-Desktop-ZOTS.git my-app-wrapper
cd my-app-wrapper/flutter-template
```

## 2. Rebrand `AppConfig`

Edit [`lib/core/config/app_config.dart`](../lib/core/config/app_config.dart):

```dart
class AppConfig {
  static const String appName = 'My App';
  static const String appId = 'com.mycompany.myapp';

  // Optional: restrict which URLs users can save
  static const List<String> allowedUrlPatterns = [
    'https://myapp.example.com',
    'https://staging.myapp.example.com',
  ];

  static const String defaultUserAgentSuffix = 'MyAppWrapper/1.0';
}
```

Leave `allowedUrlPatterns` empty to allow any valid `http`/`https` URL.

## 3. Update package metadata

In [`pubspec.yaml`](../pubspec.yaml):

```yaml
name: my_app_wrapper
description: Native wrapper for My App.
```

## 4. Replace app icons

| Platform | Location |
|---|---|
| Android | `android/app/src/main/res/mipmap-*` |
| iOS | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` |
| Windows | `windows/runner/resources/app_icon.ico` |
| macOS | `macos/Runner/Assets.xcassets/AppIcon.appiconset/` |

Update display names in platform config files:

- Android: `android/app/src/main/AndroidManifest.xml` → `android:label`
- iOS: `ios/Runner/Info.plist` → `CFBundleDisplayName`
- macOS: `macos/Runner/Configs/AppInfo.xcconfig` → `PRODUCT_NAME`
- Windows: `windows/runner/main.cpp` → window title (or set dynamically later)

## 5. Add app-specific settings (optional)

In [`lib/features/settings/screens/settings_screen.dart`](../lib/features/settings/screens/settings_screen.dart), add widgets to the "App-specific settings" `SettingsSection`:

```dart
SettingsSection(
  title: 'My App',
  children: [
    SwitchListTile(
      title: const Text('Enable notifications'),
      value: mySetting,
      onChanged: (value) => /* persist */,
    ),
  ],
),
```

Use `shared_preferences` or a dedicated service in `lib/services/` for persistence.

## 6. Verify locally

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d windows    # or your target device
```

Test the full flow:

- [ ] Add a server URL
- [ ] Connect and load the wrapped site
- [ ] Disconnect and return to hub
- [ ] Restart app — last server appears, reconnect works
- [ ] Settings: theme toggle, clear servers

## 7. Build release artifacts

```bash
flutter build windows --release
flutter build apk --release
flutter build macos --release
```

Output locations:

- Windows: `build/windows/x64/runner/Release/`
- Android APK: `build/app/outputs/flutter-apk/app-release.apk`
- macOS: `build/macos/Build/Products/Release/`

## iOS (when ready)

The iOS target is scaffolded and uses the same inline WebView path as Android. To ship on iOS:

1. Open `ios/Runner.xcworkspace` in Xcode on macOS
2. Set your development team and bundle identifier (`AppConfig.appId`)
3. Configure signing & capabilities
4. Run `flutter build ios --release` or archive from Xcode
5. Test on a physical device (WebView behavior, navigation gestures, safe areas)

No additional WebView code changes are required — iOS uses `webview_flutter` via the mobile host in `lib/services/webview/webview_host_mobile.dart`.

## What not to change

Keep these stable across forks unless you have a strong reason:

- `lib/services/webview/` platform abstraction
- `lib/services/persistence/connection_store.dart`
- Router structure in `lib/app.dart`
- CI workflow in `.github/workflows/flutter.yml`

## Distribution notes

- **Windows 10**: ship [WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/) or use fixed-version redistribution
- **Android**: prefer AAB for Play Store (`flutter build appbundle`)
- **macOS**: notarize before distribution outside the App Store
