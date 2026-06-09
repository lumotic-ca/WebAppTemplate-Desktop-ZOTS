use tauri::{AppHandle, Manager, WebviewUrl, WebviewWindowBuilder};
use tauri_plugin_opener::OpenerExt;
use tauri_plugin_window_state::{StateFlags, WindowExt};
use url::Url;

use crate::navigation::{is_allowed_navigation, is_external_navigation};
use crate::state::AppState;

const MAIN_WINDOW_LABEL: &str = "main";

pub fn show_setup_window(app: &AppHandle) -> Result<(), String> {
    rebuild_main_window(app, WebviewUrl::App("index.html".into()), None)
}

pub fn open_erp_window(app: &AppHandle, server_url: &str) -> Result<(), String> {
    let parsed = Url::parse(server_url).map_err(|_| "Invalid server URL.".to_string())?;
    rebuild_main_window(
        app,
        WebviewUrl::External(parsed),
        Some(server_url.to_string()),
    )
}

pub fn reset_to_setup(app: &AppHandle, state: &AppState) -> Result<(), String> {
    state.clear_server_url()?;
    show_setup_window(app)
}

fn rebuild_main_window(
    app: &AppHandle,
    url: WebviewUrl,
    base_url: Option<String>,
) -> Result<(), String> {
    if let Some(existing) = app.get_webview_window(MAIN_WINDOW_LABEL) {
        existing.close().map_err(|e| e.to_string())?;
    }

    let opener_app = app.clone();
    let mut builder = WebviewWindowBuilder::new(app, MAIN_WINDOW_LABEL, url)
        .title("Matcha ERP")
        .inner_size(1280.0, 800.0)
        .min_inner_size(960.0, 600.0)
        .resizable(true)
        .center();

    #[cfg(not(debug_assertions))]
    {
        builder = builder.devtools(false);
    }

    if let Some(base) = base_url {
        builder = builder.on_navigation(move |target| {
            if is_allowed_navigation(&base, target) {
                return true;
            }

            if is_external_navigation(&base, target) {
                let _ = opener_app
                    .opener()
                    .open_url(target.as_str(), None::<&str>);
            }

            false
        });
    }

    let window = builder.build().map_err(|e| e.to_string())?;
    window
        .restore_state(StateFlags::all())
        .map_err(|e| e.to_string())?;
    window.show().map_err(|e| e.to_string())?;
    window.set_focus().map_err(|e| e.to_string())?;
    Ok(())
}
