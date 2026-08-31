import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/api_failure.dart';
import '../../../l10n/app_localizations.dart';
import '../../design_system/atoms/waypoint_back_button.dart';
import '../../design_system/theming/waypoint_colors.dart';
import '../../design_system/theming/waypoint_spacing.dart';
import '../ranking/view.dart';
import 'ranking_view_model.dart';

class VerifyingScreen extends ConsumerWidget {
  const VerifyingScreen({required this.query, required this.locale, super.key});

  final String query;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(rankingViewModelProvider((query: query, locale: locale)));

    ref.listen(rankingViewModelProvider((query: query, locale: locale)), (previous, next) {
      next.whenOrNull(
        data: (result) => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RankingScreen(result: result)),
        ),
      );
    });

    return Scaffold(
      body: SafeArea(
        child: state.when(
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
          const _CompassNeedle(),
          const SizedBox(height: WaypointSpacing.lg),
          Text(phrases[_index % phrases.length], style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

/// Settles toward north and overshoots each cycle, like an instrument
/// actually searching rather than a flat, indeterminate spin.
class _CompassNeedle extends StatefulWidget {
  const _CompassNeedle();

  @override
  State<_CompassNeedle> createState() => _CompassNeedleState();
}

class _CompassNeedleState extends State<_CompassNeedle> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _angleDegrees;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat();
    _angleDegrees = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -70.0, end: 14.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 55,
      ),
      TweenSequenceItem(tween: Tween(begin: 14.0, end: -6.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: -70.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _angleDegrees,
      builder: (context, _) => CustomPaint(
        size: const Size(120, 120),
        painter: _CompassPainter(angleDegrees: _angleDegrees.value),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  const _CompassPainter({required this.angleDegrees});

  final double angleDegrees;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final ring = Paint()
      ..color = WaypointColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, 52, ring);

    for (final angle in [0.0, 90.0, 180.0, 270.0]) {
      final radians = angle * math.pi / 180;
      final outer = center + Offset(math.sin(radians), -math.cos(radians)) * 50;
      final inner = center + Offset(math.sin(radians), -math.cos(radians)) * 40;
      canvas.drawLine(inner, outer, ring);
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angleDegrees * math.pi / 180);
    canvas.drawLine(
      Offset.zero,
      const Offset(0, -36),
      Paint()
        ..color = WaypointColors.amber
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset.zero,
      const Offset(0, 30),
      Paint()
        ..color = WaypointColors.textPrimary
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    canvas.drawCircle(center, 3, Paint()..color = WaypointColors.textPrimary);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) => oldDelegate.angleDegrees != angleDegrees;
}
