use tauri::{AppHandle, Emitter, Manager, WebviewUrl, WebviewWindowBuilder};

use crate::models::SavedConnection;
use crate::url_validator;

const WRAPPED_WINDOW_LABEL: &str = "wrapped";

pub struct WrappedWindowManager;

impl WrappedWindowManager {
    pub async fn open(app: &AppHandle, connection: &SavedConnection) -> Result<(), String> {
        Self::close(app)?;

        let parsed = url::Url::parse(&connection.url).map_err(|_| "Invalid server URL.".to_string())?;

        let app_handle = app.clone();
        let connection_id = connection.id.clone();

        WebviewWindowBuilder::new(
            app,
            WRAPPED_WINDOW_LABEL,
            WebviewUrl::External(parsed),
        )
        .title(&connection.display_name)
        .inner_size(1280.0, 800.0)
        .center()
        .on_navigation(move |url| url_validator::is_navigation_allowed(url))
        .build()
        .map_err(|e| e.to_string())?;

        if let Some(window) = app.get_webview_window(WRAPPED_WINDOW_LABEL) {
            window.on_window_event(move |event| {
                if matches!(
                    event,
                    tauri::WindowEvent::CloseRequested { .. } | tauri::WindowEvent::Destroyed
                ) {
                    let _ = app_handle.emit("session-ended", connection_id.clone());
                }
            });
        }

        Ok(())
    }

    pub fn close(app: &AppHandle) -> Result<(), String> {
        if let Some(window) = app.get_webview_window(WRAPPED_WINDOW_LABEL) {
            window.close().map_err(|e| e.to_string())?;
        }
        Ok(())
    }
}
