// Check-In page from the February 2020 prototype, updated to Dart 3 in 2026.
// The code behind the Scan button is from team PR #11 (April 2020).

import 'package:material_ui/material_ui.dart';

import '../models/carrier.dart';
import '../models/package.dart';
import '../services/barcode_carrier.dart';
import '../services/barcode_scanner.dart';
import '../services/mail_store.dart';
import '../widgets/nav_drawer.dart';

class CheckInMenu extends StatefulWidget {
  const CheckInMenu({super.key, required this.scanner});

  /// Reads barcodes for the Scan button.
  final BarcodeScanner scanner;

  @override
  State<CheckInMenu> createState() => _CheckInMenuState();
}

class _CheckInMenuState extends State<CheckInMenu> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController trackingController = TextEditingController();

  // Added in 2026: the form, its Carrier field and the Track button's
  // check-in, which the Scan button feeds.
  final _formKey = GlobalKey<FormState>();
  final _carrierKey = GlobalKey<FormFieldState<Carrier>>();

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    notesController.dispose();
    trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = MailStoreScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Check-In')),
      drawer: const NavDrawer(),
      body: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    controller: nameController,
                    validator: _required,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Location'),
                    controller: locationController,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Notes'),
                    controller: notesController,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Tracking'),
                    controller: trackingController,
                    validator: (value) =>
                        _required(value) ??
                        (store.packageWithTracking(value!) != null
                            ? 'Already checked in'
                            : null),
                  ),
                  DropdownButtonFormField<Carrier>(
                    key: _carrierKey,
                    decoration: const InputDecoration(labelText: 'Carrier'),
                    items: [
                      for (final carrier in Carrier.values)
                        DropdownMenuItem(
                          value: carrier,
                          child: Text(carrier.label),
                        ),
                    ],
                    onChanged: (_) {},
                    validator: (value) => value == null ? 'Required!' : null,
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.purple.shade900,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _track,
                    child: const Text('Track', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: scan,
                    child: const Text('Scan', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: QueueTable(packages: store.queue),
          ),
        ],
      ),
    );
  }

  static String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required!' : null;

  // Added in 2026: checks the package in to the demo store.
  void _track() {
    if (!_formKey.currentState!.validate()) return;
    final package = MailStoreScope.read(context).checkInPackage(
      name: nameController.text,
      carrier: _carrierKey.currentState!.value!,
      tracking: trackingController.text,
      location: locationController.text,
      notes: notesController.text,
    );
    _formKey.currentState!.reset();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Checked in ${package.tracking} for ${package.name}'),
        ),
      );
  }

  // Scan button, team PR #11 (April 2020), ported to Dart 3 in 2026: it reads
  // a barcode, puts it in the Tracking field, picks the carrier from it and
  // asks the clerk to check both.
  Future<void> scan() async {
    final barcode = (await widget.scanner.scan(context))?.trim();
    if (!mounted) return;
    if (barcode == null || barcode.isEmpty) return;

    trackingController.text = barcode;
    _carrierKey.currentState!.didChange(carrierForBarcode(barcode));

    await _ackAlert(context);
  }

  Future<void> _ackAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            'Please verify that the carrier and barcode are correct before proceeding.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class QueueTable extends StatelessWidget {
  const QueueTable({super.key, required this.packages});

  final List<Package> packages;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        // Table Displaying Queued Packages
        columnSpacing: 8,
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Location')),
          DataColumn(label: Text('Tracking')),
          DataColumn(label: Text('Carrier')),
          DataColumn(label: Text('Notes')),
          DataColumn(label: Text('Received')),
        ],
        rows: [
          for (final package in packages)
            DataRow(
              cells: [
                DataCell(Text(package.name)),
                DataCell(Text(package.location)),
                DataCell(Text(package.tracking)),
                DataCell(Text(package.carrier)),
                DataCell(Text(package.notes)),
                DataCell(Text(_date(package.rDate))),
              ],
            ),
        ],
      ),
    );
  }

  static String _date(DateTime date) =>
      '${date.month}/${date.day}/${date.year}';
}
