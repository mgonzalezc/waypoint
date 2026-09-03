import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import 'compass_needle.dart';

class RotatingPhrase extends StatefulWidget {
  const RotatingPhrase({super.key});

  @override
  State<RotatingPhrase> createState() => _RotatingPhraseState();
}

class _RotatingPhraseState extends State<RotatingPhrase> {
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
