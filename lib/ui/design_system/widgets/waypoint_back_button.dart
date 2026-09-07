import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theming/waypoint_spacing.dart';

class WaypointBackButton extends StatelessWidget {
  const WaypointBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.pop(),
      icon: Icon(
        Icons.arrow_back,
        size: WaypointSpacing.iconMd,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
      alignment: Alignment.centerLeft,
    );
  }
}
