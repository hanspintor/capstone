import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxpress/models/comments.dart';
import 'package:proxpress/models/community.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/delivery_prices.dart';
import 'package:proxpress/models/messages.dart';
import 'package:proxpress/models/notifications.dart';
import 'package:proxpress/models/reports.dart';

class DatabaseService {
  final String uid;
  final String sub_uid;

  DatabaseService({this.uid, this.sub_uid});

  // Customers Collection Reference
  final CollectionReference customerCollection = FirebaseFirestore.instance
      .collection('Customers');

  // Couriers Collection Reference
  final CollectionReference courierCollection = FirebaseFirestore.instance
      .collection('Couriers');

  // Deliveries Collection Reference
  final CollectionReference deliveryCollection = FirebaseFirestore.instance
      .collection('Deliveries');

  // Delivery Prices Collection Reference
  final CollectionReference deliveryPriceCollection = FirebaseFirestore.instance
      .collection('Delivery Prices');

  // Messages Collection Reference
  final CollectionReference messageCollection = FirebaseFirestore.instance
      .collection('Messages');

  // Notifications Collection Reference
  final CollectionReference notifCollection = FirebaseFirestore.instance
      .collection('Notifications');

  // Report Collection Reference
  final CollectionReference reportCollection = FirebaseFirestore.instance
      .collection('Reports');

  // Community Collection Reference
  final CollectionReference communityCollection = FirebaseFirestore.instance
      .collection('Community');

  // Create/Update a Customer Document
  Future updateCustomerData(String fname, String lname, String email,
      String contactNo, String password, String address,
      String avatarUrl, int wallet) async {
    return await customerCollection.doc(uid).set({
      'First Name': fname,
      'Last Name': lname,
      'Email': email,
      'Contact No': contactNo,
      'Password': password,
      'Address': address,
      'Avatar URL': avatarUrl,
      'Wallet': wallet,
    });
  }

  // Create Reports Data
  Future createReportData(String reportMessage, DocumentReference reportBy,
      DocumentReference reportTo, Timestamp timeReported, String reportTitle,
      String reportUrl) async {
    return await reportCollection.doc(uid).set({
      'Report Message': reportMessage,
      'Report By': reportBy,
      'Report To': reportTo,
      'Report Title': reportTitle,
      'Report Url' : reportUrl,
      'Time Reported': timeReported,

    });
  }

