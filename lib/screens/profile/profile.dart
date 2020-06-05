import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/screens/authenticate/authenticate.dart';
import 'package:mvp/screens/profile/settings.dart';
import 'package:mvp/services/auth.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/shared/loading.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  // first name text editing
  final _formKey = GlobalKey<FormState>();
  String _currentFirstName;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user == null) {
      return Authenticate();
    } else {

      print(user);

      return StreamBuilder<UserData>(
          stream: DatabaseService(uid: user.uid).userData,
          builder: (context, snapshot) {
            print("Snapshot: " + snapshot.toString());
            if (snapshot.hasData) {
              UserData userData = snapshot.data;
              return Scaffold(
                  appBar: AppBar(
                    title: Text("Profile"),
                    actions: <Widget>[
                      IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Settings())
                            );
                          })
                    ],
                  ),
                  body: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 50.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 20.0),
                            CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 50.0,
                              child: Text('You'),
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'First name',
                              ),
                              initialValue: userData.firstName,
                              onFieldSubmitted: (val) async {
                                await DatabaseService(uid: user.uid).updateName(
                                    val);
                              },
                            ),
                          ],
                        ),
                      )
                  )
              );
            } else {
              return Loading();
            }
          });
    }
  }
}