// Placeholder page from the February 2020 prototype, updated to Dart 3 in 2026.

import 'package:material_ui/material_ui.dart';

import '../widgets/nav_drawer.dart';

class PackageExplorerMenu extends StatelessWidget {
  const PackageExplorerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Package Explorer')),
      drawer: const NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Package Explorer'),
            // Added in 2026, so that visitors know why nothing happens here.
            Text(
              'Placeholder page: it is not connected to the demo data.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
