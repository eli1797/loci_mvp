import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/screens/home/settings_form.dart';
import 'package:mvp/screens/profile/first_time_setup.dart';
import 'package:mvp/services/auth.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/shared/loading.dart';
import 'package:provider/provider.dart';


class Home extends StatelessWidget {

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {

    final userData = Provider.of<DocumentSnapshot>(context);
    print(userData);

    if (userData == null || (userData.exists && userData.data['firstName'] == "new_unnamed_member")) {
      return FirstTimeSetup();
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Loci'),
          backgroundColor: Colors.blue,
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
                onPressed: () async {
                  await _authService.signOut();
                },
                icon: Icon(Icons.person),
                label: Text('logout')),
//            FlatButton.icon(
//                onPressed: () => _showSettingsPanel(),
//                icon: Icon(Icons.settings),
//                label: Text('settings'))
          ],
        ),
        body: Text('Hello world'),
      );
    }
  }
}
