import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

import '../../../utils/body_parse.dart';
import '../../../utils/constants.dart';
import '../../../utils/encryption.dart';
import '../../../utils/error.dart';

/// Handles HTTP POST requests for adding a new secret key (`/api/secret/add`).
///
/// This function processes a POST request to add a new secret key along with
/// a name. It validates the request body to ensure that the name, secret key,
/// key, and password are present and non-empty. If the request is valid, the data
/// is sent to the backend service to store the secret key. If successful, it
/// returns a success response; otherwise, an error response is returned.
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
  final headers = context.request.headers;
  final authHeader = headers['Authorization'];
  if (authHeader == null || authHeader.isEmpty) {
    return errorResponse(
      'Missing or invalid Authorization token.',
      statusCode: 401,
    );
  }

  // Retrieve and parse the request body.
  final body = await context.request.body();
  final bodyParam = parseBody(body);
  final name = bodyParam['name'] as String?;
  final key = bodyParam['key'] as String?;
  final secretKey = bodyParam['secret_key'] as String?;
  final password = bodyParam['password'] as String?;

  // Validate the presence and non-emptiness of required fields.
  if (!_validateRequestBody(name, secretKey, key, password)) {
    return errorResponse('All fields are required and cannot be empty.');
  }

  try {
    final secret = Encryption.encrypt(
      password: password!,
      plainText: secretKey!,
    );

    print(secret);

    // Send a POST request to the backend to store the new secret key.
    final response = await http.post(
      Uri.parse('${Urls.BASE_URL}${Urls.SECRET}'),
      headers: {
        'apikey': Constants.SUPABASE_ANON,
        'Authorization': authHeader,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'secret': secret,
        'key': key,
      }),
    );

    // If adding the secret key was successful, return a success response.
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

/// Validates that the provided fields are not null or empty.
///
/// This function checks if the [name], [secretKey], [key], and [password]
/// are present and not empty.
///
/// - Parameters:
///   - [name]: The name associated with the secret key.
///   - [secretKey]: The secret key to be stored.
///   - [key]: An additional key related to the secret key.
///   - [password]: The password used for encryption or hashing.
/// - Returns: `true` if all fields are valid, otherwise `false`.
bool _validateRequestBody(
  String? name,
  String? secretKey,
  String? key,
  String? password,
) {
  return name != null &&
      secretKey != null &&
      key != null &&
      password != null &&
      name.isNotEmpty &&
      secretKey.isNotEmpty &&
      key.isNotEmpty &&
      password.isNotEmpty;
}
