import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {


  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController _searchController = TextEditingController();
  String searched = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    print(_searchController.text);
    searched = _searchController.text;
  }
  // Stream<QuerySnapshot> getUsersPast(BuildContext context) async*{
  //     final FirebaseAuth _auth = FirebaseAuth.instance;
  //     User user = _auth.currentUser;
  //     var data = await FirebaseFirestore.instance;
  //     yield* data.collection("Couriers").where(field);
  // }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 25),
      child: SizedBox(
        height: 40,
        width: 250,
        child: TextField(
          onChanged: (text) {
            text = text.toLowerCase();
          },
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search',
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear, size: 20,
                color: Colors.black,
              ),
              onPressed: () => _searchController.clear(),
            ),
            hintStyle: TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
            ),
            contentPadding: EdgeInsets.all(10.0),
            prefixIcon: Icon(Icons.search_rounded),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(
                color: Colors.grey,
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(
                color: Colors.redAccent,
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
