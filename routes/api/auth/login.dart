import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

import '../../../utils/body_parse.dart';
import '../../../utils/constants.dart';
import '../../../utils/error.dart';

/// Handles HTTP requests for user login.
///
/// This function processes a POST request, validates the provided email
/// and password, and forwards the credentials to the login API. If the
/// login is successful, it returns the response data; otherwise, an error response is returned.
///
/// - [context]: Provides access to the HTTP request information.
Future<Response> onRequest(RequestContext context) async {
  // Ensure the request method is POST.
  if (context.request.method != HttpMethod.post) {
    return errorResponse('Invalid request method.');
  }

  // Retrieve the request body.
  final body = await context.request.body();

  // Parse the request body as JSON and extract the parameters.
  final bodyParam = parseBody(body);
  final email = bodyParam['email'] as String?;
  final password = bodyParam['password'] as String?;

  // Validate the presence and non-emptiness of email and password.
  if (!_validateCredentials(email, password)) {
    return errorResponse(
      'Email and password are required and cannot be empty.',
    );
  }

  try {
    // Send a POST request to the login API with the provided credentials.
    final response = await http.post(
      Uri.parse(Urls.BASE_URL + Urls.LOGIN),
      headers: {
        'apikey': Constants.SUPABASE_ANON,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    // If the login is successful, return the API response.
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Response.json(body: data);
    }

    // Return an error response if login fails.
    return errorResponse('Login failed. Please check your credentials.');
  } catch (e) {
    // Handle any errors that occur during the login process.
    return errorResponse('An error occurred while logging in.', error: e);
  }
}

/// Validates that the provided [email] and [password] are not null or empty.
///
/// Returns true if both are valid; otherwise, returns false.
bool _validateCredentials(String? email, String? password) {
  return email != null &&
      password != null &&
      email.isNotEmpty &&
      password.isNotEmpty;
}
