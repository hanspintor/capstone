import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:proxpress/Load/user_load.dart';

class LandingPage extends StatefulWidget{
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>{
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return loading ? UserLoading(): WillPopScope(
      onWillPop: () async {
        print("Back Button pressed");
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Image.asset(
                          "assets/PROExpress-logo.png",
                          height: 150,
                          width: 300,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 30, bottom: 30),
                        child: Lottie.asset('assets/landing.json'),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 15,
                          width: MediaQuery.of(context).size.width / 1.1,
                          child: ElevatedButton(
                            onPressed: () async {
                              showMaterialModalBottomSheet(
                                backgroundColor: Colors.red[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                context: context,
                                builder: (context) => Container(height: 130, child: _userChoice()),
                              );
                            },
                            child: Text(
                              "GET STARTED",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xfffb0d0d),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/loginScreen');
                          },
                          child: Text(
                            "Already have an account?",
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }

  _userChoice() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            child: Text('Create a new account',style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white, // background
                  onPrimary: Colors.red, // foreground
                ),
                child: Text('CUSTOMER', style: TextStyle(fontSize: 18)),
                onPressed: () {
                  Navigator.pushNamed(context, '/signupCustomer');
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('OR',style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white, // background
                  onPrimary: Colors.red, // foreground
                ),
                child: Text('COURIER', style: TextStyle(fontSize: 18)),
                onPressed: () {
                  Navigator.pushNamed(context, '/signupCourier');
                },
              ),
            ],
          ),

        ],
      ),
    );
  }
}