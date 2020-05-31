import 'package:flutter/material.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/screens/authenticate/authenticate.dart';
import 'package:mvp/screens/home/home.dart';
import 'package:provider/provider.dart';

/*
Wrapper listens for auth changes and chooses what to show accordingly
 */
class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    print(user);

    //return either home or authenticate widget based on auth state
    return user == null ? Authenticate() : Home();
  }
}
