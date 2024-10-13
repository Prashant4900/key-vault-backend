import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

import '../../../utils/body_parse.dart';
import '../../../utils/constants.dart';
import '../../../utils/error.dart';

/// Handles HTTP POST requests for adding a new log entry.
/// This function expects a POST request with an `Authorization` token in the
/// headers and a JSON body containing `user_id` and `key`. It delegates the
/// log addition to the `addLog` function.
///
/// - [context]: Provides access to the HTTP request information.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return errorResponse('Invalid request method. Only POST is allowed.');
  }

  final header = context.request.headers;
  final authHeader = header['Authorization'];

  if (authHeader == null || authHeader.isEmpty) {
    return errorResponse(
      'Missing or invalid Authorization token.',
      statusCode: 401,
    );
  }

  final body = await context.request.body();
  final bodyParam = parseBody(body);

  try {
    // Use addLog to handle the log addition
    await addLog(authHeader, bodyParam);
    return Response.json(
      body: {'message': 'Log added successfully'},
      statusCode: 201,
    );
  } catch (e) {
    return errorResponse(
      'An error occurred while adding the log.',
      error: e,
    );
  }
}

/// Adds a log entry internally or via external service.
/// Validates the request body and performs the log addition.
/// If successful, the log is added; otherwise, an error is thrown.
///
/// - [authHeader]: The authorization token.
/// - [body]: The log data as a map containing `user_id` and `key`.
Future<void> addLog(String authHeader, Map<String, dynamic> body) async {
  final userID = body['user_id'] as String?;
  final key = body['key'] as String?;

  // Validate request body parameters
  if (!_validateRequestBody(userID, key)) {
    throw Exception('All fields are required and cannot be empty.');
  }

  // Perform the log addition operation via HTTP request to external service
  final response = await http.post(
    Uri.parse(Urls.BASE_URL + Urls.LOGS),
    headers: {
      'apikey': Constants.SUPABASE_ANON,
      'Authorization': authHeader,
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'user_id': userID, 'key': key}),
  );

  // Check if the log was added successfully
  if (response.statusCode != 201) {
    throw Exception(
      'Failed to add log. ${response.body} ${response.statusCode}',
    );
  }
}

/// Validates the request body parameters.
/// Ensures that both `userID` and `key` are not null or empty.
/// Returns true if valid, otherwise false.
///
/// - [userID]: The ID of the user.
/// - [key]: The key associated with the log entry.
bool _validateRequestBody(String? userID, String? key) {
  return userID != null && key != null && userID.isNotEmpty && key.isNotEmpty;
}
