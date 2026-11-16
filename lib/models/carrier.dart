// Added in 2026: the carriers for the Check-In page's Carrier field, which the
// Scan button fills in. The February 2020 prototype had no Carrier field. The
// names and their order are Adam Ghaffarian's carrier list in the team app,
// which the 2020 Scan rules indexed into.

enum Carrier {
  usps('USPS'),
  ups('UPS'),
  fedexGround('FedEx Ground'),
  fedexExpress('FedEx Express'),
  amazon('Amazon'),
  dhl('DHL'),
  other('Other');

  const Carrier(this.label);

  final String label;
}
