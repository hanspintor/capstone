import 'package:cloud_firestore/cloud_firestore.dart';

class Comment{
  final String uid;
  final String comment;
  final DocumentReference commentBy;
  final Timestamp timeSent;

  Comment({
    this.uid,
    this.comment,
    this.commentBy,
    this.timeSent
  });
}