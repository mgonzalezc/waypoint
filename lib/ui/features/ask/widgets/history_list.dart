import 'package:flutter/material.dart';

import '../../../../domain/history/history_entry.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../design_system/theming/waypoint_spacing.dart';
import 'history_row.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({required this.entries, required this.onEntryTap, required this.onClear, super.key});

  final List<HistoryEntry> entries;
  final ValueChanged<HistoryEntry> onEntryTap;
  final VoidCallback onClear;

  Future<void> _showConfirmAndClearHistoryDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.historyClearConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.historyClearAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    onClear();
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: WaypointSpacing.xxl),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _showConfirmAndClearHistoryDialog(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: theme.colorScheme.onSurface,
            ),
            child: Text(l10n.historyClearAction, style: theme.textTheme.labelSmall),
          ),
        ),
        const SizedBox(height: WaypointSpacing.sm),
        for (final entry in entries) HistoryRow(entry: entry, onTap: () => onEntryTap(entry)),
      ],
    );
  }
}
