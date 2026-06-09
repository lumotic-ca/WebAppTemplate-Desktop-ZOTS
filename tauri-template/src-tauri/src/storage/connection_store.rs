use std::fs;
use std::path::PathBuf;

use crate::models::SavedConnection;

const CONNECTIONS_FILE: &str = "connections.json";
const LAST_USED_FILE: &str = "last_used_connection_id.txt";

pub struct ConnectionStore {
    data_dir: PathBuf,
}

impl ConnectionStore {
    pub fn new(data_dir: PathBuf) -> Self {
        Self { data_dir }
    }

    pub fn load_connections(&self) -> Result<Vec<SavedConnection>, String> {
        let path = self.connections_path();
        if !path.exists() {
            return Ok(Vec::new());
        }

        let raw = fs::read_to_string(path).map_err(|e| e.to_string())?;
        if raw.trim().is_empty() {
            return Ok(Vec::new());
        }

        serde_json::from_str(&raw).map_err(|e| e.to_string())
    }

    pub fn save_connections(&self, connections: &[SavedConnection]) -> Result<(), String> {
        self.ensure_dir()?;
        let encoded = serde_json::to_string_pretty(connections).map_err(|e| e.to_string())?;
        fs::write(self.connections_path(), encoded).map_err(|e| e.to_string())
    }

    pub fn load_last_used_id(&self) -> Result<Option<String>, String> {
        let path = self.last_used_path();
        if !path.exists() {
            return Ok(None);
        }
        let raw = fs::read_to_string(path).map_err(|e| e.to_string())?;
        let trimmed = raw.trim();
        if trimmed.is_empty() {
            Ok(None)
        } else {
            Ok(Some(trimmed.to_string()))
        }
    }

    pub fn save_last_used_id(&self, id: Option<&str>) -> Result<(), String> {
        self.ensure_dir()?;
        let path = self.last_used_path();
        match id {
            Some(value) => fs::write(path, value).map_err(|e| e.to_string())?,
            None => {
                if path.exists() {
                    fs::remove_file(path).map_err(|e| e.to_string())?;
                }
            }
        }
        Ok(())
    }

    pub fn clear_all(&self) -> Result<(), String> {
        self.save_connections(&[])?;
        self.save_last_used_id(None)
    }

    fn connections_path(&self) -> PathBuf {
        self.data_dir.join(CONNECTIONS_FILE)
    }

    fn last_used_path(&self) -> PathBuf {
        self.data_dir.join(LAST_USED_FILE)
    }

    fn ensure_dir(&self) -> Result<(), String> {
        fs::create_dir_all(&self.data_dir).map_err(|e| e.to_string())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::Utc;

    fn temp_store() -> (ConnectionStore, PathBuf) {
        let dir = std::env::temp_dir().join(format!("webapp-template-test-{}", uuid::Uuid::new_v4()));
        (ConnectionStore::new(dir.clone()), dir)
    }

    #[test]
    fn persists_and_reloads_connections() {
        let (store, dir) = temp_store();
        let connection = SavedConnection {
            id: "1".to_string(),
            display_name: "Test".to_string(),
            url: "https://example.com/".to_string(),
            last_used_at: Some(Utc::now()),
        };

        store.save_connections(&[connection.clone()]).unwrap();
        store.save_last_used_id(Some("1")).unwrap();

        assert_eq!(store.load_connections().unwrap(), vec![connection]);
        assert_eq!(store.load_last_used_id().unwrap(), Some("1".to_string()));

        let _ = fs::remove_dir_all(dir);
    }
}
