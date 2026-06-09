mod commands;
mod navigation;
mod state;
mod storage;
mod window;

use state::AppState;
use tauri::Manager;
use window::{attach_window_listeners, ensure_main_window, open_erp_window, show_setup_window};

fn prevent_default_plugin() -> tauri::plugin::TauriPlugin<tauri::Wry> {
    use tauri_plugin_prevent_default::Flags;

    // Block devtools shortcuts in production, but keep the context menu so users can paste.
    #[cfg(debug_assertions)]
    let flags = Flags::empty();

    #[cfg(not(debug_assertions))]
    let flags = Flags::all()
        .difference(Flags::CONTEXT_MENU)
        .difference(Flags::RELOAD);

    tauri_plugin_prevent_default::Builder::new()
        .with_flags(flags)
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

            if saved_url.is_some() {
                ensure_main_window(app.handle())?;
            } else {
                show_setup_window(app.handle())?;
            }

            attach_window_listeners(app.handle())?;

            if let Some(url) = saved_url {
                let handle = app.handle().clone();
                let _ = app.handle().run_on_main_thread(move || {
                    if let Err(error) = open_erp_window(&handle, &url) {
                        eprintln!("Failed to open ERP window: {error}");
                    }
                });
            }

            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            commands::get_saved_url,
            commands::save_server_url,
            commands::reset_server,
            commands::refresh_erp,
            commands::open_settings,
            commands::return_to_erp,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
