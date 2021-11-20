import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/services/auth.dart';

class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String contactNo = '';
  String password = '';
  String error = '';
  bool visibleE = false;
  bool loading = false;

  Widget _alertmessage(){
    return ForgotPassword();
  }

  Widget _buildUsername(){
    return TextFormField(
        autofillHints: [AutofillHints.email],
        validator: (val) => val.isEmpty ? 'Email is Required': null,
        decoration: InputDecoration(
          labelText: "Email",
        ),
        onSaved: (String value){
          email = value;
        },
        onChanged: (val){
          setState(() => email = val);
        }
    );
  }

  Widget _buildPassword(){
    return TextFormField(
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
        ),
        onChanged: (val){
          setState(() => password = val);
        }

    );
  }

  @override
  Widget build(BuildContext context) {
    return loading ? UserLoading() : WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Image.asset(
                    "assets/PROExpress-logo.png",
                    height: 160,
                    width: 300,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: _buildUsername(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: _buildPassword(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                Visibility(
                    visible: visibleE,
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Colors.red,
                      ),

                    )
                ),
                SizedBox(height: 5,),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 15,
                    width: MediaQuery.of(context).size.width / 1.35,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState.validate()){
                          setState(() => loading = true); // loading = true;
                          dynamic result = await _auth.SignInCustomer(email, password);
                          if(result == null){
                            setState((){
                              error = 'Invalid email or password';
                              loading = false;
                              visibleE = true;
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xfffb0d0d),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),

                      child: Text(
                        "LOGIN",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                          context: context, builder: (BuildContext context) => AlertDialog(
                        content: (_alertmessage()),
                      )
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: InkWell(
                    onTap: () {
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
                      "Don't have an account?",
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
      ),
    );
  }

  _userChoice(){
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
                onPressed: (){
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
                onPressed: (){
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