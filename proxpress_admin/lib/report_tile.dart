import 'package:flutter/material.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/customers.dart';
import 'package:proxpress/database.dart';
import 'package:proxpress/reports.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'auth.dart';

class ReportTile extends StatefulWidget {
  final Reports report;
  final int reportNo;

  ReportTile({this.report, this.reportNo });

  @override
  _ReportTileState createState() => _ReportTileState();
}

class _ReportTileState extends State<ReportTile> {



  @override
  Widget build(BuildContext context) {
    String time = DateFormat.yMMMMd('en_US').format(widget.report.time.toDate());
    String time1 = DateFormat.jm().format(widget.report.time.toDate());
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Table(
        border: TableBorder.all(),
        children: [
          TableRow(
            children: [
              Align(child: Text("${widget.reportNo}")),
              StreamBuilder<Customer>(
                stream: DatabaseService(uid: widget.report.reportBy.id).customerData,
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    Customer customerData = snapshot.data;
                    return Align(child: Text("${customerData.fName} ${customerData.lName}"));
                  }
                  return Text("");
                }
              ),
              StreamBuilder<Courier>(
                stream: DatabaseService(uid: widget.report.reportTo.id).courierData,
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    Courier courierData = snapshot.data;
                    return Align(child: Text("${courierData.fName} ${courierData.lName}"));
                  }
                  return Text("");
                }
              ),
              Align(child: Text("${widget.report.reportMessage}")),
              Align(child: Text("${time} ${time1}")),
            ]
          )
        ],
      ),
    );
  }
}
