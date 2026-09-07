import 'package:flutter/material.dart';

import '../../../../domain/ranking/ranking_item.dart';
import '../../../design_system/widgets/waypoint_list_row.dart';
import '../../../design_system/widgets/waypoint_numeral.dart';
import '../../../design_system/theming/waypoint_spacing.dart';

class RankingRow extends StatelessWidget {
  const RankingRow({required this.item, required this.onTap, super.key});

  final RankingItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WaypointListRow(
      onTap: onTap,
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
                Text(
                  item.reason,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
