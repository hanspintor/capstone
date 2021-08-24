import 'package:proxpress/UI/dashboard_location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/authenticate.dart';

class Wrapper extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    if(user == null){
      return Authenticate();
    } else{
      return DashboardLocation();
    }
  }
}
