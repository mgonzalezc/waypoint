import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theming/waypoint_spacing.dart';

class WaypointAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WaypointAppBar({super.key});

  static const double _scrimOpacity = 0.9;
  static const double _shadowOpacity = 0.16;
  static const double _shadowBlur = 6;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: kToolbarHeight,
      leading: Padding(
        padding: const EdgeInsets.all(WaypointSpacing.sm),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: _scrimOpacity),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onSurface.withValues(alpha: _shadowOpacity),
                blurRadius: _shadowBlur,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, size: WaypointSpacing.iconMd, color: theme.colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}
