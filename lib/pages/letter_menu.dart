// Letters menu, team PR #10 (April 2020), ported to Dart 3 in 2026. The
// search field is also the name field: Search finds the letters for a name,
// Track puts a letter for that name on the first empty shelf, and Check Out
// takes the selected letters off their shelves. The search bar and results
// list started from Adam Ghaffarian's Check-Out page in the team app.

import 'package:material_ui/material_ui.dart';

import '../models/letter.dart';
import '../services/mail_store.dart';
import '../widgets/display_letter.dart';
import '../widgets/nav_drawer.dart';

class LetterMenu extends StatefulWidget {
  const LetterMenu({super.key});

  @override
  State<LetterMenu> createState() => _LetterMenuState();
}

class _LetterMenuState extends State<LetterMenu> {
  final TextEditingController searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // The current search, and the shelf numbers of the selected letters. In
  // 2020 a SearchNotifier and a shared List<Letter> held them.
  String search = '';
  final Set<int> selectedShelves = {};

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _search() {
    setState(() {
      search = searchController.text.trim();
      selectedShelves.clear();
    });
  }

  void _track() {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    final Letter? letter = MailStoreScope.read(context)
        .trackLetter(searchController.text);
    if (letter == null) {
      _showMessage('Every shelf is full.');
      return;
    }

    searchController.clear();
    setState(() {
      search = '';
      selectedShelves.clear();
    });
    _showMessage(
      'Letter for ${letter.owner} is on shelf ${letter.shelfLabel}.',
    );
  }

  void _checkOut() {
    if (selectedShelves.isEmpty) {
      _showMessage('Select the letters to check out first.');
      return;
    }
    final count = selectedShelves.length;
    MailStoreScope.read(context).checkOutLetters(selectedShelves);
    setState(selectedShelves.clear);
    _showMessage(
      count == 1 ? 'Checked out 1 letter.' : 'Checked out $count letters.',
    );
  }

  void _toggle(Letter letter) {
    setState(() {
      if (!selectedShelves.remove(letter.shelfNum)) {
        selectedShelves.add(letter.shelfNum);
      }
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final redButton = FilledButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 18),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Letter Menu')),
      drawer: const NavDrawer(),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Form(
              key: _formKey,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: searchController,
                      decoration: const InputDecoration(labelText: 'Search'),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Required!'
                          : null,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _search, child: const Text('Search')),
                ],
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilledButton(
                    style: redButton,
                    onPressed: _track,
                    child: const Text('Track'),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilledButton(
                    style: redButton,
                    onPressed: _checkOut,
                    child: const Text('Check Out'),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: LetterDisplay(
              search: search,
              selectedShelves: selectedShelves,
              onTap: _toggle,
            ),
          ),
        ],
      ),
    );
  }
}
