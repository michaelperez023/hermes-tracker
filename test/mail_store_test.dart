import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_tracker/models/carrier.dart';
import 'package:hermes_tracker/models/letter.dart';
import 'package:hermes_tracker/services/mail_store.dart';

void main() {
  final now = DateTime(2026, 11, 16, 9, 30);
  late MailStore store;
  late int changes;

  setUp(() {
    store = MailStore.withSampleData(clock: () => now);
    changes = 0;
    store.addListener(() => changes++);
  });

  group('sample data', () {
    test('lists the letters in shelf order, without the empty shelves', () {
      expect(store.shelfCount, 20);
      expect(store.letters, const [
        Letter('Jane Doe', 1),
        Letter('John Doe', 2),
        Letter('Richard Roe', 4),
        Letter('Jane Doe', 5),
        Letter('Mary Major', 6),
        Letter('Joe Bloggs', 8),
        Letter('Erika Mustermann', 9),
        Letter('John Q. Public', 10),
      ]);
    });

    test('has a queue of packages, newest first', () {
      expect(store.queue.map((p) => p.name), [
        'Jane Doe',
        'John Doe',
        'Richard Roe',
        'Mary Major',
      ]);
      expect(store.queue.first.rDate, now);
      expect(store.queue.last.rDate, now.subtract(const Duration(days: 3)));
    });
  });

  group('trackLetter', () {
    test('puts the letter on the first empty shelf', () {
      expect(
        store.trackLetter('Max Mustermann'),
        const Letter('Max Mustermann', 3),
      );
      expect(store.trackLetter('Richard Roe'), const Letter('Richard Roe', 7));
      expect(store.trackLetter('Mary Major'), const Letter('Mary Major', 11));
      expect(changes, 3);
    });

    test('keeps the name as typed, without spaces at the ends', () {
      expect(
        store.trackLetter('  Max Mustermann '),
        const Letter('Max Mustermann', 3),
      );
    });

    test('returns null and changes nothing when every shelf is taken', () {
      final small = MailStore(shelfCount: 2);
      expect(small.trackLetter('Jane Doe'), const Letter('Jane Doe', 1));
      expect(small.trackLetter('John Doe'), const Letter('John Doe', 2));
      expect(small.trackLetter('Richard Roe'), isNull);
      expect(small.letters, const [
        Letter('Jane Doe', 1),
        Letter('John Doe', 2),
      ]);
    });

    test('refuses an empty name', () {
      expect(() => store.trackLetter('  '), throwsArgumentError);
      expect(changes, 0);
    });
  });

  group('checkOutLetters', () {
    test('empties the shelves, which Track then reuses', () {
      store.checkOutLetters([2, 5]);
      expect(store.letters.map((l) => l.shelfNum), [1, 4, 6, 8, 9, 10]);
      expect(changes, 1);
      expect(
        store.trackLetter('Max Mustermann'),
        const Letter('Max Mustermann', 2),
      );
    });

    test('ignores empty and unknown shelves', () {
      store.checkOutLetters([3, 0, -1, 21, 99]);
      expect(store.letters, hasLength(8));
      expect(changes, 0);
    });
  });

  group('searchLettersByName', () {
    test('finds each letter once, with the shelf it is on', () {
      // In 2020 a name with letters on two shelves came back four times.
      expect(store.searchLettersByName('Jane Doe'), const [
        Letter('Jane Doe', 1),
        Letter('Jane Doe', 5),
      ]);
    });

    test('ignores case and extra spaces, and matches part of a name', () {
      expect(store.searchLettersByName('  JANE   doe '), hasLength(2));
      expect(store.searchLettersByName('mustermann'), const [
        Letter('Erika Mustermann', 9),
      ]);
      expect(store.searchLettersByName('john').map((l) => l.owner), [
        'John Doe',
        'John Q. Public',
      ]);
    });

    test('finds a letter tracked with capitals', () {
      // In 2020, Track stored names in lowercase while Search compared the
      // text as typed, so "Max Mustermann" was never found.
      store.trackLetter('Max Mustermann');
      expect(store.searchLettersByName('Max Mustermann'), const [
        Letter('Max Mustermann', 3),
      ]);
    });

    test('returns nothing when no name matches', () {
      expect(store.searchLettersByName('Nobody'), isEmpty);
    });
  });

  group('packages', () {
    test('checkInPackage adds the package to the front of the queue', () {
      final package = store.checkInPackage(
        name: 'jane doe',
        carrier: Carrier.ups,
        tracking: ' 1Z000AA00000000002 ',
        location: 'Small',
        notes: 'Fragile',
      );
      expect(store.queue.first, same(package));
      expect(store.queue, hasLength(5));
      expect(package.owner.studentID, '0000000001');
      expect(package.name, 'Jane Doe');
      expect(package.carrier, 'UPS');
      expect(package.tracking, '1Z000AA00000000002');
      expect(package.rDate, now);
      expect(changes, 1);
    });

    test('checkInPackage keeps a name that matches no student', () {
      final package = store.checkInPackage(
        name: 'Ann Example',
        carrier: Carrier.other,
        tracking: 'X1',
      );
      expect(package.name, 'Ann Example');
      expect(package.owner.studentID, isEmpty);
    });

    test('checkInPackage refuses a tracking number that is already in', () {
      expect(
        () => store.checkInPackage(
          name: 'John Doe',
          carrier: Carrier.ups,
          tracking: '1z999aa10123456784',
        ),
        throwsStateError,
      );
      expect(store.queue, hasLength(4));
    });

    test('packageWithTracking finds a package by its code, ignoring case', () {
      expect(store.packageWithTracking('tba000000000001')?.name, 'Mary Major');
      expect(store.packageWithTracking('TBA000000000002'), isNull);
      expect(store.packageWithTracking(''), isNull);
    });

    test('studentNamed ignores case and extra spaces', () {
      expect(store.studentNamed(' john  q. public')?.studentID, '0000000007');
      expect(store.studentNamed('Nobody'), isNull);
    });
  });

  test('Letter.shelfLabel pads the shelf number to three digits', () {
    expect(const Letter('A', 4).shelfLabel, '004');
    expect(const Letter('A', 12).shelfLabel, '012');
    expect(const Letter('A', 120).shelfLabel, '120');
  });
}
