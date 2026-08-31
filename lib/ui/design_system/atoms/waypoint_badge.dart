import 'package:flutter/material.dart';

import '../theming/waypoint_spacing.dart';

class WaypointBadge extends StatelessWidget {
  const WaypointBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: WaypointSpacing.sm, vertical: WaypointSpacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(WaypointSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.onPrimary),
      ),
    );
  }
}
