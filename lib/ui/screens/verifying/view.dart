import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/api_failure.dart';
import '../../../l10n/app_localizations.dart';
import '../../design_system/atoms/waypoint_back_button.dart';
import '../../design_system/atoms/waypoint_scaffold.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import '../ranking/view.dart';
import 'compass_needle.dart';
import 'verifying_view_model.dart';

class VerifyingScreen extends ConsumerWidget {
  const VerifyingScreen({required this.query, required this.locale, super.key});

  final String query;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(verifyingViewModelProvider((query: query, locale: locale)));

    ref.listen(verifyingViewModelProvider((query: query, locale: locale)), (previous, next) {
      next.whenOrNull(
        data: (result) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => RankingScreen(result: result)),
          );
        },
      );
    });

    return WaypointScaffold(
      body: state.when(
        data: (_) => const SizedBox.shrink(),
        loading: () => const _RotatingPhrase(),
        error: (error, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(WaypointSpacing.lg),
              child: WaypointBackButton(),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: WaypointSpacing.lg),
                  child: Text(_errorMessage(l10n, error), textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
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

class _RotatingPhrase extends StatefulWidget {
  const _RotatingPhrase();

  @override
  State<_RotatingPhrase> createState() => _RotatingPhraseState();
}

class _RotatingPhraseState extends State<_RotatingPhrase> {
  late final Timer _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => setState(() => _index++));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final phrases = [
      l10n.verifyingPhrase1,
      l10n.verifyingPhrase2,
      l10n.verifyingPhrase3,
      l10n.verifyingPhrase4,
    ];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CompassNeedle(),
          const SizedBox(height: WaypointSpacing.lg),
          Text(phrases[_index % phrases.length], style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
