import 'package:flutter/material.dart';

import '../../../../domain/history/history_entry.dart';
import '../../../design_system/widgets/waypoint_list_row.dart';
import '../../../design_system/theming/waypoint_spacing.dart';

class HistoryRow extends StatelessWidget {
  const HistoryRow({required this.entry, required this.onTap, super.key});

  final HistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WaypointListRow(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.result.query, style: theme.textTheme.titleMedium),
          const SizedBox(height: WaypointSpacing.xs),
          Text(
            entry.result.items.map((item) => item.name).join(', '),
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
