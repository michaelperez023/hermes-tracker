# Hermes Tracker

A Flutter app for a university mail center: the staff check packages and letters in, find them when a student comes to the window, and check them out. This repository has an early prototype of our team's app and the two features I wrote for the final version, the Letters menu and the Scan button, updated in 2026 so that they run on current Flutter and in a browser.

This was a Spring 2020 student team project at Florida Polytechnic University, for the campus mail center. It is not an official Florida Polytechnic University app.

Team: [Adam Ghaffarian](https://github.com/b34st80y), [Michael Perez](https://github.com/michaelperez023) and Jared Fuller.

## What is in this repository

- **Adam's early prototype (February 2020).** Adam Ghaffarian wrote the first version of the app: the Check-In page with its form and queue table, a placeholder Package Explorer page, the navigation drawer with the outlined "Hermes" title, the purple theme, and the `Package` and `Student` models. At that stage it had no database and the buttons were not wired up yet. The repository also has a draft Check-Out page.
- **My Letters menu and Scan button (April 2020), ported.** I wrote these for the final team app, in pull requests #10 and #11 of the team repository, and they are ported here to Dart 3 and current Flutter widgets, with bug fixes. Parts of the Letters menu started from Adam's code; see [Credits](#credits).
- **2026 updates.** An in-memory data store with made-up students, packages and letters takes the place of the team app's Firebase database. The app builds with Flutter 3.50 and Dart 3.14, runs as a [web demo](#live-demo), and has tests.

## My role

In April 2020 I wrote two features of the team app:

- **The Letters menu** (pull request #10, April 9 to 20, 2020): the `Letter` model and the Letter Menu page, with the database functions behind its buttons. I started the page from a copy of Adam's Check-Out search page, and his commit in the same pull request first put a shelf number on each tile; I moved the number into the `Letter` model and made search results show the right shelf (see [Credits](#credits)). One text field is used both to search and to track. Search lists a student's letters with the numbers of the shelves they are on, Track puts a new letter for that student on the first empty shelf, and Check Out takes the selected letters off their shelves.
- **The code behind the Scan button** on the Check-In page (pull request #11, April 13 to 21, 2020): it reads a package's barcode with the camera, puts the code in the Tracking field, guesses the carrier from the code's length and first characters, and asks the clerk to check both before going on.

| Feature | Files |
| --- | --- |
| Letters menu | [`letter_menu.dart`](lib/pages/letter_menu.dart), [`display_letter.dart`](lib/widgets/display_letter.dart), [`letter_tile.dart`](lib/widgets/letter_tile.dart), [`letter.dart`](lib/models/letter.dart), and the letter functions in [`mail_store.dart`](lib/services/mail_store.dart) |
| Scan button | `scan()` in [`check_in_menu.dart`](lib/pages/check_in_menu.dart), and the carrier rules in [`barcode_carrier.dart`](lib/services/barcode_carrier.dart) |

The full team app, with its Firebase backend, Adam's later work and Jared's Package Explorer, is in a private team repository and is not included here. Code that my features called but that I did not write, such as the team's database service and the route and drawer entry for the Letters menu, is replaced by new, minimal code from 2026, which the source files mark as such. Where my own code started from Adam's, as listed under [Credits](#credits), the source files say so.

## Live demo

**[michaelperez023.github.io/hermes-tracker](https://michaelperez023.github.io/hermes-tracker/)**

The demo runs in the browser with made-up data. Nothing is saved: reloading the page starts over. In the browser the Scan button asks for the code instead of using the camera, and offers a few sample codes to pick from.

## Screenshots

<p>
  <img src="docs/screenshot-letters.png" width="260" alt="The Letter Menu: letters for made-up students, each with its shelf number, one of them selected for check-out, and a message that a new letter is on shelf 003">
  <img src="docs/screenshot-scan-entry.png" width="260" alt="The Scan button in the web demo: a dialog asks for the barcode and offers four sample codes">
  <img src="docs/screenshot-scan.png" width="260" alt="The Check-In page after a UPS code was entered: the Tracking and Carrier fields are filled in, and a dialog asks to verify them">
</p>

From left to right: the Letter Menu after tracking a letter, which went to shelf 003, the first empty one; the Scan button in the web demo, which asks for the code; and the Check-In page after a UPS code was entered, with the carrier filled in and the request to verify it. They are screenshots of the web demo, and all names and tracking numbers are made up.

## Running it

You need [Flutter](https://docs.flutter.dev/get-started/install) 3.50 or later, which comes with Dart 3.14.

```sh
flutter pub get
flutter run -d chrome
```

The 2026 update was tested in the browser. The `android/` and `ios/` folders were recreated with `flutter create`. On a phone, the Scan button opens the camera with the [mobile_scanner](https://pub.dev/packages/mobile_scanner) plugin. The camera page is tested with a stand-in for the camera, but the updated app has not been tried on a phone yet.

To build the web demo the way CI does:

```sh
flutter build web --release --base-href /hermes-tracker/
```

## Tests

```sh
flutter test
```

- [`letter_menu_test.dart`](test/letter_menu_test.dart) tests the Letter Menu: the list with its shelf numbers, Search, Track to the first empty shelf, and Check Out, also from search results, with the selection cleared afterwards.
- [`check_in_test.dart`](test/check_in_test.dart) tests the Scan button with a fake scanner and with typed codes: the Tracking and Carrier fields, the verify dialog, Track adding the package to the queue, and refusing a code that is already checked in.
- [`camera_scanner_test.dart`](test/camera_scanner_test.dart) tests the camera page that the Scan button opens on phones, with a stand-in for the camera: a code read by the camera, typing the code in instead (the camera is ignored while the dialog is open), closing the page, and a camera that cannot start.
- [`navigation_test.dart`](test/navigation_test.dart) tests the drawer (pages are not stacked), links to a page and unknown routes.
- [`mail_store_test.dart`](test/mail_store_test.dart) and [`barcode_carrier_test.dart`](test/barcode_carrier_test.dart) are unit tests for the data store and the carrier rules.

[`ci.yml`](.github/workflows/ci.yml) runs on GitHub Actions with Flutter 3.50.0. On every push it checks the formatting and runs `flutter analyze` and `flutter test`. On `main` it then builds the web demo and publishes it to GitHub Pages.

## Credits

- Adam Ghaffarian wrote the February 2020 prototype (see [What is in this repository](#what-is-in-this-repository)), and the team app's database service and navigation that my features first ran on. Parts of my features started from his code in the team app:
  - My Letter Menu page began as a copy of his Check-Out search page and its results list (March 2020), and its search bar and results list still follow them.
  - My letter tiles started from his package tiles, and his commit in pull request #10 first showed the shelf number on each tile.
  - My letter search in the team database started from his package search.
  - My Scan rules pick from his list of carriers, which the Check-In page's Carrier field shows.
- Jared Fuller wrote the team app's Package Explorer, which is not included here.
- The outlined "Hermes" title in the drawer follows the "Borders and stroke" sample in [Flutter's `TextStyle` documentation](https://api.flutter.dev/flutter/painting/TextStyle-class.html).
- Barcode scanning on Android and iOS uses [mobile_scanner](https://pub.dev/packages/mobile_scanner). In 2020 the Scan button used barcode_scan.
