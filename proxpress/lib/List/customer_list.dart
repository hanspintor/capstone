import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/models/customers.dart';

class CustomerList extends StatefulWidget {
  @override
  _CustomerListState createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  @override
  Widget build(BuildContext context) {
    final Customers = Provider.of<List<Customer>>(context);

    Customers.forEach((customer) {
      print(customer.fName);
      print(customer.lName);
      print(customer.email);
      print(customer.contactNo);
      print(customer.password);
      print(customer.address);
    });

    // return ListView.builder(
    //     itemCount: Customers.length,
    //     itemBuilder: (context, index){
    //       return DashboardLocation(customer: Customers);
    //     }
    // );
  }
}
