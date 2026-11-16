// Letters menu, team PR #10 (April 2020), ported to Dart 3 in 2026. The
// selection now lives in the Letter Menu page instead of in each tile. The
// tile started from Adam Ghaffarian's package tile in the team app, and his
// commit in PR #10 first showed the shelf number on it.

import 'package:material_ui/material_ui.dart';

import '../models/letter.dart';

class LetterTile extends StatelessWidget {
  const LetterTile({
    super.key,
    required this.letter,
    required this.selected,
    required this.onTap,
  });

  final Letter letter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20, 6, 20, 0),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          selected: selected,
          leading: _ShelfNumber(letter.shelfLabel),
          title: Text(letter.owner),
          trailing: !selected
              ? const Icon(Icons.check_box_outline_blank)
              : const Icon(Icons.check_box),
        ),
      ),
    );
  }
}

// Added in 2026: the shelf number at the start of each tile.
class _ShelfNumber extends StatelessWidget {
  const _ShelfNumber(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Shelf', style: textTheme.labelSmall),
        Text(
          label,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
