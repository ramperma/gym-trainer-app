import 'package:flutter/foundation.dart';

class Env {
  static String get apiBaseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }

    if (kIsWeb) {
      final origin = Uri.base.origin;
      return '$origin/api/v1';
    }

    return 'http://localhost:8000/api/v1';
  }
}
