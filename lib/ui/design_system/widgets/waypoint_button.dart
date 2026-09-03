import 'package:flutter/material.dart';

import '../theming/waypoint_spacing.dart';

class WaypointButton extends StatelessWidget {
  const WaypointButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;
    final arrowColor = enabled ? theme.colorScheme.primary : theme.disabledColor;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: theme.colorScheme.onSurface,
        disabledForegroundColor: theme.disabledColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.labelLarge?.copyWith(color: enabled ? null : theme.disabledColor)),
          const SizedBox(width: WaypointSpacing.sm),
          Icon(Icons.arrow_forward, size: WaypointSpacing.iconSm, color: arrowColor),
        ],
      ),
    );
  }
}
