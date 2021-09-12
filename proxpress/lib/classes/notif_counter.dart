import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/deliveries.dart';


class NotifCounter extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  NotifCounter({
    Key key,
    @required this.scaffoldKey,
  }) : super(key: key);

  @override
  _NotifCounterState createState() => _NotifCounterState();
}

class _NotifCounterState extends State<NotifCounter> {
  void _openEndDrawer() {
    widget.scaffoldKey.currentState.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final delivery = Provider.of<List<Delivery>>(context);
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded),
          onPressed: (){
            _openEndDrawer();
          },
          iconSize: 25,
        ),
        Container(
          margin: EdgeInsets.only(left: 25, top: 5),
          height: 20,
          width: 30,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red
          ),
          child: Center(
            child: Text(
              delivery.length.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        )
      ],
    );
  }
}
