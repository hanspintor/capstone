import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:proxpress/classes/courier_classes/delivery_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as Path;
import 'package:file_picker/file_picker.dart';
import 'package:proxpress/services/upload_file.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

class CourierDashboard extends StatefulWidget {
  @override
  State<CourierDashboard> createState() => _CourierDashboardState();
}

class _CourierDashboardState extends State<CourierDashboard> {
  File driversLicenseFront;
  File driversLicenseBack;
  File nbiClearancePhoto;
  File vehicleRegistrationOR;
  File vehicleRegistrationCR;
  File vehiclePhoto;

  int remainingTime = 120;
  final CountdownController _controller =
  new CountdownController(autoStart: true);

  String driversLicenseFront_ = '';
  String driversLicenseBack_ = '';
  String nbiClearancePhoto_ = '';
  String vehicleRegistrationOR_ = '';
  String vehicleRegistrationCR_ = '';
  String vehiclePhoto_ = '';
  bool vPhone = false;
  bool rButton = true;
  String contactNo;
  String _verificationCode = "";

  final BoxDecoration pinPutDecoration = BoxDecoration(
    border: Border.all(color: Colors.redAccent),
    borderRadius: BorderRadius.circular(15.0),
  );
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    final auth = FirebaseAuth.instance;
    User user1 = auth.currentUser;
    final driversLicenseFrontFileName =  driversLicenseFront != null ? Path.basename(driversLicenseFront.path) : 'No File Selected';
    final driversLicenseBackFileName =  driversLicenseBack != null ? Path.basename(driversLicenseBack.path) : 'No File Selected';
    final nbiClearancePhotoFileName =  nbiClearancePhoto != null ? Path.basename(nbiClearancePhoto.path) : 'No File Selected';
    final vehicleRegistrationORFileName =  vehicleRegistrationOR != null ? Path.basename(vehicleRegistrationOR.path) : 'No File Selected';
    final vehicleRegistrationCRFileName =  vehicleRegistrationCR != null ? Path.basename(vehicleRegistrationCR.path) : 'No File Selected';
    final vehiclePhotoFileName =  vehiclePhoto != null ? Path.basename(vehiclePhoto.path) : 'No File Selected';

    bool approved = false;
    bool notifPopUpStatus = false;
    int notifCounter = 0;

    verifyPhone(String contact) async {
      contact = "+63" + contact.substring(1);
      print("sending ${contact}");
      try {
        await auth.verifyPhoneNumber
          (
            phoneNumber: contact,
            verificationCompleted: (PhoneAuthCredential credential) async {
              await FirebaseAuth.instance.signInWithCredential(credential).
              then((value) async {
                if (value.user != null) {
                  print('verified naaaaa');
                }
              });
            },
            verificationFailed: (FirebaseAuthException e) {
              print(e.message);
            },
            codeSent: (String verificationID, int resendToken) {
              setState(() {
                _verificationCode = verificationID;
              });
            },
            codeAutoRetrievalTimeout: (String verificationID) {
              setState(() {
                _verificationCode = verificationID;
              });
            },
            timeout: Duration(seconds: remainingTime)
        );
      } catch (e) {
        print(e);
      }
    }

