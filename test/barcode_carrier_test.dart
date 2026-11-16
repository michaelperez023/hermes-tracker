import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_tracker/models/carrier.dart';
import 'package:hermes_tracker/services/barcode_carrier.dart';

void main() {
  test('long numbers are USPS', () {
    expect(carrierForBarcode('9400100000000000000001'), Carrier.usps);
    // The 2020 code also had a rule for 16 characters (UPS), but it came
    // after the rule for 16 or more and could never run.
    expect(carrierForBarcode('1234567890123456'), Carrier.usps);
  });

  test('12 and 13 characters are FedEx Ground', () {
    expect(carrierForBarcode('123456789012'), Carrier.fedexGround);
    expect(carrierForBarcode('1234567890123'), Carrier.fedexGround);
  });

  test('10 characters are DHL', () {
    expect(carrierForBarcode('1234567890'), Carrier.dhl);
  });

  test('a code that does not start with a digit is USPS', () {
    expect(carrierForBarcode('EA123456789US'), Carrier.usps);
  });

  test('TBA codes are Amazon, in either case', () {
    expect(carrierForBarcode('TBA000000000001'), Carrier.amazon);
    expect(carrierForBarcode('tba000000000001'), Carrier.amazon);
    expect(carrierForBarcode('TBAMCO000000001'), Carrier.amazon);
  });

  test('1Z codes are UPS, in either case', () {
    expect(carrierForBarcode('1Z999AA10123456784'), Carrier.ups);
    expect(carrierForBarcode('1z999aa10123456784'), Carrier.ups);
  });

  test('short codes do not throw', () {
    // The 2020 code took the first five characters of every code, which threw
    // for shorter codes before the code reached the Tracking field.
    expect(carrierForBarcode('1Z'), Carrier.ups);
    expect(carrierForBarcode('AB'), Carrier.usps);
    expect(carrierForBarcode('12345'), isNull);
  });

  test('blank codes and codes that match no rule give no carrier', () {
    expect(carrierForBarcode(''), isNull);
    expect(carrierForBarcode('   '), isNull);
    expect(carrierForBarcode('123456789012345'), isNull);
  });

  test('spaces around the code are ignored', () {
    expect(carrierForBarcode('  1Z999AA10123456784\n'), Carrier.ups);
  });
}
