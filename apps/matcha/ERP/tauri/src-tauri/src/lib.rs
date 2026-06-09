mod commands;
mod navigation;
mod state;
mod storage;
mod window;

use state::AppState;
use tauri::Manager;
use window::{open_erp_window, show_setup_window};

#[cfg(not(debug_assertions))]
fn prevent_default_plugin() -> tauri::plugin::TauriPlugin<tauri::Wry> {
    tauri_plugin_prevent_default::init()
}

#[cfg(debug_assertions)]
fn prevent_default_plugin() -> tauri::plugin::TauriPlugin<tauri::Wry> {
    use tauri_plugin_prevent_default::Flags;

    tauri_plugin_prevent_default::Builder::new()
        .with_flags(Flags::CONTEXT_MENU | Flags::PRINT)
        .build()
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_window_state::Builder::default().build())
        .plugin(prevent_default_plugin())
        .setup(|app| {
            let data_dir = app.path().app_data_dir().map_err(|e| e.to_string())?;
            std::fs::create_dir_all(&data_dir).map_err(|e| e.to_string())?;

            let app_state = AppState::new(data_dir);
            let saved_url = app_state.load_server_url()?;
            app.manage(app_state);

            if let Some(url) = saved_url {
                open_erp_window(app.handle(), &url)?;
            } else {
                show_setup_window(app.handle())?;
            }

            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            commands::get_saved_url,
            commands::save_server_url,
            commands::reset_server,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
