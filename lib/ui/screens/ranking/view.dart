import 'package:flutter/material.dart';

import '../../../domain/ranking/ranking_result.dart';
import '../../../l10n/app_localizations.dart';
import '../../design_system/atoms/waypoint_app_bar.dart';
import '../../design_system/atoms/waypoint_numeral.dart';
import '../../design_system/atoms/waypoint_scaffold.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import '../detail/view.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({required this.result, super.key});

  final RankingResult result;

  @override
  Widget build(BuildContext context) {
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailScreen(item: item, query: result.query)),
              ),
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
