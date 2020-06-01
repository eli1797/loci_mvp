import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/screens/authenticate/authenticate.dart';
import 'package:mvp/screens/home/home_wrapper.dart';
import 'package:mvp/services/database.dart';
import 'package:provider/provider.dart';

/*
Wrapper listens for auth changes and chooses what to show accordingly
 */
class Wrapper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    print(user);

    //@Todo: show the home or the firstTimeSetup screen based on if the user has set a firstName

    if (user == null) {
      return Authenticate();
    } else {
      return StreamProvider<DocumentSnapshot> (
        create: (_) => DatabaseService(uid: user.uid).userDataDoc,
        child: HomeWrapper(),
      );
    }
  }
}
