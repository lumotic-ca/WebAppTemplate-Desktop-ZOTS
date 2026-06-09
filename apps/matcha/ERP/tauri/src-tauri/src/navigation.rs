use tauri::{AppHandle, Manager};
use tauri_plugin_opener::OpenerExt;
use url::Url;

pub fn handle_navigation(app: &AppHandle, target: &Url) -> bool {
    if is_local_shell_url(target) {
        return true;
    }

    let Some(state) = app.try_state::<crate::state::AppState>() else {
        return false;
    };

    let Ok(Some(base)) = state.load_server_url() else {
        return false;
    };

    if is_allowed_navigation(&base, target) {
        return true;
    }

    if is_external_navigation(&base, target) {
        let _ = app
            .opener()
            .open_url(target.as_str(), None::<&str>);
    }

    false
}

pub fn is_local_shell_url(url: &Url) -> bool {
    match url.scheme() {
        "tauri" | "asset" | "file" => return true,
        "http" | "https" => {}
        _ => return false,
    }

    match url.host_str() {
        Some("localhost") | Some("127.0.0.1") | Some("tauri.localhost") => true,
        Some(host) if host.ends_with(".localhost") => true,
        _ => false,
    }
}

pub fn normalize_server_url(input: &str) -> Result<String, String> {
    let trimmed = input.trim();
    if trimmed.is_empty() {
        return Err("Enter your ERPNext server URL.".to_string());
    }

    let with_scheme = if trimmed.contains("://") {
        trimmed.to_string()
    } else {
        format!("https://{trimmed}")
    };

    let parsed = Url::parse(&with_scheme).map_err(|_| {
        "Enter a valid URL (e.g. https://erp.company.com).".to_string()
    })?;

    if parsed.host().is_none() {
        return Err("Enter a valid URL (e.g. https://erp.company.com).".to_string());
    }

    match parsed.scheme() {
        "http" | "https" => {}
        _ => return Err("Only http and https URLs are supported.".to_string()),
    }

    Ok(normalize_url(&parsed))
}

pub fn is_allowed_navigation(base_url: &str, target: &Url) -> bool {
    match target.scheme() {
        "http" | "https" => {}
        _ => return false,
    }

    let Ok(base) = Url::parse(base_url) else {
        return false;
    };

    same_site(&base, target)
}

pub fn is_external_navigation(base_url: &str, target: &Url) -> bool {
    !is_allowed_navigation(base_url, target)
}

fn same_site(base: &Url, target: &Url) -> bool {
    match (base.host(), target.host()) {
        (Some(base_host), Some(target_host)) => {
            base_host == target_host && base.scheme() == target.scheme()
        }
        _ => false,
    }
}

fn normalize_url(url: &Url) -> String {
    let mut normalized = format!(
        "{}://{}",
        url.scheme(),
        url.host_str().unwrap_or_default()
    );

    if let Some(port) = url.port() {
        normalized.push(':');
        normalized.push_str(&port.to_string());
    }

    let path = url.path();
    if path.is_empty() {
        normalized.push('/');
    } else {
        normalized.push_str(path);
    }

    if let Some(query) = url.query() {
        normalized.push('?');
        normalized.push_str(query);
    }

    normalized
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn normalizes_https_url() {
        let result = normalize_server_url("https://erp.example.com").unwrap();
        assert_eq!(result, "https://erp.example.com/");
    }

    #[test]
    fn allows_same_host_navigation() {
        let base = "https://erp.example.com/";
        let target = Url::parse("https://erp.example.com/app").unwrap();
        assert!(is_allowed_navigation(base, &target));
    }

    #[test]
    fn blocks_external_host() {
        let base = "https://erp.example.com/";
        let target = Url::parse("https://google.com").unwrap();
        assert!(is_external_navigation(base, &target));
    }
}
