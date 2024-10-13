import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

import '../../../utils/constants.dart';
import '../../../utils/encryption.dart';
import '../../../utils/error.dart';
import '../../../utils/parse_jwt.dart';
import '../logs/add.dart';

/// Handles the HTTP GET request for retrieving a secret key by its associated key.
///
/// This function expects the request method to be GET and retrieves the
/// `Authorization` token and the `X-API-KEY` from the headers. It sends the
/// `key` to the backend and returns the corresponding secret key if the
/// request is successful. If the authorization token or API key is missing,
/// or if any other error occurs during the process, an error response is returned.
///
/// - Parameters:
///   - [context]: Provides access to the HTTP request information.
/// - Returns: A `Future<Response>` representing the HTTP response.
Future<Response> onRequest(RequestContext context) async {
  // Ensure the request method is GET.
  if (context.request.method != HttpMethod.get) {
    return errorResponse('Invalid request method. Only GET is allowed.');
  }

  // Retrieve Authorization and API key from headers.
  final headers = context.request.headers;
  final authHeader = headers['Authorization'];
  final apiKey = headers['X-API-KEY'];
  final password = headers['password'];

  // Validate Authorization token.
  if (authHeader == null || authHeader.isEmpty) {
    return errorResponse(
      'Missing or invalid Authorization token.',
      statusCode: 401,
    );
  }

  // Extract user ID from the Authorization token.
  final userIDResponse = getUserIDFromHeader(authHeader);
  final userID = await userIDResponse.body();
  if (userID.isEmpty) {
    return errorResponse(
      'Missing or invalid Authorization token.',
      statusCode: 401,
    );
  }

  // Validate API key.
  if (apiKey == null ||
      apiKey.isEmpty ||
      password == null ||
      password.isEmpty) {
    return errorResponse(
      'API key and password are required and cannot be empty.',
    );
  }

  try {
    // Log the action of retrieving the secret key.
    final logBody = {'user_id': userID, 'key': apiKey};
    await addLog(authHeader, logBody);

    // Send a GET request to retrieve the secret key from the backend.
    final response = await http.get(
      Uri.parse('${Urls.BASE_URL}${Urls.SECRET}?key=eq.$apiKey'),
      headers: {
        'apikey': Constants.SUPABASE_ANON,
        'Authorization': authHeader,
      },
    );

    // Check if the request was successful.
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as List<dynamic>;

      if (responseBody.isEmpty) {
        return Response.json(
          body: {
            'message': 'No secret key found for the provided key.',
          },
        );
      }

      final result = responseBody.first as Map<String, dynamic>;
      final encryptedText = result['secret'] as String;

      final secretKey =
          Encryption.decrypt(password: password, encryptedText: encryptedText);

      return Response.json(
        body: {
          'message': 'Secret key retrieved successfully',
          'secret_key': secretKey,
        },
      );
    }

    // Return an error response if the retrieval fails.
    return errorResponse(
      'Failed to retrieve secret key. ${response.body} ${response.statusCode}',
      statusCode: response.statusCode,
    );
  } catch (e) {
    // Handle any errors that occur during the process.
    return errorResponse(
      'An error occurred while retrieving the secret key.',
      error: e,
    );
  }
}

/// Extracts the user ID from the provided Authorization header.
///
/// - Parameters:
///   - [authHeader]: The Authorization header containing the token.
/// - Returns: A `Response` object containing the user ID or an error response.
Response getUserIDFromHeader(String authHeader) {
  final arr = authHeader.split(' ');

  // Validate the Authorization token format.
  if (arr.length != 2) {
    return errorResponse(
      'Missing or invalid Authorization token.',
      statusCode: 401,
    );
  }

  final token = arr[1];
  final result = parseJwt(token);
  final userID = result['sub'] as String?;

  return Response(body: userID ?? '');
}
