use std::fs;
use std::path::PathBuf;

const SERVER_URL_FILE: &str = "erp_server_url.txt";

pub struct ServerStorage {
    data_dir: PathBuf,
}

impl ServerStorage {
    pub fn new(data_dir: PathBuf) -> Self {
        Self { data_dir }
    }

    pub fn load(&self) -> Result<Option<String>, String> {
        let path = self.file_path();
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

    pub fn save(&self, url: &str) -> Result<(), String> {
        fs::create_dir_all(&self.data_dir).map_err(|e| e.to_string())?;
        fs::write(self.file_path(), url).map_err(|e| e.to_string())
    }

    pub fn clear(&self) -> Result<(), String> {
        let path = self.file_path();
        if path.exists() {
            fs::remove_file(path).map_err(|e| e.to_string())?;
        }
        Ok(())
    }

    fn file_path(&self) -> PathBuf {
        self.data_dir.join(SERVER_URL_FILE)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn saves_and_loads_url() {
        let dir = std::env::temp_dir().join(format!("matcha-erp-test-{}", uuid_simple()));
        let storage = ServerStorage::new(dir.clone());
        storage.save("https://erp.example.com/").unwrap();
        assert_eq!(
            storage.load().unwrap().as_deref(),
            Some("https://erp.example.com/")
        );
        let _ = fs::remove_dir_all(dir);
    }

    fn uuid_simple() -> u64 {
        use std::time::{SystemTime, UNIX_EPOCH};
        SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos() as u64
    }
}
