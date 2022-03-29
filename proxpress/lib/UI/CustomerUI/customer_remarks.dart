import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/UI/CustomerUI/review_request.dart';

class CustomerRemarks extends StatefulWidget {
  final String courierUID;
  final String pickupAddress;
  final GeoPoint pickupCoordinates;
  final String dropOffAddress;
  final GeoPoint dropOffCoordinates;
  final int deliveryFee;

  CustomerRemarks({
    Key key,
    @required this.courierUID,
    @required this.pickupAddress,
    @required this.pickupCoordinates,
    @required this.dropOffAddress,
    @required this.dropOffCoordinates,
    @required this.deliveryFee,
  }) : super(key: key);

  @override
  _CustomerRemarksState createState() => _CustomerRemarksState();
}

class _CustomerRemarksState extends State<CustomerRemarks> {
  String itemDescription;
  int itemWeight;
  String pickupPointPerson;
  TextEditingController textPickupPointPerson = TextEditingController();
  String pickupContactNum;
  TextEditingController textPickupContactNum = TextEditingController();
  String dropoffPointPerson;
  TextEditingController textDropoffPointPerson = TextEditingController();
  String dropoffContactNum;
  TextEditingController textDropoffContactNum = TextEditingController();
  String whoWillPay = 'Who Will Pay';
  String specificInstructions;
  String paymentOption = 'Choose Payment Option';
  List<String> optionsCustomerIsPickUp = ['Me', 'Drop-off Point Person',];
  List<String> optionsCustomerIsDropOff = ['Pick-up Point Person', 'Me',];
  List<String> optionsCustomerNotBoth = ['Pick-up Point Person', 'Drop-off Point Person', 'Me'];
  String onlinePayment = '';

  int currentStep = 0;
  int step = 0;

  bool customerIsPickUp = false;
  bool customerIsDropOff = false;

