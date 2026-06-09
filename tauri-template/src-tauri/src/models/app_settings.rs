use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum ThemeMode {
    System,
    Light,
    Dark,
}

impl Default for ThemeMode {
    fn default() -> Self {
        Self::System
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AppSettings {
    pub theme_mode: ThemeMode,
    pub auto_reconnect_on_launch: bool,
}

impl Default for AppSettings {
    fn default() -> Self {
        Self {
            theme_mode: ThemeMode::System,
            auto_reconnect_on_launch: false,
        }
    }
}
