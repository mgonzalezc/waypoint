import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/history/history_entry.dart';
import '../../../l10n/app_localizations.dart';
import '../../design_system/atoms/waypoint_button.dart';
import '../../design_system/atoms/waypoint_scaffold.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import '../ranking/view.dart';
import '../verifying/view.dart';
import 'ask_view_model.dart';

class AskView extends ConsumerStatefulWidget {
  const AskView({super.key});

  @override
  ConsumerState<AskView> createState() => _AskViewState();
}

class _AskViewState extends ConsumerState<AskView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    final locale = Localizations.localeOf(context).languageCode;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VerifyingScreen(query: query, locale: locale)),
    );
  }

  Future<void> _showConfirmAndClearHistoryDialog() async {
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

    await ref.read(askViewModelProvider.notifier).clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final history = ref.watch(askHistoryProvider);

    return WaypointScaffold(
      body: ListView(
        padding: const EdgeInsets.all(WaypointSpacing.lg),
        children: [
          Text(l10n.askHeadline, style: theme.textTheme.displayLarge),
          const SizedBox(height: WaypointSpacing.xl),
          Text(l10n.askFieldLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: WaypointSpacing.sm),
          TextField(
            controller: _controller,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: l10n.askHint,
              isDense: true,
              contentPadding: const EdgeInsets.only(bottom: WaypointSpacing.sm),
              border: const UnderlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: WaypointSpacing.lg),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => WaypointButton(
              label: l10n.askSubmit,
              onPressed: value.text.trim().isEmpty ? null : _submit,
            ),
          ),
          if (history.isNotEmpty) ...[
            const SizedBox(height: WaypointSpacing.xxl),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showConfirmAndClearHistoryDialog,
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
            for (final entry in history) _HistoryRow(entry: entry),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RankingScreen(result: entry.result)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: WaypointSpacing.md),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.queries.last, style: theme.textTheme.titleMedium),
            const SizedBox(height: WaypointSpacing.xs),
            Text(
              entry.result.items.map((item) => item.name).join(', '),
              style: theme.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
