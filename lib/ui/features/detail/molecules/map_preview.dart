import 'package:flutter/material.dart';

import '../../../design_system/theming/waypoint_spacing.dart';
import 'fade_in_network_image.dart';

class MapPreview extends StatelessWidget {
  const MapPreview({required this.mapUrl, super.key});

  final String? mapUrl;

  static const double _aspectRatio = 2;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _MapPlaceholder(),
          if (mapUrl != null) FadeInNetworkImage(url: mapUrl!, fit: BoxFit.cover),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.outline,
      child: Center(
        child: Icon(Icons.location_on, size: WaypointSpacing.iconLg, color: theme.colorScheme.primary),
      ),
    );
  }
}
