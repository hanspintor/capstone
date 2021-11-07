import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/customer_classes/pin_widget.dart';
import 'package:proxpress/classes/verify.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/customers.dart';

class DashboardLocation extends StatefulWidget{
  @override
  _DashboardLocationState createState() => _DashboardLocationState();
}

class _DashboardLocationState extends State<DashboardLocation>{
  final bool notBookmarks = false;
  int duration = 60;
  int flag = 0;
  String contactNo;
  final textFieldPickup = TextEditingController();
  final textFieldDropOff = TextEditingController();
  String _verificationCode = "";
  final BoxDecoration pinPutDecoration = BoxDecoration(
    border: Border.all(color: Colors.redAccent),
    borderRadius: BorderRadius.circular(15.0),
  );
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final GlobalKey<FormState> locKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;


  verifyPhone(String contact) async{
    contact = "+63" + contact.substring(1);
    print("sending ${contact}");
    await auth.verifyPhoneNumber
      (
        phoneNumber: contact,
        verificationCompleted: (PhoneAuthCredential credential) async{
          await FirebaseAuth.instance.signInWithCredential(credential).
          then((value) async {
            if(value.user != null){
              print('verified');
            }
          });
        },
        verificationFailed: (FirebaseAuthException e){
          print(e.message);
        },
        codeSent: (String verificationID, int resendToken){
          setState(() {
            _verificationCode = verificationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID){
          setState(() {
            _verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 60)
    );
  }


  @override
  Widget build(BuildContext context) {
    User user = auth.currentUser;
    print(user.phoneNumber);
    return  StreamBuilder<Customer>(
      stream: DatabaseService(uid: user.uid).customerData,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          Customer customerData = snapshot.data;
          contactNo = customerData.contactNo;
          verifyPhone(contactNo);
          return SingleChildScrollView(
            child: Column(
                children: [
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text("Welcome, ${customerData.fName}!",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                  !user.emailVerified ? Container(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Card(
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
                                  // try{
                                  //   await FirebaseAuth.instance.signInWithCredential
                                  //     (PhoneAuthProvider.credential(
                                  //       verificationId: _verificationCode, smsCode: pin)
                                  //   ).then((value) async{
                                  //     if(value.user != null){
                                  //       print("wrong code");
                                  //     }
                                  //   });
                                  // } catch (e){
                                  //   FocusScope.of(context).unfocus();
                                  //   print("invalid otp");
                                  // }
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
                                    "We have sent the code to ${customerData.contactNo}.",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold

                                    ),
                                  ),
                                ],
                              ),
                            )
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.info,
                              color: Colors.red,
                            ),
                            title: Text(
                              "Kindly verify your email ${user.email} to use the app.",
                              style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold
                              ),
                            ),

                          ),
                        ),
                        //verifyCond(),
                        //VerifyEmail()
                      ],
                    ),
                  )
                      : SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          PinLocation(
                            locKey: locKey,
                            textFieldPickup: textFieldPickup,
                            textFieldDropOff: textFieldDropOff,
                            isBookmarks: false,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          );
        } else {
          return UserLoading();
        }
      }
    );


  }





}





