
import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications{

  final String uid;
  final String notifMessage;
  final DocumentReference sentBy;
  final DocumentReference sentTo;
  final Timestamp time;
  final bool seen;
  final bool popsOnce;

  Notifications({ this.uid, this.notifMessage, this.time,
    this.sentBy, this.sentTo, this.seen, this.popsOnce });
}