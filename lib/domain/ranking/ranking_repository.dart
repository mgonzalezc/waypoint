import 'ranking_result.dart';

abstract interface class RankingRepository {
  Future<RankingResult> generateRanking({
    required String query,
    required String locale,
  });
}
