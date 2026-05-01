"""
Python-JS bridge (pywebview js_api) for the local panel window.
All public methods are callable from JS via window.pywebview.api.<method>().
"""

import json
import os
import sys

import webview

from .download_engine import DownloadEngine
from .settings import settings_manager
from .utils import get_default_download_dir, normalize_app_url, open_path, resource_path
from .workers import UnzipWorker
from . import dialogs


class AppBridge:
    """Exposed to JS as window.pywebview.api."""

    def __init__(self, main_window, panel_window, download_engine: DownloadEngine, on_remote_navigation=None):
        self._main_window = main_window
        self._panel_window = panel_window
        self._download_engine = download_engine
        self._on_remote_navigation = on_remote_navigation
        self._unzip_workers: dict[str, UnzipWorker] = {}

    # CORE: Platform

    def get_platform(self) -> str:
        return sys.platform

    # CORE: Main window navigation

    def navigate_main_to_remote(self) -> str:
        """Load the configured remote URL in the main window."""
        url_raw = settings_manager.get("WEBAPPCORE_URL") or ""
        normalized = normalize_app_url(url_raw) or url_raw
        if not normalized:
            return json.dumps({"ok": False, "error": "Remote URL is not configured."})

        if self._on_remote_navigation:
            self._on_remote_navigation(True)
        if self._main_window:
            self._main_window.load_url(normalized)
            self._main_window.show()
        return json.dumps({"ok": True})

    def navigate_main_to_panel(self, tab: str = "downloads") -> str:
        """Load the local panel UI in the main window, optionally selecting a tab via hash."""
        tab_norm = (tab or "").strip().lower() or "downloads"
        if tab_norm not in ("downloads", "settings"):
            tab_norm = "downloads"

        path = resource_path(os.path.join("webappcore", "panel", "index.html"))
        url = f"file:///{path}#{tab_norm}"

        if self._on_remote_navigation:
            self._on_remote_navigation(False)
        if self._main_window:
            self._main_window.load_url(url)
            self._main_window.show()
        return json.dumps({"ok": True})

    # CORE: Settings

    def get_settings(self) -> str:
        return json.dumps(settings_manager.get_all())

    def save_settings(self, data_json: str) -> str:
        try:
            data = json.loads(data_json)
            url = data.get("WEBAPPCORE_URL")
            if url:
                normalized = normalize_app_url(url)
                if not normalized:
                    return json.dumps({"ok": False, "error": "Invalid URL"})
                data["WEBAPPCORE_URL"] = normalized
                data["WEBAPPCORE_SERVER_CONFIGURED"] = 1
            settings_manager.set_many(data)
            if self._main_window:
                new_url = settings_manager.get("WEBAPPCORE_URL")
                if self._on_remote_navigation and new_url:
                    self._on_remote_navigation(True)
                self._main_window.load_url(new_url)
            return json.dumps({"ok": True})
        except Exception as e:
            return json.dumps({"ok": False, "error": str(e)})

    def complete_server_setup(self, url: str) -> str:
        """Validate URL, save, mark onboarding done, load remote URL in the main window."""
        normalized = normalize_app_url((url or "").strip())
        if not normalized:
            return json.dumps(
                {
                    "ok": False,
                    "error": "Enter a valid URL with a host, e.g. https://app.home or http://192.168.1.10:8080",
                }
            )
        settings_manager.set("WEBAPPCORE_URL", normalized)
        settings_manager.set("WEBAPPCORE_SERVER_CONFIGURED", 1)
        if self._on_remote_navigation:
            self._on_remote_navigation(True)
        if self._main_window:
            self._main_window.load_url(normalized)
        return json.dumps({"ok": True, "url": normalized})

    def show_server_setup(self) -> str:
        """Open the local setup page in the main window (change server / fix connection)."""
        path = resource_path(os.path.join("webappcore", "panel", "setup.html"))
        setup_url = f"file:///{path}"
        if self._on_remote_navigation:
            self._on_remote_navigation(False)
        if self._main_window:
            self._main_window.load_url(setup_url)
        return json.dumps({"ok": True})

    # CORE: Download pipeline
    # The browser handles the actual download (via hidden iframe with full
    # auth). These methods manage records and a filesystem watcher that
    # detects new files and tracks progress in the download folder.

    def get_downloads(self) -> str:
        records = self._download_engine.get_records()
        return json.dumps(records)

    def register_download(self, url: str) -> str:
        """Called by JS when a download link is intercepted."""
        download_dir = settings_manager.get("WEBAPPCORE_DEFAULT_DOWNLOAD_DIR") or get_default_download_dir()

        def on_progress(dl_id, received, total):
            pct = int((received / total) * 100) if total > 0 else 0
            if self._main_window:
                self._main_window.evaluate_js(
                    f'if(window._onDownloadProgress) window._onDownloadProgress("{dl_id}",{received},{total},{pct})'
                )

        def on_complete(dl_id):
            if self._main_window:
                self._main_window.evaluate_js(
                    f'if(window._onDownloadComplete) window._onDownloadComplete("{dl_id}")'
                )

        def on_error(dl_id, msg):
            if self._main_window:
                safe_msg = msg.replace("\\", "\\\\").replace('"', '\\"').replace("\n", " ")
                self._main_window.evaluate_js(
                    f'if(window._onDownloadError) window._onDownloadError("{dl_id}","{safe_msg}")'
                )

        try:
            dl_id = self._download_engine.register_download(
                url, download_dir, on_progress=on_progress, on_complete=on_complete, on_error=on_error
            )
            return json.dumps({"ok": True, "id": dl_id})
        except Exception as e:
            return json.dumps({"ok": False, "error": str(e)})

    def cancel_download(self, dl_id: str):
        self._download_engine.cancel_download(dl_id)

    def remove_download(self, dl_id: str):
        self._download_engine.remove_record(dl_id)

    def remove_zip(self, path: str) -> str:
        try:
            if os.path.exists(path):
                os.remove(path)
            return json.dumps({"ok": True})
        except Exception as e:
            return json.dumps({"ok": False, "error": str(e)})

    def open_file(self, path: str):
        open_path(path)

    def open_folder(self, path: str):
        open_path(os.path.dirname(path))

    # CORE: ZIP extraction / installer launcher

    def unzip_file(self, zip_path: str, target_dir: str = "") -> str:
        """Start an extraction. Returns immediately, progress via JS callbacks."""
        if not target_dir:
            default_unzip_dir = settings_manager.get("WEBAPPCORE_DEFAULT_UNZIP_DIR")
            download_dir = settings_manager.get("WEBAPPCORE_DEFAULT_DOWNLOAD_DIR")
            base = default_unzip_dir or download_dir or get_default_download_dir()
            basename = os.path.splitext(os.path.basename(zip_path))[0]
            target_dir = os.path.join(base, basename)

        os.makedirs(target_dir, exist_ok=True)
        unzip_id = os.path.basename(zip_path)

        def on_progress(pct):
            if self._panel_window:
                self._panel_window.evaluate_js(
                    f'if(window._onUnzipProgress) window._onUnzipProgress("{unzip_id}",{pct})'
                )

        def on_finished():
            if self._panel_window:
                self._panel_window.evaluate_js(
                    f'if(window._onUnzipFinished) window._onUnzipFinished("{unzip_id}")'
                )
            self._unzip_workers.pop(unzip_id, None)

        def on_error(msg):
            if self._panel_window:
                safe = msg.replace("\\", "\\\\").replace('"', '\\"')
                self._panel_window.evaluate_js(
                    f'if(window._onUnzipError) window._onUnzipError("{unzip_id}","{safe}")'
                )
            self._unzip_workers.pop(unzip_id, None)

        worker = UnzipWorker(zip_path, target_dir, on_progress, None, on_finished, on_error)
        self._unzip_workers[unzip_id] = worker
        worker.start()
        return json.dumps({"ok": True, "target_dir": target_dir})

    def get_exe_list(self, target_dir: str) -> str:
        return json.dumps(dialogs.get_exe_list(target_dir))

    def run_installer(self, launcher_path: str) -> str:
        """Run an installer (blocking)."""
        if sys.platform != "win32":
            return json.dumps({"ok": False, "error": "Installer launching is supported on Windows only."})
        code = dialogs.launch_windows_installer(launcher_path)
        return json.dumps({"ok": True, "exit_code": code})

    # CORE: File dialogs

    def pick_directory(self, title: str = "Select Directory") -> str:
        result = self._panel_window.create_file_dialog(webview.FOLDER_DIALOG, directory="", allow_multiple=False)
        if result and len(result) > 0:
            return result[0]
        return ""

    def pick_file(self, title: str = "Select File", file_types: str = "") -> str:
        ft = tuple(file_types.split(";")) if file_types else ()
        result = self._panel_window.create_file_dialog(
            webview.OPEN_DIALOG, directory="", allow_multiple=False, file_types=ft
        )
        if result and len(result) > 0:
            return result[0]
        return ""

    # CORE: Window control

    def show_main(self):
        if self._main_window:
            self._main_window.show()

    def show_panel(self):
        if self._panel_window:
            self._panel_window.show()

