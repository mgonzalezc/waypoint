import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/history/history_entry.dart';
import '../../../l10n/app_localizations.dart';
import '../../design_system/atoms/waypoint_button.dart';
import '../../design_system/templates/waypoint_scaffold.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import '../../navigation/app_routes.dart';
import 'ask_view_model.dart';
import 'organisms/history_list.dart';

class AskScreen extends ConsumerStatefulWidget {
  const AskScreen({super.key});

  @override
  ConsumerState<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends ConsumerState<AskScreen> {
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
    ref.read(askViewModelProvider.notifier).submitQuery(query: query, locale: locale);
    context.pushNamed(AppRoutes.verifyingName, extra: (query: query, locale: locale));
  }

  void _openHistoryEntry(HistoryEntry entry) {
    ref.read(askViewModelProvider.notifier).openHistoryEntry(entry.query);
    context.pushNamed(AppRoutes.rankingName, extra: entry.result);
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
              hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyMedium?.color),
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
          HistoryList(
            entries: history,
            onEntryTap: _openHistoryEntry,
            onClear: () => ref.read(askViewModelProvider.notifier).clearHistory(),
          ),
        ],
      ),
    );
  }
}
