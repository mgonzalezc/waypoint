import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../design_system/atoms/waypoint_button.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import '../verifying/view.dart';

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
      MaterialPageRoute(builder: (_) => VerifyingScreen(query: query, locale: locale)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(WaypointSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
            ],
          ),
        ),
      ),
    );
  }
}
