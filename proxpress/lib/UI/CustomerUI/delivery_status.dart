import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DeliveryStatus extends StatefulWidget {
  @override
  _DeliveryStatusState createState() => _DeliveryStatusState();
}

class _DeliveryStatusState extends State<DeliveryStatus> {
  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(right: 40),
                child: Lottie.asset('assets/delivery.json')
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(50, 0, 0, 10),
                  child: Text('Delivery in Progress',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 6),
                  child: SizedBox(
                    height: 50,
                      width: 50,
                      child: Lottie.asset('assets/dots.json')
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: ElevatedButton.icon(
                label: Text('Message Courier'),
                icon: Icon(Icons.message_outlined),
                style : ElevatedButton.styleFrom(primary: Color(0xfffb0d0d)),
                onPressed: (){
                  Navigator.pushNamed(context, '/chatPage');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
