import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/forgot_password.dart';
import 'package:proxpress/UI/reg_landing_page.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/services/auth.dart';

class LoginScreen extends StatefulWidget{

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

Widget _alertmessage(){
  return ForgotPassword();
}



class _LoginScreenState extends State<LoginScreen> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String contactNo = '';
  String password = '';
  String error = '';
  bool loading = false;


  Widget _buildUsername(){
    return TextFormField(
        autofillHints: [AutofillHints.email],
        validator: (val) => val.isEmpty ? 'Phone number / Email is Required': null,
        decoration: InputDecoration(
          labelText: "Phone number / Email",
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
        print("Back Button pressed");
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Image.asset(
                  "assets/PROExpress-logo.png",
                  height: 250,
                  width: 250,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
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
                  ],
                ),
              ),
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
            ],
          ),
        ),
      ),
    );
  }
}