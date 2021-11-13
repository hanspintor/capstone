import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:proxpress/UI/CustomerUI/customer_wallet.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({Key key}) : super(key: key);

  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.red),
        title: Text('Top Up', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          int amount = (index + 1) * 200;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: ListTile(
                title: Text('\₱$amount', style: TextStyle(fontSize: 30),),
                onTap: () async {
                  dynamic result = await showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return PaymentOptionList(amount: amount); // PaymentOptionList(cart: _cart);
                    }
                  );

                  if (result != null) {
                    Navigator.pop(context, result);
                  }
                },
              ),
            ),
          );
        },
      )
    );
  }
}
