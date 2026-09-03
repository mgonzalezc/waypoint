import 'package:flutter/material.dart';

import 'fade_in_network_image.dart';

class PhotoBackground extends StatelessWidget {
  const PhotoBackground({required this.photoUrl, super.key});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: theme.colorScheme.outline),
        if (photoUrl != null) FadeInNetworkImage(url: photoUrl!, fit: BoxFit.cover),
      ],
    );
  }
}