  final GlobalKey<FormState> locKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<GlobalKey<FormState>> formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>(),];

  Widget _buildItemDescription() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Item Description'),
        keyboardType: TextInputType.text,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Item description is required.';
          }
          else if(value.length < 3){
            return 'Item description should be more than 3 characters';
          }
          else return null;
        },
        onSaved: (String value) {
          itemDescription = value;
        },
        onChanged: (String value) {
          setState(() => itemDescription = value);
        },
      ),
    );
  }
  Widget _buildItemWeight() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Item Weight',
          hintText: "Weight should be in kg",
          hintStyle: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 14
          ),
        ),
        keyboardType: TextInputType.number,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Item weight is required.';
          }
          else if(int.parse(value) <= 0){
            return 'Item weight should not be less than or equal to 0';
          }
          else return null;
        },
        onSaved: (String value) {
          itemWeight = int.parse(value);
        },
        onChanged: (String value) {
          setState(() => itemWeight = int.parse(value));
        },
      ),
    );
  }
  Widget _buildSenderName() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: TextFormField(
        controller: textPickupPointPerson,
        decoration: InputDecoration(labelText: 'Name'),
        keyboardType: TextInputType.name,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Pick up point person is required.';
          }
          else return null;
        },
        onSaved: (String value) {
          pickupPointPerson = value;
        },
        onChanged: (String value) {
          setState(() => pickupPointPerson = value);
        },
      ),
    );
  }

  Widget _buildSenderContactNum() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: TextFormField(
        controller: textPickupContactNum,
        maxLength: 11,
        decoration: InputDecoration(labelText: 'Contact Number'),
        keyboardType: TextInputType.number,
        validator: (String value) {
          String temp = value.substring(0,2);
          if (value.length < 11 && value.length > 0) {
            return 'Pick up contact number should be 11 digits.';
          }
          else if(temp != "09" && temp != "08"){
            return 'Contact number should start with 09/08';
          }
          else if (value.isEmpty) {
            return 'Pick up contact number is required.';
          }
          else return null;
        },
        onSaved: (String value) {
          pickupContactNum = value;
        },
        onChanged: (String value) {
          setState(() => pickupContactNum = value);
        },
      ),
    );
  }

  Widget _buildReceiverName() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: TextFormField(
        controller: textDropoffPointPerson,
        decoration: InputDecoration(labelText: 'Name'),
        keyboardType: TextInputType.name,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Drop off point person is required.';
          }
          else return null;
        },
        onSaved: (String value) {
          dropoffPointPerson = value;
        },
        onChanged: (String value) {
          setState(() => dropoffPointPerson = value);
        },
      ),
    );
  }

  Widget _buildReceiverContactNum() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: TextFormField(
        controller: textDropoffContactNum,
        maxLength: 11,
        decoration: InputDecoration(labelText: 'Contact Number'),
        keyboardType: TextInputType.number,
        validator: (String value) {
          String temp = value.substring(0,2);
          if (value.length < 11 && value.length > 0) {
            return 'Drop off contact number should be 11 digits.';
          }
          else if(temp != "09" && temp != "08"){
            return 'Contact number should start with 09/08';
          }
          else if (value.isEmpty) {
            return 'Drop off contact number is required.';
          }
          else return null;
        },
        onSaved: (String value) {
          dropoffContactNum = value;
        },
        onChanged: (String value) {
          setState(() => dropoffContactNum = value);
        },
      ),
    );
  }

  Widget _buildWhoWillPay() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: DropdownButtonFormField<String>(
        validator: (String value) {
          if (value == 'Who Will Pay') {
            return 'Please choose who will pay.';
          } else if (value == null) {
            return 'Please choose who will pay.';
          }
          else return null;
        },
        decoration: InputDecoration(labelText: 'Who Will Pay'),
        elevation: 16,
        onChanged: (String newValue) {
          setState(() {
            whoWillPay = null;
            whoWillPay = newValue;
          });
        },
        onSaved: (String value) {
          whoWillPay = value;
        },
        items: optionsCustomerNotBoth.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpecificInstructions() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: TextFormField(
        maxLines: null,
        maxLength: 200,
        decoration: InputDecoration(labelText: 'Specific Instructions'),
        keyboardType: TextInputType.text,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Item description is required.';
          }
          else return null;
        },
        onSaved: (String value) {
          specificInstructions = value;
        },
        onChanged: (String value) {
          setState(() => specificInstructions = value);
        },
      ),
    );
  }

  Widget _buildDropDown() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: DropdownButtonFormField<String>(
        validator: (String value) {
          if (value == 'Choose Payment Option') {
            return 'Please choose a payment option.';
          } else if (value == null) {
            return 'Please choose a payment option.';
          } else if (value == 'Cash on Delivery' && !customerIsPickUp && !customerIsDropOff && whoWillPay == 'Me') {
            return 'You are not in the pick-up or drop-off location.';
          }
          else return null;
        },
        decoration: InputDecoration(labelText: 'Payment Option'),
        elevation: 16,
        onChanged: (String newValue) {
          setState(() {
            paymentOption = newValue;
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

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    DocumentReference customer;
    if (user != null) {
      customer = FirebaseFirestore.instance.collection('Customers').doc(user.uid);
    }
    DocumentReference courier = FirebaseFirestore.instance.collection('Couriers').doc(widget.courierUID);

    GeoPoint pickupGeoPoint = GeoPoint(widget.pickupCoordinates.latitude, widget.pickupCoordinates.longitude);
    GeoPoint dropOffGeoPoint = GeoPoint(widget.dropOffCoordinates.latitude, widget.dropOffCoordinates.longitude);

    final isLastStep = currentStep == getSteps(user.uid).length - 1;

    return Scaffold(
        drawerEnableOpenDragGesture: false,
        endDrawerEnableOpenDragGesture: false,
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
          actions: [
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
                Stepper(
                  type: StepperType.vertical,
                  steps: getSteps(user.uid),
                  currentStep: currentStep,
                  physics: NeverScrollableScrollPhysics(),
                  controlsBuilder: (context, ControlsDetails) {
                    return Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (isLastStep) {
                                  if (formKeys[currentStep].currentState.validate()) {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            child: ReviewRequest(
                                                customer: customer,
                                                courier: courier,
                                                pickupAddress: widget.pickupAddress,
                                                pickupGeoPoint: pickupGeoPoint,
                                                dropOffAddress: widget.dropOffAddress,
                                                dropOffGeoPoint: dropOffGeoPoint,
                                                itemDescription: itemDescription,
                                                itemWeight: itemWeight,
                                                pickupPointPerson: pickupPointPerson,
                                                pickupContactNum: pickupContactNum,
                                                dropOffPointPerson: dropoffPointPerson,
                                                dropOffContactNum: dropoffContactNum,
                                                whoWillPay: whoWillPay,
                                                specificInstructions: specificInstructions,
                                                paymentOption: paymentOption,
                                                deliveryFee: widget.deliveryFee),
                                            type: PageTransitionType.bottomToTop
                                        )
                                    );
                                  }
                                } else {
                                  if (formKeys[currentStep].currentState.validate()) {
                                    setState(() => currentStep += 1);
                                  }
                                }
                              },
                              child: Text(isLastStep ? 'PROCEED' : 'NEXT'),
                            ),
                          ),
                          const SizedBox(width: 12,),
                          if (currentStep != 0)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    if (currentStep == 0) {
                                      return null;
                                    }
                                    else currentStep -= 1;
                                  });
                                  print(whoWillPay);
                                },
                                child: Text('BACK'),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        )
    );
  }

  List<Step> getSteps(String uid) => [
    Step(
      state: currentStep > 0 ? StepState.complete: StepState.indexed,
      isActive: currentStep >= 0,
      title: Text('Item Description'),
      content: Form(
        key: formKeys[0],
        child: Column(
          children: [
            _buildItemDescription(),
            _buildItemWeight(),
          ],
        ),
      ),
    ),
    Step(
      state: currentStep > 1 ? StepState.complete: StepState.indexed,
      isActive: currentStep >= 1,
      title: Text('Pick-up Point Person'),
      content: Form(
        key: formKeys[1],
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: customerIsPickUp ? BorderSide(color: Colors.red) : BorderSide(color: Colors.grey),
                    ),
                    onPressed: () async {
                      String name = '';
                      String num = '';

                      await FirebaseFirestore.instance
                          .collection('Customers')
                          .doc(uid)
                          .get()
                          .then((DocumentSnapshot documentSnapshot) {
                        if (documentSnapshot.exists) {
                          name = "${documentSnapshot['First Name']} ${documentSnapshot['Last Name']}";
                          num = documentSnapshot['Contact No'];
                        }
                      });

                      setState(() {
                        textPickupPointPerson.text = name;
                        textPickupContactNum.text = num;
                        pickupPointPerson = textPickupPointPerson.text;
                        pickupContactNum = textPickupContactNum.text;
                        customerIsPickUp = true;
                      });
                    },
                    child: Text('ME', style: TextStyle(color: customerIsPickUp ? Colors.red : Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12,),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: !customerIsPickUp ? BorderSide(color: Colors.red) : BorderSide(color: Colors.grey),
                    ),
                    onPressed: () {
                      setState(() {
                        textPickupPointPerson.text = '';
                        textPickupContactNum.text = '';
                        customerIsPickUp = false;
                      });
                    },
                    child: Text('OTHER', style: TextStyle(color: !customerIsPickUp ? Colors.red : Colors.grey)),
                  ),
                ),
              ],
            ),
            _buildSenderName(),
            _buildSenderContactNum(),
          ],
        ),
      ),
    ),
    Step(
      state: currentStep > 2 ? StepState.complete: StepState.indexed,
      isActive: currentStep >= 2,
      title: Text('Drop-off Point Person'),
      content: Form(
        key: formKeys[2],
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: customerIsDropOff ? BorderSide(color: Colors.red) : BorderSide(color: Colors.grey),
                    ),
                    onPressed: () async {
                      String name = '';
                      String num = '';

                      await FirebaseFirestore.instance
                          .collection('Customers')
                          .doc(uid)
                          .get()
                          .then((DocumentSnapshot documentSnapshot) {
                        if (documentSnapshot.exists) {
                          name = "${documentSnapshot['First Name']} ${documentSnapshot['Last Name']}";
                          num = documentSnapshot['Contact No'];
                        }
                      });

                      setState(() {
                        textDropoffPointPerson.text = name;
                        textDropoffContactNum.text = num;
                        dropoffPointPerson = textDropoffPointPerson.text;
                        dropoffContactNum = textDropoffContactNum.text;
                        customerIsDropOff = true;
                      });
                    },
                    child: Text('ME', style: TextStyle(color: customerIsDropOff ? Colors.red : Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12,),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: !customerIsDropOff ? BorderSide(color: Colors.red) : BorderSide(color: Colors.grey),
                    ),
                    onPressed: () {
                      setState(() {
                        textDropoffPointPerson.text = '';
                        textDropoffContactNum.text = '';
                        customerIsDropOff = false;
                      });
                    },
                    child: Text('OTHER', style: TextStyle(color: !customerIsDropOff ? Colors.red : Colors.grey)),
                  ),
                ),
              ],
            ),
            _buildReceiverName(),
            _buildReceiverContactNum(),
          ],
        ),
      ),
    ),
    Step(
      state: currentStep > 3 ? StepState.complete: StepState.indexed,
      isActive: currentStep >= 3,
      title: Text('Additional Information'),
      content: Form(
        key: formKeys[3],
        child: Column(
          children: [
            _buildWhoWillPay(),
            _buildSpecificInstructions(),
          ],
        ),
      ),
    ),
    Step(
      state: currentStep > 4 ? StepState.complete: StepState.indexed,
      isActive: currentStep >= 4,
      title: Text('Payment Option'),
      content: Form(
        key: formKeys[4],
        child: Column(
          children: [
            _buildDropDown(),
          ],
        ),
      ),
    ),
  ];
}