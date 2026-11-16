// Added in 2026: made-up sample data for the demo. The names are placeholder
// names, the email addresses use example.edu, and none of the tracking numbers
// are real.

import '../models/carrier.dart';
import '../models/student.dart';

const sampleStudents = <Student>[
  Student('0000000001', 'Jane Doe', 'jdoe@example.edu'),
  Student('0000000002', 'John Doe', 'johndoe@example.edu'),
  Student('0000000003', 'Richard Roe', 'rroe@example.edu'),
  Student('0000000004', 'Mary Major', 'mmajor@example.edu'),
  Student('0000000005', 'Joe Bloggs', 'jbloggs@example.edu'),
  Student('0000000006', 'Erika Mustermann', 'emustermann@example.edu'),
  Student('0000000007', 'John Q. Public', 'jqpublic@example.edu'),
  Student('0000000008', 'Max Mustermann', 'mmustermann@example.edu'),
];

/// Packages waiting in the queue, newest first.
const samplePackages =
    <
      ({
        String student,
        String location,
        Carrier carrier,
        int daysAgo,
        String tracking,
        String notes,
      })
    >[
      (
        student: 'Jane Doe',
        location: 'Large',
        carrier: Carrier.usps,
        daysAgo: 0,
        tracking: '9400100000000000000001',
        notes: '',
      ),
      (
        student: 'John Doe',
        location: 'Small',
        carrier: Carrier.ups,
        daysAgo: 1,
        tracking: '1Z999AA10123456784',
        notes: 'Fragile',
      ),
      (
        student: 'Richard Roe',
        location: 'Medium',
        carrier: Carrier.fedexGround,
        daysAgo: 2,
        tracking: '123456789012',
        notes: '',
      ),
      (
        student: 'Mary Major',
        location: 'Floor',
        carrier: Carrier.amazon,
        daysAgo: 3,
        tracking: 'TBA000000000001',
        notes: 'Oversized',
      ),
    ];

/// Letters on the shelves: shelf number to student name. Jane Doe has two.
const sampleLetters = <int, String>{
  1: 'Jane Doe',
  2: 'John Doe',
  4: 'Richard Roe',
  5: 'Jane Doe',
  6: 'Mary Major',
  8: 'Joe Bloggs',
  9: 'Erika Mustermann',
  10: 'John Q. Public',
};

/// Barcodes to try in the demo, where the Scan button asks for the code.
const sampleBarcodes = <String>[
  '1Z000AA00000000002',
  '9400100000000000000002',
  'TBA000000000002',
  '1234567890',
];
