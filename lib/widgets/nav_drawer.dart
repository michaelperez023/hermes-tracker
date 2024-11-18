import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[
                    Colors.purple[900],
                    Colors.purple[600],
                  ])),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Material(
                          borderRadius:
                          BorderRadius.all(Radius.circular(50.0)),
                          color: Colors.transparent,
                          child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Stack(
                                children: <Widget>[
                                  // Stroked text as border.
                                  Text('Hermes', style: TextStyle(fontSize: 40,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.black,
                                          offset: Offset(5.0, 5.0),
                                        )
                                      ],
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 6
                                        ..color = Colors.black,
                                    ),
                                  ),
                                  // Solid text as fill.
                                  Text('Hermes', style: TextStyle(fontSize: 40, color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                          )
                      ),
                    )
                  ],
                ),
              )),
          CustomListTile(Icons.scanner, 'Check-In', () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/checkin');
          }),
          CustomListTile(Icons.credit_card, 'Check-Out', () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/checkout');
          }),
          CustomListTile(Icons.explore, 'Explore', () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/explorer');
          }),
        ],
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function onTap;

  CustomListTile(this.icon, this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey))),
        child: InkWell(
          onTap: () {
            onTap();
          },
          child: Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(children: <Widget>[
                  Icon(icon),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ]),
                Icon(Icons.arrow_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


