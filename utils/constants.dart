import 'package:dotenv/dotenv.dart';

/// Loads environment variables from a `.env` file and includes platform
/// environment variables.
///
/// The `_env` object is used to access the environment variables throughout
/// the application.
final _env = DotEnv(includePlatformEnvironment: true)..load();

/// A class that contains URLs used throughout the application.
class Urls {
  /// The base URL for API requests. This value is loaded from the environment
  /// variables. If the `BASE_URL` variable is not defined, an empty string
  /// is used as a fallback.
  static String BASE_URL = _env['BASE_URL'] ?? '';

  /// Endpoint for the login API. This is used to obtain authentication tokens
  /// using the password grant type.
  static const String LOGIN = 'auth/v1/token?grant_type=password';

  /// Endpoint for retrieving secret keys.
  static const String SECRET = 'rest/v1/secret_keys';

  /// Endpoint for accessing secret logs.
  static const String LOGS = 'rest/v1/secret_logs';
}

/// A class that holds various constant values used in the application.
class Constants {
  /// The Supabase anonymous key for accessing the Supabase API. This value is
  /// loaded from the environment variables. If the `SUPABASE_ANON` variable
  /// is not defined, an empty string is used as a fallback.
  static String SUPABASE_ANON = _env['SUPABASE_ANON'] ?? '';
}
