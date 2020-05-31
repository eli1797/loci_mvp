import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Brew_List extends StatefulWidget {
  @override
  _Brew_ListState createState() => _Brew_ListState();
}

class _Brew_ListState extends State<Brew_List> {
  @override
  Widget build(BuildContext context) {

    final brews = Provider.of<QuerySnapshot>(context);
//    print(brews.documents);
    for (var doc in brews.documents) {
      print(doc.data);
    }
    
    return Container();
  }
}


