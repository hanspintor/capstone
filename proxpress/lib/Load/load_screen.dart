import 'package:flutter/material.dart';
import 'dart:async';

class LoadScreen extends StatefulWidget{
  @override
  _LoadScreenState createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {
  @override
  void initState(){
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushNamed(context, '/wrapper');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}