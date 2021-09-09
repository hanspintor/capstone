import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  String message = '';

  Widget _buildMessage() {
    return Container(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: InputDecoration(
                  filled: true,

                  hintText: 'Type your message',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 0),
                    gapPadding: 10,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onChanged: (value) => setState(() {
                  message = value;
                }),
              ),
            )
          ],
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
        actions: [
          IconButton(icon: Icon(
            Icons.help_outline,
          ),
            onPressed: (){
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: _buildMessage(),
            ),
          ],
        ),
      )
    );
  }
}
