import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

import '../../../utils/constants.dart';
import '../../../utils/error.dart';

/// Handles HTTP GET requests for retrieving log entries (`/api/logs/get`).
///
/// This function expects a GET request with an `Authorization` token in the
/// headers. It attempts to fetch log entries from the external service. If
/// successful, it returns the log data; otherwise, it returns an error response.
///
/// - Parameters:
///   - [context]: Provides access to the HTTP request information.
/// - Returns: A `Future<Response>` representing the HTTP response.
Future<Response> onRequest(RequestContext context) async {
  // Ensure the request method is GET.
  if (context.request.method != HttpMethod.get) {
    return errorResponse('Invalid request method. Only GET is allowed.');
  }

  // Retrieve the Authorization header.
  final headers = context.request.headers;
  final authHeader = headers['Authorization'];

  if (authHeader == null || authHeader.isEmpty) {
    return errorResponse(
      'Missing or invalid Authorization token.',
      statusCode: 401,
    );
  }

  try {
    // Perform the GET request to fetch log entries from the external service.
    final response = await http.get(
      Uri.parse('${Urls.BASE_URL}${Urls.LOGS}?select=*'),
      headers: {
        'apikey': Constants.SUPABASE_ANON,
        'Authorization': authHeader,
      },
    );

    // Check if the log entries were retrieved successfully.
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as List<dynamic>;

      return Response.json(
        body: {
          'message': 'Log entries retrieved successfully.',
          'logs': responseBody,
        },
      );
    }

    // Return an error response if the retrieval fails.
    return errorResponse(
      'Failed to retrieve log entries. ${response.body} (Status Code: ${response.statusCode})',
      statusCode: response.statusCode,
    );
  } catch (e) {
    // Handle errors that occur during the retrieval process.
    return errorResponse(
      'An error occurred while retrieving the log entries.',
      error: e,
    );
  }
}
