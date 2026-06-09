mod commands;
mod config;
mod models;
mod state;
mod storage;
mod url_validator;
mod webview;

use state::AppState;
use tauri::Manager;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .setup(|app| {
            let data_dir = app
                .path()
                .app_data_dir()
                .map_err(|e| e.to_string())?;
            std::fs::create_dir_all(&data_dir).map_err(|e| e.to_string())?;
            app.manage(AppState::new(data_dir));
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            commands::connections::list_connections,
            commands::connections::add_connection,
            commands::connections::update_connection,
            commands::connections::delete_connection,
            commands::connections::clear_connections,
            commands::connections::get_last_used_connection,
            commands::settings::get_settings,
            commands::settings::update_settings,
            commands::settings::set_theme_mode,
            commands::settings::set_auto_reconnect,
            commands::session::connect,
            commands::session::disconnect,
            commands::session::get_active_session,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
