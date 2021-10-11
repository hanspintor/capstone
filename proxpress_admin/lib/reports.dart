import 'package:cloud_firestore/cloud_firestore.dart';

class Reports{

  final String uid;
  final String reportMessage;
  final DocumentReference reportBy;
  final DocumentReference reportTo;
  final Timestamp time;

  Reports({ this.uid, this.reportMessage, this.time,
    this.reportBy, this.reportTo});
}