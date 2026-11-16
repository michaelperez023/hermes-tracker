// From the February 2020 prototype, updated to Dart 3 in 2026.

import 'package:material_ui/material_ui.dart';

import 'pages/check_in_menu.dart';
import 'pages/check_out_menu.dart';
import 'pages/letter_menu.dart';
import 'pages/package_explorer_menu.dart';
import 'routes.dart';
import 'services/barcode_scanner.dart';
import 'services/mail_store.dart';

void main() {
  runApp(HermesApp(store: MailStore.withSampleData()));
}

class HermesApp extends StatelessWidget {
  HermesApp({super.key, required this.store, BarcodeScanner? scanner})
    : scanner = scanner ?? BarcodeScanner.forPlatform();

  final MailStore store;

  /// Reads barcodes for the Check-In page's Scan button.
  final BarcodeScanner scanner;

  // Any route the app does not know opens the Check-In page, which used to
  // throw instead. Updated in 2026.
  Route<void> _route(RouteSettings settings) {
    final name = switch (settings.name) {
      Routes.checkOut || Routes.explorer || Routes.letters => settings.name!,
      _ => Routes.checkIn,
    };
    return MaterialPageRoute<void>(
      settings: RouteSettings(name: name, arguments: settings.arguments),
      builder: (context) => switch (name) {
        Routes.checkOut => const CheckOutMenu(),
        Routes.explorer => const PackageExplorerMenu(),
        Routes.letters => const LetterMenu(),
        _ => CheckInMenu(scanner: scanner),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MailStoreScope(
      store: store,
      child: MaterialApp(
        title: 'Hermes Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple.shade900,
            primary: Colors.purple.shade900,
            secondary: Colors.purple.shade800,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.purple.shade900,
            foregroundColor: Colors.white,
          ),
        ),
        // On a wide screen, such as the web demo on a desktop browser, keep
        // the app phone-sized in the middle of the window. Added in 2026.
        builder: (context, child) => ColoredBox(
          color: Colors.grey.shade300,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: child,
            ),
          ),
        ),
        initialRoute: Routes.checkIn,
        onGenerateRoute: _route,
        onGenerateInitialRoutes: (initialRoute) => [
          _route(RouteSettings(name: initialRoute)),
        ],
      ),
    );
  }
}
