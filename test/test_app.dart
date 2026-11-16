import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_tracker/main.dart';
import 'package:hermes_tracker/models/carrier.dart';
import 'package:hermes_tracker/services/barcode_scanner.dart';
import 'package:hermes_tracker/services/mail_store.dart';
import 'package:material_ui/material_ui.dart';

/// The time the test store uses for "now".
final testNow = DateTime(2026, 11, 16, 9, 30);

/// A scanner that returns [code] without a camera.
class FakeScanner implements BarcodeScanner {
  FakeScanner(this.code);

  final String? code;
  var scans = 0;

  @override
  Future<String?> scan(BuildContext context) async {
    scans++;
    return code;
  }
}

/// Starts the app with the sample data on a phone-sized screen, at [route],
/// and returns its store.
Future<MailStore> pumpApp(
  WidgetTester tester, {
  String route = '/',
  BarcodeScanner? scanner,
}) async {
  tester.view.physicalSize = const Size(600, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  if (route != '/') {
    tester.binding.platformDispatcher.defaultRouteNameTestValue = route;
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
  }

  final store = MailStore.withSampleData(clock: () => testNow);
  await tester.pumpWidget(
    HermesApp(store: store, scanner: scanner ?? FakeScanner(null)),
  );
  await tester.pumpAndSettle();
  return store;
}

/// Opens the drawer and taps the entry called [label].
Future<void> openFromDrawer(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: find.byType(Drawer), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

/// The text field labelled [label].
Finder field(String label) => find.widgetWithText(TextFormField, label);

/// The dialog text that asks the clerk to check a scanned code.
const verifyText =
    'Please verify that the carrier and barcode are correct before proceeding.';

/// The Check-In page's Carrier field.
Finder get carrierField => find.byType(DropdownButtonFormField<Carrier>);

/// The code in the Check-In page's Tracking field.
String trackingText(WidgetTester tester) =>
    tester.widget<TextFormField>(field('Tracking')).controller!.text;

/// The carrier picked in the Check-In page's Carrier field.
Carrier? carrierValue(WidgetTester tester) =>
    tester.state<FormFieldState<Carrier>>(carrierField).value;

/// Taps the Check-In page's Scan button.
Future<void> tapScan(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Scan'));
  await tester.pumpAndSettle();
}
