import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WaypointScaffold extends StatelessWidget {
  const WaypointScaffold({
    required this.body,
    this.appBar,
    this.extendBodyBehindAppBar = false,
    super.key,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool extendBodyBehindAppBar;

  static const _systemOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemOverlayStyle,
      child: Scaffold(
        appBar: appBar,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        body: SafeArea(top: appBar == null, child: body),
      ),
    );
  }
}