    return StreamBuilder<Courier>(
      stream: DatabaseService(uid: user.uid).courierData,
      builder: (context,snapshot) {
        if (snapshot.hasData) {
          Courier courierData = snapshot.data;
          approved = courierData.approved;
          notifPopUpStatus = courierData.NotifPopStatus;
          notifCounter = courierData.NotifPopCounter;
          Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
              .collection('Deliveries')
              .where('Courier Approval', isEqualTo: 'Pending')
              .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
              .snapshots()
              .map(DatabaseService().deliveryDataListFromSnapshot);

          bool allCredentialsValid = courierData.adminCredentialsResponse[0]  == false &&
              courierData.adminCredentialsResponse[1] == false &&
              courierData.adminCredentialsResponse[2] == false &&
              courierData.adminCredentialsResponse[3] == false &&
              courierData.adminCredentialsResponse[4] == false &&
              courierData.adminCredentialsResponse[5] == false ? true : false;

          Widget _welcomeMessage() {
            String welcomeMessage = courierData.adminMessage;
            print(welcomeMessage);
            return Container(
              margin: EdgeInsets.fromLTRB(20, 40, 20, 0),
              child: Align(
                child: Text(welcomeMessage,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            );
          }

          Widget _updateCredential1() {
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: OutlinedButton(
                child: ListTile(
                  title: Text('Driver\'s License Front'),
                  subtitle: Text(driversLicenseFrontFileName),
                  trailing: IconButton(
                    icon: Icon(driversLicenseFrontFileName == 'No File Selected' ? Icons.attach_file_rounded: Icons.cancel_rounded, color: Color(0xfffb0d0d),),
                    onPressed:  driversLicenseFrontFileName == 'No File Selected' || driversLicenseFront == null ? null : () {
                      setState(() {
                        driversLicenseFront = null;
                      });
                    },
                  ),
                ),
                onPressed: driversLicenseFrontFileName != 'No File Selected' || driversLicenseFront != null ? null : () async{
                  final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
                  final path = result.files.single.path;
                  setState(() {
                    driversLicenseFront = File(path);
                  });
                },
              ),
            );
          }

          Widget _updateCredential2() {
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: OutlinedButton(
                child: ListTile(
                  title: Text('Driver\'s License Back'),
                  subtitle: Text(driversLicenseBackFileName),
                  trailing: IconButton(
                    icon: Icon(driversLicenseBackFileName == 'No File Selected' ? Icons.attach_file_rounded: Icons.cancel_rounded, color: Color(0xfffb0d0d),),
                    onPressed:  driversLicenseBackFileName == 'No File Selected' || driversLicenseBack == null ? null : () {
                      setState(() {
                        driversLicenseBack = null;
                      });
                    },
                  ),
                ),
                onPressed: driversLicenseBackFileName != 'No File Selected' || driversLicenseBack != null ? null : () async{
                  final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
                  final path = result.files.single.path;
                  setState(() {
                    driversLicenseBack = File(path);
                  });
                },
              ),
            );
          }
          Widget _updateCredential3() {
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: OutlinedButton(
                child: ListTile(
                  title: Text('NBI Clearance'),
                  subtitle: Text(nbiClearancePhotoFileName),
                  trailing: IconButton(
                    icon: Icon(nbiClearancePhotoFileName == 'No File Selected' ? Icons.attach_file_rounded: Icons.cancel_rounded, color: Color(0xfffb0d0d),),
                    onPressed:  nbiClearancePhotoFileName == 'No File Selected' || nbiClearancePhoto == null ? null : () {
                      setState(() {
                        nbiClearancePhoto = null;
                      });
                      print(nbiClearancePhoto);
                    },
                  ),
                ),
                onPressed: nbiClearancePhotoFileName != 'No File Selected' || nbiClearancePhoto != null ? null : () async{
                  final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
                  final path = result.files.single.path;
                  setState(() {
                    nbiClearancePhoto = File(path);
                  });
                },
              ),
            );
          }

          Widget _updateCredential4() {
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: OutlinedButton(
                child: ListTile(
                  title: Text('Vehicle Official Receipt (OR)'),
                  subtitle: Text(vehicleRegistrationORFileName),
                  trailing: IconButton(
                    icon: Icon(vehicleRegistrationORFileName == 'No File Selected' ? Icons.attach_file_rounded: Icons.cancel_rounded, color: Color(0xfffb0d0d),),
                    onPressed:  vehicleRegistrationORFileName == 'No File Selected' || vehicleRegistrationOR == null ? null : () {
                      setState(() {
                        vehicleRegistrationOR = null;
                      });
                      print(vehicleRegistrationOR);
                    },
                  ),
                ),
                onPressed: vehicleRegistrationORFileName != 'No File Selected' || vehicleRegistrationOR != null ? null : () async{
                  final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
                  final path = result.files.single.path;
                  setState(() {
                    vehicleRegistrationOR = File(path);
                  });
                },
              ),
            );
          }

          Widget _updateCredential5() {
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: OutlinedButton(
                child: ListTile(
                  title: Text('Vehicle Official Receipt (CR)'),
                  subtitle: Text(vehicleRegistrationCRFileName),
                  trailing: IconButton(
                    icon: Icon(vehicleRegistrationCRFileName == 'No File Selected' ? Icons.attach_file_rounded: Icons.cancel_rounded, color: Color(0xfffb0d0d),),
                    onPressed:  vehicleRegistrationCRFileName == 'No File Selected' || vehicleRegistrationCR == null ? null : () {
                      setState(() {
                        vehicleRegistrationCR = null;
                      });
                      print(vehicleRegistrationCR);
                    },
                  ),
                ),
                onPressed: vehicleRegistrationCRFileName != 'No File Selected' || vehicleRegistrationCR != null ? null : () async{
                  final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
                  final path = result.files.single.path;
                  setState(() {
                    vehicleRegistrationCR = File(path);
                  });
                },
              ),
            );
          }

