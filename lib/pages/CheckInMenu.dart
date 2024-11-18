import 'package:flutter/material.dart';
import 'package:hermes_tracker/datatypes/Package.dart';
import 'package:hermes_tracker/datatypes/Student.dart';
import 'package:hermes_tracker/widgets/nav_drawer.dart';

class CheckInMenu extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController trackingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Check-In"),
      ),
      drawer: NavDrawer(),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: " Name"),
                controller: nameController,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: " Location",
                ),
                controller: locationController,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: " Notes",
                ),
                controller: notesController,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: " Tracking",
                ),
                controller: trackingController,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    child: Text('Track', style: TextStyle(color: Colors.white, fontSize: 20)),
                    color: Colors.purple[900],
                    onPressed: () {},
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    child: Text('Scan', style: TextStyle(color: Colors.white, fontSize: 20)),
                    color: Colors.red,
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: QueueTable(),
          ),
        ],
      ),
    );
  }
}

class QueueTable extends StatefulWidget {
  @override
  _QueueTableState createState() => _QueueTableState();
}

class _QueueTableState extends State<QueueTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        //color: Colors.grey[200],
        child: DataTable(
          // Table Displaying Queued Packages
            columnSpacing: 8,
            columns: [
              DataColumn(label: Text("Name"),numeric: false, onSort: (i, b) {}),
              DataColumn(label: Text("Location"),numeric: false, onSort: (i, b) {}),
              DataColumn(label: Text("Tracking"),numeric: false, onSort: (i, b) {}),
              DataColumn(label: Text("Carrier"),numeric: false, onSort: (i, b) {}),
              DataColumn(label: Text("Notes"),numeric: false, onSort: (i, b) {}),
              DataColumn(label: Text("Received"),numeric: false, onSort: (i, b) {}),
            ],
            rows: packages.map((package) => DataRow(
                onSelectChanged: (b) {},
                cells: [
                  DataCell(Text(package.owner.name), onTap: (){}),
                  DataCell(Text(package.location), onTap: (){}),
                  DataCell(Text(package.tracking)),
                  DataCell(Text(package.carrier)),
                  DataCell(Text(package.notes), onTap: (){}),
                  DataCell(Text(package.rDate)),
            ])).toList()
        ),
      ),
    );
  }
}

Student adam =
    Student('0000004028', 'Adam Ghaffarian', 'aghaffarian4028@floridapoly.edy');
var packages = [
  Package(adam, 'Large', 'USPS', '1/15/2020', '123456', 'Great Dude!'),
  Package(adam, 'Small', 'UPS', '1/16/2020', '1234567', 'Great Guy!'),
  Package(adam, 'Medium', 'FedEx', '1/18/2020', '12345678', 'Great Bro!'),
  Package(adam, 'Floor', 'Amazon', '1/5/2020', '123456789', 'Great Person!'),
];
