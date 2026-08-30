import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/ranking/ranking_repository.dart';
import '../services/openai_service.dart';
import 'direct_openai_ranking_repository.dart';

final dioProvider = Provider<Dio>((ref) => OpenAiService.buildClient());

final openAiServiceProvider = Provider<OpenAiService>(
  (ref) => OpenAiService(ref.watch(dioProvider)),
);

final rankingRepositoryProvider = Provider<RankingRepository>(
  (ref) => DirectOpenAiRankingRepository(ref.watch(openAiServiceProvider)),
);
