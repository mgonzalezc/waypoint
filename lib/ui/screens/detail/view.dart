import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/ranking/ranking_item.dart';
import '../../../l10n/app_localizations.dart';
import '../../design_system/atoms/waypoint_numeral.dart';
import '../../design_system/atoms/waypoint_scaffold.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import 'place_media_view_model.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({required this.item, required this.query, super.key});

  final RankingItem item;
  final String query;

  static const double _photoAspectRatio = 4 / 3;
  static const double _mapAspectRatio = 2;
  static const double _headlineFontSize = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final media = ref.watch(placeMediaViewModelProvider((placeName: item.name, query: query))).value;
    final photoHeight = MediaQuery.sizeOf(context).width / _photoAspectRatio;

    return WaypointScaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: photoHeight,
            child: _PhotoBackground(photoUrl: media?.photoUrl),
          ),
          Positioned(
            top: photoHeight - WaypointSpacing.lg,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(WaypointSpacing.radiusMd)),
              child: ColoredBox(
                color: theme.colorScheme.surface,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(WaypointSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WaypointNumeral(value: item.position, fontSize: WaypointNumeral.cardSize),
                      const SizedBox(height: WaypointSpacing.md),
                      Text(
                        item.name,
                        style: theme.textTheme.displayLarge?.copyWith(fontSize: _headlineFontSize),
                      ),
                      const SizedBox(height: WaypointSpacing.md),
                      Text(item.reason, style: theme.textTheme.bodyLarge),
                      if (item.sources.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: WaypointSpacing.lg),
                          child: Divider(height: 1, color: theme.colorScheme.outline),
                        ),
                        Text(l10n.detailSourcesLabel, style: theme.textTheme.labelSmall),
                        for (final (index, source) in item.sources.indexed) ...[
                          if (index > 0) Divider(height: 1, color: theme.colorScheme.outline),
                          _LinkRow(label: source.title, url: source.url),
                        ],
                      ],
                      const SizedBox(height: WaypointSpacing.lg),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(WaypointSpacing.sm),
                        child: _MapPreview(mapUrl: media?.mapUrl),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            top: WaypointSpacing.sm,
            left: WaypointSpacing.sm,
            child: _BackButtonChip(),
          ),
        ],
      ),
    );
  }
}

class _BackButtonChip extends StatelessWidget {
  const _BackButtonChip();

  static const double _scrimOpacity = 0.9;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: _scrimOpacity),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, size: WaypointSpacing.iconMd, color: theme.colorScheme.onSurface),
      ),
    );
  }
}

class _PhotoBackground extends StatelessWidget {
  const _PhotoBackground({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: theme.colorScheme.outline),
        if (photoUrl != null) _FadeInNetworkImage(url: photoUrl!, fit: BoxFit.cover),
      ],
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.mapUrl});

  final String? mapUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: DetailScreen._mapAspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _MapPlaceholder(),
          if (mapUrl != null) _FadeInNetworkImage(url: mapUrl!, fit: BoxFit.cover),
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

class _FadeInNetworkImage extends StatelessWidget {
  const _FadeInNetworkImage({required this.url, required this.fit});

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

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.url});

  final String label;
  final String url;

  Future<void> _open(BuildContext context) async {
    final launched = await launchUrl(Uri.parse(url));
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.detailSourceLaunchFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _open(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: WaypointSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface)),
            ),
            Icon(Icons.arrow_forward, size: WaypointSpacing.iconSm, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
