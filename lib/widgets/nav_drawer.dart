// Navigation drawer from the February 2020 prototype, updated to Dart 3 in
// 2026.

import 'package:material_ui/material_ui.dart';

import '../routes.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Closes the drawer, then replaces the current page, so that pages do not
    // pile up (they used to be pushed on top of each other). Updated in 2026.
    void open(String route) {
      Navigator.of(context).pop();
      if (route != currentRoute) {
        Navigator.of(context).pushReplacementNamed(route);
      }
    }

    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Colors.purple.shade900, Colors.purple.shade600],
              ),
            ),
            // The title ignores the text size setting and shrinks instead of
            // wrapping, so that it always fits in the header. Updated in 2026.
            child: MediaQuery.withNoTextScaling(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Material(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(50.0),
                      ),
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        // From the "Borders and stroke" sample in Flutter's TextStyle docs: https://api.flutter.dev/flutter/painting/TextStyle-class.html
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Stack(
                            children: <Widget>[
                              // Stroked text as border.
                              Text(
                                'Hermes',
                                style: TextStyle(
                                  fontSize: 40,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Colors.black,
                                      offset: Offset(5.0, 5.0),
                                    ),
                                  ],
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 6
                                    ..color = Colors.black,
                                ),
                              ),
                              // Solid text as fill.
                              const Text(
                                'Hermes',
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomListTile(Icons.scanner, 'Check-In', () => open(Routes.checkIn)),
          CustomListTile(
            Icons.credit_card,
            'Check-Out',
            () => open(Routes.checkOut),
          ),
          CustomListTile(Icons.explore, 'Explore', () => open(Routes.explorer)),
          // Added in 2026: the Letters menu from team PR #10.
          CustomListTile(Icons.mail, 'Letters', () => open(Routes.letters)),
        ],
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile(this.icon, this.text, this.onTap, {super.key});

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(icon),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(text, style: const TextStyle(fontSize: 16.0)),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
