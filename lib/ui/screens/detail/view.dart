import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/ranking/ranking_item.dart';
import '../../../domain/ranking/source_citation.dart';
import '../../../l10n/app_localizations.dart';
import '../../design_system/atoms/waypoint_back_button.dart';
import '../../design_system/atoms/waypoint_numeral.dart';
import '../../design_system/atoms/waypoint_scaffold.dart';
import '../../design_system/theming/waypoint_spacing.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({required this.item, super.key});

  final RankingItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return WaypointScaffold(
      body: ListView(
        padding: const EdgeInsets.all(WaypointSpacing.lg),
        children: [
          const WaypointBackButton(),
          const SizedBox(height: WaypointSpacing.md),
          WaypointNumeral(value: item.position, fontSize: 72),
          Text(item.name, style: theme.textTheme.displayLarge?.copyWith(fontSize: 30)),
          const SizedBox(height: WaypointSpacing.md),
          Text(item.reason, style: theme.textTheme.bodyLarge),
          if (item.sources.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: WaypointSpacing.lg),
              child: Divider(height: 1, color: theme.colorScheme.outline),
            ),
            Text(l10n.detailSourcesLabel, style: theme.textTheme.labelSmall),
            for (final source in item.sources) _SourceRow(source: source),
          ],
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.source});

  final SourceCitation source;

  Future<void> _open(BuildContext context) async {
    final launched = await launchUrl(Uri.parse(source.url));
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: WaypointSpacing.md),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(source.title, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface)),
            ),
            Icon(Icons.arrow_forward, size: WaypointSpacing.iconSm, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