  // Update Customer Password in Auth
  Future<void> AuthupdateCustomerPassword(String password) {
    return customerCollection
        .doc(uid)
        .update({'Password': password})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  // Update Customer Profile Picture
  Future updateCustomerProfilePic(String avatarUrl) async {
    await customerCollection
        .doc(uid)
        .update({
      'Avatar URL': avatarUrl,
    });
  }

  Future updateCustomerWallet(int wallet) async {
    await customerCollection
        .doc(uid)
        .update({
      'Wallet': wallet
    }).then((_) {
    });
  }

  Future updateCourierProfilePic(String avatarUrl) async {
    await courierCollection
        .doc(uid)
        .update({
      'Avatar URL': avatarUrl,
    });
  }

  // Create/Update a Courier Document
  Future updateCourierData(String fname, String lname, String email,
      String contactNo, String password, String address, String status,
      String avatarUrl, bool approved, String vehicleType,
      int vehicleColor, String driversLicenseFront_,
      String driversLicenseBack_, String nbiClearancePhoto_,
      String vehicleRegistrationOR_, String vehicleRegistrationCR_,
      String vehiclePhoto_, DocumentReference deliveryPriceRef, String adminMessage,
      List adminCredentialsResponse, int wallet, bool requestedCashout) async {
    return await courierCollection.doc(uid).set({
      'First Name': fname,
      'Last Name': lname,
      'Email': email,
      'Contact No': contactNo,
      'Password': password,
      'Address': address,
      'Active Status': status,
      'Avatar URL': avatarUrl,
      'Admin Approved': approved,
      'Vehicle Type': vehicleType,
      'Vehicle Color': vehicleColor,
      'License Front URL': driversLicenseFront_,
      'License Back URL': driversLicenseBack_,
      'NBI Clearance URL': nbiClearancePhoto_,
      'Vehicle OR URL': vehicleRegistrationOR_,
      'Vehicle CR URL': vehicleRegistrationCR_,
      'Vehicle Photo URL': vehiclePhoto_,
      'Delivery Price Reference': deliveryPriceRef,
      'Admin Message': adminMessage,
      'Credential Response': adminCredentialsResponse,
      'Wallet': wallet,
      'Requested Cash-out': requestedCashout,
    });
  }

  Future createCommunity(String title, String content, DocumentReference sentBy,
      Timestamp timeSent) async {
    return await communityCollection.doc(uid).set({
      'Title': title,
      'Content': content,
      'Sent By': sentBy,
      'Time Sent': timeSent,
    });
  }

  Future createCommentData(String comment, DocumentReference commentBy,
      Timestamp timeSent) async {
    return await communityCollection.doc(uid).collection('Comments').add({
      'Comment': comment,
      'Comment By': commentBy,
      'Time Sent': timeSent,
    });
  }

  Future createNotificationData(String notifMessage, DocumentReference sentBy,
      DocumentReference sentTo, Timestamp time, bool IsSeen,
      bool popsOnce) async {
    return await notifCollection.doc(uid).set({
      'Notification Message': notifMessage,
      'Sent By': sentBy,
      'Sent To': sentTo,
      'Time Sent': time,
      'Seen': IsSeen,
      'Notch': popsOnce,
    });
  }

  // Together with Courier Creation, Update Credentials URL
  Future updateCourierCredentials(String driversLicenseFront_,
      String driversLicenseBack_, String nbiClearancePhoto_,
      String vehicleRegistrationOR_, String vehicleRegistrationCR_,
      String vehiclePhoto_) async {
    await courierCollection
        .doc(uid)
        .update({
      'License Front URL': driversLicenseFront_,
      'License Back URL': driversLicenseBack_,
      'NBI Clearance URL': nbiClearancePhoto_,
      'Vehicle OR URL': vehicleRegistrationOR_,
      'Vehicle CR URL': vehicleRegistrationCR_,
      'Vehicle Photo URL': vehiclePhoto_,
    });
  }

  // Update Courier if requested cash-out
  Future courierRequestCashout(bool requestedCashout) async {
    await courierCollection.doc(uid).update({
      'Requested Cash-out': requestedCashout,
    });
  }

  // Update Courier Password in Auth
  Future<void> AuthupdateCourierPassword(String password) {
    return courierCollection
        .doc(uid)
        .update({'Password': password})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  // Update Courier Status
  Future updateStatus(String status) async {
    return await courierCollection.doc(uid).update({
      'Active Status': status,
    });
  }

  Future updateCourierWallet(int wallet) async {
    return await courierCollection.doc(uid).update({
      'Wallet': wallet,
    });
  }

  // Update delivery approval
  Future updateApprovalAndDeliveryStatus(String courierApproval,
      String status) async {
    return await deliveryCollection.doc(uid).update({
      'Courier Approval': courierApproval,
      'Delivery Status': status,
    });
  }

  Future customerCancelRequest(String message) async {
    return await deliveryCollection.doc(uid).update({
      'Delivery Status': 'Cancelled',
      'Courier Approval': 'Cancelled by Customer',
      'Cancellation Message': message,
    });
  }

  Future updateNotifSeenCourier(bool isSeen) async {
    return await notifCollection.doc(uid).update({
      'Seen': isSeen,
    });
  }

  Future updateNotifNotchCourier(bool popsOnce) async {
    return await notifCollection.doc(uid).update({
      'Notch': popsOnce,
    });
  }

  Future updateNotifCounterCustomer(int notifC) async {
    return await customerCollection.doc(uid).update({
      'Current Notification': notifC,
    });
  }

  Future updateNotifStatusCustomer(bool viewable) async {
    return await customerCollection.doc(uid).update({
      'Notification Status': viewable,
    });
  }

  Future updateAdminMessage(String adminMessage) async {
    return await courierCollection.doc(uid).update({
      'Admin Message': adminMessage,
    });
  }

  Future updateCredentialsResponse(List adminCredentialsResponse) async {
    return await courierCollection.doc(uid).update({
      'Credential Response': adminCredentialsResponse,
    });
  }

  // Create Delivery Document
  Future updateDelivery(DocumentReference customer, DocumentReference courier,
      String pickupAddress, GeoPoint pickupCoordinates, String dropOffAddress,
      GeoPoint dropOffCoordinates, String itemDescription, String senderName,
      String senderContactNum, String receiverName, String receiverContactNum,
      String whoWillPay, String specificInstructions, String paymentOption,
      int deliveryFee, int itemWeight, String courierApproval, String deliveryStatus,
      GeoPoint courierLocation, int rating, String feedback, bool isReported,
      String message, Timestamp time) async {
    await deliveryCollection
        .doc(uid)
        .set({
      'Customer Reference': customer,
      'Courier Reference': courier,
      'Pickup Address': pickupAddress,
      'Pickup Coordinates': pickupCoordinates,
      'DropOff Address': dropOffAddress,
      'DropOff Coordinates': dropOffCoordinates,
      'Item Description': itemDescription,
      'Sender Name': senderName,
      'Sender Contact Number': senderContactNum,
      'Receiver Name': receiverName,
      'Receiver Contact Number': receiverContactNum,
      'Who Will Pay': whoWillPay,
      'Specific Instructions': specificInstructions,
      'Payment Option': paymentOption,
      'Delivery Fee': deliveryFee,
      'Item Weight' : itemWeight,
      'Courier Approval': courierApproval,
      'Delivery Status': deliveryStatus,
      'Courier Location': courierLocation,
      'Rating': rating,
      'Feedback': feedback,
      'Reported': isReported,
      'Cancellation Message': message,
      'Time' : time,
    });
  }

  Future updateCourierLocation(GeoPoint courierLocation) async {
    return await deliveryCollection.doc(uid).update({
      'Courier Location': courierLocation,
    });
  }

  Future updateRatingFeedback(int rating, String feedback) async {
    return await deliveryCollection.doc(uid).update({
      'Rating': rating,
      'Feedback': feedback,
    });
  }

  Future updateMessage(String newMessage) async {
    return await messageCollection.doc(uid).update({
      'Message Content': newMessage,
    });
  }

  Future updateReport(bool isReported) async {
    return await deliveryCollection.doc(uid).update({
      'Reported': isReported,
    });
  }

  Future updateCustomerFullName(String fName, String lName) async {
    return await customerCollection.doc(uid).update({
      'First Name' : fName,
      'Last Name': lName,
    });
  }

  Future updateCustomerAddress(String address) async {
    return await customerCollection.doc(uid).update({
      'Address' : address,
    });
  }

  Future updateCustomerEmail(String email) async {
    return await customerCollection.doc(uid).update({
      'Email' : email,
    });
  }

  Future updateCustomerContactNo(String contactNo) async {
    return await customerCollection.doc(uid).update({
      'Contact No' : contactNo,
    });
  }

  Future updateCustomerPassword(String password) async {
    return await customerCollection.doc(uid).update({
      'Password' : password,
    });
  }

  Future updateCourierFullName(String fName, String lName) async {
    return await courierCollection.doc(uid).update({
      'First Name' : fName,
      'Last Name': lName,
    });
  }

  Future updateCourierAddress(String address) async {
    return await courierCollection.doc(uid).update({
      'Address' : address,
    });
  }

  Future updateCourierEmail(String email) async {
    return await courierCollection.doc(uid).update({
      'Email' : email,
    });
  }

  Future updateCourierContactNo(String contactNo) async {
    return await courierCollection.doc(uid).update({
      'Contact No' : contactNo,
    });
  }

  Future updateCourierPassword(String password) async {
    return await courierCollection.doc(uid).update({
      'Password' : password,
    });
  }

  // Create a Message Document
  Future createMessageData(String messageContent, Timestamp timeSent,
      DocumentReference sentBy, DocumentReference sentTo) async {
    return await messageCollection.doc(uid).set({
      'Message Content': messageContent,
      'Time Sent': timeSent,
      'Sent By': sentBy,
      'Sent To': sentTo,
    });
  }

  Future updateTime(Timestamp time) async {
    await deliveryCollection
        .doc(uid)
        .update({
      'Time': time,
    });
  }

  // Customer Model List Builder
  List<Customer> _customerDataListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Customer(
          fName: (doc.data() as dynamic) ['First Name'] ?? '',
          lName: (doc.data() as dynamic) ['Last Name'] ?? '',
          contactNo: (doc.data() as dynamic) ['Contact No'] ?? '',
          password: (doc.data() as dynamic) ['Password'] ?? '',
          email: (doc.data() as dynamic) ['Email'] ?? '',
          address: (doc.data() as dynamic) ['Address'] ?? '',
          avatarUrl: (doc.data() as dynamic) ['Avatar URL'] ?? '',
          wallet: (doc.data() as dynamic) ['Wallet'] ?? ''
      );
    }).toList();
  }

  // Courier Model List Builder
  List<Courier> courierDataListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Courier(
        uid: doc.id,
        fName: (doc.data() as dynamic) ['First Name'] ?? '',
        lName: (doc.data() as dynamic) ['Last Name'] ?? '',
        contactNo: (doc.data() as dynamic) ['Contact No'] ?? '',
        password: (doc.data() as dynamic) ['Password'] ?? '',
        email: (doc.data() as dynamic) ['Email'] ?? '',
        address: (doc.data() as dynamic) ['Address'] ?? '',
        status: (doc.data() as dynamic) ['Active Status'] ?? '',
        avatarUrl: (doc.data() as dynamic) ['Avatar URL'] ?? '',
        vehicleColor: (doc.data() as dynamic) ['Vehicle Color'] ?? '',
        vehicleType: (doc.data() as dynamic) ['Vehicle Type'] ?? '',
        deliveryPriceRef: (doc
            .data() as dynamic) ['Delivery Price Reference'] ?? '',
        vehiclePhoto_: (doc.data() as dynamic) ['Vehicle Photo URL'] ?? '',
        wallet: (doc.data() as dynamic) ['Wallet'] ?? '',
        requestedCashout: (doc.data() as dynamic) ['Requested Cash-out'] ?? '',
      );
    }).toList();
  }

  // Delivery Model List Builder
  List<Delivery> deliveryDataListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Delivery(
        uid: doc.id,
        customerRef: (doc.data() as dynamic) ['Customer Reference'] ?? '',
        courierRef: (doc.data() as dynamic) ['Courier Reference'] ?? '',
        pickupAddress: (doc.data() as dynamic) ['Pickup Address'] ?? '',
        pickupCoordinates: (doc.data() as dynamic) ['Pickup Coordinates'] ?? '',
        dropOffAddress: (doc.data() as dynamic) ['DropOff Address'] ?? '',
        dropOffCoordinates: (doc.data() as dynamic) ['DropOff Coordinates'] ??
            '',
        itemDescription: (doc.data() as dynamic) ['Item Description'] ?? '',
        pickupPointPerson: (doc.data() as dynamic) ['Sender Name'] ?? '',
        pickupContactNum: (doc.data() as dynamic) ['Sender Contact Number'] ??
            '',
        dropoffPointPerson: (doc.data() as dynamic) ['Receiver Name'] ?? '',
        dropoffContactNum: (doc
            .data() as dynamic) ['Receiver Contact Number'] ?? '',
        whoWillPay: (doc.data() as dynamic) ['Who Will Pay'] ?? '',
        specificInstructions: (doc
            .data() as dynamic) ['Specific Instructions'] ?? '',
        paymentOption: (doc.data() as dynamic) ['Payment Option'] ?? '',
        itemWeight: (doc.data() as dynamic) ['Item Weight'] ?? '',
        deliveryFee: (doc.data() as dynamic) ['Delivery Fee'] ?? '',
        courierApproval: (doc.data() as dynamic) ['Courier Approval'] ?? '',
        deliveryStatus: (doc.data() as dynamic) ['Delivery Status'] ?? '',
        courierLocation: (doc.data() as dynamic) ['Courier Location'] ?? '',
        rating: (doc.data() as dynamic) ['Rating'] ?? '',
        feedback: (doc.data() as dynamic) ['Feedback'] ?? '',
        isReported: (doc.data() as dynamic) ['Reported'] ?? '',
        cancellationMessage: (doc.data() as dynamic) ['Cancellation Message'] ?? '',
        time: (doc.data() as dynamic) ['Time'] ?? '',
      );
    }).toList();
  }

  // Delivery Model List Builder
  List<DeliveryPrice> deliveryPriceDataListFromSnapshot(
      QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return DeliveryPrice(
        uid: doc.id,
        vehicleType: (doc.data() as dynamic) ['Vehicle Type'] ?? '',
        baseFare: (doc.data() as dynamic) ['Base Fare'] ?? '',
        farePerKM: (doc.data() as dynamic) ['Fare Per KM'] ?? '',
      );
    }).toList();
  }

  // Delivery Model List Builder
  List<Message> messageDataListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Message(
        uid: doc.id,
        messageContent: (doc.data() as dynamic) ['Message Content'] ?? '',
        timeSent: (doc.data() as dynamic) ['Time Sent'] ?? '',
        sentBy: (doc.data() as dynamic) ['Sent By'] ?? '',
        sentTo: (doc.data() as dynamic) ['Sent To'] ?? '',
      );
    }).toList();
  }

  List<Community> communityListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Community(
        uid: doc.id,
        title: (doc.data() as dynamic) ['Title'] ?? '',
        content: (doc.data() as dynamic) ['Content'] ?? '',
        sentBy: (doc.data() as dynamic) ['Sent By'] ?? '',
        timeSent: (doc.data() as dynamic) ['Time Sent'] ?? '',
      );
    }).toList();
  }

  List<Comment> commentListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Comment(
        uid: doc.id,
        comment: (doc.data() as dynamic) ['Comment'] ?? '',
        commentBy: (doc.data() as dynamic) ['Comment By'] ?? '',
        timeSent: (doc.data() as dynamic) ['Time Sent'] ?? '',
      );
    }).toList();
  }

  CourToCustomer messageDataListFromSnapshot2(QuerySnapshot snapshot) {
    return CourToCustomer(value: messageDataListFromSnapshot(snapshot));
  }

  CustomerToCour messageDataListFromSnapshot3(QuerySnapshot snapshot) {
    return CustomerToCour(value: messageDataListFromSnapshot(snapshot));
  }

  List<Notifications> notifListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Notifications(
        uid: doc.id,
        notifMessage: (doc.data() as dynamic) ['Notification Message'] ?? '',
        time: (doc.data() as dynamic) ['Time Sent'] ?? '',
        sentBy: (doc.data() as dynamic) ['Sent By'] ?? '',
        sentTo: (doc.data() as dynamic) ['Sent To'] ?? '',
        seen: (doc.data() as dynamic) ['Seen'] ?? '',
        popsOnce: (doc.data() as dynamic) ['Notch'] ?? '',
      );
    }).toList();
  }

  // Get list of data from Customers Collection
  Stream<List<Customer>> get customerList {
    return customerCollection.snapshots().map(_customerDataListFromSnapshot);
  }

  // Get list of data from Couriers Collection
  Stream<List<Courier>> get courierList {
    return courierCollection.snapshots().map(courierDataListFromSnapshot);
  }

  // Get list of data from Deliveries Collection
  Stream<List<Delivery>> get deliveryList {
    return deliveryCollection.snapshots().map(deliveryDataListFromSnapshot);
  }

  Stream<List<Delivery>> get deliveryListCustomer {
    return deliveryCollection.where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection("Customers").doc(uid)).where('Rating', isNotEqualTo: 0).snapshots().map(deliveryDataListFromSnapshot);
  }

  // Get list of data from Customers Collection
  Stream<List<DeliveryPrice>> get deliveryPriceList {
    return deliveryPriceCollection.snapshots().map(
        deliveryPriceDataListFromSnapshot);
  }

  Stream<List<Community>> get communityDataList {
    return communityCollection.snapshots().map(communityListFromSnapshot);
  }

  Stream<List<Comment>> get commentDataList {
    return communityCollection.doc(uid).collection('Comments').snapshots().map(
        commentListFromSnapshot);
  }

  // Get Customer Document Data using StreamBuilder
  Customer _customerDataFromSnapshot(DocumentSnapshot snapshot) {
    return Customer(
        uid: uid,
        fName: snapshot['First Name'],
        lName: snapshot['Last Name'],
        contactNo: snapshot['Contact No'],
        password: snapshot['Password'],
        email: snapshot['Email'],
        address: snapshot['Address'],
        avatarUrl: snapshot['Avatar URL'],
        wallet: snapshot['Wallet']
    );
  }

  // Get Courier Document Data using StreamBuilder
  Courier _courierDataFromSnapshot(DocumentSnapshot snapshot) {
    return Courier(
      uid: uid,
      fName: snapshot['First Name'],
      lName: snapshot['Last Name'],
      contactNo: snapshot['Contact No'],
      password: snapshot['Password'],
      email: snapshot['Email'],
      address: snapshot['Address'],
      approved: snapshot['Admin Approved'],
      status: snapshot['Active Status'],
      avatarUrl: snapshot['Avatar URL'],
      vehicleType: snapshot['Vehicle Type'],
      vehicleColor: snapshot['Vehicle Color'],
      driversLicenseFront_: snapshot['License Front URL'],
      driversLicenseBack_: snapshot['License Back URL'],
      nbiClearancePhoto_: snapshot['NBI Clearance URL'],
      vehicleRegistrationOR_: snapshot['Vehicle OR URL'],
      vehicleRegistrationCR_: snapshot['Vehicle CR URL'],
      vehiclePhoto_: snapshot['Vehicle Photo URL'],
      deliveryPriceRef: snapshot['Delivery Price Reference'],
      adminMessage: snapshot['Admin Message'],
      adminCredentialsResponse: snapshot['Credential Response'],
      wallet: snapshot['Wallet'],
      requestedCashout: snapshot['Requested Cash-out'],
    );
  }

  // Get Delivery Document Data using StreamBuilder
  Delivery _deliveryDataFromSnapshot(DocumentSnapshot snapshot) {
    return Delivery(
      uid: uid,
      customerRef: snapshot['Customer Reference'],
      courierRef: snapshot['Courier Reference'],
      pickupAddress: snapshot['Pickup Address'],
      pickupCoordinates: snapshot['Pickup Coordinates'],
      dropOffAddress: snapshot['DropOff Address'],
      dropOffCoordinates: snapshot['DropOff Coordinates'],
      itemDescription: snapshot['Item Description'],
      pickupPointPerson: snapshot['Sender Name'],
      pickupContactNum: snapshot['Sender Contact Number'],
      dropoffPointPerson: snapshot['Receiver Name'],
      dropoffContactNum: snapshot['Receiver Contact Number'],
      whoWillPay: snapshot['Who Will Pay'],
      specificInstructions: snapshot['Specific Instructions'],
      paymentOption: snapshot['Payment Option'],
      deliveryFee: snapshot['Delivery Fee'],
      itemWeight: snapshot['Item Weight'],
      rating: snapshot['Rating'],
      feedback: snapshot['Feedback'],
      courierApproval: snapshot['Courier Approval'],
      deliveryStatus: snapshot['Delivery Status'],
      courierLocation: snapshot['Courier Location'],
      isReported: snapshot['Reported'],
      cancellationMessage: snapshot['Cancellation Message'],
      time: snapshot['Time'],
    );
  }

  // Get Delivery Document Data using StreamBuilder
  DeliveryPrice _deliveryPriceDataFromSnapshot(DocumentSnapshot snapshot) {
    return DeliveryPrice(
        uid: uid,
        vehicleType: snapshot['Vehicle Type'],
        baseFare: snapshot['Base Fare'],
        farePerKM: snapshot['Fare Per KM']
    );
  }

  // Get Message Data using StreamBuilder
  Message _messageDataFromSnapshot(DocumentSnapshot snapshot) {
    return Message(
        uid: uid,
        messageContent: snapshot['Message Content'],
        timeSent: snapshot['Time Sent'],
        sentBy: snapshot['Sent By'],
        sentTo: snapshot['Sent To']
    );
  }

  // Get Notification Data using StreamBuilder
  Notifications notficationDataFromSnapshot(DocumentSnapshot snapshot) {
    return Notifications(
        uid: uid,
        notifMessage: snapshot['Notification Message'],
        time: snapshot['Time Sent'],
        sentBy: snapshot['Sent By'],
        sentTo: snapshot['Sent To'],
        seen: snapshot['Seen'],
        popsOnce: snapshot['Notch']
    );
  }

  Reports reportsDataFromSnapshot(DocumentSnapshot snapshot) {
    return Reports(
      uid: uid,
      reportMessage: snapshot['Report Message'],
      time: snapshot['Time Reported'],
      reportBy: snapshot['Report By'],
      reportTo: snapshot['Report To'],
      ReportTitle: snapshot['Report Title'],
      ReportUrl: snapshot['Report Url'],
    );
  }

  //Community Module List Builder
  Community communityDataFromSnapshot(DocumentSnapshot snapshot) {
    return Community(
      uid: uid,
      title: snapshot['Title'],
      content: snapshot['Content'],
      sentBy: snapshot['Sent By'],
      timeSent: snapshot['Time Sent'],
    );
  }

  Comment commentDataFromSnapshot(DocumentSnapshot snapshot) {
    return Comment(
      uid: uid,
      comment: snapshot['Comment'],
      commentBy: snapshot['Comment By'],
      timeSent: snapshot['Time Sent'],
    );
  }

  // Get Customer Document Data
  Stream<Customer> get customerData {
    return customerCollection.doc(uid).snapshots().map(
        _customerDataFromSnapshot);
  }

  // Get Courier Document Data
  Stream<Courier> get courierData {
    return courierCollection.doc(uid).snapshots().map(_courierDataFromSnapshot);
  }

  // Get Delivery Document Data
  Stream<Delivery> get deliveryData {
    return deliveryCollection.doc(uid).snapshots().map(
        _deliveryDataFromSnapshot);
  }

  // Get Delivery Price Document Data
  Stream<DeliveryPrice> get deliveryPriceData {
    return deliveryPriceCollection.doc(uid).snapshots().map(
        _deliveryPriceDataFromSnapshot);
  }

  // Get Message Document Data
  Stream<Message> get messageData {
    return messageCollection.doc(uid).snapshots().map(_messageDataFromSnapshot);
  }

  Stream<Notifications> get notificationData {
    return notifCollection.doc(uid).snapshots().map(
        notficationDataFromSnapshot);
  }

  Stream<Reports> get ReportsData {
    return reportCollection.doc(uid).snapshots().map(reportsDataFromSnapshot);
  }

  Stream<Community> get communityData {
    return communityCollection.doc(uid).snapshots().map(
        communityDataFromSnapshot);
  }

  Stream<Comment> get commentData {
    return communityCollection.doc(uid).collection('Comments')
        .doc(sub_uid)
        .snapshots()
        .map(commentDataFromSnapshot);
  }
}

class CourToCustomer {
  final List<Message> value;

  CourToCustomer({ this.value });
}

class CustomerToCour {
  final List<Message> value;

  CustomerToCour({ this.value });
}