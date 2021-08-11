import 'package:flutter/material.dart';

class SignupCourier extends StatefulWidget{
  @override
  _SignupCourierState createState() => _SignupCourierState();
}

class _SignupCourierState extends State<SignupCourier> {
  String _fName;
  String _lName;
  String _contactNo;
  String _password;
  String _address;
  bool agree = false;

  void _validate(){
    if(!regKey.currentState.validate()){
      return;
    }
    regKey.currentState.save();

    print (_fName);
    print (_lName);
    print (_contactNo);
    print (_password);
    print (_address);
  }

  Widget _alertmessage(){
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: Text("A User is permitted to install the copy of PROXpress mobile application into their mobile device for use in the Philippines provided that User shall not use the software or the services for any illegal purposes. Other than the software license specified below, PROXpress is not hereby explicitly reserved any other license or right for the use or possession of the software. The following are the User shall not do:", textAlign: TextAlign.justify),
          ),
          Text("\u2022 Disrupt regular software operations or utilize any export or modification techniques to software source code."
              "\n \u2022 Download or send out viruses, worms, trojans or harmful programs of all types."
              "\n \u2022 Renting, leasing, sub-licensing or distributing to third parties copies of the Software or the Software license. "
              "\n \u2022 Modify, adapt, reverse engineer, decompile, disassemble, translate or generate software-based derivatives.", textAlign: TextAlign.justify),

          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text("A Customer shall agree to be bound by this contract of private transport of parcel, by the PROXpress, of the computing fees and charges of that particular request, and by its acceptance by the Courier of that request; hereby agree that it will be bound by the following private carriage of terms and conditions: ", textAlign: TextAlign.justify),
          ),

          Container(
            margin: EdgeInsets.only(top:20, right: 46),
            child: Text("1. Definitions and Interpretations", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text("a. The capitalized phrases used in this contract shall have the meaning given under the Terms and Conditions of the Customer and/or the Conditions of the Courier."
              "\nb. If the terms of this agreement are in disagreement with the Terms & Conditions of the Customer/Courier, this agreement governs rights, responsibilities and remedies between the Customer and Courier.", textAlign: TextAlign.justify),
          Container(
            margin: EdgeInsets.only(top:20),
            child: Text("2. Special Contact of Delivery of Parcel", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text("a. Once the Courier has accepted the request, this contract will take effect between the Customer and the Courier. "
              "\nb. Upon submission of the request, the Customer shall pay the Courier according to the agreed method of payment chosen in the Software. "
              "\nc. It should be clearly understood that the contract covers only the exclusive delivery of parcels and does not apply to transportation of persons. "
              "\nd. The Customer is responsible for paying an additional fee if cash on delivery is chosen as a mode of payment based on the agreement of Courier and Customer.  Since a Courier shall travel again to that point of delivery for the payment if the Customer requests a delivery of parcel into a different location or person. If an online payment method is chosen, the Customer shall pay the regular service fee of the delivery according to the agreement of both users.", textAlign: TextAlign.justify),
          Container(
            margin: EdgeInsets.only(top:20),
            child: Text("3. Courier Warranties; Duties and Obligations", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text("a. The Courier guarantees that he/she is a duly licensed driver in compliance with Philippine laws as well as a registered wonder of the delivery vehicle or authorized driver to be utilized in this agreement."
              "\nb. In accordance with this contract, the Courier promises to carry out the private carrier's personal duties and obligations."
              "\nc. The Courier shall provide and guarantee to the Customer, in accordance with the instructions of the Courier stated in the delivery request, that he/she has the necessary expertise, appropriate delivery parcel and adequate property to provide delivery services under this contract."
              "\nd. The Courier accepts that it is permissible for the Customer to report on PROXpress for any violation of the present agreement, upon due enquiry by him/her, may be penalized for breaking the conditions of the present agreement, as a result of which he/she may be excluded from the system or deletion of his/her PROXpress courier account."
              "\ne. The Courier must always have pocket money in case of Customer request for delivery of food. Which means Courier is responsible for buying that particular food in their own money based on both users agreement. "
              "\nf. The Courier shall reject any shipments which are banned or appear to be detrimental to the Courier or the delivery vehicle, dangerous or hazardous material or radioactive materials, by law or that appear harmful. "
              "\ng. The Courier will take reasonable efforts to supply the shipment as directed by the Customer as well as the expected time of arrival. The Courier shall not be liable for any delay in delivery thereof for whatever reasons, unless the delay is directly caused by the Courier gross negligence or fault. "
              "\nh. The Courier cannot accept any responsibility for any loss or losses originating from or related to breaches of warranties and duties under or in connection with Customer as specified in the Terms and Conditions of the Customer or in this agreement. "
              "\ni. The Courier shall exert care to deliver the request of the Customer. It shall take reasonable care not to let unauthorized people interrupt the delivery request. He/she takes appropriate precautions against loss or damage during the transit of the delivery. "
              "\nj. The Courier must take responsibility for accepting the delivery request of the Customer. He/she must not do any sorts of activities if the request is accepted, the Courier must automatically comply with the Customer request based on their agreement.", textAlign: TextAlign.justify),
          Container(
            margin: EdgeInsets.only(top:20),
            child: Text("4. Customer’s Warranties; Duties and Obligations", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text("a. The Customer shall guarantee that under Philippine law he or she has the legal ability to enter this contract."
              "\nb. The Customer shall accept in a convincing manner that the Courier delivery services are subject to this contract. "
              "\nc. The Customer recognizes and accepts that the Courier is a private carrier and not a public service or a common carrier and thus no rules relating to a public service or a public carrier do not apply to this agreement."
              "\nd. The Customer guarantees that the delivery requests have been submitted with full and accurate information such as the descriptive parcel of the shipment and its choice of the type of delivery vehicle, supplementary service provided and, where appropriate, software instructions to handle the delivery, and consents that the Courier may rely on the information provided in the Customer."
              "\ne. The Customer must guarantee that he/she is either the owner or the authorized representative of the owner of this delivery and is authorized not only by himself, but also as the agent and the agent on behalf of, the owner of the delivery, to engage into this agreement."
              "\nf. The Customer shall ensure that all laws and rules regarding the nature, condition, packaging, management, storage and carriage of the delivery have been complied with. Customers should never send items forbidden or damaging to a Participating Driver or delivery vehicle by law, unsafe or dangerous chemicals or radioactive materials."
              "\ng. In order to safeguard against harm during transportation, the Customer is completely responsible to ensure the shipment is appropriately packaged. The delivery of parcels are poorly packaged if they appear to have been taken without the case, wrapper or container or if the seal or wrapping of the delivery items in the shipment is damaged or broken. It is definitely believed that."
              "\nh. The Customer acknowledges that the Courier is not obligated to open and examine the parcel and that the Courier does not bear any obligation to or legal liability arising from the transit of the delivery."
              "\ni. The Customer shall be responsible for any loss or damage that may come from breach of this agreement by the Courier."
              "\nj. The Customer agrees and undertakes to compensate the Courier against any and all assessments of, liabilities, claims, suits, claims, damages and judgements, fees, fines, fines, interest, and expenses of any kind which may be suffered by or related to transport to the delivery by a Courier  at the request of the Customer.", textAlign: TextAlign.justify),
          Container(
            margin: EdgeInsets.only(top:20, right: 160),
            child: Text("5. Miscellaneous", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text("a. Entire agreement. Both parties accept and agree to be bound by the terms of this agreement and to agree that, together with the terms of that delivery request and to be the exclusive and complete declaration in respect of the subject matter of the agreement between the parties hereof, this agreement is to supersede all proposals and other communications irrespective of whether or not the party has read this agreement. Any party that is not included in this agreement, and neither party shall be obliged or accountable for any representation, promise or incitement otherwise not mentioned in this contract, made any representation, promise or induction."
              "\nb. Governing Law. In line with the laws of the Philippines, this contract is regulated and interpreted."
              "\nc. Severability. If any provision of this Contract is invalid or becoming illegal or non-performing, the remaining provisions shall remain in full force and effect, and a valid, legal and enforceable provision which shall be as similar as possible to the economic and business aims intended by the parties shall be replaced by the invalid, illegal or unperforming provision."
              "\nd. Courier’s Limited Liability.  Couriers liability to the Customer for loss or destruction of the Shipment shall be limited to One Thousand Five Hundred Pesos (PHP 1,500) for delivery where is through motorcycle and Three Thousand Pesos (PHP 3,000) for delivery where is through a 4-wheeled vehicle. The Customer shall bear the risk of loss if he/she requests the delivery services with a value of exceeding this amount. Any claims for any loss or destruction of the parcel by the Courier must, within a period of  two (2) days of the calendar day, be made by the Courier, if the delivery is in the possession of the Courier and ten (10) calendar days if not in the possession of the Courier for delivery. A claim lodged by the Customer after 10 days shall be regarded to have been waived. The Customer and Courier acknowledge that PROXpress is not a part of these delivery services and consequently shall, for any reason whatsoever, be not liable for any loss of or damage to the delivery.", textAlign: TextAlign.justify),

          Container(
            margin: EdgeInsets.only(left: 200, top: 30),
            width: MediaQuery.of(context).size.width / 7,
            child:FlatButton(
                child: Text(
                  'OK', style: TextStyle(color: Colors.white, fontSize:15),
                ),
                color: Color(0xffA82A2A),
                onPressed: (){
                  Navigator.pop(context, false);
                }
            ),
          ),
        ],
      ),
    );
  }

  final GlobalKey<FormState> regKey = GlobalKey<FormState>();

  Widget _buildFName(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'First Name'),
      validator: (String value){
        if(value.isEmpty){
          return 'First Name is Required';
        }
      },
      onSaved: (String value){
        _fName = value;
      },
    );
  }

  Widget _buildLName(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Last Name'),
      validator: (String value){
        if(value.isEmpty){
          return 'Last Name is Required';
        }
      },
      onSaved: (String value){
        _lName = value;
      },
    );
  }

  Widget _buildContactNo(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Contact Number'),
      maxLength: 11,
      validator: (String value){
        if(value.isEmpty){
          return 'Contact Number is Required';
        }
      },
      onSaved: (String value){
        _contactNo = value;
      },
    );
  }

  Widget _buildPassword(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Password'),
      obscureText: true,
      validator: (String value){
        if(value.isEmpty){
          return 'Password is Required';
        }
      },
      onSaved: (String value){
        _password = value;
      },
    );
  }

  Widget _buildAddress(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Home Address'),
      keyboardType: TextInputType.streetAddress,
      validator: (String value){
        if(value.isEmpty){
          return 'Home Address is Required';
        }
      },
      onSaved: (String value){
        _address = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
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
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Row(
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
                    Container(
                      margin: EdgeInsets.only(left: 50),
                      child: Text(
                        "Courier Registration",
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.all(50),
                  child: Form(
                    key: regKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _buildFName(),
                        _buildLName(),
                        _buildContactNo(),
                        _buildPassword(),
                        _buildAddress(),
                        Row(
                          children: [
                            Container (
                              child: Checkbox(
                                  value: agree,
                                  onChanged: (value){
                                    setState(() {
                                      agree = value;
                                    });
                                  }
                              ),
                            ),
                            Container(
                              child: Text(
                                  'I do accept the '
                              ),
                            ),
                            Container(
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context, builder: (BuildContext context) => AlertDialog(
                                    title: Text('Terms and Conditions', style: TextStyle(fontWeight: FontWeight.bold)),
                                    content: (_alertmessage()),
                                  )
                                  );
                                },
                                child: Text(
                                  "Terms and Conditions",
                                  style: TextStyle(
                                    color: Color(0xffFD3F40),
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        RaisedButton(
                          child: Text(
                            'Signup', style: TextStyle(color: Colors.white, fontSize:18),
                          ),
                          color: Color(0xffA82A2A),
                          onPressed: agree ? _validate : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}