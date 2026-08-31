import 'package:flutter/material.dart';

class WaypointNumeral extends StatelessWidget {
  const WaypointNumeral({required this.value, this.fontSize = 30, super.key});

  final int value;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      value.toString().padLeft(2, '0'),
      style: theme.textTheme.displayLarge?.copyWith(
        fontSize: fontSize,
        color: theme.colorScheme.outline,
      ),
    );
  }
}
