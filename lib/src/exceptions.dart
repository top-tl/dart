/// Exception hierarchy for the TOP.TL SDK.
///
/// All failures throw a subclass of [TopTLException] so callers can catch
/// broadly or match on the specific HTTP-class.

class TopTLException implements Exception {
  final String message;
  final int? statusCode;
  final Object? body;
  TopTLException(this.message, {this.statusCode, this.body});

  @override
  String toString() => 'TopTLException: $message';

  static TopTLException forStatus(int status, String message, Object? body) {
    switch (status) {
      case 401:
      case 403:
        return AuthenticationException(message, statusCode: status, body: body);
      case 404:
        return NotFoundException(message, statusCode: status, body: body);
      case 429:
        return RateLimitException(message, statusCode: status, body: body);
      default:
        if (status >= 400 && status < 500) {
          return ValidationException(message, statusCode: status, body: body);
        }
        return TopTLException(message, statusCode: status, body: body);
    }
  }
}

class AuthenticationException extends TopTLException {
  AuthenticationException(super.message, {super.statusCode, super.body});
}

class NotFoundException extends TopTLException {
  NotFoundException(super.message, {super.statusCode, super.body});
}

class RateLimitException extends TopTLException {
  RateLimitException(super.message, {super.statusCode, super.body});
}

class ValidationException extends TopTLException {
  ValidationException(super.message, {super.statusCode, super.body});
}
