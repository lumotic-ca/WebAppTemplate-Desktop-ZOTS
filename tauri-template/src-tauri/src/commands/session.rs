use chrono::Utc;
use tauri::{AppHandle, Manager, State};

use crate::models::SavedConnection;
use crate::state::{ActiveSession, AppState};
use crate::webview::WrappedWindowManager;

#[tauri::command]
pub async fn connect(
    id: String,
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<ActiveSession, String> {
    let mut connections = state.connections.load_connections()?;
    let index = connections
        .iter()
        .position(|item| item.id == id)
        .ok_or_else(|| "Connection not found.".to_string())?;

    let updated = SavedConnection {
        last_used_at: Some(Utc::now()),
        ..connections[index].clone()
    };
    connections[index] = updated.clone();
    state.connections.save_connections(&connections)?;
    state
        .connections
        .save_last_used_id(Some(updated.id.as_str()))?;

    WrappedWindowManager::open(&app, &updated).await?;

    let session = ActiveSession {
        connection: updated,
    };
    *state.active_session.lock().map_err(|e| e.to_string())? = Some(session.clone());

    Ok(session)
}

#[tauri::command]
pub async fn disconnect(app: AppHandle, state: State<'_, AppState>) -> Result<(), String> {
    WrappedWindowManager::close(&app)?;
    *state.active_session.lock().map_err(|e| e.to_string())? = None;
    Ok(())
}

#[tauri::command]
pub fn get_active_session(
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<Option<ActiveSession>, String> {
    if app.get_webview_window("wrapped").is_none() {
        *state.active_session.lock().map_err(|e| e.to_string())? = None;
        return Ok(None);
    }

    let session = state
        .active_session
        .lock()
        .map_err(|e| e.to_string())?
        .clone();
    Ok(session)
}
