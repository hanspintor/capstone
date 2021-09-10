import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  String message = '';

  Widget _buildMessage() {
    return Container(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: InputDecoration(
                  filled: true,

                  hintText: 'Type your message',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 0),
                    gapPadding: 10,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onChanged: (value) => setState(() {
                  message = value;
                }),
              ),
            )
          ],
        )
    );
  }
  @override
  Widget build(BuildContext context) {

    // final FirebaseAuth _auth = FirebaseAuth.instance;
    // User user = _auth.currentUser;
    Delivery delivery = Delivery();
    // print("Delivery Id: ${delivery.uid}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
        actions: [
          IconButton(icon: Icon(
            Icons.help_outline,
          ),
            onPressed: (){
              showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text("Help"),
                      content: Text('nice'),
                      actions: [
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  }
              );
            },
            iconSize: 25,
          ),
        ],
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
      body: StreamBuilder<Delivery>(

        stream: DatabaseService(uid: delivery.uid).deliveryData,
          builder: (context,snapshot){
            if(snapshot.hasData){
              Delivery deliveryData = snapshot.data;
              return Text(deliveryData.courierRef.toString());
            }
            else{
              return Text("data");
            }
          }
      )
    );
  }
}
