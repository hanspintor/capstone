import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/courier_list.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/database.dart';

class Dashboard extends StatefulWidget {

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Courier>>.value(
      value: DatabaseService().courierList,
      initialData: null,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: Text("PROExpress Admin"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      children: [
                        //Align(alignment: Alignment.center,child: Text('User ID', style: TextStyle(fontWeight: FontWeight.bold),)),
                        Align(alignment: Alignment.center,child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold),)),
                        Align(alignment: Alignment.center,child: Text('Address', style: TextStyle(fontWeight: FontWeight.bold),)),
                        Align(alignment: Alignment.center,child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold),)),
                        Align(alignment: Alignment.center,child: Text('Contact Number', style: TextStyle(fontWeight: FontWeight.bold),)),
                        Align(alignment: Alignment.center,child: Text('Vehicle Type', style: TextStyle(fontWeight: FontWeight.bold),)),
                        Align(alignment: Alignment.center,child: Text('Vehicle Color', style: TextStyle(fontWeight: FontWeight.bold),)),
                      ],
                    ),
                  ],
                ),
              ),
              CourierList(),
            ],
          ),
        ),
      ),
    );
  }
}
