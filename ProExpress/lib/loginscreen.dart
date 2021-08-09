import 'package:flutter/material.dart';
import 'signup_consignee.dart';
class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
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
                margin: EdgeInsets.symmetric(vertical: 50),
                child: Column(
                  children: [
                    Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 50,
                      ),
                    ),
                    Divider(
                      color: Color(0xffFD3F40),
                      thickness: 5,
                      indent: 120,
                      endIndent: 120,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 50,),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Email Address",
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 50,),
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 70),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(builder: (context) => new SignupConsignee()));
                  },
                  child: Text(
                    "Need an Account?",
                    style: TextStyle(
                      color: Color(0xffFD3F40),
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10, top: 90),
                child: Divider(
                  thickness: 5,
                  color: Colors.black,
                  indent: 190,
                  endIndent: 190,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 0),
                //margin: EdgeInsets.only(top: 190),
                height: MediaQuery.of(context).size.width / 8,
                width: MediaQuery.of(context).size.width / 1.1,
                child: FlatButton(
                  onPressed: () {},

                  color: Color(0xffA82A2A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    "Login",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18
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