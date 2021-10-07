import 'package:flutter/material.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';

class CustomerCreatePost extends StatefulWidget {
  @override
  _CustomerCreatePostState createState() => _CustomerCreatePostState();
}

class _CustomerCreatePostState extends State<CustomerCreatePost> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create a post', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.red),
        actions: [
          TextButton(
            child: Text('Post'),
            onPressed: (){
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                    autofocus: true,
                    decoration: InputDecoration.collapsed(
                      hintText: "Title here",
                      hintStyle: TextStyle(fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Divider(
                  color: Colors.grey,
                  height: 20,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  maxLines: 30,
                  autofocus: true,
                  decoration: InputDecoration.collapsed(
                    hintText: "Write something to post",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
