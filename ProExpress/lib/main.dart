import 'dart:async';

import 'package:flutter/material.dart';
import 'loginscreen.dart';
void main()=> runApp(PROExporessApp());

class PROExporessApp extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: LoadScreen(),
    );
  }
}

// Load Screen Code can be transferable into another file
class LoadScreen extends StatefulWidget{
  @override
  _LoadScreenState createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {

  @override
  void initState(){
    super.initState();
    Timer(Duration(seconds: 3), () {
      // move to next screen / page
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffA82A2A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/PROExpress-logo.png',
              height: 150,
              width: 500,
            ),
            SizedBox(
              height: 50,
            ),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

}