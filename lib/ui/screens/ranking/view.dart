import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/api_failure.dart';
import '../../../l10n/app_localizations.dart';
import '../../design_system/atoms/waypoint_badge.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import 'ranking_view_model.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({required this.query, required this.locale, super.key});

  final String query;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(rankingViewModelProvider((query: query, locale: locale)));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.rankingTitle)),
      body: state.when(
        data: (result) {
          return ListView(
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(_errorMessage(l10n, error))),
      ),
    );
  }

  String _errorMessage(AppLocalizations l10n, Object error) {
    if (error is! ApiFailure) return l10n.errorUnexpected;
    return switch (error) {
      NoConnection() => l10n.errorNoConnection,
      ServiceUnavailable() => l10n.errorServiceUnavailable,
      UnexpectedFailure() => l10n.errorUnexpected,
    };
  }
}
