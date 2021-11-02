import 'package:cloud_firestore/cloud_firestore.dart';

class Reports{

  final String uid;
  final String reportMessage;
  final DocumentReference reportBy;
  final DocumentReference reportTo;
  final String ReportTitle;
  final String ReportUrl;
  final Timestamp time;

  Reports({ this.uid, this.reportMessage, this.time,
    this.reportBy, this.reportTo, this.ReportTitle, this.ReportUrl});
}