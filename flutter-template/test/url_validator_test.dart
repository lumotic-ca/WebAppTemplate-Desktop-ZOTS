import 'package:flutter_test/flutter_test.dart';
import 'package:webapp_template/core/utils/url_validator.dart';

void main() {
  group('UrlValidator', () {
    test('accepts https URL', () {
      final result = UrlValidator.validate('https://app.example.com');
      expect(result.isValid, isTrue);
      expect(result.normalizedUrl, 'https://app.example.com/');
    });

    test('adds https scheme when missing', () {
      final result = UrlValidator.validate('app.example.com');
      expect(result.isValid, isTrue);
      expect(result.normalizedUrl, 'https://app.example.com/');
    });

    test('rejects empty input', () {
      final result = UrlValidator.validate('   ');
      expect(result.isValid, isFalse);
      expect(result.error, isNotNull);
    });

    test('rejects unsupported scheme', () {
      final result = UrlValidator.validate('ftp://app.example.com');
      expect(result.isValid, isFalse);
    });

    test('displayHost returns hostname', () {
      expect(
        UrlValidator.displayHost('https://app.example.com/path'),
        'app.example.com',
      );
    });
  });
}
