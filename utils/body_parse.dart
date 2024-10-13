import 'dart:convert';

Map<String, dynamic> parseBody(String body) {
  try {
    return jsonDecode(body) as Map<String, dynamic>;
  } catch (e) {
    return {};
  }
}
