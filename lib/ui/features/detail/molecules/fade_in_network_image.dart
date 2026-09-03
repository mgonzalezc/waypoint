import 'package:flutter/material.dart';

class FadeInNetworkImage extends StatelessWidget {
  const FadeInNetworkImage({required this.url, required this.fit, super.key});

  final String url;
  final BoxFit fit;

  static const Duration _fadeDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: _fadeDuration,
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}
