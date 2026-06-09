use tauri::State;

use crate::models::{AppSettings, ThemeMode};
use crate::state::AppState;

#[tauri::command]
pub fn get_settings(state: State<'_, AppState>) -> Result<AppSettings, String> {
    state.settings.load()
}

#[tauri::command]
pub fn update_settings(
    settings: AppSettings,
    state: State<'_, AppState>,
) -> Result<AppSettings, String> {
    state.settings.save(&settings)?;
    Ok(settings)
}

#[tauri::command]
pub fn set_theme_mode(
    theme_mode: ThemeMode,
    state: State<'_, AppState>,
) -> Result<AppSettings, String> {
    let mut settings = state.settings.load()?;
    settings.theme_mode = theme_mode;
    state.settings.save(&settings)?;
    Ok(settings)
}

#[tauri::command]
pub fn set_auto_reconnect(
    auto_reconnect_on_launch: bool,
    state: State<'_, AppState>,
) -> Result<AppSettings, String> {
    let mut settings = state.settings.load()?;
    settings.auto_reconnect_on_launch = auto_reconnect_on_launch;
    state.settings.save(&settings)?;
    Ok(settings)
}
