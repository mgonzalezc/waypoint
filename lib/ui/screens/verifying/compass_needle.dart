import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/theming/waypoint_colors.dart';

/// Settles toward north and overshoots each cycle, like an instrument
/// actually searching rather than a flat, indeterminate spin.
class CompassNeedle extends StatefulWidget {
  const CompassNeedle({super.key});

  @override
  State<CompassNeedle> createState() => _CompassNeedleState();
}

class _CompassNeedleState extends State<CompassNeedle> with SingleTickerProviderStateMixin {
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
