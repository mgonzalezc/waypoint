import 'package:flutter/material.dart';

import '../../../domain/ranking/source_citation.dart';
import '../../../l10n/app_localizations.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import 'link_row.dart';

class SourcesList extends StatelessWidget {
  const SourcesList({required this.sources, required this.onOpenSource, super.key});

  final List<SourceCitation> sources;
  final ValueChanged<String> onOpenSource;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: WaypointSpacing.lg),
          child: Divider(height: 1, color: theme.colorScheme.outline),
        ),
        Text(l10n.detailSourcesLabel, style: theme.textTheme.labelSmall),
        for (final (index, source) in sources.indexed) ...[
          if (index > 0) Divider(height: 1, color: theme.colorScheme.outline),
          LinkRow(label: source.title, url: source.url, onOpen: () => onOpenSource(source.url)),
        ],
      ],
    );
  }
}
