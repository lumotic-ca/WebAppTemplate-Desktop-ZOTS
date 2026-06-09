/// Fork customization point — change these values when creating a new app.
class AppConfig {
  const AppConfig._();

  static const String appName = 'WebApp Template';
  static const String appId = 'com.lumotic.webapp_template';

  /// Optional URL scheme allowlist. Empty list allows any valid http/https URL.
  static const List<String> allowedUrlPatterns = [];

  static const String defaultUserAgentSuffix = 'WebAppTemplate/1.0';

  static bool isUrlAllowed(String url) {
    if (allowedUrlPatterns.isEmpty) {
      return true;
    }
    return allowedUrlPatterns.any(url.startsWith);
  }
}
