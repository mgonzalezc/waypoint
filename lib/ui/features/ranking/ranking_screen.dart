import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/ranking/ranking_item.dart';
import '../../../domain/ranking/ranking_result.dart';
import '../../../l10n/app_localizations.dart';
import '../../design_system/atoms/waypoint_scaffold.dart';
import '../../design_system/molecules/waypoint_app_bar.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import '../detail/detail_screen.dart';
import 'organisms/ranking_list.dart';
import 'ranking_view_model.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({required this.result, super.key});

  final RankingResult result;

  void _openDetail(BuildContext context, WidgetRef ref, RankingItem item) {
    ref.read(rankingViewModelProvider.notifier).openItem(item);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(item: item, query: result.query)),
    );
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
