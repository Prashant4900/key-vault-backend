import 'package:dart_frog/dart_frog.dart';

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
