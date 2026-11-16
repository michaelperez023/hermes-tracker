// Letters menu, team PR #10 (April 2020), ported to Dart 3 in 2026.

/// A letter waiting on a shelf in the mail room.
class Letter {
  const Letter(this.owner, this.shelfNum);

  /// Name of the student the letter is for.
  final String owner;

  /// Number of the shelf the letter is on, starting at 1.
  final int shelfNum;

  /// The shelf number padded to three digits, for example 004.
  String get shelfLabel => shelfNum.toString().padLeft(3, '0');

  @override
  bool operator ==(Object other) =>
      other is Letter && other.owner == owner && other.shelfNum == shelfNum;

  @override
  int get hashCode => Object.hash(owner, shelfNum);

  @override
  String toString() => 'Letter($owner, shelf $shelfLabel)';
}
