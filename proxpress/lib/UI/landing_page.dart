import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget{
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Image.asset(
                  "assets/PROExpress-logo.png",
                  height: 250,
                  width: 250,
                ),
              ),
              
              // Container(
              //   margin: EdgeInsets.all(25),
              //   height: MediaQuery.of(context).size.height / 3.5,
              //   width: MediaQuery.of(context).size.width / 1.1,
              //   child: ElevatedButton.icon(
              //     icon: SizedBox(height: 50, width: 50, child: Image.asset('assets/customer.png')),
              //     onPressed: () {
              //       Navigator.pushNamed(context, '/signupCustomer');
              //     },
              //     style: ElevatedButton.styleFrom(primary: Color(0xfffb0d0d), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),),
              //     label: Text(
              //       "Customer",
              //       style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 30
              //       ),
              //     ),
              //   ),
              // ),
              // Container(
              //   margin: EdgeInsets.all(25),
              //   height: MediaQuery.of(context).size.height / 3.5,
              //   width: MediaQuery.of(context).size.width / 1.1,
              //   child: ElevatedButton.icon(
              //     icon: SizedBox(height: 50, width: 50, child: Image.asset('assets/courier.png')),
              //     onPressed: () {
              //       Navigator.pushNamed(context, '/signupCourier');
              //     },
              //     style: ElevatedButton.styleFrom(primary: Color(0xfffb0d0d), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),),
              //     label: Text(
              //       "Courier",
              //       style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 30
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        )
    );
  }
}