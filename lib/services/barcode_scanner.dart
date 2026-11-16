// Added in 2026. In 2020 the Scan button used the barcode_scan plugin, which is
// no longer maintained. On Android and iOS the camera scanner now uses the
// mobile_scanner plugin. Everywhere else, the web demo included, the Scan
// button asks for the code to be typed in.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart'
    show
        BarcodeCapture,
        MobileScanner,
        MobileScannerController,
        MobileScannerErrorCode,
        MobileScannerException;

import 'sample_data.dart';

/// Reads a barcode for the Check-In page's Scan button.
abstract interface class BarcodeScanner {
  /// The camera on Android and iOS, and typing the code in everywhere else.
  factory BarcodeScanner.forPlatform() {
    final mobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    return mobile
        ? const CameraBarcodeScanner()
        : const ManualBarcodeEntry(examples: sampleBarcodes);
  }

  /// Returns the code that was read, or null if the clerk cancelled.
  Future<String?> scan(BuildContext context);
}

/// Asks the clerk to type the code in.
class ManualBarcodeEntry implements BarcodeScanner {
  const ManualBarcodeEntry({this.examples = const []});

  /// Codes to pick from instead of typing one, for trying the app out.
  final List<String> examples;

  @override
  Future<String?> scan(BuildContext context) => showDialog<String>(
    context: context,
    builder: (context) => _ManualEntryDialog(examples: examples),
  );
}

class _ManualEntryDialog extends StatefulWidget {
  const _ManualEntryDialog({required this.examples});

  final List<String> examples;

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    if (code.isNotEmpty) Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Enter the barcode'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Barcode'),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          if (widget.examples.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Or pick a sample code:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final code in widget.examples)
                  ActionChip(
                    label: Text(code),
                    onPressed: () => Navigator.of(context).pop(code),
                  ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => FilledButton(
            onPressed: value.text.trim().isEmpty ? null : _submit,
            child: const Text('OK'),
          ),
        ),
      ],
    );
  }
}

/// Scans the code with the camera.
class CameraBarcodeScanner implements BarcodeScanner {
  const CameraBarcodeScanner();

  @override
  Future<String?> scan(BuildContext context) =>
      Navigator.of(context).push<String>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => const _CameraScannerPage(),
        ),
      );
}

class _CameraScannerPage extends StatefulWidget {
  const _CameraScannerPage();

  @override
  State<_CameraScannerPage> createState() => _CameraScannerPageState();
}

class _CameraScannerPageState extends State<_CameraScannerPage> {
  final _controller = MobileScannerController();
  var _done = false;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _finish(String code) {
    if (_done) return;
    _done = true;
    Navigator.of(context).pop(code);
  }

  void _onDetect(BarcodeCapture capture) {
    // The camera keeps running while the dialog for typing the code in is
    // open. Ignore it then: _finish would close the dialog instead of this
    // page, and the code would be lost.
    if (!mounted || ModalRoute.isCurrentOf(context) != true) return;
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue?.trim();
      if (code != null && code.isNotEmpty) {
        _finish(code);
        return;
      }
    }
  }

  Future<void> _typeCode() async {
    final code = await const ManualBarcodeEntry().scan(context);
    if (mounted && code != null) _finish(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard),
            tooltip: 'Type the code in',
            onPressed: _typeCode,
          ),
        ],
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
        errorBuilder: (context, error) =>
            _CameraError(error: error, onTypeCode: _typeCode),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error, required this.onTypeCode});

  final MobileScannerException error;
  final VoidCallback onTypeCode;

  @override
  Widget build(BuildContext context) {
    final message = error.errorCode == MobileScannerErrorCode.permissionDenied
        ? 'The camera permission was not granted.'
        : 'The camera could not be started.';
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onTypeCode,
                child: const Text('Type the code in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
