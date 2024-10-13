import 'dart:convert';

/// Parses a JSON-encoded string and returns a `Map<String, dynamic>`.
///
/// This function attempts to decode the given [body] as a JSON-encoded
/// string and returns a map representation of the JSON data. If the
/// decoding fails (e.g., the input is not valid JSON), it returns an
/// empty map.
///
/// - Parameter [body]: The JSON-encoded string to parse.
/// - Returns: A `Map<String, dynamic>` representation of the JSON data,
///   or an empty map if the decoding fails.
Map<String, dynamic> parseBody(String body) {
  try {
    return jsonDecode(body) as Map<String, dynamic>;
  } catch (e) {
    // Return an empty map if the input is not valid JSON
    return {};
  }
}
