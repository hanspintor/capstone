import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lottie/lottie.dart';

class DeliveryStatus extends StatefulWidget {
  @override
  _DeliveryStatusState createState() => _DeliveryStatusState();
}

class _DeliveryStatusState extends State<DeliveryStatus> {
  double rating = 0;

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
        // child: Column(
        //   children: [
        //     Container(
        //       margin: EdgeInsets.fromLTRB(0, 20, 40, 10),
        //         child: Lottie.asset('assets/delivery.json')
        //     ),
        //     Row(
        //       children: [
        //         Container(
        //           margin: EdgeInsets.fromLTRB(50, 0, 0, 10),
        //           child: Text('Delivery in Progress',
        //             style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        //           ),
        //         ),
        //         Container(
        //           margin: EdgeInsets.only(top: 6),
        //           child: SizedBox(
        //             height: 50,
        //               width: 50,
        //               child: Lottie.asset('assets/dots.json')
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text('Delivered',
                style: TextStyle(fontSize: 50),
              ),
            ),
            ElevatedButton(
              child: Text(
                'Send Feedback',
                style:
                TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                  primary: Color(0xfffb0d0d)),
              onPressed: () => showFeedback(),
            ),
            //SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
  //shows the alert dialog for sending a feedback to the courier's service
  void showFeedback() => showDialog(
    context : context,
    builder: (context) => AlertDialog(
      title: Text('How\'s My Service?'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            minRating: 1,
            itemBuilder: (context, _) => Icon(Icons.star, color: Color(0xfffb0d0d)),
            updateOnDrag: true,
            onRatingUpdate: (rating) => setState((){
              this.rating = rating;
            }),
          ),
          Text('Rate Me',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10),
          TextFormField(
            maxLines: 2,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Leave a Feedback',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.multiline,
          ),
          //SizedBox(height: 10),
        ],
      ),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.pop(context);
          }
        ),
      ],
    ),
  );
}
