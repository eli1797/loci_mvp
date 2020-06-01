//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';
//import 'package:mvp/models/brew.dart';
//import 'package:mvp/screens/home/brew_tile.dart';
//import 'package:provider/provider.dart';
//
//class Brew_List extends StatefulWidget {
//  @override
//  _Brew_ListState createState() => _Brew_ListState();
//}
//
//class _Brew_ListState extends State<Brew_List> {
//  @override
//  Widget build(BuildContext context) {
//
//    final brews = Provider.of<List<Brew>>(context);
//
//    brews.forEach((brew) {
//      print(brew.name);
//      print(brew.sugars);
//      print(brew.strength);
//    });
//
//    return ListView.builder(
//      itemCount: brews.length,
//      itemBuilder: (context, index) {
//        return BrewTile(brew: brews[index]);
//      },
//    );
//  }
//}
//
//
