use std::fs;
use std::path::PathBuf;

use crate::models::AppSettings;

const SETTINGS_FILE: &str = "settings.json";

pub struct SettingsStore {
    data_dir: PathBuf,
}

impl SettingsStore {
    pub fn new(data_dir: PathBuf) -> Self {
        Self { data_dir }
    }

    pub fn load(&self) -> Result<AppSettings, String> {
        let path = self.settings_path();
        if !path.exists() {
            return Ok(AppSettings::default());
        }

        let raw = fs::read_to_string(path).map_err(|e| e.to_string())?;
        serde_json::from_str(&raw).map_err(|e| e.to_string())
    }

    pub fn save(&self, settings: &AppSettings) -> Result<(), String> {
        fs::create_dir_all(&self.data_dir).map_err(|e| e.to_string())?;
        let encoded = serde_json::to_string_pretty(settings).map_err(|e| e.to_string())?;
        fs::write(self.settings_path(), encoded).map_err(|e| e.to_string())
    }

    fn settings_path(&self) -> PathBuf {
        self.data_dir.join(SETTINGS_FILE)
    }
}
