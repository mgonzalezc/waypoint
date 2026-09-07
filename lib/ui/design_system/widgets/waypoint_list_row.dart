import 'package:flutter/material.dart';

import '../theming/waypoint_spacing.dart';

/// A tappable row with a bottom divider, used by any list of past
/// searches or ranked items. Callers only supply the row's own content.
class WaypointListRow extends StatelessWidget {
  const WaypointListRow({required this.onTap, required this.child, super.key});

  final VoidCallback onTap;
  final Widget child;

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
        child: child,
      ),
    );
  }
}
