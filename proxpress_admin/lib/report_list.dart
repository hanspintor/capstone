import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/report_tile.dart';
import 'package:proxpress/reports.dart';

class ReportList extends StatefulWidget {

  @override
  _ReportListState createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {


  @override
  Widget build(BuildContext context) {
    final reports = Provider.of<List<Reports>>(context);
    if (reports != null && reports.length > 0) {
      return SizedBox(
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ReportTile(report: reports[index], reportNo: ++index,);
          },
          itemCount: reports.length,
        ),
      );
    } else return Container();
  }
}

