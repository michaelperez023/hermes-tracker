// Letters menu, team PR #10 (April 2020), ported to Dart 3 in 2026. The
// letters come from the in-memory store instead of Firestore. This list
// started from the search results list on Adam Ghaffarian's Check-Out page in
// the team app.

import 'package:material_ui/material_ui.dart';

import '../models/letter.dart';
import '../services/mail_store.dart';
import 'letter_tile.dart';

/// Every letter on the shelves, or the search results when there is a search.
class LetterDisplay extends StatelessWidget {
  const LetterDisplay({
    super.key,
    required this.search,
    required this.selectedShelves,
    required this.onTap,
  });

  final String search;

  /// Shelf numbers of the selected letters.
  final Set<int> selectedShelves;
  final ValueChanged<Letter> onTap;

  @override
  Widget build(BuildContext context) {
    final store = MailStoreScope.of(context);
    final List<Letter> letters = search.isEmpty
        ? store.letters
        : store.searchLettersByName(search);

    if (letters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          search.isEmpty
              ? 'No letters on the shelves.'
              : 'No Search Results...',
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        return LetterTile(
          letter: letter,
          selected: selectedShelves.contains(letter.shelfNum),
          onTap: () => onTap(letter),
        );
      },
    );
  }
}
