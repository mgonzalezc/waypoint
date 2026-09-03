import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/ranking/ranking_item.dart';
import '../../../domain/ranking/ranking_result.dart';
import '../../../l10n/app_localizations.dart';
import '../../design_system/atoms/waypoint_app_bar.dart';
import '../../design_system/atoms/waypoint_numeral.dart';
import '../../design_system/atoms/waypoint_scaffold.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import '../detail/view.dart';
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
          if (result.items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: WaypointSpacing.xs),
              child: Text(l10n.rankingEmptyNote, style: theme.textTheme.bodyMedium),
            )
          else if (result.isDegraded)
            Padding(
              padding: const EdgeInsets.only(top: WaypointSpacing.xs),
              child: Text(l10n.rankingDegradedNote, style: theme.textTheme.bodyMedium),
            ),
          const SizedBox(height: WaypointSpacing.md),
          for (final item in result.items)
            InkWell(
              onTap: () => _openDetail(context, ref, item),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: WaypointSpacing.md),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: WaypointNumeral.columnWidth, child: WaypointNumeral(value: item.position)),
                    const SizedBox(width: WaypointSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: theme.textTheme.titleMedium),
                          const SizedBox(height: WaypointSpacing.xs),
                          Text(item.reason, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
