import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/atoms/waypoint_button.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import 'ranking_view_model.dart';

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
    final locale = Localizations.localeOf(context).languageCode;
    ref.read(rankingViewModelProvider.notifier).submitQuery(query: _controller.text, locale: locale);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rankingViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('preguntar')),
      body: Padding(
        padding: const EdgeInsets.all(WaypointSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'top 10 tapas bars in Seville...',
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: WaypointSpacing.sm),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) => WaypointButton(
                label: 'generar ranking',
                onPressed: state.isLoading || value.text.trim().isEmpty ? null : _submit,
              ),
            ),
            const SizedBox(height: WaypointSpacing.md),
            Expanded(
              child: state.when(
                data: (result) {
                  if (result == null) return const SizedBox.shrink();
                  return ListView(
                    children: [
                      if (result.isDegraded)
                        const Text('(fewer than 10 good candidates)'),
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
            ),
          ],
        ),
      ),
    );
  }
}
