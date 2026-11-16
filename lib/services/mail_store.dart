// Added in 2026: an in-memory stand-in for the team app's Cloud Firestore
// database, so that the app runs anywhere, the web demo included, without a
// server or an account. Nothing is saved: reloading the app brings back the
// sample data.

import 'package:flutter/widgets.dart';

import '../models/carrier.dart';
import '../models/letter.dart';
import '../models/package.dart';
import '../models/student.dart';
import 'sample_data.dart';

class MailStore extends ChangeNotifier {
  /// An empty store with [shelfCount] letter shelves. [clock] gives the time a
  /// package is received (the current time by default).
  MailStore({int shelfCount = 20, DateTime Function()? clock})
    : assert(shelfCount > 0),
      _shelves = List<String?>.filled(shelfCount, null),
      _clock = clock ?? DateTime.now;

  /// A store filled with the made-up students, packages and letters in
  /// sample_data.dart.
  factory MailStore.withSampleData({DateTime Function()? clock}) {
    final store = MailStore(clock: clock);
    store._students.addAll(sampleStudents);
    final now = store._clock();
    for (final sample in samplePackages) {
      store._queue.add(
        Package(
          store.studentNamed(sample.student)!,
          sample.location,
          sample.carrier.label,
          now.subtract(Duration(days: sample.daysAgo)),
          sample.tracking,
          sample.notes,
        ),
      );
    }
    sampleLetters.forEach((shelfNum, owner) {
      store._shelves[shelfNum - 1] = owner;
    });
    return store;
  }

  final List<Student> _students = [];
  final List<Package> _queue = [];

  /// The owner of the letter on each shelf (shelf number = index + 1), or null
  /// for an empty shelf.
  final List<String?> _shelves;
  final DateTime Function() _clock;

  List<Student> get students => List.unmodifiable(_students);

  /// The packages that are checked in and waiting to be picked up, newest
  /// first.
  List<Package> get queue => List.unmodifiable(_queue);

  /// The student with this name, ignoring case and extra spaces, or null.
  Student? studentNamed(String name) {
    final key = _normalize(name);
    for (final student in _students) {
      if (_normalize(student.name) == key) return student;
    }
    return null;
  }

  /// The checked-in package with this tracking number, ignoring case, or null.
  Package? packageWithTracking(String tracking) {
    final key = tracking.trim().toUpperCase();
    if (key.isEmpty) return null;
    for (final package in _queue) {
      if (package.tracking.toUpperCase() == key) return package;
    }
    return null;
  }

  /// Checks a package in for the student called [name] and adds it to the
  /// front of the queue, received now. A name that matches no student is kept
  /// as it was typed.
  Package checkInPackage({
    required String name,
    required Carrier carrier,
    required String tracking,
    String location = '',
    String notes = '',
  }) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    if (tracking.trim().isEmpty) {
      throw ArgumentError.value(tracking, 'tracking', 'must not be empty');
    }
    if (packageWithTracking(tracking) != null) {
      throw StateError('$tracking is already checked in');
    }
    final owner = studentNamed(name) ?? Student('', name.trim(), '');
    final package = Package(
      owner,
      location.trim(),
      carrier.label,
      _clock(),
      tracking.trim(),
      notes.trim(),
    );
    _queue.insert(0, package);
    notifyListeners();
    return package;
  }

  // Letters. These follow the Firestore functions of the Letters menu (team
  // PR #10, April 2020): trackLetter was addLetter, checkOutLetters was
  // removeFromLetters, and searchLettersByName kept its name. The 2020
  // searchLettersByName started from Adam Ghaffarian's package search in the
  // team app. In Firestore each shelf was a document whose owner was 'none'
  // while the shelf was empty.

  int get shelfCount => _shelves.length;

  /// The letters on the shelves, in shelf order. Empty shelves are left out.
  List<Letter> get letters => [
    for (var i = 0; i < _shelves.length; i++)
      if (_shelves[i] case final owner?) Letter(owner, i + 1),
  ];

  /// Puts a letter for [owner] on the first empty shelf and returns it, or
  /// returns null when every shelf is taken.
  Letter? trackLetter(String owner) {
    final name = owner.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(owner, 'owner', 'must not be empty');
    }
    final index = _shelves.indexOf(null);
    if (index == -1) return null;
    _shelves[index] = name;
    notifyListeners();
    return Letter(name, index + 1);
  }

  /// Checks out the letters on these shelves, which empties the shelves.
  void checkOutLetters(Iterable<int> shelfNums) {
    var changed = false;
    for (final shelfNum in shelfNums) {
      final index = shelfNum - 1;
      if (index >= 0 && index < _shelves.length && _shelves[index] != null) {
        _shelves[index] = null;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// The letters for every student whose name contains [search], ignoring
  /// case and extra spaces, each with the number of the shelf it is on.
  List<Letter> searchLettersByName(String search) {
    final query = _normalize(search);
    return [
      for (final letter in letters)
        if (_normalize(letter.owner).contains(query)) letter,
    ];
  }

  static String _normalize(String text) =>
      text.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}

/// Makes a [MailStore] available to the pages below it.
class MailStoreScope extends InheritedNotifier<MailStore> {
  const MailStoreScope({
    super.key,
    required MailStore store,
    required super.child,
  }) : super(notifier: store);

  /// The store. [context] rebuilds whenever the store changes.
  static MailStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MailStoreScope>()!.notifier!;

  /// The store, without rebuilding [context] when it changes. For callbacks.
  static MailStore read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<MailStoreScope>()!.notifier!;
}
