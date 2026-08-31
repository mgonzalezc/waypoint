import 'package:flutter/material.dart';

import '../../../domain/ranking/ranking_result.dart';
import '../../../l10n/app_localizations.dart';
import '../../design_system/atoms/waypoint_badge.dart';
import '../../design_system/theming/waypoint_spacing.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({required this.result, super.key});

  final RankingResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rankingTitle)),
      body: ListView(
        padding: const EdgeInsets.all(WaypointSpacing.md),
        children: [
          if (result.isDegraded)
            Padding(
              padding: const EdgeInsets.only(bottom: WaypointSpacing.md),
              child: WaypointBadge(label: l10n.rankingDegradedBadge),
            ),
          for (final item in result.items)
            ListTile(
              title: Text('${item.position}. ${item.name}'),
              subtitle: Text(item.reason),
            ),
        ],
      ),
    );
  }
}
