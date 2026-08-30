sealed class RankingFailure implements Exception {
  const RankingFailure();
}

class NoConnection extends RankingFailure {
  const NoConnection();
}

class ServiceUnavailable extends RankingFailure {
  const ServiceUnavailable();
}

class RateLimited extends RankingFailure {
  const RateLimited();
}

class InsufficientQuota extends RankingFailure {
  const InsufficientQuota();
}

class UnexpectedFailure extends RankingFailure {
  const UnexpectedFailure(this.message);

  final String message;
}
