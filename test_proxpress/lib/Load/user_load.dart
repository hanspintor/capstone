import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class UserLoading extends StatelessWidget{
    @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red[400],
      child: Center(
        child: SpinKitDualRing(
          color: Colors.white,
          size: 50.0,
        ),
      ),
    );
  }


}