import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';

class RatedCourierTile extends StatefulWidget {
  final Delivery delivery;

  RatedCourierTile({
    Key key,
    @required this.delivery
  }) : super(key: key);

  @override
  State<RatedCourierTile> createState() => _RatedCourierTileState();
}

class _RatedCourierTileState extends State<RatedCourierTile> {
  GlobalKey<FormState> _feedbackKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    return user == null ? LoginScreen() : StreamBuilder<Delivery>(
      stream: DatabaseService(uid: widget.delivery.uid).deliveryData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          int rating = widget.delivery.rating;
          String feedback = widget.delivery.feedback;

          if (widget.delivery.rating != 0 && widget.delivery.feedback != "") {
            return Padding(
              padding: const EdgeInsets.all(0),
              child: StreamBuilder<Courier>(
                stream: DatabaseService(uid: widget.delivery.courierRef.id).courierData,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Courier courier = snapshot.data;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: ListTile(
                          title: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('${courier.fName} ${courier.lName}')
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: Icon(Icons.edit, color: Colors.red,),
                                      onPressed: () {
                                        showFeedback(widget.delivery);
                                      },
                                    ),
                                  )
                                ],
                              ),
                              Divider(
                                color: Colors.grey,
                                thickness: .5,
                              ),
                            ],
                          ),
                          subtitle: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < rating ? Icons.star : Icons.star_border, color: Colors.amber,
                                  );
                                }),
                              ),
                              SizedBox(height: 10,),
                              Text(feedback, style: TextStyle(color: Colors.black)),
                              SizedBox(height: 10,),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }
              ),
            );
          }
          return Container();
        } else {
          return Container();
        }
      },
    );
  }

  double rating = 0.0;
  String feedback  = '';
  bool starsTapped = false;

  void showFeedback(Delivery delivery) {
    showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) => Container(
        child: ListTile(
          title: Row(
            children: [
              Text('How\'s My Service?'),
            ],
          ),
          subtitle: Form(
            key: _feedbackKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10,),
                RatingBar.builder(
                  minRating: 1,
                  itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber,),
                  updateOnDrag: true,
                  onRatingUpdate: (rating) => setState(() {
                    starsTapped = true;
                    this.rating = rating;
                  }),
                ),
                Text('Rate Me',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                TextFormField(
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Feedback is required.';
                    }
                    else if(value.length < 3){
                      return 'Feedback should be more than 3 characters';
                    }
                    else return null;
                  },
                  maxLines: 2,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'Leave a Feedback',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.multiline,
                  onChanged: (val) => setState(() => feedback = val),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                        child: Text('OK'),
                        onPressed: () async{
                          if (_feedbackKey.currentState.validate() && starsTapped) {
                            await DatabaseService(uid: delivery.uid).updateRatingFeedback(rating.toInt(), feedback);
                            Navigator.pop(context);
                            showToast('Feedback Sent');
                          } else {
                            showToastRed('You must tap how many stars.');
                          }
                        }
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

  Future showToast(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.green, textColor: Colors.white);
  }

  Future showToastRed(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.red, textColor: Colors.white);
  }
}