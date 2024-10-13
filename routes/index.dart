import 'package:dart_frog/dart_frog.dart';

/// Handles HTTP requests for the root route ('/').
///
/// This function responds to incoming requests to the root URL with a simple
/// text message, "Welcome to Dart Frog!".
///
/// - Parameters:
///   - [context]: The `RequestContext` containing the HTTP request information.
/// - Returns: A `Response` object with a plain text body.
Response onRequest(RequestContext context) {
  return Response(body: 'Welcome to Dart Frog!');
}
