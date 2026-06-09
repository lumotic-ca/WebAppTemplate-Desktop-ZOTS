# Forking this template

Use this guide to create a new branded desktop web wrapper from `tauri-template` in about 15 minutes.

## 1. Fork or copy

```bash
git clone https://github.com/lumotic-ca/WebAppTemplate-Desktop-ZOTS.git my-app-wrapper
cd my-app-wrapper/tauri-template
```

## 2. Rebrand frontend config

Edit [`src/lib/app-config.ts`](../src/lib/app-config.ts):

```ts
export const appConfig = {
  appName: 'My App',
  identifier: 'com.mycompany.myapp',
  allowedUrlPatterns: ['https://myapp.example.com'],
  userAgentSuffix: 'MyAppWrapper-Tauri/1.0',
};
```

## 3. Rebrand Rust config

Edit [`src-tauri/src/config.rs`](../src-tauri/src/config.rs) with the same allowlist and identifiers. Rust enforces the allowlist at connect time.

**Note:** Tauri bundle identifiers may only contain alphanumeric characters, hyphens, and periods (no underscores). Use `com.mycompany.myapp` not `com.mycompany.my_app`.

## 4. Update Tauri metadata

In [`src-tauri/tauri.conf.json`](../src-tauri/tauri.conf.json):

```json
{
  "productName": "My App",
  "identifier": "com.mycompany.myapp"
}
```

Replace icons in `src-tauri/icons/`.

## 5. Add app-specific settings (optional)

In [`src/routes/settings/+page.svelte`](../src/routes/settings/+page.svelte), add widgets to the "App-specific settings" `SettingsSection`.

Persist new values via additional Tauri commands in `src-tauri/src/commands/`.

## 6. Verify locally

```bash
npm install
npm test
cd src-tauri && cargo test && cd ..
npm run tauri dev
```

Checklist:

- [ ] Add a server URL
- [ ] Connect — wrapped window opens
- [ ] Disconnect — return to hub
- [ ] Restart — last server persists
- [ ] Settings theme toggle works

## 7. Build release artifacts

```bash
npm run tauri build
```

| Platform | Typical output |
|---|---|
| Linux | `.deb`, `.AppImage` in `src-tauri/target/release/bundle/` |
| Windows | `.msi`, `.exe` in `src-tauri/target/release/bundle/` |
| macOS | `.dmg`, `.app` in `src-tauri/target/release/bundle/` |

## Distribution notes

- **Windows 10:** ship [WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/) or use fixed-version redistribution
- **Linux:** WebKitGTK is typically preinstalled; AppImage bundling may need `linuxdeploy` on the build host
- **macOS:** codesign and notarize before distribution outside the App Store

## Flutter vs Tauri

| Use Tauri when… | Use Flutter when… |
|---|---|
| Desktop only (Win/Mac/Linux) | You need Android or iOS |
| Smallest binary size matters | You want one UI toolkit everywhere |
| Rust backend is a fit | Dart/Flutter ecosystem is a fit |
