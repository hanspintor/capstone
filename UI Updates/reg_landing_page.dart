import 'package:flutter/material.dart';
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
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
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
                Row(
                  children: [
                    Container(
                      child: IconButton(icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                        onPressed: (){
                          Navigator.pop(context, false);
                        },
                        iconSize: 25,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 0),
                      child: Text(
                        "Choose a Registration Form",
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.all(25),
                  height: MediaQuery.of(context).size.width / 2.2,
                  width: MediaQuery.of(context).size.width / 1.1,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(builder: (context) => new SignupCustomer()));
                    },
                    color: Color(0xfffb0d0d),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
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
                  height: MediaQuery.of(context).size.width / 2.2,
                  width: MediaQuery.of(context).size.width / 1.1,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(builder: (context) => new SignupCourier()));
                    },
                    color: Color(0xfffb0d0d),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
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