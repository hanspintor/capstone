import 'package:flutter/material.dart';
import 'menu_drawer.dart';
import 'notif_drawer.dart';

class CustomerRemarks extends StatefulWidget {
  @override
  _CustomerRemarksState createState() => _CustomerRemarksState();
}

class _CustomerRemarksState extends State<CustomerRemarks> {
  String _itemDescription;
  String _senderName;
  String _senderContactNum;
  String _receiverName;
  String _receiverContactNum;
  List<String> _whoCanPay = ['Sender', 'Receiver', 'You'];
  String _whoWillPay;
  String _specificInstructions;
  List<String> _paymentOptions = ['Gcash', 'PayMaya'];
  String _paymentOption;

  void _validate(){
    if(!locKey.currentState.validate()){
      return;
    }
    locKey.currentState.save();
    print (_itemDescription);
    print (_senderName);
    print (_senderContactNum);
    print (_receiverName);
    print (_receiverContactNum);
    print (_whoWillPay);
    print (_specificInstructions);
    print (_paymentOption);
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  Widget _alertmessage(){
    return null;
  }

  final GlobalKey<FormState> locKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Function to create a text field but modular for other variables
  Widget _buildTextField(String labelText, IconData icon, TextInputType textInputType, String error, dynamic textFieldInput){
    return Container(
      padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
      child: TextFormField(
        decoration: InputDecoration(labelText: labelText, prefixIcon: Icon(icon)),
        keyboardType: textInputType,
        validator: (String value){
          if(value.isEmpty){
            return error;
          }
        },
        onSaved: (String value){
          textFieldInput = value;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawerEnableOpenDragGesture: false,
        endDrawerEnableOpenDragGesture: false,
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
          actions: [
            IconButton(icon: Icon(
              Icons.notifications_none_rounded,
            ),
              onPressed: () {
                _openEndDrawer();
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
        drawer: MainDrawer(),
        endDrawer: NotifDrawer(),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: IconButton(icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                        onPressed: (){
                          Navigator.pop(context, false);
                        },
                        iconSize: 25,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Customer Remarks dae pa tapos",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.all(40),
                  child: Form(
                    key: locKey,
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTextField(
                              'Item Description',
                              Icons.production_quantity_limits,
                              TextInputType.text,
                              'Item description is required.',
                              _itemDescription
                          ),
                          _buildTextField(
                              'Sender Name',
                              Icons.person,
                              TextInputType.name,
                              'Sender name is required.',
                              _senderName
                          ),
                          _buildTextField(
                              'Sender Contact Number',
                              Icons.phone,
                              TextInputType.number,
                              'Sender contact number is required.',
                              _senderContactNum
                          ),
                          _buildTextField(
                              'Receiver name',
                              Icons.person,
                              TextInputType.name,
                              'Receiver name is required.',
                              _receiverName
                          ),
                          _buildTextField(
                              'Receiver Contact Number',
                              Icons.phone,
                              TextInputType.number,
                              'Receiver contact number is required.',
                              _receiverContactNum
                          ),
                          // Dapat dropdown ni para sa sender/receiver
                          _buildTextField(
                              'Who Will Pay',
                              Icons.production_quantity_limits,
                              TextInputType.name,
                              'Who will pay must be specified.',
                              _whoWillPay
                          ),
                          _buildTextField(
                              'Specific Instructions',
                              Icons.production_quantity_limits,
                              TextInputType.text,
                              'Item description is required.',
                              _itemDescription
                          ),
                          // Dapat dropdown ni gcash/paymaya
                          _buildTextField(
                              'Payment Option',
                              Icons.production_quantity_limits,
                              TextInputType.text,
                              'Item description is required.',
                              _itemDescription
                          ),
                        ],
                      ),
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  child: Text(
                    'Proceed',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(primary: Color(0xfffb0d0d)),
                  onPressed: () {
                    // _validate();

                  },
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        )
    );
  }
}