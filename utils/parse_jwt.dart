import 'dart:convert';

/// Parses a JWT token and returns the decoded payload as a Map<String, dynamic>.
///
/// This function decodes the second part of the JWT (payload) from base64
/// and converts it into a Dart Map. If the token is not valid, or if the payload
/// cannot be decoded, it returns an empty map.
///
/// - [token]: The JWT token string.
///
/// Returns a Map<String, dynamic> containing the decoded payload.
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
