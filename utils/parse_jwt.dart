import 'dart:convert';

/// Parses a JWT token and returns the decoded payload as a `Map<String, dynamic>`.
///
/// This function decodes the second part of the JWT (payload) from Base64URL
/// and converts it into a Dart map. If the token format is not valid, or if
/// the payload cannot be decoded, it throws an exception.
///
/// - Parameters:
///   - [token]: The JWT token string to be parsed.
/// - Returns: A `Map<String, dynamic>` containing the decoded payload data.
/// - Throws: An `Exception` if the JWT token is invalid (does not consist of three parts).
Map<String, dynamic> parseJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('Invalid JWT token');
  }

  final payload = parts[1];
  final normalized = base64Url.normalize(payload);
  final decodedBytes = base64Url.decode(normalized);
  final decodedString = utf8.decode(decodedBytes);

  return jsonDecode(decodedString) as Map<String, dynamic>;
}
