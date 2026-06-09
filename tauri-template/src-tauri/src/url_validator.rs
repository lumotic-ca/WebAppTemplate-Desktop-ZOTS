use crate::config;
use url::Url;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct UrlValidationResult {
    pub is_valid: bool,
    pub normalized_url: Option<String>,
    pub error: Option<String>,
}

pub fn validate(input: &str) -> UrlValidationResult {
    let trimmed = input.trim();
    if trimmed.is_empty() {
        return UrlValidationResult {
            is_valid: false,
            normalized_url: None,
            error: Some("Enter a server URL.".to_string()),
        };
    }

    let with_scheme = ensure_scheme(trimmed);
    let parsed = match Url::parse(&with_scheme) {
        Ok(url) => url,
        Err(_) => {
            return UrlValidationResult {
                is_valid: false,
                normalized_url: None,
                error: Some("Enter a valid URL (e.g. https://app.example.com).".to_string()),
            };
        }
    };

    if parsed.host().is_none() {
        return UrlValidationResult {
            is_valid: false,
            normalized_url: None,
            error: Some("Enter a valid URL (e.g. https://app.example.com).".to_string()),
        };
    }

    match parsed.scheme() {
        "http" | "https" => {}
        _ => {
            return UrlValidationResult {
                is_valid: false,
                normalized_url: None,
                error: Some("Only http and https URLs are supported.".to_string()),
            };
        }
    }

    let normalized = normalize_url(&parsed);
    if !config::is_url_allowed(&normalized) {
        return UrlValidationResult {
            is_valid: false,
            normalized_url: None,
            error: Some("This URL is not allowed for this app.".to_string()),
        };
    }

    UrlValidationResult {
        is_valid: true,
        normalized_url: Some(normalized),
        error: None,
    }
}

pub fn display_host(url: &str) -> String {
    Url::parse(url)
        .ok()
        .and_then(|parsed| parsed.host_str().map(str::to_string))
        .unwrap_or_else(|| url.to_string())
}

pub fn is_navigation_allowed(url: &Url) -> bool {
    match url.scheme() {
        "http" | "https" => config::is_url_allowed(&url.to_string()),
        _ => false,
    }
}

fn ensure_scheme(value: &str) -> String {
    if value.contains("://") {
        value.to_string()
    } else {
        format!("https://{value}")
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
    fn accepts_https_url() {
        let result = validate("https://app.example.com");
        assert!(result.is_valid);
        assert_eq!(
            result.normalized_url.as_deref(),
            Some("https://app.example.com/")
        );
    }

    #[test]
    fn adds_https_scheme_when_missing() {
        let result = validate("app.example.com");
        assert!(result.is_valid);
        assert_eq!(
            result.normalized_url.as_deref(),
            Some("https://app.example.com/")
        );
    }

    #[test]
    fn rejects_unsupported_scheme() {
        let result = validate("ftp://app.example.com");
        assert!(!result.is_valid);
    }
}
