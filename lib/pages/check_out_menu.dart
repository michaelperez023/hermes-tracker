// Draft Check-Out page, updated to Dart 3 in 2026.

import 'package:material_ui/material_ui.dart';

import '../widgets/nav_drawer.dart';

class CheckOutMenu extends StatefulWidget {
  const CheckOutMenu({super.key});

  @override
  State<CheckOutMenu> createState() => _CheckOutMenuState();
}

class _CheckOutMenuState extends State<CheckOutMenu> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController proofController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    proofController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-Out')),
      drawer: const NavDrawer(),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Search...'),
              controller: searchController,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Proof'),
                    controller: proofController,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: FilledButton(onPressed: null, child: Text('Check Out')),
              ),
            ],
          ),
          // Added in 2026, so that visitors know why nothing happens here.
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Draft page: it is not connected to the demo data.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
