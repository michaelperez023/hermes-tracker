import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_tracker/models/letter.dart';
import 'package:hermes_tracker/routes.dart';
import 'package:hermes_tracker/widgets/letter_tile.dart';
import 'package:material_ui/material_ui.dart';

import 'test_app.dart';

/// The tile of the letter on shelf [shelfLabel].
Finder tileOnShelf(String shelfLabel) =>
    find.ancestor(of: find.text(shelfLabel), matching: find.byType(LetterTile));

/// The names on the tiles, top to bottom, with their shelf numbers.
List<String> shownLetters(WidgetTester tester) => [
  for (final tile in tester.widgetList<LetterTile>(find.byType(LetterTile)))
    '${tile.letter.shelfLabel} ${tile.letter.owner}',
];

Future<void> search(WidgetTester tester, String text) async {
  await tester.enterText(field('Search'), text);
  await tester.tap(find.widgetWithText(FilledButton, 'Search'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists the letters with their shelf numbers', (tester) async {
    await pumpApp(tester, route: Routes.letters);

    expect(find.text('Letter Menu'), findsOneWidget);
    expect(shownLetters(tester), [
      '001 Jane Doe',
      '002 John Doe',
      '004 Richard Roe',
      '005 Jane Doe',
      '006 Mary Major',
      '008 Joe Bloggs',
      '009 Erika Mustermann',
      '010 John Q. Public',
    ]);
    expect(
      find.descendant(
        of: tileOnShelf('004'),
        matching: find.text('Richard Roe'),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_box), findsNothing);
  });

  testWidgets('Search shows the letters for a name, with the right shelves', (
    tester,
  ) async {
    await pumpApp(tester, route: Routes.letters);

    await search(tester, 'jane doe');
    expect(shownLetters(tester), ['001 Jane Doe', '005 Jane Doe']);

    await search(tester, 'Nobody');
    expect(find.byType(LetterTile), findsNothing);
    expect(find.text('No Search Results...'), findsOneWidget);

    // An empty search shows every letter again.
    await search(tester, '');
    expect(find.byType(LetterTile), findsNWidgets(8));
  });

  testWidgets('Track needs a name', (tester) async {
    final store = await pumpApp(tester, route: Routes.letters);

    await tester.tap(find.widgetWithText(FilledButton, 'Track'));
    await tester.pumpAndSettle();

    expect(find.text('Required!'), findsOneWidget);
    expect(store.letters, hasLength(8));
  });

  testWidgets('Track puts a letter on the first empty shelf', (tester) async {
    final store = await pumpApp(tester, route: Routes.letters);

    await tester.enterText(field('Search'), 'Max Mustermann');
    await tester.tap(find.widgetWithText(FilledButton, 'Track'));
    await tester.pumpAndSettle();

    expect(
      find.text('Letter for Max Mustermann is on shelf 003.'),
      findsOneWidget,
    );
    expect(store.letters, contains(const Letter('Max Mustermann', 3)));
    expect(shownLetters(tester), contains('003 Max Mustermann'));
    expect(
      tester.widget<TextFormField>(field('Search')).controller!.text,
      isEmpty,
    );

    // The new letter can be found by name right away.
    await search(tester, 'max mustermann');
    expect(shownLetters(tester), ['003 Max Mustermann']);
  });

  testWidgets('Track says so when every shelf is taken', (tester) async {
    final store = await pumpApp(tester, route: Routes.letters);
    for (var i = 0; i < 12; i++) {
      store.trackLetter('Student $i');
    }
    await tester.pumpAndSettle();

    await tester.enterText(field('Search'), 'Max Mustermann');
    await tester.tap(find.widgetWithText(FilledButton, 'Track'));
    await tester.pumpAndSettle();

    expect(find.text('Every shelf is full.'), findsOneWidget);
    expect(store.letters, hasLength(20));
    // The name stays in the field.
    expect(
      tester.widget<TextFormField>(field('Search')).controller!.text,
      'Max Mustermann',
    );
  });

  testWidgets('Check Out takes the selected letters off their shelves', (
    tester,
  ) async {
    final store = await pumpApp(tester, route: Routes.letters);

    await tester.tap(tileOnShelf('002'));
    await tester.tap(tileOnShelf('004'));
    await tester.pump();
    expect(find.byIcon(Icons.check_box), findsNWidgets(2));

    await tester.tap(find.widgetWithText(FilledButton, 'Check Out'));
    await tester.pumpAndSettle();

    expect(find.text('Checked out 2 letters.'), findsOneWidget);
    expect(store.letters.map((l) => l.shelfNum), [1, 5, 6, 8, 9, 10]);
    expect(shownLetters(tester), isNot(contains('002 John Doe')));
    expect(shownLetters(tester), isNot(contains('004 Richard Roe')));
    // Nothing stays checked after a check-out.
    expect(find.byIcon(Icons.check_box), findsNothing);
  });

  testWidgets('tapping a selected letter again deselects it', (tester) async {
    final store = await pumpApp(tester, route: Routes.letters);

    await tester.tap(tileOnShelf('006'));
    await tester.pump();
    await tester.tap(tileOnShelf('006'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Check Out'));
    await tester.pumpAndSettle();

    expect(find.text('Select the letters to check out first.'), findsOneWidget);
    expect(store.letters, hasLength(8));
  });

  testWidgets('Check Out works on search results', (tester) async {
    final store = await pumpApp(tester, route: Routes.letters);

    await search(tester, 'Jane Doe');
    await tester.tap(tileOnShelf('005'));
    await tester.tap(find.widgetWithText(FilledButton, 'Check Out'));
    await tester.pumpAndSettle();

    expect(find.text('Checked out 1 letter.'), findsOneWidget);
    expect(shownLetters(tester), ['001 Jane Doe']);
    expect(store.searchLettersByName('Jane Doe'), const [
      Letter('Jane Doe', 1),
    ]);
  });

  testWidgets('a new search clears the selection', (tester) async {
    final store = await pumpApp(tester, route: Routes.letters);

    await tester.tap(tileOnShelf('008'));
    await search(tester, 'Jane');
    await tester.tap(find.widgetWithText(FilledButton, 'Check Out'));
    await tester.pumpAndSettle();

    // Joe Bloggs, selected before the search and no longer shown, stays.
    expect(find.text('Select the letters to check out first.'), findsOneWidget);
    expect(store.letters, contains(const Letter('Joe Bloggs', 8)));
  });
}
