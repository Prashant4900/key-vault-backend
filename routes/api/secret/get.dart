import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

import '../../../utils/constants.dart';
import '../../../utils/error.dart';
import '../../../utils/parse_jwt.dart';
import '../logs/add.dart';

/// Handles the HTTP GET request for retrieving a secret key by its associated key.
///
/// This function expects the request method to be GET and retrieves the
/// `Authorization` token and the `X-API-KEY` from the headers.
/// It sends the `key` to the backend and returns the corresponding secret key
/// if the request is successful. If the authorization token or API key is missing,
/// or if any other error occurs during the process, an error response is returned.
///
/// - [context]: Provides access to the HTTP request information.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return errorResponse('Invalid request method. Only GET is allowed.');
  }

  final headers = context.request.headers;
  final authHeader = headers['Authorization'];
  final apiKey = headers['X-API-KEY'];

  if (authHeader == null || authHeader.isEmpty) {
    return errorResponse(
      'Missing or invalid Authorization token.',
      statusCode: 401,
    );
  }

  final userID = await getUserIDFromHeader(authHeader).body();

  if (userID.isEmpty) {
    return errorResponse(
      'Missing or invalid Authorization token.',
      statusCode: 401,
    );
  }

  if (apiKey == null || apiKey.isEmpty) {
    return errorResponse('API key is required and cannot be empty.');
  }

  try {
    final logBody = {'user_id': userID, 'key': apiKey};
    await addLog(authHeader, logBody);

    final response = await http.get(
      Uri.parse('${Urls.BASE_URL}${Urls.SECRET}?key=eq.$apiKey'),
      headers: {
        'apikey': Constants.SUPABASE_ANON,
        'Authorization': authHeader,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as List<dynamic>;

      if (responseBody.isEmpty) {
        return Response.json(
          body: {
            'message': 'Something went wrong.',
          },
        );
      }

      final result = responseBody.first as Map<String, dynamic>;

      final secretKey = result['secret'];

      return Response.json(
        body: {
          'message': 'Secret key retrieved successfully',
          'secret_key': secretKey,
        },
      );
    }

    return errorResponse(
      'Failed to retrieve secret key. ${response.body} ${response.statusCode}',
      statusCode: response.statusCode,
    );
  } catch (e) {
    return errorResponse(
      'An error occurred while retrieving the secret key.',
      error: e,
    );
  }
}

Response getUserIDFromHeader(String authHeader) {
  final arr = authHeader.split(' ');

  if (arr.length != 2) {
    return errorResponse(
      'Missing or invalid Authorization token.',
      statusCode: 401,
    );
  }

  final token = arr[1];

  final result = parseJwt(token);

  final userID = result['sub'] as String?;

  return Response(body: userID);
}
