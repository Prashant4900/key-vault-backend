import 'package:dart_frog/dart_frog.dart';

/// Handles HTTP requests for the logs API route (`/api/logs/`).
///
/// This function responds to incoming requests to the logs API route with
/// a simple text message, "This is a logs api route!".
///
/// - Parameters:
///   - [context]: Provides access to the HTTP request information.
/// - Returns: A `Response` object with a plain text body.
Response onRequest(RequestContext context) {
  return Response(body: 'This is a logs api route!');
}
