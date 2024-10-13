import 'package:dart_frog/dart_frog.dart';

/// Handles requests to the /api/secret/ endpoint.
///
/// This function responds with a simple message indicating that the
/// endpoint is accessible.
///
/// - Parameters:
///   - [context]: Provides access to the HTTP request information.
/// - Returns: A `Response` with a message indicating the route's purpose.
Response onRequest(RequestContext context) {
  // Respond with a message indicating that this is the secret API route.
  return Response(body: 'This is a secret API route!');
}
