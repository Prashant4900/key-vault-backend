import 'dart:io';

class Urls {
  static String BASE_URL = Platform.environment['BASE_URL'] ?? '';

  static const String LOGIN = 'auth/v1/token?grant_type=password';

  static const String SECRET = 'rest/v1/secret_keys';

  static const String LOGS = 'rest/v1/secret_logs';
}

class Constants {
  static String SUPABASE_ANON = Platform.environment['SUPABASE_ANON'] ?? '';
}
