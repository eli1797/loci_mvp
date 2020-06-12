import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/screens/authenticate/authenticate.dart';
import 'package:mvp/screens/home/home.dart';
import 'package:mvp/screens/profile/first_time_setup.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/services/local_persistence.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeWrapper extends StatefulWidget {

  @override
  _HomeWrapperState createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {

  final LocalPersistence _localPersistence = LocalPersistence();
  bool _hasOnboarded;

  //Loading counter value on start
  void _loadOnBoarded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool result = (prefs.getBool('onboarded') ?? false);

    if (result == null || result != _hasOnboarded) {
      setState(() {
        _hasOnboarded = result;
      });
    }
  }

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
