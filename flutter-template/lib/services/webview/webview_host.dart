import 'package:webapp_template/features/connection/models/saved_connection.dart';

enum WebViewPresentation {
  inline,
  externalWindow,
}

abstract class WebViewHost {
  WebViewPresentation get presentation;

  Future<String?> availabilityError();

  Future<void> open(SavedConnection connection);

  Future<void> close();

  Stream<void> get onClosed;
}
