use tauri::{AppHandle, State};

use crate::navigation::normalize_server_url;
use crate::state::AppState;
use crate::window::{open_erp_window, reset_to_setup};

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
