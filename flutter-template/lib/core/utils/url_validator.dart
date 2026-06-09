import 'package:webapp_template/core/config/app_config.dart';

class UrlValidationResult {
  const UrlValidationResult({required this.isValid, this.normalizedUrl, this.error});

  final bool isValid;
  final String? normalizedUrl;
  final String? error;
}

class UrlValidator {
  const UrlValidator._();

  static UrlValidationResult validate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const UrlValidationResult(
        isValid: false,
        error: 'Enter a server URL.',
      );
    }

    final withScheme = _ensureScheme(trimmed);
    final uri = Uri.tryParse(withScheme);

    if (uri == null || !uri.hasAuthority) {
      return const UrlValidationResult(
        isValid: false,
        error: 'Enter a valid URL (e.g. https://app.example.com).',
      );
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return const UrlValidationResult(
        isValid: false,
        error: 'Only http and https URLs are supported.',
      );
    }

    final normalized = _normalize(uri);
    if (!AppConfig.isUrlAllowed(normalized)) {
      return const UrlValidationResult(
        isValid: false,
        error: 'This URL is not allowed for this app.',
      );
    }

    return UrlValidationResult(isValid: true, normalizedUrl: normalized);
  }

  static String _ensureScheme(String value) {
    if (value.contains('://')) {
      return value;
    }
    return 'https://$value';
  }

  static String _normalize(Uri uri) {
    final buffer = StringBuffer()
      ..write(uri.scheme)
      ..write('://')
      ..write(uri.authority);

    if (uri.path.isNotEmpty) {
      buffer.write(uri.path);
    } else {
      buffer.write('/');
    }

    if (uri.hasQuery) {
      buffer.write('?${uri.query}');
    }

    return buffer.toString();
  }

  static String displayHost(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) {
      return url;
    }
    return uri.host;
  }
}
