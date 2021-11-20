import 'package:flutter/material.dart';
import 'package:proxpress/services/auth.dart';


class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String alert = '';
  String email;
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close_rounded,
                    ),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 5),
                child:  Text("Reset Password",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Container(
                child: Text(
                  alert,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.green,
                    fontStyle: FontStyle.italic,
                  )  ,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5),
                child: TextFormField(
                    validator: (val) => val.isEmpty ? 'Email is Required': null,
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_rounded),
                    ),
                    onSaved: (String value) {
                      email = value;
                    },
                    onChanged: (val) {
                      setState(() => email = val);
                    }
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                height: MediaQuery.of(context).size.height / 15,
                width: MediaQuery.of(context).size.width / 1.3,
                child: ElevatedButton(
                  onPressed: () async {
                    _auth.ResetPassword(email);
                    setState(() {
                      alert = "Email Sent, check now your email";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),

                  child:  Text("Verify Email"),
                  ),
              ),
            ],
          ),
      ),
    );
  }
}