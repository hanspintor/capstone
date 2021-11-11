import 'package:flutter/material.dart';
import 'package:proxpress/database.dart';
import 'package:proxpress/delivery_prices.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth.dart';

class DeliveryPriceTile extends StatefulWidget {
  final DeliveryPrice deliveryPrice;

  DeliveryPriceTile({this.deliveryPrice});

  @override
  _DeliveryPriceTileState createState() => _DeliveryPriceTileState();
}
class _DeliveryPriceTileState extends State<DeliveryPriceTile> {
  bool editPressed = false;

  int baseFare = 0;
  int farePerKM = 0;

  final GlobalKey<FormState> priceKey = GlobalKey<FormState>();

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Form(
        key: priceKey,
        child: Table(
          border: TableBorder.all(),
          children: [
            TableRow(
              children: [
                Align(child: Text("${widget.deliveryPrice.vehicleType}")),
                Align(
                  child: editPressed ? TextFormField(
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "${widget.deliveryPrice.baseFare}",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black
                      ),
                    ),
                    validator: (String val){
                      if(val.isEmpty){
                        return null;
                      }
                      else if (!isNumeric(val)){
                        return 'Please Enter an Integer';
                      }
                      else
                        return null;
                    },
                    onSaved: (val) => setState(() => baseFare = int.parse(val)),
                  ) : Text("₱${widget.deliveryPrice.baseFare}")
                ),
                Align(
                    child: editPressed ? TextFormField(
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "${widget.deliveryPrice.farePerKM}",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black
                        ),
                      ),
                      validator: (String val){
                        if(val.isEmpty){
                          return null;
                        }
                        else if (!isNumeric(val)){
                          return 'Please Enter an Integer';
                        }
                        else
                          return null;
                      },
                      onSaved: (val) => setState(() => farePerKM = int.parse(val)),
                    ) : Text("₱${widget.deliveryPrice.farePerKM}/KM")
                ),
                Align(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: EdgeInsets.all(10),
                        child: ElevatedButton.icon(
                          onPressed: editPressed ? () async {
                            if (priceKey.currentState.validate()) {
                              priceKey.currentState.save();
                              //await DatabaseService(uid: widget.deliveryPrice.uid).updateDeliveryPrice(baseFare, farePerKM);
                              setState((){
                                editPressed = false;
                              });
                            }
                          } : () {
                            setState((){
                              editPressed = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          ),
                          icon: Icon(editPressed ? Icons.save : Icons.edit),
                          label: Text(
                            editPressed ? "Update" : "Edit",
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}