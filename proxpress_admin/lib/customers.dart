
class Customer{
  final String uid;
  final String fName;
  final String lName;
  final String email;
  final String contactNo;
  final String password;
  final String address;
  final String avatarUrl;
  final bool notifStatus;
  final int currentNotif;
  final Map courier_ref;

  Customer({this.uid, this.fName, this.lName, this.email,
    this.contactNo, this.password, this.address, this.avatarUrl,
    this.notifStatus, this.currentNotif, this.courier_ref});


}