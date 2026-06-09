use chrono::Utc;
use tauri::State;
use uuid::Uuid;

use crate::models::SavedConnection;
use crate::state::AppState;
use crate::url_validator::{self, validate};

fn sort_connections(mut connections: Vec<SavedConnection>) -> Vec<SavedConnection> {
    connections.sort_by(|a, b| {
        let a_time = a.last_used_at.unwrap_or_else(|| chrono::DateTime::UNIX_EPOCH);
        let b_time = b.last_used_at.unwrap_or_else(|| chrono::DateTime::UNIX_EPOCH);
        b_time.cmp(&a_time)
    });
    connections
}

#[tauri::command]
pub fn list_connections(state: State<'_, AppState>) -> Result<Vec<SavedConnection>, String> {
    let connections = state.connections.load_connections()?;
    Ok(sort_connections(connections))
}

#[tauri::command]
pub fn add_connection(
    display_name: String,
    url: String,
    state: State<'_, AppState>,
) -> Result<SavedConnection, String> {
    let validation = validate(&url);
    if !validation.is_valid {
        return Err(validation
            .error
            .unwrap_or_else(|| "Invalid URL.".to_string()));
    }

    let normalized = validation.normalized_url.ok_or_else(|| "Invalid URL.".to_string())?;
    let mut connections = state.connections.load_connections()?;

    if connections
        .iter()
        .any(|item| item.url.eq_ignore_ascii_case(&normalized))
    {
        return Err("This server is already saved.".to_string());
    }

    let connection = SavedConnection {
        id: Uuid::new_v4().to_string(),
        display_name: if display_name.trim().is_empty() {
            url_validator::display_host(&normalized)
        } else {
            display_name.trim().to_string()
        },
        url: normalized,
        last_used_at: Some(Utc::now()),
    };

    connections.push(connection.clone());
    state.connections.save_connections(&connections)?;
    state
        .connections
        .save_last_used_id(Some(connection.id.as_str()))?;

    Ok(connection)
}

#[tauri::command]
pub fn update_connection(
    connection: SavedConnection,
    state: State<'_, AppState>,
) -> Result<SavedConnection, String> {
    let validation = validate(&connection.url);
    if !validation.is_valid {
        return Err(validation
            .error
            .unwrap_or_else(|| "Invalid URL.".to_string()));
    }

    let normalized = validation.normalized_url.ok_or_else(|| "Invalid URL.".to_string())?;
    let mut connections = state.connections.load_connections()?;
    let updated = SavedConnection {
        id: connection.id,
        display_name: if connection.display_name.trim().is_empty() {
            url_validator::display_host(&normalized)
        } else {
            connection.display_name.trim().to_string()
        },
        url: normalized,
        last_used_at: connection.last_used_at,
    };

    let mut found = false;
    for item in connections.iter_mut() {
        if item.id == updated.id {
            *item = updated.clone();
            found = true;
            break;
        }
    }

    if !found {
        return Err("Connection not found.".to_string());
    }

    state.connections.save_connections(&connections)?;
    Ok(updated)
}

#[tauri::command]
pub fn delete_connection(id: String, state: State<'_, AppState>) -> Result<(), String> {
    let mut connections = state.connections.load_connections()?;
    let before = connections.len();
    connections.retain(|item| item.id != id);

    if connections.len() == before {
        return Err("Connection not found.".to_string());
    }

    state.connections.save_connections(&connections)?;

    if state.connections.load_last_used_id()? == Some(id) {
        let next = connections.first().map(|item| item.id.as_str());
        state.connections.save_last_used_id(next)?;
    }

    Ok(())
}

#[tauri::command]
pub fn clear_connections(state: State<'_, AppState>) -> Result<(), String> {
    state.connections.clear_all()
}

#[tauri::command]
pub fn get_last_used_connection(state: State<'_, AppState>) -> Result<Option<SavedConnection>, String> {
    let last_id = state.connections.load_last_used_id()?;
    let Some(last_id) = last_id else {
        return Ok(None);
    };

    let connections = state.connections.load_connections()?;
    Ok(connections.into_iter().find(|item| item.id == last_id))
}
