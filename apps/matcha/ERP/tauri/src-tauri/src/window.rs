use tauri::{
    AppHandle, LogicalPosition, Manager, Url, WebviewUrl, WebviewWindow, WebviewWindowBuilder,
};
use tauri_plugin_window_state::{StateFlags, WindowExt};

use crate::navigation::handle_navigation;
use crate::state::AppState;

pub const MAIN_WINDOW_LABEL: &str = "main";
pub const TOOLBAR_WINDOW_LABEL: &str = "toolbar";
const TOOLBAR_HEIGHT: f64 = 44.0;

pub fn show_setup_window(app: &AppHandle) -> Result<(), String> {
    let window = ensure_main_window(app)?;
    hide_toolbar(app)?;
    window
        .navigate(resolve_app_page(app, "index.html")?)
        .map_err(|e| e.to_string())?;
    window.show().map_err(|e| e.to_string())?;
    window.set_focus().map_err(|e| e.to_string())?;
    Ok(())
}

pub fn show_settings_window(app: &AppHandle) -> Result<(), String> {
    let window = ensure_main_window(app)?;
    hide_toolbar(app)?;
    window
        .navigate(resolve_app_page(app, "settings.html")?)
        .map_err(|e| e.to_string())?;
    window.show().map_err(|e| e.to_string())?;
    window.set_focus().map_err(|e| e.to_string())?;
    Ok(())
}

pub fn open_erp_window(app: &AppHandle, server_url: &str) -> Result<(), String> {
    let parsed = Url::parse(server_url).map_err(|_| "Invalid server URL.".to_string())?;
    let window = ensure_main_window(app)?;
    window.navigate(parsed).map_err(|e| e.to_string())?;
    show_toolbar(app, &window)?;
    window.show().map_err(|e| e.to_string())?;
    window.set_focus().map_err(|e| e.to_string())?;
    Ok(())
}

pub fn refresh_erp(app: &AppHandle) -> Result<(), String> {
    let window = app
        .get_webview_window(MAIN_WINDOW_LABEL)
        .ok_or("Main window is not open.".to_string())?;
    window.reload().map_err(|e| e.to_string())
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
    .on_navigation(move |target| handle_navigation(&app_handle, target))
    .devtools(cfg!(debug_assertions));

    let window = builder.build().map_err(|e| e.to_string())?;
    window
        .restore_state(StateFlags::SIZE | StateFlags::POSITION)
        .map_err(|e| e.to_string())?;
    window.show().map_err(|e| e.to_string())?;
    Ok(window)
}

fn show_toolbar(app: &AppHandle, main: &WebviewWindow) -> Result<(), String> {
    if let Some(toolbar) = app.get_webview_window(TOOLBAR_WINDOW_LABEL) {
        sync_toolbar_geometry(main, &toolbar)?;
        toolbar.show().map_err(|e| e.to_string())?;
        return Ok(());
    }

    let size = main.inner_size().map_err(|e| e.to_string())?;
    let toolbar = WebviewWindowBuilder::new(
        app,
        TOOLBAR_WINDOW_LABEL,
        WebviewUrl::App("toolbar.html".into()),
    )
    .title("Matcha ERP Toolbar")
    .parent(main)
    .map_err(|e| e.to_string())?
    .decorations(false)
    .resizable(false)
    .skip_taskbar(true)
    .inner_size(size.width as f64, TOOLBAR_HEIGHT)
    .position(0.0, 0.0)
    .build()
    .map_err(|e| e.to_string())?;

    toolbar.show().map_err(|e| e.to_string())?;
    Ok(())
}

pub fn hide_toolbar(app: &AppHandle) -> Result<(), String> {
    if let Some(toolbar) = app.get_webview_window(TOOLBAR_WINDOW_LABEL) {
        toolbar.hide().map_err(|e| e.to_string())?;
    }
    Ok(())
}

pub fn sync_toolbar_geometry(main: &WebviewWindow, toolbar: &WebviewWindow) -> Result<(), String> {
    let size = main.inner_size().map_err(|e| e.to_string())?;
    toolbar
        .set_size(tauri::LogicalSize::new(size.width as f64, TOOLBAR_HEIGHT))
        .map_err(|e| e.to_string())?;
    // Child toolbar is positioned relative to the parent window.
    toolbar
        .set_position(LogicalPosition::new(0.0, 0.0))
        .map_err(|e| e.to_string())?;
    Ok(())
}

pub fn attach_window_listeners(app: &AppHandle) -> Result<(), String> {
    let app_handle = app.clone();
    if let Some(main) = app.get_webview_window(MAIN_WINDOW_LABEL) {
        let toolbar_app = app_handle.clone();
        main.on_window_event(move |event| {
            if let tauri::WindowEvent::Resized(_) | tauri::WindowEvent::Moved(_) = event {
                if let (Some(main), Some(toolbar)) = (
                    toolbar_app.get_webview_window(MAIN_WINDOW_LABEL),
                    toolbar_app.get_webview_window(TOOLBAR_WINDOW_LABEL),
                ) {
                    let _ = sync_toolbar_geometry(&main, &toolbar);
                }
            }
        });
    }
    Ok(())
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
