import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VerifyEmail extends StatefulWidget {

  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  final auth = FirebaseAuth.instance;
  User user;
  Timer timer;

  @override
  void initState(){
    user = auth.currentUser;
    user.sendEmailVerification();

    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkEmailVerified();
    });

    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<void> checkEmailVerified() async {
    print("verifying..");
    user = auth.currentUser;
    await user.reload();
    if(user.emailVerified){
      timer.cancel();
      print("verified");
      ScaffoldMessenger.of(context)..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("Your email is now verified you can now relogin")));
    }
  }
}