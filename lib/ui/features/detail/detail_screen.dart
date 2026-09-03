import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/ranking/ranking_item.dart';
import '../../design_system/atoms/waypoint_numeral.dart';
import '../../design_system/atoms/waypoint_scaffold.dart';
import '../../design_system/molecules/waypoint_app_bar.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import 'detail_view_model.dart';
import 'organisms/map_preview.dart';
import 'organisms/photo_background.dart';
import 'organisms/sources_list.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({required this.item, required this.query, super.key});

  final RankingItem item;
  final String query;

  static const double _photoAspectRatio = 4 / 3;
  static const double _headlineFontSize = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final detailQuery = (placeName: item.name, query: query);
    final media = ref.watch(detailViewModelProvider(detailQuery)).value;
    final photoHeight = MediaQuery.sizeOf(context).width / _photoAspectRatio;

    return WaypointScaffold(
      appBar: const WaypointAppBar(),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: photoHeight,
            child: PhotoBackground(photoUrl: media?.photoUrl),
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
                      SourcesList(
                        sources: item.sources,
                        onOpenSource: (url) => ref
                            .read(detailViewModelProvider(detailQuery).notifier)
                            .openSource(url),
                      ),
                      const SizedBox(height: WaypointSpacing.lg),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(WaypointSpacing.sm),
                        child: MapPreview(mapUrl: media?.mapUrl),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
