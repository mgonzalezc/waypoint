import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/api_failure.dart';
import '../../../l10n/app_localizations.dart';
import '../../design_system/atoms/waypoint_back_button.dart';
import '../../design_system/templates/waypoint_scaffold.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import '../../navigation/app_routes.dart';
import 'molecules/rotating_phrase.dart';
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
          context.pushReplacementNamed(AppRoutes.rankingName, extra: result);
        },
      );
    });

    return WaypointScaffold(
      body: state.when(
        data: (_) => const SizedBox.shrink(),
        loading: () => const RotatingPhrase(),
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
