import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/customer_classes/pin_widget.dart';
import 'package:proxpress/classes/verify.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/customers.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';


class DashboardLocation extends StatefulWidget{
  @override
  _DashboardLocationState createState() => _DashboardLocationState();
}

class _DashboardLocationState extends State<DashboardLocation>{
  final bool notBookmarks = false;
  int duration = 60;
  int flag = 0;
  int remainingTime = 120;
  final CountdownController _controller =
  new CountdownController(autoStart: true);
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
  bool vPhone = false;
  bool rButton = true;


  verifyPhone(String contact) async{
    contact = "+63" + contact.substring(1);
    print("sending ${contact}");
    try{
      await auth.verifyPhoneNumber
        (
          phoneNumber: contact,
          verificationCompleted: (PhoneAuthCredential credential) async{
            await FirebaseAuth.instance.signInWithCredential(credential).
            then((value) async {
              if(value.user != null){
                print('verified naaaaa');
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
          timeout: Duration(seconds: remainingTime)
      );
    } catch (e){
      print(e);
    }
  }




  @override
  Widget build(BuildContext context) {
    User user = auth.currentUser;
    print("Phone: ${user.phoneNumber}");
    print("Phone: ${user.uid}");
    return  StreamBuilder<Customer>(
      stream: DatabaseService(uid: user.uid).customerData,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          Customer customerData = snapshot.data;
          contactNo = customerData.contactNo;

          return SingleChildScrollView(
            child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text("Welcome, ${customerData.fName}!",
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          color: Colors.red,
                          icon: Icon(Icons.help_outline,),
                          iconSize: 25,
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    titlePadding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    title: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(0),
                                          child: Container(
                                            margin: EdgeInsets.all(0),
                                            alignment: Alignment.topRight,
                                            child: IconButton(
                                              icon: const Icon(Icons.close_sharp),
                                              color: Colors.redAccent,
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(bottom: 15),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(color: Colors.grey[500])
                                              )
                                          ),
                                          child: Center(
                                              child: Text('Pinning the Locations')
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Container(
                                        width: double.maxFinite,
                                        child: Text(
                                          'There are two locations that we require from you: pick-up and drop-off location.\n\n'
                                              'In case you don\'t know the exact location, just try to pin the location as near as possible, since our pricing depends on your given details.\n\n'
                                              'Also, just give additional instructions to the courier if you don\'t know specifically where your desired location is.',
                                          textAlign: TextAlign.justify,
                                        )
                                    ),
                                  );
                                }
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  !user.emailVerified && user.phoneNumber == null ? Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      children: [
                        Visibility(
                          visible: rButton,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height / 3,
                            )
                        ),
                        Visibility(
                          visible: rButton,
                          child: ElevatedButton(
                            onPressed: (){

                              setState(() {
                                vPhone = true;
                                rButton = false;
                              });
                              showToast("OTP has been sent");
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
                                          fontWeight: FontWeight.bold,

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
                                          await user.linkWithCredential(
                                              PhoneAuthProvider.credential(verificationId: _verificationCode, smsCode: pin)
                                          ).then((value) async {
                                            if(value.user != null){
                                              print("works?");
                                              setState(() {
                                                vPhone = false;
                                              });
                                              showToast("Your phone number is now verified");
                                              Future.delayed(const Duration(seconds: 3), () {
                                                setState(() {
                                                  Navigator.pushNamed(context, '/template');
                                                });
                                              });

                                            }
                                          });
                                        } catch (e){
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
                                      "We have sent the code to ${customerData.contactNo}.",
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
                                            build: (_, double time){
                                              Color color1 = Colors.green;
                                              if(time.toInt() <= 60){
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
                                      onTap: (){
                                        showToast("We have sent a new OTP");
                                        verifyPhone(contactNo);
                                        _controller.restart();
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
                  ) : PinLocation(
                    locKey: locKey,
                    textFieldPickup: textFieldPickup,
                    textFieldDropOff: textFieldDropOff,
                    isBookmarks: false,
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



  Future showToast(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.green, textColor: Colors.white);
  }

}





