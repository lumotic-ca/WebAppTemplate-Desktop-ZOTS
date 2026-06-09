use std::path::PathBuf;
use std::sync::Mutex;

use crate::models::SavedConnection;
use crate::storage::{ConnectionStore, SettingsStore};

#[derive(Debug, Clone, serde::Serialize)]
pub struct ActiveSession {
    pub connection: SavedConnection,
}

pub struct AppState {
    pub connections: ConnectionStore,
    pub settings: SettingsStore,
    pub active_session: Mutex<Option<ActiveSession>>,
}

impl AppState {
    pub fn new(data_dir: PathBuf) -> Self {
        Self {
            connections: ConnectionStore::new(data_dir.clone()),
            settings: SettingsStore::new(data_dir),
            active_session: Mutex::new(None),
        }
    }
}
