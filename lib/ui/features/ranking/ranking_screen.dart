import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/ranking/ranking_item.dart';
import '../../../domain/ranking/ranking_result.dart';
import '../../../l10n/app_localizations.dart';
import '../../design_system/widgets/waypoint_app_bar.dart';
import '../../design_system/widgets/waypoint_scaffold.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import '../../navigation/app_routes.dart';
import 'widgets/ranking_list.dart';
import 'ranking_view_model.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({required this.result, super.key});

  final RankingResult result;

  void _openDetail(BuildContext context, WidgetRef ref, RankingItem item) {
    ref.read(rankingViewModelProvider.notifier).openItem(item);
    context.pushNamed(AppRoutes.detailName, extra: (item: item, query: result.query));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return WaypointScaffold(
      appBar: const WaypointAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(WaypointSpacing.lg),
        children: [
          Text(l10n.rankingTitle, style: theme.textTheme.displayLarge?.copyWith(fontSize: 22)),
          RankingList(result: result, onItemTap: (item) => _openDetail(context, ref, item)),
        ],
      ),
    );
  }
}
