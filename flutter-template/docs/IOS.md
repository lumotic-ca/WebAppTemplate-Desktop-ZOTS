# iOS support

The iOS target is scaffolded and wired to the same mobile WebView host as Android. No separate iOS WebView implementation is required.

## How it works

- Platform detection in `lib/services/webview/webview_host_factory.dart` routes iOS to `MobileWebViewHost`
- Connecting opens the inline `WebViewScreen` using `webview_flutter` + WKWebView
- Connection Hub, Settings, and persistence behave identically to Android

## Requirements

- macOS with Xcode 15 or newer
- Apple Developer account for device testing and App Store distribution
- CocoaPods (`sudo gem install cocoapods` if not present)

```bash
cd ios && pod install && cd ..
flutter doctor
```

## Configure signing

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target → **Signing & Capabilities**
3. Set **Team** to your Apple Developer team
4. Set **Bundle Identifier** to match `AppConfig.appId` in `lib/core/config/app_config.dart` (default: `com.lumotic.webapp_template`)

Or edit `ios/Runner.xcodeproj/project.pbxproj` / Flutter build settings if you prefer CLI-only workflows.

## Run on simulator or device

```bash
flutter run -d ios
```

For a connected physical device, ensure the device is trusted and provisioning profiles are valid.

## Build for release

```bash
flutter build ios --release
```

Archive and upload via Xcode (**Product → Archive**) for TestFlight or App Store distribution.

## Network access

`ios/Runner/Info.plist` includes `NSAllowsArbitraryLoadsInWebContent` so user-entered server URLs load inside the WebView. Forks that need stricter ATS rules should replace this with domain-specific exceptions.

## Testing checklist

- [ ] Add server URL on Connection Hub
- [ ] Connect — wrapped site loads in inline WebView
- [ ] Back/disconnect returns to hub
- [ ] Last server persists after force-quit
- [ ] Settings theme toggle works
- [ ] Safe area and rotation on phone and iPad
- [ ] Self-signed or internal HTTPS hosts (if used) load correctly

## Known considerations

- WebView performance on iOS is generally excellent with WKWebView
- If you see rendering issues with Impeller on simulators, test on a physical device first
- For apps that need camera, microphone, or geolocation inside the WebView, add the corresponding `Info.plist` usage descriptions
