import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

import '../../../utils/body_parse.dart';
import '../../../utils/constants.dart';
import '../../../utils/error.dart';

/// Handles HTTP requests for adding a new secret key.
///
/// This function processes a POST request to add a new secret key along with a
/// name. It validates the request body to ensure that the name and secret key
/// are present and non-empty. If the request is valid, the data is sent to the
/// backend service to store the secret key. If successful, it returns a success
/// response, otherwise, an error response is returned.
///
/// - [context]: Provides access to the HTTP request information.
Future<Response> onRequest(RequestContext context) async {
  // Ensure the request method is POST.
  if (context.request.method != HttpMethod.post) {
    return errorResponse('Invalid request method. Only POST is allowed.');
  }

  // Retrieve the request header
  final header = context.request.headers;

  final authHeader = header['Authorization'];
  if (authHeader == null || authHeader.isEmpty) {
    return errorResponse(
      'Missing or invalid Authorization token.',
      statusCode: 401,
    );
  }

  // Retrieve the request body.
  final body = await context.request.body();

  // Parse the request body as JSON and extract the parameters.
  final bodyParam = parseBody(body);
  final name = bodyParam['name'] as String?;
  final key = bodyParam['key'] as String?;
  final secretKey = bodyParam['secret_key'] as String?;
  final salt = bodyParam['salt'] as String?;

  // Validate the presence and non-emptiness of name and secretKey.
  if (!_validateRequestBody(name, secretKey, key, salt)) {
    return errorResponse('All field are required and cannot be empty.');
  }

  try {
    // Send a POST request to the backend to store the new secret key.
    final response = await http.post(
      Uri.parse(Urls.BASE_URL + Urls.SECRET),
      headers: {
        'apikey': Constants.SUPABASE_ANON,
        'Authorization': authHeader,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'secret': secretKey,
        'key': key,
      }),
    );

    // If adding the secret key was successful, return the API response.
    if (response.statusCode == 201) {
      return Response.json(
        body: {'message': 'Secret key added successfully'},
        statusCode: 201,
      );
    }

    // Return an error response if adding the secret key fails.
    return errorResponse(
      'Failed to add secret key.',
      statusCode: response.statusCode,
    );
  } catch (e) {
    // Handle any errors that occur during the process.
    return errorResponse(
      'An error occurred while adding the secret key.',
      error: e,
    );
  }
}

/// Validates that the provided [name] and [secretKey] are not null or empty.
///
/// This function checks if both the name and secret key
/// are present and not empty.
/// Returns true if both are valid, otherwise returns false.
bool _validateRequestBody(
  String? name,
  String? secretKey,
  String? key,
  String? salt,
) {
  return name != null &&
      secretKey != null &&
      key != null &&
      salt != null &&
      salt.isNotEmpty &&
      name.isNotEmpty &&
      secretKey.isNotEmpty &&
      key.isNotEmpty;
}
