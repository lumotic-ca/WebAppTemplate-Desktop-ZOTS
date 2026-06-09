use std::path::PathBuf;
use std::sync::Mutex;

use crate::storage::ServerStorage;

pub struct AppState {
    pub storage: ServerStorage,
    pub server_url: Mutex<Option<String>>,
}

impl AppState {
    pub fn new(data_dir: PathBuf) -> Self {
        Self {
            storage: ServerStorage::new(data_dir),
            server_url: Mutex::new(None),
        }
    }

    pub fn load_server_url(&self) -> Result<Option<String>, String> {
        let mut cached = self.server_url.lock().map_err(|e| e.to_string())?;
        if cached.is_some() {
            return Ok(cached.clone());
        }

        let loaded = self.storage.load()?;
        *cached = loaded.clone();
        Ok(loaded)
    }

    pub fn set_server_url(&self, url: String) -> Result<(), String> {
        self.storage.save(&url)?;
        let mut cached = self.server_url.lock().map_err(|e| e.to_string())?;
        *cached = Some(url);
        Ok(())
    }

    pub fn clear_server_url(&self) -> Result<(), String> {
        self.storage.clear()?;
        let mut cached = self.server_url.lock().map_err(|e| e.to_string())?;
        *cached = None;
        Ok(())
    }
}
