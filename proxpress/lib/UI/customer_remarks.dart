import 'package:flutter/material.dart';

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
  String _paymentOption = 'Choose Payment Option';
  List<String> _onlinePaymentOptions = ['Gcash', 'PayMaya'];

  bool buttonState = true;

  void _buttonChange() {
    setState(() {
      buttonState = !buttonState;
    });
  }
  
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
              Icons.help_outline,
            ),
              onPressed: () {
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
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "Courier Remarks",
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
                              Icons.person_search,
                              TextInputType.name,
                              'Who will pay must be specified.',
                              _whoWillPay
                          ),
                          _buildTextField(
                              'Specific Instructions',
                              Icons.integration_instructions_outlined,
                              TextInputType.text,
                              'Item description is required.',
                              _itemDescription
                          ),
                          // Dapat dropdown ni gcash/paymaya
                          _buildTextField(
                              'Payment Option',
                              Icons.payments_outlined,
                              TextInputType.text,
                              'Item description is required.',
                              _itemDescription
                          ),
                          DropdownButton<String>(
                            value: _paymentOption,
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            underline: Container(
                              height: 2,
                              color: Colors.black,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                _paymentOption = newValue;
                              });
                            },
                            items: <String>['Choose Payment Option', 'Cash on Delivery', 'Online Payment']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          Text(
                            "Online Payment Options",
                            style: TextStyle(fontSize: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: buttonState ? _buttonChange : null,
                                    child: Text(
                                      "Gcash",
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: buttonState ? null : _buttonChange,
                                    child: Text(
                                      "Paymaya",
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                )
                              ],
                            ),
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
                    'Send Remarks',
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