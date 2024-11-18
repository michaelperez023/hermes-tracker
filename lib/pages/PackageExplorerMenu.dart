import 'package:flutter/material.dart';
import 'package:hermes_tracker/widgets/nav_drawer.dart';

class PackageExplorerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Package Explorer"),
      ),
      drawer: NavDrawer(),
      body: Column(
        children: <Widget>[
          Text("Package Explorer"),
        ],
      ),
    );
  }
}
