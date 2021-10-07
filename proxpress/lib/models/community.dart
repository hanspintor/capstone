import 'package:cloud_firestore/cloud_firestore.dart';

class Community{
  final String uid;
  final String title;
  final String content;
  final DocumentReference sentBy;
  final Timestamp timeSent;

  Community({
    this.uid, this.title, this.content, this.sentBy, this.timeSent
  });
}