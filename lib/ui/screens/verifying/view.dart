import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import '../ranking/ranking_view_model.dart';
import '../ranking/view.dart';

class VerifyingScreen extends ConsumerWidget {
  const VerifyingScreen({required this.query, required this.locale, super.key});

  final String query;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(rankingViewModelProvider((query: query, locale: locale)), (previous, next) {
      if (next.isLoading) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RankingScreen(query: query, locale: locale)),
      );
    });

    return const Scaffold(body: _RotatingPhrase());
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
          const CircularProgressIndicator(),
          const SizedBox(height: WaypointSpacing.md),
          Text(phrases[_index % phrases.length]),
        ],
      ),
    );
  }
}
