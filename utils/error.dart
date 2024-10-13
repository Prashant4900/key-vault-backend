import 'package:dart_frog/dart_frog.dart';

/// Creates an error response in JSON format.
///
/// This function generates a JSON response with a specified error [message].
/// Optionally, additional [error] details and a custom [statusCode] can be
/// provided. If no [statusCode] is specified, a default value of 500 (Internal
/// Server Error) is used.
///
/// - Parameters:
///   - [message]: The error message to be included in the response.
///   - [error]: Optional additional details about the error (e.g., stack trace).
///   - [statusCode]: The HTTP status code for the response. Defaults to 500 if not provided.
/// - Returns: A `Response` object containing the error details in JSON format.
Response errorResponse(
  String message, {
  dynamic error,
  int? statusCode,
}) {
  final responseBody = {
    'message': message,
    if (error != null) 'error': '$error',
  };
  return Response.json(body: responseBody, statusCode: statusCode ?? 500);
}
