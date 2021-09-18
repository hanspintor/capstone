import 'package:cloud_firestore/cloud_firestore.dart';

class Delivery{
  final String uid;
  final DocumentReference customerRef;
  final DocumentReference courierRef;
  final String pickupAddress;
  final GeoPoint pickupCoordinates;
  final String dropOffAddress;
  final GeoPoint dropOffCoordinates;
  final String itemDescription;
  final String pickupPointPerson;
  final String pickupContactNum;
  final String dropoffPointPerson;
  final String dropoffContactNum;
  final String whoWillPay;
  final String specificInstructions;
  final String paymentOption;
  final int deliveryFee;
  final String courierApproval;
  final String deliveryStatus;
  final int rating;

  Delivery({
    this.uid,
    this.customerRef,
    this.courierRef,
    this.pickupAddress,
    this.pickupCoordinates,
    this.dropOffAddress,
    this.dropOffCoordinates,
    this.itemDescription,
    this.pickupPointPerson,
    this.pickupContactNum,
    this.dropoffPointPerson,
    this.dropoffContactNum,
    this.whoWillPay,
    this.specificInstructions,
    this.paymentOption,
    this.deliveryFee,
    this.courierApproval,
    this.deliveryStatus,
    this.rating,
  });
}