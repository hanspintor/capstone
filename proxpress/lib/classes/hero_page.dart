import 'package:flutter/material.dart';


class HeroPage extends StatefulWidget {
  final String url;

  HeroPage({this.url});

  @override
  State<HeroPage> createState() => _HeroPageState();
}

class _HeroPageState extends State<HeroPage> {
  @override
  Widget build(BuildContext context) {
    if(widget.url != null){
      return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: Center(
              child: Container(
                child: Image.network(widget.url),
              )
          )
      );
    } else{
      return Text("loading");
    }
  }
}
