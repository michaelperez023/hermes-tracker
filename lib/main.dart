import 'package:flutter/material.dart';
import 'package:hermes_tracker/pages/CheckInMenu.dart';
import 'package:hermes_tracker/pages/CheckOutMenu.dart';
import 'package:hermes_tracker/pages/PackageExplorerMenu.dart';

void main() {
  runApp(MaterialApp(
    title: 'Hermes Tracker',
    theme: ThemeData(
      primaryColor: Colors.purple[900],
      accentColor: Colors.purple[800],
    ),
    initialRoute: '/checkin',
    routes: {
      '/checkin': (context) => CheckInMenu(),
      '/checkout': (context) => CheckOutMenu(),
      '/explorer': (context) => PackageExplorerMenu(),
    },
  ));
}
