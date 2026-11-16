import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_tracker/pages/check_in_menu.dart';
import 'package:hermes_tracker/pages/check_out_menu.dart';
import 'package:hermes_tracker/pages/letter_menu.dart';
import 'package:hermes_tracker/pages/package_explorer_menu.dart';
import 'package:hermes_tracker/routes.dart';
import 'package:material_ui/material_ui.dart';

import 'test_app.dart';

bool canGoBack(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator).first).canPop();

void main() {
  testWidgets('starts on the Check-In page', (tester) async {
    await pumpApp(tester);

    expect(find.byType(CheckInMenu), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Check-In'), findsOneWidget);
    expect(canGoBack(tester), isFalse);
  });

  testWidgets('the drawer opens every page without stacking them', (
    tester,
  ) async {
    await pumpApp(tester);

    await openFromDrawer(tester, 'Letters');
    expect(find.byType(LetterMenu), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Letter Menu'), findsOneWidget);
    expect(canGoBack(tester), isFalse);

    await openFromDrawer(tester, 'Check-Out');
    expect(find.byType(CheckOutMenu), findsOneWidget);
    expect(find.byType(LetterMenu), findsNothing);
    expect(canGoBack(tester), isFalse);

    await openFromDrawer(tester, 'Explore');
    expect(find.byType(PackageExplorerMenu), findsOneWidget);
    expect(canGoBack(tester), isFalse);

    await openFromDrawer(tester, 'Check-In');
    expect(find.byType(CheckInMenu), findsOneWidget);
    expect(find.byType(PackageExplorerMenu), findsNothing);
    expect(canGoBack(tester), isFalse);
  });

  testWidgets('the entry for the current page only closes the drawer', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.enterText(field('Name'), 'Jane Doe');

    await openFromDrawer(tester, 'Check-In');

    expect(find.byType(Drawer), findsNothing);
    // Still the same page: what was typed is still there.
    expect(
      tester.widget<TextFormField>(field('Name')).controller!.text,
      'Jane Doe',
    );
  });

  testWidgets('the drawer header shows the stroked Hermes title', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    // One Text for the black outline and one for the white fill.
    expect(find.text('Hermes'), findsNWidgets(2));
    expect(find.text('Letters'), findsOneWidget);
  });

  testWidgets('a link to a page opens that page', (tester) async {
    await pumpApp(tester, route: Routes.letters);

    expect(find.byType(LetterMenu), findsOneWidget);
    expect(canGoBack(tester), isFalse);
  });

  testWidgets('an unknown route opens the Check-In page', (tester) async {
    await pumpApp(tester, route: '/nonsense');

    expect(tester.takeException(), isNull);
    expect(find.byType(CheckInMenu), findsOneWidget);
  });

  testWidgets('the draft pages say they are not connected', (tester) async {
    await pumpApp(tester, route: Routes.checkOut);
    expect(
      find.text('Draft page: it is not connected to the demo data.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Check Out'))
          .onPressed,
      isNull,
    );
  });
}
