import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvp/models/user.dart';
import 'package:mvp/screens/authenticate/authenticate.dart';
import 'package:mvp/screens/profile/settings.dart';
import 'package:mvp/services/auth.dart';
import 'package:mvp/services/database.dart';
import 'package:mvp/shared/constants.dart';
import 'package:mvp/shared/loading.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  // first name text editing
  final _formKey = GlobalKey<FormState>();

  double _sliderVal;
//  Map _sliderLabel = Map();
//  Map _sliderColor = Map();


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    if (user == null) {
      return Authenticate();
    } else {

//      _sliderLabel[0.0] = "Hidden";
//      _sliderLabel[1.0] = "Close Friends Only";
//      _sliderLabel[2.0] = "Open";
//      _sliderColor[0.0] = Colors.grey;
//      _sliderColor[1.0] = Colors.blue[300];
//      _sliderColor[2.0] = Colors.green[500];

      print(user);

      return StreamBuilder<UserData>(
          stream: DatabaseService(uid: user.uid).streamThisUserData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserData userData = snapshot.data;

              _sliderVal = userData.openness ?? 0.0;

              return Scaffold(
                  resizeToAvoidBottomInset: false,
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
                                await DatabaseService(uid: user.uid).updateFirstName(
                                    val);
                              },
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Currently',
                              ),
                              initialValue: userData.status ?? '',
                              onFieldSubmitted: (val) async {
                                await DatabaseService(uid: user.uid).updateStatus(
                                    val);
                              },
                            ),
                            SizedBox(height: 20.0),
                            Text("Openness"),
                            Slider.adaptive(
                                min: 0.0,
                                max: 2,
                                divisions: 2,
                                value: _sliderVal ?? 0.0,
                                label: Constants.sliderLabel[_sliderVal],
                                activeColor: Constants.sliderColor[_sliderVal],
                                inactiveColor: Constants.sliderColor[_sliderVal],
                                onChanged: (val) async {
                                  setState(() {
                                    _sliderVal = val;
                                  });
                                  await DatabaseService(uid: user.uid).updateOpenness(val);
                                })
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
