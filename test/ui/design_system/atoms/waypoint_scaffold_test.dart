import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/ui/design_system/atoms/waypoint_scaffold.dart';

void main() {
  group('WaypointScaffold', () {
    group('when it builds', () {
      testWidgets('then it wraps its body in exactly one Scaffold', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: WaypointScaffold(body: Text('content'))),
        );

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('content'), findsOneWidget);
      });

      testWidgets('then the status bar is transparent with dark icons, not the OS default', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: WaypointScaffold(body: Text('content'))),
        );

        final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
          find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
        );
        expect(region.value.statusBarColor, Colors.transparent);
        expect(region.value.statusBarIconBrightness, Brightness.dark);
      });
    });

    group('when an appBar is provided', () {
      testWidgets('then the Scaffold uses it', (tester) async {
        const appBar = PreferredSize(preferredSize: Size.fromHeight(40), child: Text('bar'));

        await tester.pumpWidget(
          const MaterialApp(
            home: WaypointScaffold(appBar: appBar, body: Text('content')),
          ),
        );

        expect(find.text('bar'), findsOneWidget);
        expect(tester.widget<Scaffold>(find.byType(Scaffold)).appBar, appBar);
      });

      testWidgets('then the body SafeArea skips the top inset', (tester) async {
        const appBar = PreferredSize(preferredSize: Size.fromHeight(40), child: Text('bar'));

        await tester.pumpWidget(
          const MaterialApp(
            home: WaypointScaffold(appBar: appBar, body: Text('content')),
          ),
        );

        expect(tester.widget<SafeArea>(find.byType(SafeArea)).top, isFalse);
      });
    });

    group('when no appBar is provided', () {
      testWidgets('then the body SafeArea applies the top inset', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: WaypointScaffold(body: Text('content'))),
        );

        expect(tester.widget<SafeArea>(find.byType(SafeArea)).top, isTrue);
      });
    });

    group('when extendBodyBehindAppBar is true', () {
      testWidgets('then the Scaffold extends its body behind the appBar', (tester) async {
        const appBar = PreferredSize(preferredSize: Size.fromHeight(40), child: Text('bar'));

        await tester.pumpWidget(
          const MaterialApp(
            home: WaypointScaffold(appBar: appBar, extendBodyBehindAppBar: true, body: Text('content')),
          ),
        );

        expect(tester.widget<Scaffold>(find.byType(Scaffold)).extendBodyBehindAppBar, isTrue);
      });
    });

    group('when extendBodyBehindAppBar is not specified', () {
      testWidgets('then the Scaffold does not extend its body behind the appBar', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: WaypointScaffold(body: Text('content'))),
        );

        expect(tester.widget<Scaffold>(find.byType(Scaffold)).extendBodyBehindAppBar, isFalse);
      });
    });
  });
}
