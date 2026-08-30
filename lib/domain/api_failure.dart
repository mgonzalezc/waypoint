sealed class ApiFailure implements Exception {
  const ApiFailure();
}

class NoConnection extends ApiFailure {
  const NoConnection();
}

class ServiceUnavailable extends ApiFailure {
  const ServiceUnavailable();
}

class UnexpectedFailure extends ApiFailure {
  const UnexpectedFailure(this.message);

  final String message;
}
