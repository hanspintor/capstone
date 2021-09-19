import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  final String uid;
  final String messageContent;
  final Timestamp timeSent;
  final DocumentReference sentBy;
  final DocumentReference sentTo;

  Message({ this.uid, this.messageContent, this.timeSent, this.sentBy, this.sentTo });
}