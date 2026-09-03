import 'package:flutter/material.dart';

import '../../../../domain/ranking/ranking_item.dart';
import '../../../../domain/ranking/ranking_result.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../design_system/theming/waypoint_spacing.dart';
import 'ranking_row.dart';

class RankingList extends StatelessWidget {
  const RankingList({required this.result, required this.onItemTap, super.key});

  final RankingResult result;
  final ValueChanged<RankingItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          RankingRow(item: item, onTap: () => onItemTap(item)),
      ],
    );
  }
}
