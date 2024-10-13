import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

import '../../../utils/constants.dart';
import '../../../utils/error.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return errorResponse('Invalid request method. Only GET is allowed.');
  }

  final headers = context.request.headers;
  final authHeader = headers['Authorization'];

  if (authHeader == null || authHeader.isEmpty) {
    return errorResponse(
      'Missing or invalid Authorization token.',
      statusCode: 401,
    );
  }

  try {
    final response = await http.get(
      Uri.parse('${Urls.BASE_URL}${Urls.LOGS}?select=*'),
      headers: {
        'apikey': Constants.SUPABASE_ANON,
        'Authorization': authHeader,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as List<dynamic>;

      return Response.json(
        body: {
          'message': 'Secret key retrieved successfully',
          'logs': responseBody,
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
