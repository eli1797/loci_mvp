import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvp/models/brew.dart';
import 'package:mvp/screens/home/brew_list.dart';
import 'package:mvp/screens/home/settings_form.dart';
import 'package:mvp/services/auth.dart';
import 'package:mvp/services/database.dart';
import 'package:provider/provider.dart';


class Home extends StatelessWidget {

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {

//    void _showSettingsPanel() {
//      showModalBottomSheet(context: context, builder: (context) {
//        return Container(
//          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
//          child: SettingsForm()
//        );
//      });
//    }

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

