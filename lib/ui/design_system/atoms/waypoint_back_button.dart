import 'package:flutter/material.dart';

class WaypointBackButton extends StatelessWidget {
  const WaypointBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: Icon(Icons.arrow_back, size: 20, color: Theme.of(context).colorScheme.onSurface),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
      alignment: Alignment.centerLeft,
    );
  }
}
