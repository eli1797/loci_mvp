import 'package:flutter/material.dart';
import 'package:mvp/screens/home/home.dart';

/*
Wrapper keeps track of authentication state and chooses what to show accordingly
 */
class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //return either home or authenticate widget
    return Home();
  }
}
