// From the February 2020 prototype, updated to Dart 3 in 2026.

import 'student.dart';

class Package {
  Package(
    this.owner,
    this.location,
    this.carrier,
    this.rDate,
    this.tracking,
    this.notes,
  );

  final Student owner;
  final String location;
  final String carrier;

  /// When the package was received.
  final DateTime rDate;
  final String tracking;
  final String notes;

  /// When the package was delivered, and the proof of delivery.
  DateTime? dDate;
  String? dProof;

  String get name => owner.name;
}
