import 'package:flutter/material.dart';

class SignupConsignee extends StatefulWidget{
  @override
  _SignupConsigneeState createState() => _SignupConsigneeState();
}

class _SignupConsigneeState extends State<SignupConsignee> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Color(0xffA82A2A),
            flexibleSpace: Container(
              margin: EdgeInsets.only(top: 10),
              child: Image.asset(
                "assets/PROExpress-logo.png",
                height: 120,
                width: 120,
              ),
            ),
            //title: Text("PROExpress"),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 340),
                  child: IconButton(icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                    onPressed: (){
                      Navigator.pop(context, false);
                    },
                    iconSize: 45,
                  ),
                ),
                Container(
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}