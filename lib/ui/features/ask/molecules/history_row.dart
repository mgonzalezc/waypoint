import 'package:flutter/material.dart';

import '../../../../domain/history/history_entry.dart';
import '../../../design_system/theming/waypoint_spacing.dart';

class HistoryRow extends StatelessWidget {
  const HistoryRow({required this.entry, required this.onTap, super.key});

  final HistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: WaypointSpacing.md),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.query, style: theme.textTheme.titleMedium),
            const SizedBox(height: WaypointSpacing.xs),
            Text(
              entry.result.items.map((item) => item.name).join(', '),
              style: theme.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
