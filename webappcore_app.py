"""
WebAppCore Desktop — main entry point (Windows only).
Uses pywebview (Edge WebView2) for OS-native rendering.
"""

import os
import sys

import webview
from dotenv import load_dotenv

from webappcore.bridge import AppBridge
from webappcore.download_engine import DownloadEngine
from webappcore.settings import settings_manager
from webappcore.tray import TrayController
from webappcore.utils import normalize_app_url, resource_path


load_dotenv()

# CORE: pywebview global settings
webview.settings["ALLOW_DOWNLOADS"] = True
webview.settings["OPEN_EXTERNAL_LINKS_IN_BROWSER"] = False
# CORE: Useful for homelab HTTPS with private CAs / self-signed certs.
webview.settings["IGNORE_SSL_ERRORS"] = True

# CORE: JS injected into the remote web UI after each page load.
# Intercepts download navigations and triggers native browser downloads
# via hidden iframe (full auth, no CORS issues).
DOWNLOAD_INTERCEPT_JS = """
(function() {
    if (window._wacInterceptInstalled) return;
    window._wacInterceptInstalled = true;

    function _wacAbsUrl(url) {
        if (!url) return '';
        try {
            if (url.startsWith('/')) return window.location.origin + url;
        } catch (_) {}
        return url;
    }

    function _wacIsDownloadUrl(url) {
        return !!url && String(url).indexOf('/download/') !== -1;
    }

    function _wacStartDownload(url) {
        var absUrl = _wacAbsUrl(url);
        var api = window.pywebview && window.pywebview.api;
        if (!api) return;

        api.register_download(absUrl);

        var iframe = document.createElement('iframe');
        iframe.style.display = 'none';
        iframe.src = absUrl;
        document.body.appendChild(iframe);
        setTimeout(function() {
            try { document.body.removeChild(iframe); } catch(_) {}
        }, 120000);

        setTimeout(function() {
            if (api.navigate_main_to_panel) api.navigate_main_to_panel('downloads');
        }, 2000);
    }

    (function _wacInstallTabs() {
        if (document.getElementById('wac-desktop-tabs')) return;
        var bar = document.createElement('div');
        bar.id = 'wac-desktop-tabs';
        bar.style.position = 'fixed';
        bar.style.top = '0';
        bar.style.left = '0';
        bar.style.right = '0';
        bar.style.zIndex = '2147483647';
        bar.style.height = '40px';
        bar.style.display = 'flex';
        bar.style.alignItems = 'center';
        bar.style.gap = '8px';
        bar.style.padding = '0 10px';
        bar.style.background = 'rgba(9, 9, 11, 0.88)';
        bar.style.backdropFilter = 'blur(10px)';
        bar.style.borderBottom = '1px solid rgba(63, 63, 70, 0.75)';
        bar.style.fontFamily = 'system-ui, -apple-system, Segoe UI, Roboto, sans-serif';
        bar.style.userSelect = 'none';

        function mkBtn(label, onClick) {
            var b = document.createElement('button');
            b.type = 'button';
            b.textContent = label;
            b.style.cursor = 'pointer';
            b.style.border = '1px solid rgba(63, 63, 70, 0.9)';
            b.style.borderRadius = '8px';
            b.style.background = 'rgba(39, 39, 42, 0.9)';
            b.style.color = '#fafafa';
            b.style.padding = '5px 10px';
            b.style.fontSize = '12px';
            b.style.fontWeight = '600';
            b.addEventListener('click', function(ev) {
                ev.preventDefault();
                ev.stopPropagation();
                try { onClick(); } catch (_) {}
            }, true);
            return b;
        }

        bar.appendChild(mkBtn('Remote App', function() {
            if (window.pywebview && window.pywebview.api && window.pywebview.api.navigate_main_to_remote) {
                window.pywebview.api.navigate_main_to_remote();
            }
        }));
        bar.appendChild(mkBtn('Downloads', function() {
            if (window.pywebview && window.pywebview.api && window.pywebview.api.navigate_main_to_panel) {
                window.pywebview.api.navigate_main_to_panel('downloads');
            }
        }));
        bar.appendChild(mkBtn('Settings', function() {
            if (window.pywebview && window.pywebview.api && window.pywebview.api.navigate_main_to_panel) {
                window.pywebview.api.navigate_main_to_panel('settings');
            }
        }));

        document.documentElement.appendChild(bar);
        var style = document.createElement('style');
        style.textContent = 'html, body { padding-top: 40px !important; }';
        document.documentElement.appendChild(style);
    })();

    var _origOpen = window.open;
    window.open = function(url, target, features) {
        if (_wacIsDownloadUrl(url)) {
            _wacStartDownload(url);
            return null;
        }
        return _origOpen.call(window, url, target, features);
    };

    document.addEventListener('click', function(e) {
        var link = e.target.closest('a[href]');
        if (!link) return;
        var href = link.getAttribute('href') || '';
        if (_wacIsDownloadUrl(href)) {
            e.preventDefault();
            e.stopPropagation();
            _wacStartDownload(href);
        }
    }, true);

    try {
        var _origAssign = window.location.assign.bind(window.location);
        window.location.assign = function(url) {
            if (_wacIsDownloadUrl(url)) { _wacStartDownload(url); return; }
            return _origAssign(url);
        };
    } catch (_) {}

    try {
        var _origReplace = window.location.replace.bind(window.location);
        window.location.replace = function(url) {
            if (_wacIsDownloadUrl(url)) { _wacStartDownload(url); return; }
            return _origReplace(url);
        };
    } catch (_) {}

    try {
        if (_wacIsDownloadUrl(window.location.pathname || window.location.href)) {
            _wacStartDownload(window.location.href);
        }
    } catch (_) {}

    document.addEventListener('submit', function(e) {
        try {
            var form = e.target;
            if (!form) return;
            var action = form.getAttribute('action') || '';
            if (_wacIsDownloadUrl(action)) {
                e.preventDefault();
                e.stopPropagation();
                _wacStartDownload(action);
            }
        } catch (_) {}
    }, true);

    document.documentElement.style.overflowX = 'hidden';
    document.body.style.overflowX = 'hidden';
})();
"""