          Widget _updateCredential6() {
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: OutlinedButton(
                child: ListTile(
                  title: Text('Vehicle Photo'),
                  subtitle: Text(vehiclePhotoFileName),
                  trailing: Padding(
                    padding: const EdgeInsets.only(left: 38),
                    child: IconButton(
                      icon: Icon(vehiclePhotoFileName == 'No File Selected' ? Icons.attach_file_rounded: Icons.cancel_rounded, color: Color(0xfffb0d0d),),
                      onPressed:  vehiclePhotoFileName == 'No File Selected' || vehiclePhoto == null ? null : () {
                        setState(() {
                          vehiclePhoto = null;
                        });
                        print(vehiclePhoto);
                      },
                    ),
                  ),
                ),
                onPressed: vehiclePhotoFileName != 'No File Selected' || vehiclePhoto != null ? null : () async{
                  final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
                  final path = result.files.single.path;
                  setState(() {
                    vehiclePhoto = File(path);
                  });
                },
              ),
            );
          }

          Widget _updateCredentialButton() {
            return ElevatedButton(
                child: Text(
                  'Update Credentials', style: TextStyle(color: Colors.white, fontSize:18),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xfffb0d0d),
                ),
                onPressed: () async {
                  bool picsLoaded() {
                    if (courierData.adminCredentialsResponse[0] && driversLicenseFront != null) {
                      return true;
                    } else if (courierData.adminCredentialsResponse[1] && driversLicenseBack != null) {
                      return true;
                    } else if (courierData.adminCredentialsResponse[2] && nbiClearancePhoto != null) {
                      return true;
                    } else if (courierData.adminCredentialsResponse[3] && vehicleRegistrationOR != null) {
                      return true;
                    } else if (courierData.adminCredentialsResponse[4] && vehicleRegistrationCR != null) {
                      return true;
                    } else if (courierData.adminCredentialsResponse[5] && vehiclePhoto != null) {
                      return true;
                    } else return false;
                  }

                  if (picsLoaded()) {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final User user = auth.currentUser;

                      if (user != null) {
                        final driversLicenseFrontDestination = 'Couriers/${user.uid}/$driversLicenseFrontFileName';
                        final driversLicenseBackDestination = 'Couriers/${user.uid}/$driversLicenseBackFileName';
                        final nbiClearancePhotoDestination = 'Couriers/${user.uid}/$nbiClearancePhotoFileName';
                        final vehicleRegistrationORDestination = 'Couriers/${user.uid}/$vehicleRegistrationORFileName';
                        final vehicleRegistrationCRDestination = 'Couriers/${user.uid}/$vehicleRegistrationCRFileName';
                        final vehiclePhotoDestination = 'Couriers/${user.uid}/$vehiclePhotoFileName';

                        try {
                          if (courierData.adminCredentialsResponse[0]) {
                            print('1');
                            await UploadFile.uploadFile(driversLicenseFrontDestination, driversLicenseFront);
                            driversLicenseFront_ = await firebase_storage.FirebaseStorage.instance
                                .ref(driversLicenseFrontDestination)
                                .getDownloadURL();
                          }
                          if (courierData.adminCredentialsResponse[1]) {
                            print('2');
                            await UploadFile.uploadFile(driversLicenseBackDestination, driversLicenseBack);
                            driversLicenseBack_ = await firebase_storage.FirebaseStorage.instance
                                .ref(driversLicenseBackDestination)
                                .getDownloadURL();
                          }
                          if (courierData.adminCredentialsResponse[2]) {
                            print('3');
                            await UploadFile.uploadFile(nbiClearancePhotoDestination, nbiClearancePhoto);
                            nbiClearancePhoto_ = await firebase_storage.FirebaseStorage.instance
                                .ref(nbiClearancePhotoDestination)
                                .getDownloadURL();
                          }
                          if (courierData.adminCredentialsResponse[3]) {
                            print('4');
                            await UploadFile.uploadFile(vehicleRegistrationORDestination, vehicleRegistrationOR);
                            vehicleRegistrationOR_ = await firebase_storage.FirebaseStorage.instance
                                .ref(vehicleRegistrationORDestination)
                                .getDownloadURL();
                          }
                          if (courierData.adminCredentialsResponse[4]) {
                            print('5');
                            await UploadFile.uploadFile(vehicleRegistrationCRDestination, vehicleRegistrationCR);
                            vehicleRegistrationCR_ = await firebase_storage.FirebaseStorage.instance
                                .ref(vehicleRegistrationCRDestination)
                                .getDownloadURL();
                          }
                          if (courierData.adminCredentialsResponse[5]) {
                            print('6');
                            await UploadFile.uploadFile(vehiclePhotoDestination, vehiclePhoto);
                            vehiclePhoto_ = await firebase_storage.FirebaseStorage.instance
                                .ref(vehiclePhotoDestination)
                                .getDownloadURL();
                          }
                          if (driversLicenseFront_ == null || driversLicenseFront_ == '') {
                            driversLicenseFront_ = courierData.driversLicenseFront_;
                          }
                          if (driversLicenseBack_ == null || driversLicenseBack_ == '') {
                            driversLicenseBack_ = courierData.driversLicenseBack_;
                          }
                          if (nbiClearancePhoto_ == null || nbiClearancePhoto_ == '') {
                            nbiClearancePhoto_ = courierData.nbiClearancePhoto_;
                          }
                          if (vehicleRegistrationOR_ == null || vehicleRegistrationOR_ == '') {
                            vehicleRegistrationOR_ = courierData.vehicleRegistrationOR_;
                          }
                          if (vehicleRegistrationCR_ == null || vehicleRegistrationCR_ == '') {
                            vehicleRegistrationCR_ = courierData.vehicleRegistrationCR_;
                          }
                          if (vehiclePhoto_ == null || vehiclePhoto_ == '') {
                            vehiclePhoto_ = courierData.vehiclePhoto_;
                          }

                          await DatabaseService(uid: user.uid).updateCourierCredentials(driversLicenseFront_, driversLicenseBack_, nbiClearancePhoto_, vehicleRegistrationOR_, vehicleRegistrationCR_, vehiclePhoto_);
                          await DatabaseService(uid: user.uid).updateAdminMessage("Your credentials have been updated, please wait for the confirmation.");
                          await DatabaseService(uid: user.uid).updateCredentialsResponse([false,false,false,false,false,false]);

                        } catch(e) {
                          print(e.toString());
                        }
                      }
                  } else {
                    print('Photos not yet uploaded');
                  }
                  await showToast('Please wait for the confirmation.');
                }
            );
          }

          contactNo = courierData.contactNo;
          return StreamProvider<List<Delivery>>.value(
            initialData: [],
            value: deliveryList,
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text("Welcome, ${courierData.fName}!",
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                    !approved || !user1.emailVerified && user1.phoneNumber == null ? Container(
                      child: Column(
                        children: [
                          !approved ? Column(
                            children: [
                              _welcomeMessage(),
                              Column(
                                children: [
                                  courierData.adminCredentialsResponse[0] ? _updateCredential1() : Container(),
                                  courierData.adminCredentialsResponse[1] ? _updateCredential2() : Container(),
                                  courierData.adminCredentialsResponse[2] ? _updateCredential3() : Container(),
                                  courierData.adminCredentialsResponse[3] ? _updateCredential4() : Container(),
                                  courierData.adminCredentialsResponse[4] ? _updateCredential5() : Container(),
                                  courierData.adminCredentialsResponse[5] ? _updateCredential6() : Container(),
                                  !allCredentialsValid ? _updateCredentialButton(): Container(),
                                ],
                              ),
                            ],
                          ) : Visibility(
                            visible: false,
                            child: Container(),
                          ),
                          !user1.emailVerified || user1.phoneNumber == null ? Container(
                            margin: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Visibility(
                                    visible: rButton,
                                    child: SizedBox(
                                      height: MediaQuery.of(context).size.height / 3,
                                    )
                                ),
                                Visibility(
                                  visible: user1.phoneNumber != null ? false : rButton,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        vPhone = true;
                                        rButton = false;
                                      });
                                      showToast1("OTP has been sent");
                                      verifyPhone(contactNo);
                                      _controller.start();
                                    },
                                    child: Text('Verify your contact number'),
                                  ),
                                ),
                                Visibility(
                                  visible: vPhone,
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    borderOnForeground: true,
                                    child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Enter Verification code",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              SizedBox(height: 20,),
                                              Text(
                                                "Please check your mobile number for a "
                                                    "message with your code.",
                                                style: TextStyle(
                                                  fontSize: 15,

                                                ),
                                              ),
                                              SizedBox(height: 15,),
                                              PinPut(
                                                fieldsCount: 6,
                                                eachFieldHeight: 40.0,
                                                withCursor: true,
                                                onSubmit: (pin) async{
                                                  print("pin ${pin}");
                                                  try{
                                                    await user1.linkWithCredential(
                                                        PhoneAuthProvider.credential(verificationId: _verificationCode, smsCode: pin)
                                                    ).then((value) async {
                                                      if (value.user != null) {
                                                        print("works?");
                                                        setState(() {
                                                          vPhone = false;
                                                          rButton = false;
                                                        });
                                                        showToast1("Your phone number is now verified");
                                                        if (approved) {
                                                          Future.delayed(const Duration(seconds: 3), () {
                                                            setState(() {
                                                              Navigator.pushNamed(context, '/template1');
                                                            });

                                                          });
                                                        }
                                                      }
                                                    });
                                                  } catch (e) {
                                                    FocusScope.of(context).unfocus();
                                                    print("invalid otp");
                                                  }
                                                },
                                                focusNode: _pinPutFocusNode,
                                                controller: _pinPutController,
                                                submittedFieldDecoration: pinPutDecoration.copyWith(
                                                  borderRadius: BorderRadius.circular(20.0),
                                                ),
                                                selectedFieldDecoration: pinPutDecoration,
                                                followingFieldDecoration: pinPutDecoration.copyWith(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  border: Border.all(
                                                    color: Colors.redAccent.withOpacity(.5),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Text(
                                                "We have sent the code to ${courierData.contactNo}.",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Container(
                                                width: MediaQuery.of(context).size.width - 30,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        height: 1,
                                                        color: Colors.grey,
                                                        margin: EdgeInsets.symmetric(horizontal: 12),
                                                      ),
                                                    ),
                                                    Countdown(
                                                      controller: _controller,
                                                      seconds: remainingTime,
                                                      build: (_, double time) {
                                                        Color color1 = Colors.green;
                                                        if (time.toInt() <= 60) {
                                                          color1 = Colors.red;
                                                        }
                                                        return Text(
                                                          time.toInt().toString(),
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold,
                                                            color: color1,
                                                          ),
                                                        );
                                                      },
                                                      interval: Duration(seconds: 1),
                                                      onFinished: () {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text('Tap resend new code to received new text'),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        height: 1,
                                                        color: Colors.grey,
                                                        margin: EdgeInsets.symmetric(horizontal: 12),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Text(
                                                "Didn't received any code?",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              InkWell(
                                                child: new Text(
                                                  "RESEND NEW CODE",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.redAccent
                                                  ),
                                                ),
                                                onTap: () {
                                                  showToast1("We have sent a new OTP");
                                                  verifyPhone(contactNo);
                                                  print("resending");
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                                    ),
                                  ),
                                ),
                                //verifyCond(),
                                //VerifyEmail()
                              ],
                            ),
                          ) : Visibility(
                            visible: false,
                            child: Container(),
                          ),
                        ],
                      ),
                    ) : Container(
                      child: DeliveryList(notifPopUpStatus: notifPopUpStatus, notifPopUpCounter: notifCounter,),
                    ),
                  ],
                ),
              ),
          );
        } else {
          return UserLoading();
        }
      }
    );
  }

  Future showToast(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.red, textColor: Colors.white);
  }

  Future showToast1(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.green, textColor: Colors.white);
  }
}