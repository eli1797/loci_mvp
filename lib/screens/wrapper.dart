import 'package:flutter/material.dart';
import 'package:mvp/screens/authenticate/authenticate.dart';
import 'package:mvp/screens/home/home.dart';

/*
Wrapper listens for auth changes and chooses what to show accordingly
 */
class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //return either home or authenticate widget
    return Authenticate();
  }
}
