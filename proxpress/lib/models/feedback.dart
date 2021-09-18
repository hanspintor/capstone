import 'package:cloud_firestore/cloud_firestore.dart';

class Feedback{
  final String uid;
  final double rating;
  final String feedback;
  final DocumentReference courierRef;
  final DocumentReference customerRef;


  Feedback({ this.uid, this.rating, this.feedback, this.courierRef, this.customerRef });
}