import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'signup_customer.dart';
import 'signup_courier.dart';

class RegLandingPage extends StatefulWidget{
  @override
  _RegLandingPageState createState() => _RegLandingPageState();
}

class _RegLandingPageState extends State<RegLandingPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
            onPressed: (){
              Navigator.pop(context, false);
            },
            iconSize: 25,
          ),
          title: Text('Create a New Account', style: TextStyle(color: Colors.black),),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: Container(margin: EdgeInsets.only(top: 10),),
          ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(25),
                  height: MediaQuery.of(context).size.height / 3.5,
                  width: MediaQuery.of(context).size.width / 1.1,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.account_circle_rounded),
                    onPressed: () {
                      Navigator.pushNamed(context, '/signupCustomer');
                    },
                    style: ElevatedButton.styleFrom(primary: Color(0xfffb0d0d), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),),
                    label: Text(
                      "Customer",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(25),
                  height: MediaQuery.of(context).size.height / 3.5,
                  width: MediaQuery.of(context).size.width / 1.1,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.local_shipping_rounded),
                    onPressed: () {
                      Navigator.pushNamed(context, '/signupCourier');
                    },
                    style: ElevatedButton.styleFrom(primary: Color(0xfffb0d0d), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),),
                    label: Text(
                      "Courier",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30
                      ),
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