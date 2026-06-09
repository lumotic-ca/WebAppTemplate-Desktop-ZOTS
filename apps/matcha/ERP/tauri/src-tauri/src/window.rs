use tauri::{AppHandle, Manager, Url, WebviewUrl, WebviewWindow, WebviewWindowBuilder};
use tauri_plugin_window_state::{StateFlags, WindowExt};

use crate::navigation::handle_navigation;
use crate::state::AppState;

pub const MAIN_WINDOW_LABEL: &str = "main";

pub fn show_setup_window(app: &AppHandle) -> Result<(), String> {
    let window = ensure_main_window(app)?;
    window
        .navigate(resolve_app_page(app, "index.html")?)
        .map_err(|e| e.to_string())?;
    window.show().map_err(|e| e.to_string())?;
    window.set_focus().map_err(|e| e.to_string())?;
    Ok(())
}

pub fn open_erp_window(app: &AppHandle, server_url: &str) -> Result<(), String> {
    let parsed = Url::parse(server_url).map_err(|_| "Invalid server URL.".to_string())?;
    let window = ensure_main_window(app)?;
    window.navigate(parsed).map_err(|e| e.to_string())?;
    window.show().map_err(|e| e.to_string())?;
    window.set_focus().map_err(|e| e.to_string())?;
    Ok(())
}

pub fn reset_to_setup(app: &AppHandle, state: &AppState) -> Result<(), String> {
    state.clear_server_url()?;
    show_setup_window(app)
}

pub fn ensure_main_window(app: &AppHandle) -> Result<WebviewWindow, String> {
    if let Some(window) = app.get_webview_window(MAIN_WINDOW_LABEL) {
        return Ok(window);
    }

    let app_handle = app.clone();
    let builder = WebviewWindowBuilder::new(
        app,
        MAIN_WINDOW_LABEL,
        WebviewUrl::App("index.html".into()),
    )
    .title("Matcha ERP")
    .inner_size(1280.0, 800.0)
    .min_inner_size(960.0, 600.0)
    .resizable(true)
    .center()
    .zoom_hotkeys_enabled(true)
    .on_navigation(move |target| handle_navigation(&app_handle, target))
    .devtools(cfg!(debug_assertions));

    let window = builder.build().map_err(|e| e.to_string())?;
    window
        .restore_state(StateFlags::SIZE | StateFlags::POSITION)
        .map_err(|e| e.to_string())?;
    window.show().map_err(|e| e.to_string())?;
    Ok(window)
}

fn resolve_app_page(app: &AppHandle, page: &str) -> Result<Url, String> {
    let page = page.trim_start_matches('/');
    if cfg!(debug_assertions) {
        let dev_url = app
            .config()
            .build
            .dev_url
            .as_ref()
            .ok_or("Missing devUrl in tauri.conf.json.")?;
        let base = dev_url.as_str().trim_end_matches('/');
        Url::parse(&format!("{base}/{page}")).map_err(|e| e.to_string())
    } else {
        Url::parse(&format!("https://tauri.localhost/{page}")).map_err(|e| e.to_string())
    }
}
