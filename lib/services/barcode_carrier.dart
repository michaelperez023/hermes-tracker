// Scan button, team PR #11 (April 2020), ported to Dart 3 in 2026. In 2020
// these rules sat inside the Check-In page's scan() function.

import '../models/carrier.dart';

/// Guesses the carrier of a package from its barcode, or returns null when no
/// rule matches. The clerk confirms the guess before checking the package in.
///
/// The rules run in this order, and a later rule overrides an earlier one:
/// 1. 16 characters or more: USPS.
/// 2. 12 or 13 characters: FedEx Ground.
/// 3. 10 characters: DHL.
/// 4. Does not start with a digit: USPS.
/// 5. Starts with TBA: Amazon.
/// 6. Starts with 1Z: UPS.
Carrier? carrierForBarcode(String barcode) {
  final code = barcode.trim().toUpperCase();
  if (code.isEmpty) return null;

  Carrier? carrier;
  if (code.length >= 16) {
    carrier = Carrier.usps;
  } else if (code.length == 13 || code.length == 12) {
    carrier = Carrier.fedexGround;
  } else if (code.length == 10) {
    carrier = Carrier.dhl;
  }

  if (!code.startsWith(RegExp('[0-9]'))) {
    carrier = Carrier.usps;
  }
  if (code.startsWith('TBA')) {
    carrier = Carrier.amazon;
  }
  if (code.startsWith('1Z')) {
    carrier = Carrier.ups;
  }
  return carrier;
}
