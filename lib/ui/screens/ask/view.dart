import 'package:flutter/material.dart';

import '../../design_system/atoms/waypoint_button.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import '../ranking/view.dart';

class AskView extends StatefulWidget {
  const AskView({super.key});

  @override
  State<AskView> createState() => _AskViewState();
}

class _AskViewState extends State<AskView> {
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
      MaterialPageRoute(builder: (_) => RankingScreen(query: query, locale: locale)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: value.text.trim().isEmpty ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
