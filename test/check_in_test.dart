import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_tracker/models/carrier.dart';
import 'package:hermes_tracker/services/barcode_scanner.dart';
import 'package:hermes_tracker/services/sample_data.dart';
import 'package:material_ui/material_ui.dart';

import 'test_app.dart';

Future<void> tapTrack(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Track'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the queue of checked-in packages', (tester) async {
    await pumpApp(tester);

    expect(find.text('Check-In'), findsOneWidget);
    for (final sample in samplePackages) {
      expect(find.text(sample.tracking), findsOneWidget);
    }
    expect(find.text('11/16/2026'), findsOneWidget);
    expect(find.text('11/13/2026'), findsOneWidget);
  });

  testWidgets('Scan fills in the tracking number and the carrier, then asks '
      'the clerk to check them', (tester) async {
    final scanner = FakeScanner('1Z000AA00000000002');
    await pumpApp(tester, scanner: scanner);

    await tapScan(tester);
    expect(scanner.scans, 1);
    expect(find.text(verifyText), findsOneWidget);
    expect(trackingText(tester), '1Z000AA00000000002');
    expect(carrierValue(tester), Carrier.ups);

    await tester.tap(find.widgetWithText(TextButton, 'Ok'));
    await tester.pumpAndSettle();
    expect(find.text(verifyText), findsNothing);
    expect(
      find.descendant(of: carrierField, matching: find.text('UPS')),
      findsOneWidget,
    );
  });

  testWidgets('a scanned package can be checked in with Track', (tester) async {
    final store = await pumpApp(
      tester,
      scanner: FakeScanner('TBA000000000002'),
    );

    await tapScan(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Ok'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Name'), 'Max Mustermann');
    await tester.enterText(field('Location'), 'Medium');
    await tapTrack(tester);

    expect(
      find.text('Checked in TBA000000000002 for Max Mustermann'),
      findsOneWidget,
    );
    final package = store.queue.first;
    expect(package.name, 'Max Mustermann');
    expect(package.owner.studentID, '0000000008');
    expect(package.carrier, 'Amazon');
    expect(package.location, 'Medium');
    expect(package.rDate, testNow);
    expect(find.text('TBA000000000002'), findsOneWidget); // in the queue table
    expect(trackingText(tester), isEmpty); // the form is cleared
    expect(carrierValue(tester), isNull);
  });

  testWidgets('a cancelled scan changes nothing', (tester) async {
    final scanner = FakeScanner(null);
    await pumpApp(tester, scanner: scanner);

    await tapScan(tester);

    expect(scanner.scans, 1);
    expect(find.text(verifyText), findsNothing);
    expect(trackingText(tester), isEmpty);
    expect(carrierValue(tester), isNull);
  });

  testWidgets('a code with no carrier rule leaves the carrier to the clerk', (
    tester,
  ) async {
    await pumpApp(tester, scanner: FakeScanner('12345'));

    await tapScan(tester);

    expect(find.text(verifyText), findsOneWidget);
    expect(trackingText(tester), '12345');
    expect(carrierValue(tester), isNull);
  });

  testWidgets('Track looks the scanned code up and refuses a package that is '
      'already checked in', (tester) async {
    final store = await pumpApp(
      tester,
      scanner: FakeScanner('1Z999AA10123456784'),
    );

    await tapScan(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Ok'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Name'), 'John Doe');
    await tapTrack(tester);

    expect(find.text('Already checked in'), findsOneWidget);
    expect(store.queue, hasLength(4));
  });

  testWidgets('Track needs a name, a tracking number and a carrier', (
    tester,
  ) async {
    final store = await pumpApp(tester);

    await tapTrack(tester);

    expect(find.text('Required!'), findsNWidgets(3));
    expect(store.queue, hasLength(4));
  });

  testWidgets('the carrier can be picked by hand', (tester) async {
    final store = await pumpApp(tester);

    await tester.enterText(field('Name'), 'Joe Bloggs');
    await tester.enterText(field('Tracking'), 'X-100');
    await tester.tap(carrierField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('DHL').last);
    await tester.pumpAndSettle();
    await tapTrack(tester);

    expect(store.queue.first.carrier, 'DHL');
    expect(store.queue.first.tracking, 'X-100');
  });

  group('typing the code in (the web demo)', () {
    testWidgets('a typed code goes through the same steps as a scan', (
      tester,
    ) async {
      await pumpApp(tester, scanner: const ManualBarcodeEntry());

      await tapScan(tester);
      expect(find.text('Enter the barcode'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'OK'))
            .onPressed,
        isNull,
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Barcode'),
        ' 9400100000000000000002 ',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'OK'));
      await tester.pumpAndSettle();

      expect(find.text(verifyText), findsOneWidget);
      expect(trackingText(tester), '9400100000000000000002');
      expect(carrierValue(tester), Carrier.usps);
    });

    testWidgets('a sample code can be picked instead of typed', (tester) async {
      await pumpApp(
        tester,
        scanner: const ManualBarcodeEntry(examples: sampleBarcodes),
      );

      await tapScan(tester);
      await tester.tap(find.widgetWithText(ActionChip, '1234567890'));
      await tester.pumpAndSettle();

      expect(find.text(verifyText), findsOneWidget);
      expect(trackingText(tester), '1234567890');
      expect(carrierValue(tester), Carrier.dhl);
    });

    testWidgets('Cancel closes the dialog without a code', (tester) async {
      await pumpApp(tester, scanner: const ManualBarcodeEntry());

      await tapScan(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Enter the barcode'), findsNothing);
      expect(find.text(verifyText), findsNothing);
      expect(trackingText(tester), isEmpty);
    });
  });

  test('the web demo and desktops type the code in', () {
    // Widget tests run as Android, so the default here is the camera.
    expect(BarcodeScanner.forPlatform(), isA<CameraBarcodeScanner>());
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    expect(BarcodeScanner.forPlatform(), isA<ManualBarcodeEntry>());
  });
}
