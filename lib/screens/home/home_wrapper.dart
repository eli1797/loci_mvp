import 'package:flutter/material.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/screens/authenticate/authenticate.dart';
import 'package:mvp/screens/home/home.dart';
import 'package:mvp/services/database.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeWrapper extends StatefulWidget {

  @override
  _HomeWrapperState createState() => _HomeWrapperState();
}

/// Shows Authenticate or Provides UserData Stream and shows Home()
class _HomeWrapperState extends State<HomeWrapper> {

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null) {
      return Authenticate();
    } else {
      return StreamProvider<UserData> (
        create: (_) => DatabaseService(uid: user.uid).streamThisUserData(),
        child: Home(),
      );
    }
  }
}
