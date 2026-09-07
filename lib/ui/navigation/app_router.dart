import 'package:go_router/go_router.dart';

import '../../domain/ranking/ranking_item.dart';
import '../../domain/ranking/ranking_result.dart';
import '../features/ask/ask_screen.dart';
import '../features/detail/detail_screen.dart';
import '../features/ranking/ranking_screen.dart';
import '../features/verifying/verifying_screen.dart';
import 'app_routes.dart';

typedef VerifyingRouteArgs = ({String query, String locale});
typedef DetailRouteArgs = ({RankingItem item, String query});

final askRoute = GoRoute(
  name: AppRoutes.askName,
  path: AppRoutes.askPath,
  builder: (context, state) => const AskScreen(),
);

final verifyingRoute = GoRoute(
  name: AppRoutes.verifyingName,
  path: AppRoutes.verifyingPath,
  redirect: (context, state) => state.extra is VerifyingRouteArgs ? null : AppRoutes.askPath,
  builder: (context, state) {
    final args = state.extra! as VerifyingRouteArgs;
    return VerifyingScreen(query: args.query, locale: args.locale);
  },
);

final rankingRoute = GoRoute(
  name: AppRoutes.rankingName,
  path: AppRoutes.rankingPath,
  redirect: (context, state) => state.extra is RankingResult ? null : AppRoutes.askPath,
  builder: (context, state) => RankingScreen(result: state.extra! as RankingResult),
);

final detailRoute = GoRoute(
  name: AppRoutes.detailName,
  path: AppRoutes.detailPath,
  redirect: (context, state) => state.extra is DetailRouteArgs ? null : AppRoutes.askPath,
  builder: (context, state) {
    final args = state.extra! as DetailRouteArgs;
    return DetailScreen(item: args.item, query: args.query);
  },
);

final appRouter = GoRouter(
  initialLocation: AppRoutes.askPath,
  routes: [askRoute, verifyingRoute, rankingRoute, detailRoute],
  errorBuilder: (context, state) => const AskScreen(),
);
