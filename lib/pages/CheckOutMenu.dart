import 'package:flutter/material.dart';
import 'package:hermes_tracker/widgets/nav_drawer.dart';

class CheckOutMenu extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController proofController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Check-Out"),
      ),
      drawer: NavDrawer(),
      body: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: InputDecoration(labelText: "Search..."),
            controller: searchController,
            onSubmitted: (value) {},
          ),
        ),
        SizedBox(height: 400), // TODO make table bitch
        Row(children: [
          SizedBox(
            width: MediaQuery.of(context).size.width-100,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                decoration: InputDecoration(labelText: "Proof"),
                controller: proofController,
                onSubmitted: (value) {},
              ),
            ),
          ),
          RaisedButton(
            onPressed: () {},
            child: Text("Check Out"),
          ),
        ]),
      ]),
    );
  }
}
