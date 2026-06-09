/// Fork customization point — keep in sync with `src/lib/app-config.ts`.
#[allow(dead_code)]
pub const APP_NAME: &str = "WebApp Template";
#[allow(dead_code)]
pub const APP_IDENTIFIER: &str = "com.lumotic.webapptemplate";
#[allow(dead_code)]
pub const USER_AGENT_SUFFIX: &str = "WebAppTemplate-Tauri/1.0";

/// Empty list allows any valid http/https URL.
pub const ALLOWED_URL_PATTERNS: &[&str] = &[];

pub fn is_url_allowed(url: &str) -> bool {
    if ALLOWED_URL_PATTERNS.is_empty() {
        return true;
    }
    ALLOWED_URL_PATTERNS.iter().any(|pattern| url.starts_with(pattern))
}
