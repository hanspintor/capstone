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
  int val = -1;

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
          else return null;
        },
        onSaved: (String value){
          textFieldInput = value;
        },
      ),
    );
  }
  Widget _buildDropDown(){
    return SizedBox(
      width: 270,
      child: DropdownButton<String>(
        hint: Row(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Icon(Icons.payment_rounded),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(12, 0, 0, 0),
              child: Text('Payment Options'),
            ),
          ],
        ),
        iconSize: 20,
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
        items: <String>['Cash on Delivery', 'Online Payment']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRadioPayment(){
    return Column(
      children: [
        ListTile(
          title: Container(
            child: Row(
              children: [
                Image.asset("assets/gcash.png", height: 50, width: 50,),
                Text("GCash"),
              ],
            ),
          ),
          leading: Radio(
            value: 1,
            groupValue: val,
            onChanged: (value) {
              setState(() {
                val = value;
              });
            },
            activeColor: Color(0xfffb0d0d),
          ),
        ),
        ListTile(
          title: Container(
            child: Row(
              children: [
                Container(margin: EdgeInsets.fromLTRB(10, 0, 0, 0), child: Image.asset("assets/paymaya.png", height: 25, width: 25,)),
                Container(margin: EdgeInsets.fromLTRB(15, 0, 0, 0),child: Text("Paymaya")),
              ],
            ),
          ),
          leading: Radio(
            value: 2,
            groupValue: val,
            onChanged: (value) {
              setState(() {
                val = value;
              });
            },
            activeColor: Color(0xfffb0d0d),
          ),
        ),
      ],
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
                        "Customer Remarks",
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
                          _buildDropDown(),
                          _paymentOption == 'Online Payment' ? _buildRadioPayment() : SizedBox(height: 30),
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