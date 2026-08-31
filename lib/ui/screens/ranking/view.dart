import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/atoms/waypoint_badge.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import 'ranking_view_model.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({required this.query, required this.locale, super.key});

  final String query;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rankingViewModelProvider((query: query, locale: locale)));

    return Scaffold(
      appBar: AppBar(title: const Text('ranking')),
      body: state.when(
        data: (result) {
          return ListView(
            padding: const EdgeInsets.all(WaypointSpacing.md),
            children: [
              if (result.isDegraded)
                const Padding(
                  padding: EdgeInsets.only(bottom: WaypointSpacing.md),
                  child: WaypointBadge(label: 'fewer than 10 good candidates'),
                ),
              for (final item in result.items)
                ListTile(
                  title: Text('${item.position}. ${item.name}'),
                  subtitle: Text(item.reason),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
