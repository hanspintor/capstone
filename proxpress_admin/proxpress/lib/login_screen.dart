import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/auth.dart';
import 'package:proxpress/dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  child:Image.asset(
                    "assets/PROExpress-logo.png",
                    height: 500,
                    width: 500,
                  ),
                ),
                Container(
                  //margin: EdgeInsets.only(top: 100),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 800),
                          child: TextFormField(
                              textInputAction: TextInputAction.next,
                              validator: (val) => val.isEmpty ? 'Email is Required': null,
                              decoration: InputDecoration(
                                labelText: "Email",
                                prefixIcon: Icon(Icons.email_rounded),
                              ),
                              onSaved: (String value){
                                email = value;
                              },
                              onChanged: (val){
                                setState(() => email = val);
                              }
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 800,),
                          child: TextFormField(
                              textInputAction: TextInputAction.next,
                              obscureText: true,
                              validator: (String value){
                                if(value.isEmpty){
                                  return 'Password is Required';
                                }
                                else return null;
                              },
                              onSaved: (String value){
                                password = value;
                              },
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(Icons.lock),
                              ),
                              onChanged: (val){
                                setState(() => password = val);
                              }
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 15),
                          height: MediaQuery.of(context).size.height / 25,
                          width: MediaQuery.of(context).size.width / 24,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState.validate()){
                                dynamic result = await _auth.SignIn(email, password);
                                if (result == null) {
                                  setState(() {
                                    error = 'Invalid email or password';
                                  });
                                } else {
                                  final FirebaseAuth auth = FirebaseAuth.instance;

                                  final User user = auth.currentUser;

                                  FirebaseFirestore.instance
                                      .collection('Customers')
                                      .doc(user.uid)
                                      .get()
                                      .then((DocumentSnapshot documentSnapshot) {
                                    if (documentSnapshot.exists) {
                                      print('customer document found');
                                      setState((){
                                        error = 'Account is not an admin';
                                      });
                                      _auth.signOut();
                                    } else {
                                      FirebaseFirestore.instance
                                          .collection('Couriers')
                                          .doc(user.uid)
                                          .get()
                                          .then((DocumentSnapshot documentSnapshot) {
                                        if (documentSnapshot.exists) {
                                          print('courier document found');
                                          setState((){
                                            error = 'Account is not an admin';
                                          });
                                          _auth.signOut();
                                        } else {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard(savedPassword: password,)));
                                        }
                                      });
                                    }
                                  });
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xfffb0d0d),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12,),
                        Text(
                          error,
                          style: TextStyle(color: Colors.red, fontSize: 14.0),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(content: (Container()))
                              );
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color(0xffFD3F40),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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
