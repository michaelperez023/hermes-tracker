// The camera page that the Scan button opens on Android and iOS, with a
// stand-in for the camera.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_tracker/models/carrier.dart';
import 'package:hermes_tracker/services/barcode_scanner.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'test_app.dart';

/// Takes the place of the camera in mobile_scanner. The tests decide which
/// codes it reads.
class FakeCamera extends MobileScannerPlatform {
  FakeCamera({this.startError});

  /// Thrown when the camera starts, to act like a camera that cannot start.
  final MobileScannerException? startError;

  final _barcodes = StreamController<BarcodeCapture?>.broadcast();

  /// Makes the camera read [code].
  void read(String code) =>
      _barcodes.add(BarcodeCapture(barcodes: [Barcode(rawValue: code)]));

  @override
  Stream<BarcodeCapture?> get barcodesStream => _barcodes.stream;

  @override
  Stream<TorchState> get torchStateStream => const Stream.empty();

  @override
  Stream<double> get zoomScaleStateStream => const Stream.empty();

  @override
  Future<MobileScannerViewAttributes> start(StartOptions startOptions) async {
    if (startError case final error?) throw error;
    return const MobileScannerViewAttributes(
      cameraDirection: CameraFacing.back,
      currentTorchMode: TorchState.unavailable,
      size: Size(480, 640),
      numberOfCameras: 1,
    );
  }

  @override
  Widget buildCameraView() => const ColoredBox(color: Colors.black);

  @override
  Future<void> updateScanWindow(Rect? window) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

/// Opens the Check-In page and taps Scan, which opens the camera page.
Future<void> openCamera(WidgetTester tester) async {
  await pumpApp(tester, scanner: const CameraBarcodeScanner());
  await tapScan(tester);
  expect(find.byType(MobileScanner), findsOneWidget);
}

/// Opens the dialog for typing the code in, from the camera page.
Future<void> openTypeCode(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Type the code in'));
  await tester.pumpAndSettle();
  expect(find.text('Enter the barcode'), findsOneWidget);
}

/// Types [code] into the dialog and taps OK.
Future<void> typeCode(WidgetTester tester, String code) async {
  await tester.enterText(find.widgetWithText(TextField, 'Barcode'), code);
  await tester.pump();
  await tester.tap(find.widgetWithText(FilledButton, 'OK'));
  await tester.pumpAndSettle();
}

void main() {
  late MobileScannerPlatform realCamera;
  late FakeCamera camera;

  setUp(() {
    realCamera = MobileScannerPlatform.instance;
    MobileScannerPlatform.instance = camera = FakeCamera();
  });

  tearDown(() {
    MobileScannerPlatform.instance = realCamera;
    MobileScannerController.resetPlatformSessionOwner();
  });

  testWidgets('a code read by the camera fills in the Tracking and Carrier '
      'fields', (tester) async {
    await openCamera(tester);

    camera.read('1Z000AA00000000002');
    await tester.pumpAndSettle();

    expect(find.byType(MobileScanner), findsNothing);
    expect(find.text(verifyText), findsOneWidget);
    expect(trackingText(tester), '1Z000AA00000000002');
    expect(carrierValue(tester), Carrier.ups);
  });

  testWidgets('the camera is ignored while the code is being typed in', (
    tester,
  ) async {
    await openCamera(tester);
    await openTypeCode(tester);

    camera.read('1Z000AA00000000002');
    await tester.pumpAndSettle();

    // The dialog and the camera page both stay open.
    expect(find.text('Enter the barcode'), findsOneWidget);
    expect(find.byType(MobileScanner), findsOneWidget);
    expect(find.text(verifyText), findsNothing);

    await typeCode(tester, 'TBA000000000002');

    expect(find.byType(MobileScanner), findsNothing);
    expect(find.text(verifyText), findsOneWidget);
    expect(trackingText(tester), 'TBA000000000002');
    expect(carrierValue(tester), Carrier.amazon);
  });

  testWidgets('the camera reads codes again after the dialog is cancelled', (
    tester,
  ) async {
    await openCamera(tester);
    await openTypeCode(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(MobileScanner), findsOneWidget);

    camera.read('9400100000000000000002');
    await tester.pumpAndSettle();

    expect(find.byType(MobileScanner), findsNothing);
    expect(trackingText(tester), '9400100000000000000002');
    expect(carrierValue(tester), Carrier.usps);
  });

  testWidgets('closing the camera page changes nothing', (tester) async {
    await openCamera(tester);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(MobileScanner), findsNothing);
    expect(find.text(verifyText), findsNothing);
    expect(trackingText(tester), isEmpty);
    expect(carrierValue(tester), isNull);
  });

  testWidgets('when the camera cannot start, the code can be typed in', (
    tester,
  ) async {
    MobileScannerPlatform.instance = camera = FakeCamera(
      startError: const MobileScannerException(
        errorCode: MobileScannerErrorCode.permissionDenied,
      ),
    );
    await openCamera(tester);
    expect(find.text('The camera permission was not granted.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Type the code in'));
    await tester.pumpAndSettle();
    await typeCode(tester, '1234567890');

    expect(find.byType(MobileScanner), findsNothing);
    expect(find.text(verifyText), findsOneWidget);
    expect(trackingText(tester), '1234567890');
    expect(carrierValue(tester), Carrier.dhl);
  });
}
