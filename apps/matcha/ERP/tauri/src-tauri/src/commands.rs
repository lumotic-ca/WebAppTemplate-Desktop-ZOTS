use tauri::{AppHandle, State};

use crate::navigation::normalize_server_url;
use crate::state::AppState;
use crate::window::{open_erp_window, reset_to_setup, show_settings_window};

#[tauri::command]
pub fn get_saved_url(state: State<'_, AppState>) -> Result<Option<String>, String> {
    state.load_server_url()
}

#[tauri::command]
pub async fn save_server_url(
    url: String,
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let normalized = normalize_server_url(&url)?;
    state.set_server_url(normalized.clone())?;
    open_erp_window(&app, &normalized)
}

#[tauri::command]
pub async fn reset_server(app: AppHandle, state: State<'_, AppState>) -> Result<(), String> {
    reset_to_setup(&app, &state)
}

#[tauri::command]
pub fn refresh_erp(app: AppHandle) -> Result<(), String> {
    crate::window::refresh_erp(&app)
}

#[tauri::command]
pub fn open_settings(app: AppHandle) -> Result<(), String> {
    show_settings_window(&app)
}

#[tauri::command]
pub async fn return_to_erp(app: AppHandle, state: State<'_, AppState>) -> Result<(), String> {
    let url = state
        .load_server_url()?
        .ok_or("No ERPNext server is configured.".to_string())?;
    open_erp_window(&app, &url)
}