# CORE: When False, the main window is showing local setup HTML — do not inject download hooks.
_inject_download_hooks = False


def set_remote_content_mode(active: bool):
    """True when the main window is (or will be) on the remote web app."""
    global _inject_download_hooks
    _inject_download_hooks = bool(active)


def on_main_loaded():
    """Inject the download intercept script after each remote page load."""
    if main_window and _inject_download_hooks:
        main_window.evaluate_js(DOWNLOAD_INTERCEPT_JS)


def open_server_setup_page():
    """Tray / bridge: load the local server URL form in the main window."""
    set_remote_content_mode(False)
    if main_window:
        p = resource_path(os.path.join("webappcore", "panel", "setup.html"))
        main_window.load_url(f"file:///{p}")


def quit_app():
    """Clean shutdown from tray or other."""
    for w in webview.windows[:]:
        try:
            w.destroy()
        except Exception:
            pass


# ── Globals (set before webview.start) ────────────────────────────

main_window = None
panel_window = None


def main():
    global main_window, panel_window

    if sys.platform != "win32":
        print("WebAppCore is Windows-only.")
        return

    url_raw = settings_manager.get("WEBAPPCORE_URL")
    remote_url = normalize_app_url(url_raw) or url_raw or "http://localhost:8080"

    setup_path = resource_path(os.path.join("webappcore", "panel", "setup.html"))
    setup_url = f"file:///{setup_path}"

    configured = int(settings_manager.get("WEBAPPCORE_SERVER_CONFIGURED", 0)) == 1
    if configured:
        set_remote_content_mode(True)
        initial_main_url = remote_url
    else:
        set_remote_content_mode(False)
        initial_main_url = setup_url

    width = settings_manager.get("WEBAPPCORE_WINDOW_WIDTH") or 1420
    height = settings_manager.get("WEBAPPCORE_WINDOW_HEIGHT") or 940

    panel_html = resource_path(os.path.join("webappcore", "panel", "index.html"))
    panel_url = f"file:///{panel_html}"

    data_dir = settings_manager.settings_dir
    download_engine = DownloadEngine(data_dir)

    bridge = AppBridge(None, None, download_engine, on_remote_navigation=set_remote_content_mode)

    main_window = webview.create_window(
        "WebAppCore",
        url=initial_main_url,
        width=width,
        height=height,
        min_size=(800, 600),
        text_select=True,
        js_api=bridge,
    )
    bridge._main_window = main_window

    panel_window = webview.create_window(
        "WebAppCore - Panel",
        url=panel_url,
        width=700,
        height=600,
        min_size=(500, 400),
        hidden=True,
        js_api=bridge,
    )
    bridge._panel_window = panel_window

    main_window.events.loaded += on_main_loaded

    tray = TrayController(main_window, panel_window, quit_app, on_change_server=open_server_setup_page)
    tray.start()

    webview.start(
        private_mode=False,
        storage_path=data_dir,
    )


if __name__ == "__main__":
    main()
