import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

import '../../../utils/body_parse.dart';
import '../../../utils/constants.dart';
import '../../../utils/error.dart';

/// Handles HTTP POST requests for adding a new log entry (`/api/logs/add`).
///
/// This function expects a POST request with an `Authorization` token in the
/// headers and a JSON body containing `user_id` and `key`. If the request is
/// valid, it calls the `addLog` function to perform the log addition.
///
/// - Parameters:
///   - [context]: Provides access to the HTTP request information.
/// - Returns: A `Future<Response>` representing the HTTP response.
Future<Response> onRequest(RequestContext context) async {
  // Ensure the request method is POST.
  if (context.request.method != HttpMethod.post) {
    return errorResponse('Invalid request method. Only POST is allowed.');
  }

  // Retrieve the Authorization header.
  final header = context.request.headers;
  final authHeader = header['Authorization'];

  if (authHeader == null || authHeader.isEmpty) {
    return errorResponse(
      'Missing or invalid Authorization token.',
      statusCode: 401,
    );
  }

  // Parse the request body.
  final body = await context.request.body();
  final bodyParam = parseBody(body);

  try {
    // Delegate the log addition to the `addLog` function.
    await addLog(authHeader, bodyParam);
    return Response.json(
      body: {'message': 'Log added successfully'},
      statusCode: 201,
    );
  } catch (e) {
    // Handle errors during the log addition process.
    return errorResponse(
      'An error occurred while adding the log.',
      error: e,
    );
  }
}

/// Adds a log entry either internally or through an external service.
///
/// This function validates the request body parameters and performs the log
/// addition. If the operation fails, an exception is thrown.
///
/// - Parameters:
///   - [authHeader]: The authorization token from the request headers.
///   - [body]: The request body as a map containing `user_id` and `key`.
/// - Throws: An `Exception` if validation fails or if the log addition fails.
Future<void> addLog(String authHeader, Map<String, dynamic> body) async {
  final userID = body['user_id'] as String?;
  final key = body['key'] as String?;

  // Validate request body parameters.
  if (!_validateRequestBody(userID, key)) {
    throw Exception('All fields are required and cannot be empty.');
  }

  // Perform the log addition operation via HTTP request to the external service.
  final response = await http.post(
    Uri.parse(Urls.BASE_URL + Urls.LOGS),
    headers: {
      'apikey': Constants.SUPABASE_ANON,
      'Authorization': authHeader,
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'user_id': userID, 'key': key}),
  );

  // Check if the log was added successfully.
  if (response.statusCode != 201) {
    throw Exception(
      'Failed to add log. ${response.body} (Status Code: ${response.statusCode})',
    );
  }
}

/// Validates the request body parameters.
///
/// This function checks if both [userID] and [key] are non-null and non-empty.
///
/// - Parameters:
///   - [userID]: The user ID associated with the log entry.
///   - [key]: The key associated with the log entry.
/// - Returns: `true` if both parameters are valid, otherwise `false`.
bool _validateRequestBody(String? userID, String? key) {
  return userID != null && key != null && userID.isNotEmpty && key.isNotEmpty;
}
