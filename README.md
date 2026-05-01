# WebAppCore Desktop Template

WebAppCore is a **Windows-only** template for building “desktop wrappers” around existing web apps using **Python + pywebview**. It gives you a reusable shell (tray, settings, local panel UI, download tracking, zip/extract/install helpers) so you can focus on integrating your next web app.

## Core features (template-ready)

- **Desktop shell**: native window via Edge WebView2, plus a tray icon to show/hide/quit.
- **Remote app wrapper**: loads a configurable remote URL inside the main window.
- **Local control panel**: a separate local UI window for settings and download management.
- **Download manager**: tracks browser-initiated downloads and shows progress/history in the panel.
- **ZIP extraction + installer launcher**: unzip downloaded archives and launch a selected `.exe` (Windows).

## Configuration

Most settings are editable inside the local panel. You can also set defaults via environment variables:

| Environment Variable | Description |
|---|---|
| `WEBAPPCORE_URL` | **(Required)** Remote web app URL to load, e.g. `http://localhost:8080`. |
| `WEBAPPCORE_START_MINIMIZED` | Set to `1` to start minimized to the tray. |
| `WEBAPPCORE_ICON_PATH` | Absolute path to a custom tray icon. |
| `WEBAPPCORE_WINDOW_WIDTH` | Main window width. |
| `WEBAPPCORE_WINDOW_HEIGHT` | Main window height. |
| `WEBAPPCORE_DEFAULT_DOWNLOAD_DIR` | Default directory for downloaded files. |
| `WEBAPPCORE_DEFAULT_UNZIP_DIR` | Default base directory for extracting ZIP archives. |
| `WEBAPPCORE_PROMPT_UNZIP_DIR` | Set to `1` to always prompt for an extraction path. |

## Run from source (Windows)

```powershell
py -m pip install -r requirements.txt
py webappcore_app.py
```

## Customize in your fork (high-signal knobs)

- **Download URL detection**: the current injected JS looks for URLs containing `/download/`. Change this to match your target web app.
- **TLS/SSL behavior**: `pywebview` is currently configured to ignore SSL errors for self-hosted environments. Consider gating that behind an env var for production use.
